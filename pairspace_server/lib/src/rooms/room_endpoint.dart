import 'dart:convert';
import 'dart:math';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../generated/protocol.dart';
import 'room_lifecycle.dart';

class RoomEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<Room> createRoom(Session session, String displayName) async {
    final userId = session.authenticated!.authUserId;

    final room = await Room.db.insertRow(
      session,
      Room(code: _generateCode(), createdBy: userId),
    );

    await Participant.db.insertRow(
      session,
      Participant(
        roomId: room.id!,
        authUserId: userId,
        role: ParticipantRole.interviewer,
        status: ParticipantStatus.admitted,
        displayName: _sanitizeName(displayName, fallback: 'Interviewer'),
      ),
    );

    await syncEmptyRoomExpiry(session, room.id!);
    return room;
  }

  /// The caller's own active (not-ended) room, if they created one.
  Future<Room?> myActiveRoom(Session session) async {
    final userId = session.authenticated!.authUserId;
    return Room.db.findFirstRow(
      session,
      where: (t) => t.createdBy.equals(userId) & t.endedAt.equals(null),
      orderBy: (t) => t.createdAt.desc(),
    );
  }

  Future<Participant> joinRoom(
    Session session,
    String code,
    String displayName,
  ) async {
    final userId = session.authenticated!.authUserId;

    final room = await Room.db.findFirstRow(
      session,
      where: (t) => t.code.equals(code),
    );
    if (room == null) {
      throw AccessDeniedException(message: 'Room not found');
    }
    if (room.endedAt != null) {
      throw AccessDeniedException(message: 'This room has ended');
    }

    final existing = await Participant.db.findFirstRow(
      session,
      where: (t) => t.roomId.equals(room.id!) & t.authUserId.equals(userId),
    );
    if (existing != null) {
      existing.displayName = _sanitizeName(
        displayName,
        fallback: existing.displayName,
      );
      if (existing.status == ParticipantStatus.left) {
        existing.status = ParticipantStatus.admitted;
      }
      final updated = await Participant.db.updateRow(session, existing);
      await syncEmptyRoomExpiry(session, room.id!);
      return updated;
    }

    final isInterviewer = userId == room.createdBy;

    final inserted = await Participant.db.insertRow(
      session,
      Participant(
        roomId: room.id!,
        authUserId: userId,
        role: isInterviewer
            ? ParticipantRole.interviewer
            : ParticipantRole.candidate,
        status: isInterviewer
            ? ParticipantStatus.admitted
            : ParticipantStatus.pending,
        displayName: _sanitizeName(
          displayName,
          fallback: isInterviewer ? 'Interviewer' : 'Candidate',
        ),
      ),
    );
    if (isInterviewer) await syncEmptyRoomExpiry(session, room.id!);
    return inserted;
  }

  Future<List<Participant>> pendingParticipants(
    Session session,
    int roomId,
  ) async {
    final room = await _requireOwnedRoom(session, roomId);
    return Participant.db.find(
      session,
      where: (t) =>
          t.roomId.equals(room.id!) &
          t.status.equals(ParticipantStatus.pending),
    );
  }

  /// Everyone currently admitted and present in the room — for a
  /// Meet-style "who's here" list. Any admitted participant can call this.
  Future<List<Participant>> admittedParticipants(
    Session session,
    int roomId,
  ) async {
    await _requireAdmitted(session, roomId);
    return Participant.db.find(
      session,
      where: (t) =>
          t.roomId.equals(roomId) & t.status.equals(ParticipantStatus.admitted),
      orderBy: (t) => t.joinedAt,
    );
  }

  Future<Participant> admitParticipant(
    Session session,
    int participantId,
  ) async {
    final participant = await Participant.db.findById(session, participantId);
    if (participant == null) {
      throw AccessDeniedException(message: 'Participant not found');
    }
    await _requireOwnedRoom(session, participant.roomId);

    participant.status = ParticipantStatus.admitted;
    final updated = await Participant.db.updateRow(session, participant);
    await syncEmptyRoomExpiry(session, updated.roomId);
    return updated;
  }

  Future<Participant> denyParticipant(
    Session session,
    int participantId,
  ) async {
    final participant = await Participant.db.findById(session, participantId);
    if (participant == null) {
      throw AccessDeniedException(message: 'Participant not found');
    }
    await _requireOwnedRoom(session, participant.roomId);

    participant.status = ParticipantStatus.denied;
    return Participant.db.updateRow(session, participant);
  }

  Future<Participant> checkStatus(
    Session session,
    int participantId,
  ) async {
    final participant = await Participant.db.findById(session, participantId);
    if (participant == null) {
      throw AccessDeniedException(message: 'Participant not found');
    }
    return participant;
  }

  /// Either side leaving voluntarily. The room keeps existing; an
  /// interviewer leaving does NOT end it — use endRoom for that.
  Future<void> leaveRoom(Session session, int participantId) async {
    final userId = session.authenticated!.authUserId;
    final participant = await Participant.db.findById(session, participantId);
    if (participant == null || participant.authUserId != userId) {
      throw AccessDeniedException(message: 'Not your participant record');
    }
    participant.status = ParticipantStatus.left;
    await Participant.db.updateRow(session, participant);
    await syncEmptyRoomExpiry(session, participant.roomId);
  }

  /// Interviewer-only: ends the room for everyone. Existing room/stroke
  /// data is kept (for Day 7's recap page later); no one can join after.
  Future<void> endRoom(Session session, int roomId) async {
    await _requireOwnedRoom(session, roomId);
    await endRoomInternal(session, roomId);
  }

  /// Lets a client know if the room has ended (for candidates to detect
  /// the interviewer ending the meeting while they're still in it).
  Future<bool> isRoomEnded(Session session, int roomId) async {
    final room = await Room.db.findById(session, roomId);
    return room?.endedAt != null;
  }

  Future<void> _requireAdmitted(Session session, int roomId) async {
    final userId = session.authenticated!.authUserId;
    final participant = await Participant.db.findFirstRow(
      session,
      where: (t) => t.roomId.equals(roomId) & t.authUserId.equals(userId),
    );
    if (participant == null ||
        participant.status != ParticipantStatus.admitted) {
      throw AccessDeniedException(message: 'Not admitted to this room');
    }
  }

  Future<Room> _requireOwnedRoom(Session session, int roomId) async {
    final userId = session.authenticated!.authUserId;
    final room = await Room.db.findById(session, roomId);
    if (room == null || room.createdBy != userId) {
      throw AccessDeniedException(message: 'Interviewer only');
    }
    return room;
  }

  String _generateCode() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '').replaceAll('_', '');
  }

  String _sanitizeName(String raw, {required String fallback}) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return fallback;
    return trimmed.length > 40 ? trimmed.substring(0, 40) : trimmed;
  }
}
