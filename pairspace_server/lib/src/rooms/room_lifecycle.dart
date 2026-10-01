import 'package:serverpod/serverpod.dart';

import '../generated/future_calls.dart';
import '../generated/protocol.dart';

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

Future<void> syncEmptyRoomExpiry(Session session, int roomId) async {
  final room = await Room.db.findById(session, roomId);
  if (room == null || room.endedAt != null) return;

  final admittedCount = await Participant.db.count(
    session,
    where: (t) =>
        t.roomId.equals(roomId) & t.status.equals(ParticipantStatus.admitted),
  );

  final identifier = 'end-room-$roomId';
  if (admittedCount == 0) {
    await session.serverpod.futureCalls
        .callWithDelay(const Duration(minutes: 3), identifier: identifier)
        .endEmptyRoom
        .end(roomId);
  } else {
    await session.serverpod.futureCalls.cancel(identifier);
  }
}
