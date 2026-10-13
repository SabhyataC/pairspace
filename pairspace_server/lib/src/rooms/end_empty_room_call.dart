import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'room_lifecycle.dart';

class EndEmptyRoomFutureCall extends FutureCall {
  Future<void> end(Session session, int roomId) async {
    final room = await Room.db.findById(session, roomId);
    if (room == null || room.endedAt != null) return;
    if (await endRoomIfInterviewerGone(session, roomId)) return;
    await syncEmptyRoomExpiry(session, roomId); // look again in a minute
  }
}
