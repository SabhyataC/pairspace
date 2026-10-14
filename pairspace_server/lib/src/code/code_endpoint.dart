import 'dart:async';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'code_edit_recorder.dart';

import '../generated/protocol.dart';

class CodeEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  static const _maxChars = 100000;

  /// Latest unsaved update per room and language, shared by every stream in
  /// the room, so the most recent code of each language gets saved.
  static final Map<int, Map<String, CodeUpdate>> _pendingByRoom = {};

  /// Saves per room run one after another, so an older save can't finish
  /// after a newer one.
  static final Map<int, Future<void>> _saveChain = {};

  Stream<CodeUpdate> codeStream(
    Session session,
    int roomId,
    Stream<CodeUpdate> updates,
  ) async* {
    await _requireAdmitted(session, roomId);
    final channel = 'room-code-$roomId';

    Timer? saveTimer;

    Future<void> flush() async {
      saveTimer?.cancel();
      saveTimer = null;
      // Take the room's latest update. If another stream's timer already took
      // it, this is null and there is nothing to do (no double insert).
      final pending = _pendingByRoom.remove(roomId);
      if (pending == null || pending.isEmpty) return;
      final prev = _saveChain[roomId] ?? Future<void>.value();
      final next = prev.then((_) async {
        for (final u in pending.values) {
          await _saveSnapshot(session, roomId, u);
        }
      });
      _saveChain[roomId] = next;
      await next;
      if (identical(_saveChain[roomId], next)) await _saveChain.remove(roomId);
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
        (_pendingByRoom[roomId] ??= {})[update.language] = update;
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
    final rows = await CodeSnapshot.db.find(
      session,
      where: (t) => t.roomId.equals(roomId),
    );
    if (rows.isEmpty) return null;
    rows.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return rows.first;
  }

  Future<void> _saveSnapshot(
    Session session,
    int roomId,
    CodeUpdate u,
  ) async {
    try {
      Future<CodeSnapshot?> find() => CodeSnapshot.db.findFirstRow(
        session,
        where: (t) => t.roomId.equals(roomId) & t.language.equals(u.language),
      );

      var row = await find();
      var before = row?.content ?? '';

      if (row == null) {
        try {
          await CodeSnapshot.db.insertRow(
            session,
            CodeSnapshot(
              roomId: roomId,
              content: u.text,
              language: u.language,
              updatedAt: DateTime.now(),
            ),
          );
        } catch (_) {
          // Unique index on (roomId, language): someone inserted first.
          row = await find();
          if (row == null) rethrow;
          before = row.content;
        }
      }

      if (row != null) {
        row.content = u.text;
        row.updatedAt = DateTime.now();
        await CodeSnapshot.db.updateRow(session, row);
      }

      await recordCodeEdit(
        session,
        roomId: roomId,
        language: u.language,
        before: before,
        after: u.text,
      );
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
