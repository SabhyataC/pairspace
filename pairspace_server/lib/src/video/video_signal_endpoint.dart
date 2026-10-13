import 'dart:async';
import 'dart:convert';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../generated/protocol.dart';

class VideoSignalEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<String> iceServers(Session session) async {
    final servers = <Map<String, dynamic>>[
      {'urls': 'stun:stun.l.google.com:19302'},
    ];
    final urls = session.passwords['turnUrls'];
    final user = session.passwords['turnUsername'];
    final credential = session.passwords['turnCredential'];
    if (urls != null && urls.isNotEmpty && user != null && credential != null) {
      servers.add({
        'urls': urls
            .split(',')
            .map((u) => u.trim())
            .where((u) => u.isNotEmpty)
            .toList(),
        'username': user,
        'credential': credential,
      });
    }
    return jsonEncode(servers);
  }

  Stream<SignalMessage> signalStream(
    Session session,
    int roomId,
    int myParticipantId,
    Stream<SignalMessage> outgoing,
  ) async* {
    await _requireAdmitted(session, roomId, myParticipantId);
    final channel = 'room-signal-$roomId';

    final incoming = outgoing.listen((msg) async {
      msg.senderParticipantId = myParticipantId;
      await session.messages.postMessage(channel, msg);
    });

    try {
      await for (final msg in session.messages.createStream<SignalMessage>(
        channel,
      )) {
        if (msg.senderParticipantId == myParticipantId) continue;
        final target = msg.targetParticipantId;
        if (target != null && target != myParticipantId) continue;
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
