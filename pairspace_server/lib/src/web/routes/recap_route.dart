import 'dart:convert';
import 'dart:math';

import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';

class RecapPageWidget extends TemplateWidget {
  RecapPageWidget(Map<String, dynamic> values)
    : super(name: 'recap', values: values);
}

class RecapRoute extends WidgetRoute {
  static bool _safeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }

  @override
  Future<WebWidget?> build(Session session, Request request) async {
    final code = request.pathParameters.raw[#code];
    if (code == null || code.isEmpty) return null;

    final room = await Room.db.findFirstRow(
      session,
      where: (t) => t.code.equals(code),
    );
    if (room == null) return null;
    final key = request.url.queryParameters['k'] ?? '';
    final token = room.recapToken ?? '';
    if (token.isEmpty || !_safeEquals(key, token)) return null;

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
      where: (t) => t.roomId.equals(room.id!) & t.isDeleted.equals(false),
      orderBy: (t) => t.id,
    );
    final edits = await CodeEdit.db.find(
      session,
      where: (t) => t.roomId.equals(room.id!),
      orderBy: (t) => t.createdAt,
    );
    final events = await IntegrityEvent.db.find(
      session,
      where: (t) => t.roomId.equals(room.id!),
      orderBy: (t) => t.id,
    );

    final text = snapshot?.content ?? '';
    final origin = room.startedAt ?? room.createdAt;
    final outcome = _outcome(room, endedAt);

    return RecapPageWidget({
      'available': true,
      'started': _fmt(room.createdAt),
      'startedIso': room.createdAt.toUtc().toIso8601String(),
      'ended': _fmt(endedAt),
      'endedIso': endedAt.toUtc().toIso8601String(),
      'duration': room.startedAt == null
          ? 'Unknown'
          : '${endedAt.difference(room.startedAt!).inMinutes} min',
      'outcomeLabel': outcome.$1,
      'outcomeTone': outcome.$2,
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
      'hasReplay': strokes.length >= 2,
      'replayJson': _replayJson(strokes),
      'hasCodeReplay': edits.length >= 2,
      'codeReplayJson': _codeReplayJson(edits),
      ..._integritySummary(events, origin),
    });
  }

  static String _fmt(DateTime d) {
    final u = d.toUtc();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${u.year}-${two(u.month)}-${two(u.day)} '
        '${two(u.hour)}:${two(u.minute)} UTC';
  }

  static (String, String) _outcome(Room room, DateTime endedAt) {
    final started = room.startedAt;
    if (started == null) {
      return ('Ended before the candidate joined', 'warn');
    }
    if (endedAt.difference(started).inMinutes > room.durationMinutes) {
      return ('Interview completed (ran past the scheduled time)', 'ok');
    }
    return ('Interview completed', 'ok');
  }

  static String _offset(DateTime t, DateTime origin) {
    final s = t.difference(origin).inSeconds;
    final sign = s < 0 ? '-' : '+';
    final a = s.abs();
    String two(int n) => n.toString().padLeft(2, '0');
    return '$sign${two(a ~/ 60)}:${two(a % 60)}';
  }

  static String _eventLabel(IntegrityEvent e) {
    switch (e.type) {
      case 'tab_hidden':
        return 'Switched to another tab';
      case 'tab_visible':
        return 'Returned to the tab';
      case 'window_blur':
        return 'Window lost focus';
      case 'window_focus':
        return 'Window regained focus';
      case 'paste':
        return 'Pasted ${e.detail ?? '?'} characters';
      default:
        return e.type;
    }
  }

  static Map<String, dynamic> _integritySummary(
    List<IntegrityEvent> events,
    DateTime origin,
  ) {
    final hidden = events.where((e) => e.type == 'tab_hidden').toList();
    final extraBlurs = events
        .where((e) => e.type == 'window_blur')
        .where(
          (b) => !hidden.any(
            (h) =>
                h.createdAt.difference(b.createdAt).abs() <
                const Duration(seconds: 1),
          ),
        )
        .length;
    final pastes = events.where((e) => e.type == 'paste').toList();
    var pastedChars = 0;
    for (final p in pastes) {
      pastedChars += int.tryParse(p.detail ?? '') ?? 0;
    }
    const cap = 60;
    return {
      'hasIntegrity': events.isNotEmpty,
      'leftPage': hidden.length + extraBlurs,
      'pastes': pastes.length,
      'pastedChars': pastedChars,
      'integrityEvents': [
        for (final e in events.take(cap))
          {'time': _offset(e.createdAt, origin), 'label': _eventLabel(e)},
      ],
      'hasMoreEvents': events.length > cap,
      'moreEvents': events.length - cap,
    };
  }

  static String _n(num v) => v.isFinite ? v.toStringAsFixed(1) : '0';

  static String _strokeInner(Stroke s) {
    final full = _strokesToSvg([s]);
    final start = full.indexOf('>') + 1;
    return full.substring(start, full.length - '</svg>'.length);
  }

  static String _replayJson(List<Stroke> strokes) {
    if (strokes.isEmpty) return '[]';
    final t0 = strokes.first.createdAt;
    final times = [
      for (final s in strokes)
        if (_strokeInner(s).isNotEmpty)
          s.createdAt.difference(t0).inMilliseconds,
    ];
    return jsonEncode(times);
  }

  static String _strokesToSvg(List<Stroke> strokes) {
    final b = StringBuffer(
      '<svg viewBox="0 0 1000 625" xmlns="http://www.w3.org/2000/svg" '
      'style="width:100%;height:auto;background:#fff;border:1px solid #ccc">',
    );
    for (final s in strokes) {
      if (s.isDeleted) continue;
      final p = s.points;
      if (p.length < 2 || p.length.isOdd) continue;
      final color =
          '#${(s.color & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
      final w = s.width.clamp(0.5, 50.0);
      final style =
          'fill="none" stroke="$color" stroke-width="${_n(w)}" '
          'stroke-linecap="round" stroke-linejoin="round"';

      switch (s.kind) {
        case 'text':
          const esc = HtmlEscape();
          final size = s.width >= 8 ? s.width.clamp(8.0, 120.0) : 24.0;
          final lines = (s.text ?? '').split('\n');
          b.write(
            '<text x="${_n(p[0])}" y="${_n(p[1])}" font-size="${_n(size)}" '
            'font-family="sans-serif" dominant-baseline="hanging" '
            'fill="$color">',
          );
          for (var i = 0; i < lines.length; i++) {
            b.write(
              '<tspan x="${_n(p[0])}" dy="${i == 0 ? 0 : _n(size * 1.2)}">'
              '${esc.convert(lines[i])}</tspan>',
            );
          }
          b.write('</text>');
        case 'line':
          if (p.length < 4) continue;
          b.write(
            '<line x1="${_n(p[0])}" y1="${_n(p[1])}" x2="${_n(p[2])}" '
            'y2="${_n(p[3])}" $style/>',
          );
        case 'arrow':
          if (p.length < 4) continue;
          final angle = atan2(p[3] - p[1], p[2] - p[0]);
          final head = max(14.0, w * 5);
          final d = StringBuffer(
            'M${_n(p[0])},${_n(p[1])} L${_n(p[2])},${_n(p[3])}',
          );
          for (final side in [-0.5, 0.5]) {
            d.write(
              ' M${_n(p[2])},${_n(p[3])} L'
              '${_n(p[2] - cos(angle + side) * head)},'
              '${_n(p[3] - sin(angle + side) * head)}',
            );
          }
          b.write('<path d="$d" $style/>');
        case 'rect':
          if (p.length < 4) continue;
          b.write(
            '<rect x="${_n(min(p[0], p[2]))}" y="${_n(min(p[1], p[3]))}" '
            'width="${_n((p[2] - p[0]).abs())}" '
            'height="${_n((p[3] - p[1]).abs())}" $style/>',
          );
        case 'ellipse':
          if (p.length < 4) continue;
          b.write(
            '<ellipse cx="${_n((p[0] + p[2]) / 2)}" cy="${_n((p[1] + p[3]) / 2)}" '
            'rx="${_n((p[2] - p[0]).abs() / 2)}" '
            'ry="${_n((p[3] - p[1]).abs() / 2)}" $style/>',
          );
        default:
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
          b.write('<polyline points="$pts" $style/>');
      }
    }
    b.write('</svg>');
    return b.toString();
  }

  static String _codeReplayJson(List<CodeEdit> edits) {
    if (edits.isEmpty) return '[]';
    final t0 = edits.first.createdAt;
    final items = [
      for (final e in edits)
        {
          't': e.createdAt.difference(t0).inMilliseconds,
          'o': e.offset,
          'r': e.removed,
          'i': e.inserted,
        },
    ];
    return jsonEncode(items).replaceAll('<', r'\u003c');
  }
}
