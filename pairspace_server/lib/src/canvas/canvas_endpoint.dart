import 'dart:async';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../generated/protocol.dart';

class CanvasEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Client sends its strokes in, and receives every stroke drawn in the room.
  static const _kinds = {'pen', 'line', 'arrow', 'rect', 'ellipse', 'text'};

  Stream<Stroke> strokeStream(
    Session session,
    int roomId,
    Stream<Stroke> strokes,
  ) async* {
    await _requireAdmitted(session, roomId);
    final channel = 'room-strokes-$roomId';

    // Handle incoming messages one at a time, so an erase can never overtake
    // the insert of the stroke it refers to.
    var queue = Future<void>.value();
    final incoming = strokes.listen((stroke) {
      queue = queue.then(
        (_) => _handleIncoming(session, roomId, channel, stroke),
      );
    });

    try {
      yield* session.messages.createStream<Stroke>(channel);
    } finally {
      await incoming.cancel();
    }
  }

  Future<void> _handleIncoming(
    Session session,
    int roomId,
    String channel,
    Stroke stroke,
  ) async {
    try {
      if (stroke.isDeleted) {
        await _erase(session, roomId, channel, stroke);
        return;
      }
      if (!_isValid(stroke)) return;

      // A resend after a reconnect must not create a second row.
      if (stroke.clientId.isNotEmpty) {
        final existing = await Stroke.db.findFirstRow(
          session,
          where: (t) =>
              t.roomId.equals(roomId) & t.clientId.equals(stroke.clientId),
        );
        if (existing != null) return;
      }

      stroke.id = null; // never trust a client-sent id
      stroke.roomId = roomId; // never trust the roomId sent by the client
      stroke.isDeleted = false; // strokes are never inserted as deleted
      final saved = await Stroke.db.insertRow(session, stroke);
      await session.messages.postMessage(channel, saved);
    } catch (e, st) {
      session.log(
        'Failed to handle stroke: $e',
        level: LogLevel.error,
        stackTrace: st,
      );
    }
  }

  Future<void> _erase(
    Session session,
    int roomId,
    String channel,
    Stroke msg,
  ) async {
    final Stroke? row;
    if (msg.clientId.isNotEmpty) {
      row = await Stroke.db.findFirstRow(
        session,
        where: (t) => t.roomId.equals(roomId) & t.clientId.equals(msg.clientId),
      );
    } else if (msg.id != null) {
      // Strokes drawn before this feature have no clientId.
      row = await Stroke.db.findFirstRow(
        session,
        where: (t) => t.roomId.equals(roomId) & t.id.equals(msg.id!),
      );
    } else {
      row = null;
    }
    if (row == null || row.isDeleted) return;

    row.isDeleted =
        true; // only the flag; ignore everything else the client sent
    final saved = await Stroke.db.updateRow(session, row);
    await session.messages.postMessage(channel, saved);
  }

  bool _isValid(Stroke s) {
    if (!_kinds.contains(s.kind)) return false;
    if (s.clientId.length > 64) return false;
    final n = s.points.length;
    if (n < 2 || n.isOdd || n > 20000) return false;
    switch (s.kind) {
      case 'pen':
        return true;
      case 'text':
        final t = s.text?.trim() ?? '';
        return n == 2 &&
            t.isNotEmpty &&
            t.length <= 500 &&
            s.width > 0 &&
            s.width <= 120;
      default: // line, arrow, rect, ellipse: start + end point
        return n == 4;
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

  /// All saved strokes of a room, oldest first. Admitted participants only.
  Future<List<Stroke>> getStrokes(Session session, int roomId) async {
    await _requireAdmitted(session, roomId);
    return Stroke.db.find(
      session,
      where: (t) => t.roomId.equals(roomId),
      orderBy: (t) => t.id,
    );
  }
}
