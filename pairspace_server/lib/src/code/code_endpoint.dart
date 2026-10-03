import 'dart:async';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../generated/protocol.dart';

class CodeEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  static const _maxChars = 100000;

  /// Client sends its code updates in, and receives every update in the room.
  Stream<CodeUpdate> codeStream(
    Session session,
    int roomId,
    Stream<CodeUpdate> updates,
  ) async* {
    await _requireAdmitted(session, roomId);
    final channel = 'room-code-$roomId';

    // Save to the database at most once per second, plus once when this
    // client disconnects, instead of on every keystroke.
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

    // Incoming: client -> everyone on the channel.
    final incoming = updates.listen((update) async {
      // Basic sanity checks on client-supplied data.
      if (update.text.length > _maxChars || update.senderId.length > 64) {
        return;
      }

      try {
        update.roomId = roomId; // never trust the roomId sent by the client
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

    // Outgoing: channel -> this client.
    try {
      yield* session.messages.createStream<CodeUpdate>(channel);
    } finally {
      await incoming.cancel();
      await flush();
    }
  }

  /// Latest saved code of a room, or null if nothing was typed yet.
  /// Admitted participants only.
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
  }
}
