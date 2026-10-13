import 'package:serverpod/serverpod.dart';

import '../generated/future_calls.dart';
import '../generated/protocol.dart';

const _emptyRoomGrace = Duration(minutes: 3);

Future<void> endRoomInternal(Session session, int roomId) async {
  final room = await Room.db.findById(session, roomId);
  if (room == null || room.endedAt != null) return;

  room.endedAt = DateTime.now().toUtc();
  await Room.db.updateRow(session, room);

  final participants = await Participant.db.find(
    session,
    where: (t) =>
        t.roomId.equals(roomId) & t.status.equals(ParticipantStatus.admitted),
  );
  for (final p in participants) {
    p.status = ParticipantStatus.left;
  }
  if (participants.isNotEmpty) {
    await Participant.db.update(session, participants);
  }

  await session.serverpod.futureCalls.cancel('end-room-$roomId');
}

Future<int> activeInterviewerCount(Session session, int roomId) {
  return Participant.db.count(
    session,
    where: (t) =>
        t.roomId.equals(roomId) &
        t.status.equals(ParticipantStatus.admitted) &
        t.role.equals(ParticipantRole.interviewer),
  );
}

Future<bool> endRoomIfInterviewerGone(Session session, int roomId) async {
  final interviewers = await Participant.db.find(
    session,
    where: (t) =>
        t.roomId.equals(roomId) & t.role.equals(ParticipantRole.interviewer),
  );
  if (interviewers.isEmpty) return false;

  final latest = interviewers
      .map((p) => p.lastSeenAt)
      .reduce((a, b) => a.isAfter(b) ? a : b);
  if (DateTime.now().toUtc().difference(latest) < _emptyRoomGrace) {
    return false;
  }
  await endRoomInternal(session, roomId);
  return true;
}

const _sweepInterval = Duration(minutes: 1);

/// Keeps one "check this room again in a minute" call scheduled.
Future<void> syncEmptyRoomExpiry(Session session, int roomId) async {
  final room = await Room.db.findById(session, roomId);
  if (room == null || room.endedAt != null) return;

  final identifier = 'end-room-$roomId';
  await session.serverpod.futureCalls.cancel(identifier);
  await session.serverpod.futureCalls
      .callWithDelay(_sweepInterval, identifier: identifier)
      .endEmptyRoom
      .end(roomId);
}
