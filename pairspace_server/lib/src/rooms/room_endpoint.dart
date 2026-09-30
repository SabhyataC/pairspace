import 'dart:convert';
import 'dart:math';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../generated/protocol.dart';

class RoomEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<Room> createRoom(Session session) async {
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
        displayName: 'Interviewer',
      ),
    );

    return room;
  }

  Future<Participant> joinRoom(Session session, String code) async {
    final userId = session.authenticated!.authUserId;

    final room = await Room.db.findFirstRow(
      session,
      where: (t) => t.code.equals(code),
    );
    if (room == null) {
      throw AccessDeniedException(message: 'Room not found');
    }

    final existing = await Participant.db.findFirstRow(
      session,
      where: (t) => t.roomId.equals(room.id!) & t.authUserId.equals(userId),
    );
    if (existing != null) return existing;

    final isInterviewer = userId == room.createdBy;

    return Participant.db.insertRow(
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
        displayName: isInterviewer ? 'Interviewer' : 'Candidate',
      ),
    );
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
    return Participant.db.updateRow(session, participant);
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
}
