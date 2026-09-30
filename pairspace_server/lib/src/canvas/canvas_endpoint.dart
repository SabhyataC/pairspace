import 'dart:async';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../generated/protocol.dart';

class CanvasEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Client sends its strokes in, and receives every stroke drawn in the room.
  Stream<Stroke> strokeStream(
    Session session,
    int roomId,
    Stream<Stroke> strokes,
  ) async* {
    await _requireAdmitted(session, roomId);
    final channel = 'room-strokes-$roomId';

    // Incoming: client -> everyone on the channel.
    final incoming = strokes.listen((stroke) async {
      // Basic sanity checks on client-supplied data.
      if (stroke.points.length < 2 ||
          stroke.points.length.isOdd ||
          stroke.points.length > 20000) {
        return;
      }

      try {
        stroke.id = null; // never trust a client-sent id
        stroke.roomId = roomId; // never trust the roomId sent by the client
        final saved = await Stroke.db.insertRow(session, stroke);
        await session.messages.postMessage(channel, saved);
      } catch (e, st) {
        session.log(
          'Failed to save stroke: $e',
          level: LogLevel.error,
          stackTrace: st,
        );
      }
    });

    // Outgoing: channel -> this client.
    try {
      yield* session.messages.createStream<Stroke>(channel);
    } finally {
      await incoming.cancel();
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
