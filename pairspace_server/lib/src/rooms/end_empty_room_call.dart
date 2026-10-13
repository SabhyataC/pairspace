import 'package:serverpod/serverpod.dart';

import 'room_lifecycle.dart';

class EndEmptyRoomFutureCall extends FutureCall {
  Future<void> end(Session session, int roomId) async {
    if (await activeInterviewerCount(session, roomId) > 0) return;
    await endRoomInternal(session, roomId);
  }
}
