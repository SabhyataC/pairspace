import 'dart:math';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

bool _isHigh(int u) => u >= 0xD800 && u <= 0xDBFF;
bool _isLow(int u) => u >= 0xDC00 && u <= 0xDFFF;

Future<void> recordCodeEdit(
  Session session, {
  required int roomId,
  required String before,
  required String after,
}) async {
  if (before == after) return;

  final limit = min(before.length, after.length);
  var p = 0;
  while (p < limit && before.codeUnitAt(p) == after.codeUnitAt(p)) {
    p++;
  }
  if (p > 0 && _isHigh(after.codeUnitAt(p - 1))) p--; // don't split emoji

  var s = 0;
  final maxSuffix = limit - p;
  while (s < maxSuffix &&
      before.codeUnitAt(before.length - 1 - s) ==
          after.codeUnitAt(after.length - 1 - s)) {
    s++;
  }
  if (s > 0 && _isLow(after.codeUnitAt(after.length - s))) s--;

  await CodeEdit.db.insertRow(
    session,
    CodeEdit(
      roomId: roomId,
      offset: p,
      removed: before.length - p - s,
      inserted: after.substring(p, after.length - s),
      createdAt: DateTime.now().toUtc(),
    ),
  );
}
