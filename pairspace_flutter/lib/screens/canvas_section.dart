import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pairspace_client/pairspace_client.dart';

import '../client.dart';
import 'canvas_board.dart';

class CanvasSection extends StatefulWidget {
  const CanvasSection({super.key, required this.roomId});
  final int roomId;

  @override
  State<CanvasSection> createState() => _CanvasSectionState();
}

class _CanvasSectionState extends State<CanvasSection> {
  final _controller = CanvasController();
  final _outgoing = StreamController<Stroke>();
  StreamSubscription<Stroke>? _incomingSub;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  Future<void> _connect() async {
    try {
      // Load what's already been drawn before this client connected.
      final saved = await client.canvas.getStrokes(widget.roomId);
      // ^ adjust name below if your generated method differs — see note.
      if (!mounted) return;
      _controller.replaceAll(saved);

      // Open the bidirectional stream: send _outgoing.stream, listen to the
      // response stream for everyone's strokes (including our own echoed back).
      final incoming = client.canvas.strokeStream(
        widget.roomId,
        _outgoing.stream,
      );
      _incomingSub = incoming.listen(
        (stroke) => _controller.add(stroke),
        onError: (e) {
          if (!mounted) return;
          setState(() => _error = 'Live sync error: $e');
        },
      );

      if (!mounted) return;
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Failed to load canvas: $e';
      });
    }
  }

  void _onStrokeComplete(Stroke stroke) {
    _outgoing.add(stroke);
  }

  @override
  void dispose() {
    _incomingSub?.cancel();
    _outgoing.close();
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
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(_error!, style: const TextStyle(color: Colors.red)),
      );
    }
    return CanvasBoard(
      roomId: widget.roomId,
      controller: _controller,
      onStrokeComplete: _onStrokeComplete,
    );
  }
}
