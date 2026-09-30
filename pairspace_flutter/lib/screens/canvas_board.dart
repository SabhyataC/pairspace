import 'package:flutter/material.dart';
import 'package:pairspace_client/pairspace_client.dart';

/// Every stroke lives in a fixed "virtual" canvas of this size, so two people
/// with different window sizes still see the same drawing.
const double kCanvasWidth = 1000;
const double kCanvasHeight = 625;

/// Holds the finished strokes. Day 6 will add remote strokes through this.
class CanvasController extends ChangeNotifier {
  final List<Stroke> strokes = [];

  void add(Stroke stroke) {
    // Skip strokes we already have (the same stroke can arrive twice,
    // once from the saved list and once live).
    if (stroke.id != null && strokes.any((s) => s.id == stroke.id)) return;
    strokes.add(stroke);
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

  /// Called once when the user lifts the pointer. Day 6 sends it to the server.
  final void Function(Stroke stroke)? onStrokeComplete;

  @override
  State<CanvasBoard> createState() => _CanvasBoardState();
}

class _CanvasBoardState extends State<CanvasBoard> {
  static const _color = Colors.black;
  static const _width = 3.0;

  /// Points of the stroke being drawn right now, flat: [x0, y0, x1, y1, ...]
  List<double>? _current;

  List<double> _toCanvas(Offset local, Size size) => [
    local.dx / size.width * kCanvasWidth,
    local.dy / size.height * kCanvasHeight,
  ];

  void _finish() {
    final points = _current;
    if (points == null) return;
    setState(() => _current = null);

    final stroke = Stroke(
      roomId: widget.roomId,
      points: points,
      color: _color.toARGB32(),
      width: _width,
    );
    widget.controller.add(stroke);
    widget.onStrokeComplete?.call(stroke);
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: kCanvasWidth / kCanvasHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          return Listener(
            onPointerDown: (e) =>
                setState(() => _current = _toCanvas(e.localPosition, size)),
            onPointerMove: (e) {
              if (_current == null) return;
              setState(
                () => _current!.addAll(_toCanvas(e.localPosition, size)),
              );
            },
            onPointerUp: (_) => _finish(),
            onPointerCancel: (_) => _finish(),
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
                      current: _current,
                      currentColor: _color,
                      currentWidth: _width,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BoardPainter extends CustomPainter {
  _BoardPainter({
    required this.strokes,
    required this.current,
    required this.currentColor,
    required this.currentWidth,
  });

  final List<Stroke> strokes;
  final List<double>? current;
  final Color currentColor;
  final double currentWidth;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / kCanvasWidth);

    for (final s in strokes) {
      _drawStroke(canvas, s.points, Color(s.color), s.width);
    }
    if (current != null) {
      _drawStroke(canvas, current!, currentColor, currentWidth);
    }
  }

  void _drawStroke(Canvas canvas, List<double> pts, Color color, double width) {
    if (pts.length < 2) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

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
    canvas.drawPath(path, paint..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(covariant _BoardPainter old) => true;
}
