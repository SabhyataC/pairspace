import 'dart:async';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../generated/protocol.dart';

class CodeEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  static const _maxChars = 100000;

  Stream<CodeUpdate> codeStream(
    Session session,
    int roomId,
    Stream<CodeUpdate> updates,
  ) async* {
    await _requireAdmitted(session, roomId);
    final channel = 'room-code-$roomId';

    CodeUpdate? pending;
    Timer? saveTimer;

    Future<void> flush() async {
      saveTimer?.cancel();
      saveTimer = null;
      final u = pending;
      pending = null;
      if (u == null) return;
      await _saveSnapshot(session, roomId, u);
    }

    var lastCheck = DateTime.now();
    var allowed = true;
    var windowStart = DateTime.now();
    var inWindow = 0;

    final incoming = updates.listen((update) async {
      final now = DateTime.now();
      if (now.difference(windowStart) > const Duration(seconds: 1)) {
        windowStart = now;
        inWindow = 0;
      }
      if (++inWindow > 40) return;
      if (now.difference(lastCheck) > const Duration(seconds: 5)) {
        lastCheck = now;
        try {
          await _requireAdmitted(session, roomId);
        } catch (_) {
          allowed = false;
        }
      }
      if (!allowed) return;

      if (update.text.length > _maxChars ||
          update.senderId.length > 64 ||
          update.language.length > 20) {
        return;
      }

      try {
        update.roomId = roomId;
        pending = update;
        saveTimer ??= Timer(const Duration(seconds: 1), flush);
        await session.messages.postMessage(channel, update);
      } catch (e, st) {
        session.log(
          'Failed to broadcast code update: $e',
          level: LogLevel.error,
          stackTrace: st,
        );
      }
    });

    try {
      yield* session.messages.createStream<CodeUpdate>(channel);
    } finally {
      await incoming.cancel();
      await flush();
    }
  }

  Future<CodeSnapshot?> getCode(Session session, int roomId) async {
    await _requireAdmitted(session, roomId);
    return CodeSnapshot.db.findFirstRow(
      session,
      where: (t) => t.roomId.equals(roomId),
    );
  }

  Future<void> _saveSnapshot(
    Session session,
    int roomId,
    CodeUpdate u,
  ) async {
    try {
      final existing = await CodeSnapshot.db.findFirstRow(
        session,
        where: (t) => t.roomId.equals(roomId),
      );
      if (existing == null) {
        await CodeSnapshot.db.insertRow(
          session,
          CodeSnapshot(
            roomId: roomId,
            content: u.text,
            language: u.language,
            updatedAt: DateTime.now(),
          ),
        );
      } else {
        existing.content = u.text;
        existing.language = u.language;
        existing.updatedAt = DateTime.now();
        await CodeSnapshot.db.updateRow(session, existing);
      }
    } catch (e, st) {
      session.log(
        'Failed to save code snapshot: $e',
        level: LogLevel.error,
        stackTrace: st,
      );
    }
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

    final room = await Room.db.findById(session, roomId);
    if (room == null || room.endedAt != null) {
      throw AccessDeniedException(message: 'This room has ended');
    }
  }
}
