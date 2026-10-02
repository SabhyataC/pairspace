import 'dart:async';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../generated/protocol.dart';

class VideoSignalEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Relays WebRTC signaling messages (offers/answers/ICE candidates)
  /// between the two participants in a room. Nothing is persisted.
  Stream<SignalMessage> signalStream(
    Session session,
    int roomId,
    int myParticipantId,
    Stream<SignalMessage> outgoing,
  ) async* {
    await _requireAdmitted(session, roomId, myParticipantId);
    final channel = 'room-signal-$roomId';

    final incoming = outgoing.listen((msg) async {
      msg.senderParticipantId =
          myParticipantId; // never trust client-claimed sender
      await session.messages.postMessage(channel, msg);
    });

    try {
      await for (final msg in session.messages.createStream<SignalMessage>(
        channel,
      )) {
        if (msg.senderParticipantId == myParticipantId) continue;
        yield msg;
      }
    } finally {
      await incoming.cancel();
    }
  }

  Future<void> _requireAdmitted(
    Session session,
    int roomId,
    int participantId,
  ) async {
    final userId = session.authenticated!.authUserId;
    final participant = await Participant.db.findById(session, participantId);
    if (participant == null ||
        participant.roomId != roomId ||
        participant.authUserId != userId ||
        participant.status != ParticipantStatus.admitted) {
      throw AccessDeniedException(message: 'Not admitted to this room');
    }
  }
}
