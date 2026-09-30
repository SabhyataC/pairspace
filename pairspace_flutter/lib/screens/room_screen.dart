// import 'package:flutter/material.dart';

// import '../client.dart';

// class RoomScreen extends StatefulWidget {
//   const RoomScreen({super.key, required this.onSignOut});
//   final Future<void> Function() onSignOut;

//   @override
//   State<RoomScreen> createState() => _RoomScreenState();
// }

// class _RoomScreenState extends State<RoomScreen> {
//   String? _roomCode;
//   bool _loading = false;

//   Future<void> _createRoom() async {
//     setState(() => _loading = true);
//     final room = await client.room.createRoom();
//     setState(() {
//       _roomCode = room.code;
//       _loading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('PairSpace'),
//         actions: [
//           TextButton(onPressed: widget.onSignOut, child: const Text('Sign out')),
//         ],
//       ),
//       body: Center(
//         child: _roomCode != null
//             ? Text('Room created: $_roomCode')
//             : ElevatedButton(
//                 onPressed: _loading ? null : _createRoom,
//                 child: const Text('Create room'),
//               ),
//       ),
//     );
//   }
// }
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pairspace_client/pairspace_client.dart';
import 'package:web/web.dart' as web;
import 'canvas_board.dart';

import '../client.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key, required this.onSignOut});
  final Future<void> Function() onSignOut;

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  String? _roomCode;
  int? _roomId;
  bool _loading = false;
  bool _isInterviewer = false;
  bool _isPending = false;

  List<Participant> _pending = [];
  final CanvasController _canvas = CanvasController();
  StreamController<Stroke>? _outgoing;
  StreamSubscription<Stroke>? _incoming;
  bool _canvasWanted = false;
  Timer? _reconnectTimer;
  final Map<String, Stroke> _sent = {};

  Timer? _pendingTimer;

  @override
  void initState() {
    super.initState();
    final uri = Uri.parse(web.window.location.href);
    final roomCode = uri.queryParameters['room'];
    if (roomCode != null && roomCode.isNotEmpty) {
      _joinRoom(roomCode);
    }
  }

  @override
  void dispose() {
    _pendingTimer?.cancel();
    _canvas.dispose();
    _canvasWanted = false;
    _reconnectTimer?.cancel();
    _incoming?.cancel();
    _outgoing?.close();
    super.dispose();
  }

  Future<void> _createRoom() async {
    setState(() => _loading = true);
    try {
      final room = await client.room.createRoom();
      if (!mounted) return;
      setState(() {
        _roomCode = room.code;
        _roomId = room.id;
        _isInterviewer = true;
        _loading = false;
      });
      final uri = Uri.parse(web.window.location.href);
      web.window.history.replaceState(
        null,
        '',
        uri.replace(queryParameters: {'room': room.code}).toString(),
      );
      _openCanvasStream();
      _startPendingPolling();
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showMessage('Failed to create room: $e');
    }
  }

  Future<void> _joinRoom(String code) async {
    setState(() => _loading = true);
    try {
      final participant = await client.room.joinRoom(code);
      if (!mounted) return;

      if (participant.status == ParticipantStatus.pending) {
        setState(() {
          _roomCode = code;
          _roomId = participant.roomId;
          _isInterviewer = false;
          _isPending = true;
          _loading = false;
        });
        _pollForAdmission(participant.id!);
        return;
      }

      setState(() {
        _roomCode = code;
        _roomId = participant.roomId;
        _isInterviewer = participant.role == ParticipantRole.interviewer;
        _isPending = false;
        _loading = false;
      });
      _openCanvasStream();
      if (_isInterviewer) _startPendingPolling();
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showMessage('Failed to join room: $e');
    }
  }

  Future<void> _pollForAdmission(int participantId) async {
    while (mounted && _isPending) {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      final participant = await client.room.checkStatus(participantId);
      if (!mounted) return;

      if (participant.status == ParticipantStatus.admitted) {
        setState(() => _isPending = false);
        _openCanvasStream();
        return;
      }
      if (participant.status == ParticipantStatus.denied) {
        setState(() {
          _isPending = false;
          _roomCode = null;
        });
        _showMessage('The interviewer denied your request to join.');
        return;
      }
    }
  }

  void _startPendingPolling() {
    _refreshPending();
    _pendingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _refreshPending();
    });
  }

  Future<void> _refreshPending() async {
    if (_roomId == null) return;
    try {
      final pending = await client.room.pendingParticipants(_roomId!);
      if (!mounted) return;
      setState(() => _pending = pending);
    } catch (_) {
      // silent — a failed poll shouldn't disrupt the interviewer's screen
    }
  }

  Future<void> _admit(Participant p) async {
    try {
      await client.room.admitParticipant(p.id!);
      if (!mounted) return;
      setState(() => _pending.removeWhere((e) => e.id == p.id));
    } catch (e) {
      _showMessage('Failed to admit: $e');
    }
  }

  Future<void> _deny(Participant p) async {
    try {
      await client.room.denyParticipant(p.id!);
      if (!mounted) return;
      setState(() => _pending.removeWhere((e) => e.id == p.id));
    } catch (e) {
      _showMessage('Failed to deny: $e');
    }
  }

  Future<void> _copyRoomCode() async {
    if (_roomCode == null) return;
    await Clipboard.setData(ClipboardData(text: _roomCode!));
    if (!mounted) return;
    _showMessage('Room code copied');
  }

  Future<void> _copyInviteLink() async {
    if (_roomCode == null) return;
    final currentUri = Uri.parse(web.window.location.href);
    final inviteUri = currentUri.replace(queryParameters: {'room': _roomCode!});
    await Clipboard.setData(ClipboardData(text: inviteUri.toString()));
    if (!mounted) return;
    _showMessage('Invite link copied');
  }

  // Identifies a stroke I sent, so I can recognise it when the server echoes it back.
  String _strokeKey(Stroke s) =>
      '${s.createdAt.microsecondsSinceEpoch}|${s.points.length}';

  void _openCanvasStream() {
    final roomId = _roomId;
    if (roomId == null || _canvasWanted) return;
    _canvasWanted = true;
    _connectCanvas(roomId);
  }

  void _connectCanvas(int roomId) {
    _incoming?.cancel();
    _sent.clear();

    final outgoing = StreamController<Stroke>();
    _outgoing = outgoing;

    _incoming = client.canvas
        .strokeStream(roomId, outgoing.stream)
        .listen(
          (stroke) {
            final mine = _sent.remove(_strokeKey(stroke));
            if (mine != null) {
              mine.id = stroke.id; // learn the database id of my own stroke
              _canvas.add(mine); // does nothing if it's already on the canvas
              return;
            }
            _canvas.add(stroke);
          },
          onError: (Object e) => debugPrint('Canvas stream error: $e'),
          onDone: () {
            debugPrint('Canvas stream CLOSED');
            if (_outgoing != outgoing) return; // an older connection
            _outgoing = null;
            outgoing.close();
            if (!mounted || !_canvasWanted) return;
            _reconnectTimer?.cancel();
            _reconnectTimer = Timer(const Duration(seconds: 2), () {
              if (mounted && _canvasWanted) _connectCanvas(roomId);
            });
          },
        );

    _loadSavedStrokes(roomId);
  }

  Future<void> _loadSavedStrokes(int roomId) async {
    try {
      final saved = await client.canvas.getStrokes(roomId);
      if (!mounted) return;
      _canvas.replaceAll(saved);
    } catch (e) {
      debugPrint('Failed to load strokes: $e');
    }
  }

  void _sendStroke(Stroke stroke) {
    if (_outgoing == null) return;
    _sent[_strokeKey(stroke)] = stroke;
    _outgoing!.add(stroke);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PairSpace'),
        actions: [
          TextButton(
            onPressed: widget.onSignOut,
            child: const Text('Sign out'),
          ),
        ],
      ),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : _isPending
            ? const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Waiting for the interviewer to admit you…'),
                ],
              )
            : _roomCode != null
            ? SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isInterviewer ? 'Room created' : 'Joined room',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isInterviewer
                          ? 'You are the interviewer'
                          : 'You are the candidate',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    SelectableText(
                      _roomCode!,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_isInterviewer)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _copyRoomCode,
                            icon: const Icon(Icons.copy),
                            label: const Text('Copy Code'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: _copyInviteLink,
                            icon: const Icon(Icons.link),
                            label: const Text('Copy Invite Link'),
                          ),
                        ],
                      ),
                    if (_isInterviewer) ...[
                      const SizedBox(height: 32),
                      const Divider(),
                      const SizedBox(height: 12),
                      Text(
                        'Waiting to join (${_pending.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_pending.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text('No one is waiting right now.'),
                        )
                      else
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 360),
                          child: Column(
                            children: _pending.map((p) {
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                child: ListTile(
                                  title: Text(p.displayName),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                        ),
                                        tooltip: 'Admit',
                                        onPressed: () => _admit(p),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.cancel,
                                          color: Colors.red,
                                        ),
                                        tooltip: 'Deny',
                                        onPressed: () => _deny(p),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                    const SizedBox(height: 24),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: CanvasBoard(
                        roomId: _roomId!,
                        controller: _canvas,
                        onStrokeComplete: _sendStroke,
                      ),
                    ),
                  ],
                ),
              )
            : ElevatedButton(
                onPressed: _loading ? null : _createRoom,
                child: const Text('Create room'),
              ),
      ),
    );
  }
}
