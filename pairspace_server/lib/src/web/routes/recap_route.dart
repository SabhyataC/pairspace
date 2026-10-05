import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';

class RecapPageWidget extends TemplateWidget {
  RecapPageWidget(Map<String, dynamic> values)
    : super(name: 'recap', values: values);
}

// Read-only recap of a finished room: GET /recap/{room code}
class RecapRoute extends WidgetRoute {
  @override
  Future<WebWidget?> build(Session session, Request request) async {
    final code = request.pathParameters.raw[#code];
    if (code == null || code.isEmpty) return null;

    final room = await Room.db.findFirstRow(
      session,
      where: (t) => t.code.equals(code),
    );
    if (room == null) return null; // 404

    final endedAt = room.endedAt;
    if (endedAt == null) {
      return RecapPageWidget({'available': false});
    }

    final people = await Participant.db.find(
      session,
      where: (t) =>
          t.roomId.equals(room.id!) &
          (t.status.equals(ParticipantStatus.admitted) |
              t.status.equals(ParticipantStatus.left)),
      orderBy: (t) => t.joinedAt,
    );

    final snapshot = await CodeSnapshot.db.findFirstRow(
      session,
      where: (t) => t.roomId.equals(room.id!),
    );

    final strokes = await Stroke.db.find(
      session,
      where: (t) => t.roomId.equals(room.id!),
      orderBy: (t) => t.id,
    );

    final text = snapshot?.content ?? '';

    return RecapPageWidget({
      'available': true,
      'started': _fmt(room.createdAt),
      'ended': _fmt(endedAt),
      'duration': '${endedAt.difference(room.createdAt).inMinutes} min',
      'participants': [
        for (final p in people)
          {
            'name': p.displayName,
            'role': p.role == ParticipantRole.interviewer
                ? 'Interviewer'
                : 'Candidate',
          },
      ],
      'hasCode': text.trim().isNotEmpty,
      'code': text,
      'language': snapshot?.language ?? '',
      'hasDrawing': strokes.isNotEmpty,
      'svg': _strokesToSvg(strokes),
    });
  }

  static String _fmt(DateTime d) {
    final u = d.toUtc();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${u.year}-${two(u.month)}-${two(u.day)} '
        '${two(u.hour)}:${two(u.minute)} UTC';
  }

  static String _n(num v) => v.isFinite ? v.toStringAsFixed(1) : '0';

  /// Canvas is a fixed 1000x625 space (see kCanvasWidth/Height in Flutter).
  static String _strokesToSvg(List<Stroke> strokes) {
    final b = StringBuffer(
      '<svg viewBox="0 0 1000 625" xmlns="http://www.w3.org/2000/svg" '
      'style="width:100%;height:auto;background:#fff;border:1px solid #ccc">',
    );
    for (final s in strokes) {
      final p = s.points;
      if (p.length < 2 || p.length.isOdd) continue;
      final color =
          '#${(s.color & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
      final w = s.width.clamp(0.5, 50.0);
      if (p.length == 2) {
        b.write(
          '<circle cx="${_n(p[0])}" cy="${_n(p[1])}" r="${_n(w / 2)}" '
          'fill="$color"/>',
        );
        continue;
      }
      final pts = StringBuffer();
      for (var i = 0; i + 1 < p.length; i += 2) {
        if (i > 0) pts.write(' ');
        pts.write('${_n(p[i])},${_n(p[i + 1])}');
      }
      b.write(
        '<polyline points="$pts" fill="none" stroke="$color" '
        'stroke-width="${_n(w)}" stroke-linecap="round" '
        'stroke-linejoin="round"/>',
      );
    }
    b.write('</svg>');
    return b.toString();
  }
}
