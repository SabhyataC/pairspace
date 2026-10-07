import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pairspace_client/pairspace_client.dart';
import 'package:flutter/services.dart'; // for LogicalKeyboardKey

/// Every stroke lives in a fixed "virtual" canvas of this size, so two people
/// with different window sizes still see the same drawing.
const double kCanvasWidth = 1000;
const double kCanvasHeight = 625;

/// Text size in virtual canvas units.
const double kTextSize = 24;

enum CanvasTool { pen, eraser, line, arrow, rect, ellipse, text }

/// Holds the strokes of the room, including erased ones (kept so that a late
/// copy of the same stroke can't bring it back).
class CanvasController extends ChangeNotifier {
  final List<Stroke> strokes = [];

  static bool _same(Stroke a, Stroke b) =>
      (a.clientId.isNotEmpty && a.clientId == b.clientId) ||
      (a.id != null && a.id == b.id);

  /// Adds a stroke, or merges it into the copy we already have: the same
  /// stroke arrives from our own drawing, the live stream and the saved list.
  void add(Stroke stroke) {
    final i = strokes.indexWhere((s) => _same(s, stroke));
    if (i == -1) {
      strokes.add(stroke);
      notifyListeners();
      return;
    }
    final old = strokes[i];
    old.id ??= stroke.id; // adopt the server id of our local copy
    if (stroke.isDeleted && !old.isDeleted) {
      old.isDeleted = true;
      notifyListeners();
    }
  }

  /// Marks a stroke as erased locally (the caller also sends it to the server).
  void erase(Stroke stroke) {
    if (stroke.isDeleted) return;
    stroke.isDeleted = true;
    notifyListeners();
  }

  /// Replace the canvas with the server's saved strokes (on connect/reconnect).
  void replaceAll(List<Stroke> loaded) {
    final ids = loaded.map((s) => s.id).toSet();
    // Strokes that arrived live while the list was loading.
    final live = strokes
        .where((s) => s.id != null && !ids.contains(s.id))
        .toList();
    strokes
      ..clear()
      ..addAll(loaded)
      ..addAll(live);
    notifyListeners();
  }
}

class CanvasBoard extends StatefulWidget {
  const CanvasBoard({
    super.key,
    required this.roomId,
    required this.controller,
    this.onStrokeComplete,
  });

  final int roomId;
  final CanvasController controller;

  /// Called when a new stroke/shape/text is finished, and also with a
  /// `isDeleted: true` copy when something is erased.
  final void Function(Stroke stroke)? onStrokeComplete;

  @override
  State<CanvasBoard> createState() => _CanvasBoardState();
}

class _CanvasBoardState extends State<CanvasBoard> {
  static const _color = Colors.black;
  static const _width = 3.0;
  static const _eraserRadius = 12.0;
  static final _rng = Random.secure();

  CanvasTool _tool = CanvasTool.pen;

  /// The stroke/shape being drawn right now (not sent until the pointer lifts).
  Stroke? _preview;

  /// Where the on-canvas text box is open (canvas units), or null.
  Offset? _textAt;
  final _textController = TextEditingController();
  final _textFocus = FocusNode();
  static const _textSizes = [
    12.0,
    16.0,
    20.0,
    24.0,
    32.0,
    40.0,
    48.0,
    64.0,
    80.0,
  ];
  int _textSizeIdx = 3; // 24
  double get _textSize => _textSizes[_textSizeIdx];

  void _stepTextSize(int delta) {
    final i = (_textSizeIdx + delta).clamp(0, _textSizes.length - 1).toInt();
    if (i == _textSizeIdx) return;
    setState(() => _textSizeIdx = i);
    // Keep typing in the open text box.
    if (_textAt != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _textFocus.requestFocus();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Clicking anywhere outside the box (code editor, buttons...) places the text.
    _textFocus.addListener(() {
      if (!_textFocus.hasFocus && _textAt != null && mounted) _commitText();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFocus.dispose();
    super.dispose();
  }

  Offset _toCanvas(Offset local, Size size) => Offset(
    (local.dx / size.width * kCanvasWidth).clamp(0, kCanvasWidth),
    (local.dy / size.height * kCanvasHeight).clamp(0, kCanvasHeight),
  );

  String _newId() =>
      '${DateTime.now().microsecondsSinceEpoch}-${_rng.nextInt(0xFFFFFFFF)}';

  Stroke _newStroke(
    String kind,
    List<double> points, {
    String? text,
    double? width,
  }) => Stroke(
    roomId: widget.roomId,
    points: points,
    color: _color.toARGB32(),
    width: width ?? _width,
    kind: kind,
    text: text,
    clientId: _newId(),
  );

  void _down(Offset p) {
    _commitText(); // a click anywhere else places any open text box
    switch (_tool) {
      case CanvasTool.eraser:
        _eraseAt(p);
      case CanvasTool.text:
        _startText(p);
      case CanvasTool.pen:
        setState(() => _preview = _newStroke('pen', [p.dx, p.dy]));
      default: // line, arrow, rect, ellipse: start point, end point
        setState(
          () => _preview = _newStroke(_tool.name, [p.dx, p.dy, p.dx, p.dy]),
        );
    }
  }

  void _move(Offset p) {
    if (_tool == CanvasTool.eraser) {
      _eraseAt(p);
      return;
    }
    final s = _preview;
    if (s == null) return;
    setState(() {
      if (_tool == CanvasTool.pen) {
        s.points.addAll([p.dx, p.dy]);
      } else {
        s.points[2] = p.dx;
        s.points[3] = p.dy;
      }
    });
  }

  void _up() {
    final s = _preview;
    if (s == null) return;
    setState(() => _preview = null);

    // A shape needs a real drag; a plain click draws nothing (pen still dots).
    if (s.kind != 'pen') {
      final dx = s.points[2] - s.points[0];
      final dy = s.points[3] - s.points[1];
      if (sqrt(dx * dx + dy * dy) < 4) return;
    }
    widget.controller.add(s);
    widget.onStrokeComplete?.call(s);
  }

  void _startText(Offset p) {
    setState(() => _textAt = p);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _textFocus.requestFocus();
    });
  }

  void _commitText() {
    final at = _textAt;
    if (at == null) return;
    final t = _textController.text.trim();
    setState(() => _textAt = null);
    _textController.clear();
    if (t.isEmpty) return;

    final s = _newStroke(
      'text',
      [at.dx, at.dy],
      text: t.length > 500 ? t.substring(0, 500) : t,
      width: _textSize,
    );
    widget.controller.add(s);
    widget.onStrokeComplete?.call(s);
  }

  void _cancelText() {
    if (_textAt == null) return;
    setState(() => _textAt = null);
    _textController.clear();
  }

  Widget _buildTextBox(double scale) {
    final at = _textAt!;
    return Positioned(
      left: at.dx * scale,
      top: at.dy * scale,
      // Same wrap width the painter uses once the text is placed.
      width: max(40.0, kCanvasWidth - at.dx) * scale,
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): _cancelText,
          const SingleActivator(LogicalKeyboardKey.enter, control: true):
              _commitText,
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueGrey),
          ),
          child: TextField(
            key: ValueKey(at),
            controller: _textController,
            focusNode: _textFocus,
            minLines: 1,
            maxLines: null,
            cursorColor: _color,
            style: _textStyle(_color, _textSize * scale),
            decoration: const InputDecoration.collapsed(hintText: null),
          ),
        ),
      ),
    );
  }

  void _eraseAt(Offset p) {
    for (final s in List<Stroke>.of(widget.controller.strokes)) {
      if (s.isDeleted || !_hits(s, p)) continue;
      widget.controller.erase(s);
      // Send a light copy: the server only needs the id and the flag.
      widget.onStrokeComplete?.call(s.copyWith(points: [], isDeleted: true));
    }
  }

  bool _hits(Stroke s, Offset p) {
    final q = s.points;
    if (q.length < 2) return false;
    final tol = _eraserRadius + s.width / 2;

    switch (s.kind) {
      case 'text':
        return (Offset(q[0], q[1]) & _layoutText(s).size)
            .inflate(_eraserRadius)
            .contains(p);
      case 'line':
      case 'arrow':
        if (q.length < 4) return false;
        return _distToSegment(p, Offset(q[0], q[1]), Offset(q[2], q[3])) <= tol;
      case 'rect':
        if (q.length < 4) return false;
        final r = Rect.fromPoints(Offset(q[0], q[1]), Offset(q[2], q[3]));
        final edges = [
          (r.topLeft, r.topRight),
          (r.topRight, r.bottomRight),
          (r.bottomRight, r.bottomLeft),
          (r.bottomLeft, r.topLeft),
        ];
        return edges.any((e) => _distToSegment(p, e.$1, e.$2) <= tol);
      case 'ellipse':
        if (q.length < 4) return false;
        final r = Rect.fromPoints(Offset(q[0], q[1]), Offset(q[2], q[3]));
        final a = r.width / 2, b = r.height / 2;
        if (a < 0.5 || b < 0.5) return false;
        final nx = (p.dx - r.center.dx) / a;
        final ny = (p.dy - r.center.dy) / b;
        // How far from the outline, roughly, in canvas units.
        return ((sqrt(nx * nx + ny * ny) - 1).abs() * min(a, b)) <= tol;
      default: // pen
        if (q.length == 2) return (Offset(q[0], q[1]) - p).distance <= tol;
        for (var i = 0; i + 3 < q.length; i += 2) {
          final d = _distToSegment(
            p,
            Offset(q[i], q[i + 1]),
            Offset(q[i + 2], q[i + 3]),
          );
          if (d <= tol) return true;
        }
        return false;
    }
  }

  MouseCursor get _cursor => switch (_tool) {
    CanvasTool.text => SystemMouseCursors.text,
    CanvasTool.eraser => SystemMouseCursors.click,
    _ => SystemMouseCursors.precise,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: _Toolbar(
            tool: _tool,
            onChanged: (t) {
              _commitText();
              setState(() => _tool = t);
            },
            textSize: _textSize,
            onSmaller: _textSizeIdx > 0 ? () => _stepTextSize(-1) : null,
            onBigger: _textSizeIdx < _textSizes.length - 1
                ? () => _stepTextSize(1)
                : null,
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: kCanvasWidth / kCanvasHeight,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = constraints.biggest;
                  final scale = size.width / kCanvasWidth;
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      MouseRegion(
                        cursor: _cursor,
                        child: Listener(
                          onPointerDown: (e) =>
                              _down(_toCanvas(e.localPosition, size)),
                          onPointerMove: (e) =>
                              _move(_toCanvas(e.localPosition, size)),
                          onPointerUp: (_) => _up(),
                          onPointerCancel: (_) => _up(),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.black26),
                            ),
                            child: ClipRect(
                              child: ListenableBuilder(
                                listenable: widget.controller,
                                builder: (context, _) => CustomPaint(
                                  size: Size.infinite,
                                  painter: _BoardPainter(
                                    strokes: widget.controller.strokes,
                                    preview: _preview,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (_textAt != null) _buildTextBox(scale),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.tool,
    required this.onChanged,
    required this.textSize,
    required this.onSmaller,
    required this.onBigger,
  });

  final CanvasTool tool;
  final ValueChanged<CanvasTool> onChanged;
  final double textSize;
  final VoidCallback? onSmaller;
  final VoidCallback? onBigger;

  static const _items = <(CanvasTool, IconData, String)>[
    (CanvasTool.pen, Icons.edit, 'Pen'),
    (CanvasTool.eraser, Icons.cleaning_services, 'Eraser'),
    (CanvasTool.line, Icons.horizontal_rule, 'Line'),
    (CanvasTool.arrow, Icons.north_east, 'Arrow'),
    (CanvasTool.rect, Icons.crop_square, 'Rectangle'),
    (CanvasTool.ellipse, Icons.circle_outlined, 'Ellipse'),
    (CanvasTool.text, Icons.text_fields, 'Text'),
  ];

  @override
  Widget build(BuildContext context) {
    final highlight = Theme.of(context).colorScheme.primaryContainer;
    return Wrap(
      spacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final (t, icon, label) in _items)
          IconButton(
            tooltip: label,
            icon: Icon(icon),
            onPressed: () => onChanged(t),
            style: IconButton.styleFrom(
              backgroundColor: t == tool ? highlight : null,
            ),
          ),
        if (tool == CanvasTool.text)
          // TextFieldTapRegion + ExcludeFocus: pressing these buttons must not
          // count as "clicking outside" the text box, or it would be placed.
          TextFieldTapRegion(
            child: ExcludeFocus(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Smaller text',
                    icon: const Icon(Icons.text_decrease),
                    onPressed: onSmaller,
                  ),
                  SizedBox(
                    width: 32,
                    child: Text(
                      '${textSize.round()}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Bigger text',
                    icon: const Icon(Icons.text_increase),
                    onPressed: onBigger,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Geometry + painting
// ---------------------------------------------------------------------------

double _distToSegment(Offset p, Offset a, Offset b) {
  final ab = b - a;
  final len2 = ab.dx * ab.dx + ab.dy * ab.dy;
  if (len2 == 0) return (p - a).distance;
  final ap = p - a;
  final t = ((ap.dx * ab.dx + ap.dy * ab.dy) / len2).clamp(0.0, 1.0);
  return (p - (a + ab * t)).distance;
}

TextStyle _textStyle(Color color, double size) =>
    TextStyle(inherit: false, color: color, fontSize: size);

/// Text strokes keep their font size in `width`. Older text (width 3) was
/// always 24.
double _fontSize(Stroke s) => s.width >= 8 ? s.width.clamp(8, 120) : kTextSize;

/// Laying out text is slow, so keep one TextPainter per text stroke.
final _textCache = Expando<TextPainter>();

TextPainter _layoutText(Stroke s) {
  return _textCache[s] ??= TextPainter(
    text: TextSpan(
      text: s.text ?? '',
      style: _textStyle(Color(s.color), _fontSize(s)),
    ),
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: max(20.0, kCanvasWidth - s.points[0]));
}

class _BoardPainter extends CustomPainter {
  _BoardPainter({required this.strokes, required this.preview});

  final List<Stroke> strokes;
  final Stroke? preview;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / kCanvasWidth, size.height / kCanvasHeight);

    for (final s in strokes) {
      if (!s.isDeleted) _drawStroke(canvas, s);
    }
    if (preview != null) _drawStroke(canvas, preview!);
  }

  void _drawStroke(Canvas canvas, Stroke s) {
    final q = s.points;
    if (q.length < 2) return;

    final paint = Paint()
      ..color = Color(s.color)
      ..strokeWidth = s.width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    switch (s.kind) {
      case 'text':
        _layoutText(s).paint(canvas, Offset(q[0], q[1]));
      case 'line':
        if (q.length >= 4) {
          canvas.drawLine(Offset(q[0], q[1]), Offset(q[2], q[3]), paint);
        }
      case 'arrow':
        if (q.length >= 4) {
          _drawArrow(canvas, Offset(q[0], q[1]), Offset(q[2], q[3]), paint);
        }
      case 'rect':
        if (q.length >= 4) {
          canvas.drawRect(
            Rect.fromPoints(Offset(q[0], q[1]), Offset(q[2], q[3])),
            paint,
          );
        }
      case 'ellipse':
        if (q.length >= 4) {
          canvas.drawOval(
            Rect.fromPoints(Offset(q[0], q[1]), Offset(q[2], q[3])),
            paint,
          );
        }
      default:
        _drawPen(canvas, q, paint, s.width);
    }
  }

  void _drawPen(Canvas canvas, List<double> pts, Paint paint, double width) {
    // A single click: draw a dot.
    if (pts.length == 2) {
      canvas.drawCircle(
        Offset(pts[0], pts[1]),
        width / 2,
        paint..style = PaintingStyle.fill,
      );
      return;
    }
    final path = Path()..moveTo(pts[0], pts[1]);
    for (var i = 2; i + 1 < pts.length; i += 2) {
      path.lineTo(pts[i], pts[i + 1]);
    }
    canvas.drawPath(path, paint);
  }

  void _drawArrow(Canvas canvas, Offset a, Offset b, Paint paint) {
    final head = max(14.0, paint.strokeWidth * 5);
    final angle = atan2(b.dy - a.dy, b.dx - a.dx);
    canvas.drawLine(a, b, paint);
    for (final side in [-0.5, 0.5]) {
      final dir = Offset(cos(angle + side), sin(angle + side));
      canvas.drawLine(b, b - dir * head, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BoardPainter old) => true;
}
