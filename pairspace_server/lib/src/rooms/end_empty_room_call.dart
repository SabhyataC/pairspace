import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'room_lifecycle.dart';

class EndEmptyRoomFutureCall extends FutureCall {
  Future<void> end(Session session, int roomId) async {
    final admittedCount = await Participant.db.count(
      session,
      where: (t) =>
          t.roomId.equals(roomId) & t.status.equals(ParticipantStatus.admitted),
    );
    if (admittedCount > 0) return;

    await endRoomInternal(session, roomId);
  }
}
