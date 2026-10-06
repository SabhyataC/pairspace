import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../generated/protocol.dart';

class IntegrityEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  static const _allowedTypes = {
    'tab_hidden',
    'tab_visible',
    'window_blur',
    'window_focus',
    'paste',
  };

  /// Any admitted participant can report their own focus/paste events.
  /// The participant id is derived server-side, never taken from the client.
  Future<void> report(
    Session session,
    int roomId,
    String type,
    String? detail,
  ) async {
    final participant = await _requireAdmitted(session, roomId);
    if (!_allowedTypes.contains(type)) return;

    final room = await Room.db.findById(session, roomId);
    if (room == null || room.endedAt != null) return;

    // Only the candidate is monitored; interviewer events are not recorded.
    if (participant.role != ParticipantRole.candidate) return;

    await IntegrityEvent.db.insertRow(
      session,
      IntegrityEvent(
        roomId: roomId,
        participantId: participant.id!,
        type: type,
        detail: detail != null && detail.length > 20
            ? detail.substring(0, 20)
            : detail,
      ),
    );
  }

  /// Interviewer-only. Checked server-side against the participant role.
  Future<List<IntegrityEvent>> getEvents(Session session, int roomId) async {
    final participant = await _requireAdmitted(session, roomId);
    if (participant.role != ParticipantRole.interviewer) {
      throw AccessDeniedException(message: 'Interviewer only');
    }
    return IntegrityEvent.db.find(
      session,
      where: (t) => t.roomId.equals(roomId),
      orderBy: (t) => t.id,
    );
  }

  Future<Participant> _requireAdmitted(Session session, int roomId) async {
    final userId = session.authenticated!.authUserId;
    final participant = await Participant.db.findFirstRow(
      session,
      where: (t) => t.roomId.equals(roomId) & t.authUserId.equals(userId),
    );
    if (participant == null ||
        participant.status != ParticipantStatus.admitted) {
      throw AccessDeniedException(message: 'Not admitted to this room');
    }
    return participant;
  }
}
