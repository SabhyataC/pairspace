import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pairspace_client/pairspace_client.dart';

import '../client.dart';
import 'canvas_board.dart';
import 'dart:math';

class CanvasSection extends StatefulWidget {
  const CanvasSection({super.key, required this.roomId});
  final int roomId;

  @override
  State<CanvasSection> createState() => _CanvasSectionState();
}

class _CanvasSectionState extends State<CanvasSection> {
  final _controller = CanvasController();
  StreamController<Stroke>? _outgoing;
  StreamSubscription<Stroke>? _incomingSub;
  Timer? _reconnectTimer;
  Timer? _syncTimer;

  /// Strokes drawn while the stream was down; sent after reconnect.
  final List<Stroke> _pending = [];
  int _retry = 0;
  bool _disposed = false;
  bool _loading = true;
  bool _connected = false;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  Future<void> _connect() async {
    if (_disposed) return;
    try {
      // Reload saved strokes (also resyncs anything missed while offline).
      final saved = await client.canvas.getStrokes(widget.roomId);
      if (!mounted) return;
      _controller.replaceAll(saved);

      // replaceAll drops our unsent strokes, so put them back on screen.
      final unsent = List<Stroke>.of(_pending);
      for (final s in unsent) {
        _controller.add(s);
      }

      _incomingSub?.cancel();
      _outgoing?.close();
      final out = StreamController<Stroke>();
      _outgoing = out;
      _incomingSub = client.canvas
          .strokeStream(widget.roomId, out.stream)
          .listen(
            (stroke) => _controller.add(stroke),
            onError: (Object e) {
              debugPrint('strokeStream error: $e');
              _onDisconnected();
            },
            onDone: _onDisconnected,
          );

      // Flush strokes drawn while offline.
      for (final s in unsent) {
        out.add(s);
      }
      _pending.clear();

      _retry = 0;
      _syncTimer?.cancel();
      _syncTimer = Timer.periodic(
        const Duration(seconds: 4),
        (_) => _catchUp(),
      );
      setState(() {
        _loading = false;
        _connected = true;
      });
    } catch (e) {
      debugPrint('canvas connect failed: $e');
      if (!mounted) return;
      setState(() => _loading = false);
      _onDisconnected();
    }
  }

  void _onDisconnected() {
    if (_disposed || !mounted) return;
    if (_reconnectTimer?.isActive ?? false) return; // error + done both fire

    debugPrint('canvas stream dropped, retry $_retry');
    _incomingSub?.cancel();
    _incomingSub = null;
    _outgoing?.close();
    _outgoing = null;
    setState(() => _connected = false);

    final seconds = min(1 << min(_retry, 4), 10); // 1, 2, 4, 8, 10, 10...
    _retry++;
    _reconnectTimer = Timer(Duration(seconds: seconds), _connect);
  }

  Future<void> _catchUp() async {
    if (!_connected || _disposed) return;
    try {
      final saved = await client.canvas.getStrokes(widget.roomId);
      if (!mounted) return;
      for (final s in saved) {
        _controller.add(s); // skips strokes we already have
      }
    } catch (_) {}
  }

  void _onStrokeComplete(Stroke stroke) {
    final out = _outgoing;
    if (_connected && out != null && !out.isClosed) {
      out.add(stroke);
    } else {
      _pending.add(stroke); // sent after reconnect
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _reconnectTimer?.cancel();
    _syncTimer?.cancel();
    _incomingSub?.cancel();
    _outgoing?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: CircularProgressIndicator(),
      );
    }
    return Stack(
      fit: StackFit.passthrough,
      children: [
        CanvasBoard(
          roomId: widget.roomId,
          controller: _controller,
          onStrokeComplete: _onStrokeComplete,
        ),
        if (!_connected)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Reconnecting…',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }
}
