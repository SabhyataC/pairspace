import 'dart:async';
import 'video_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pairspace_client/pairspace_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web/web.dart' as web;

import '../client.dart';
import 'canvas_section.dart';
import 'code_editor_panel.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key, required this.onSignOut});
  final Future<void> Function() onSignOut;

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  String? _roomCode;
  int? _roomId;
  int? _participantId;
  bool _loading = false;
  bool _isInterviewer = false;
  bool _isPending = false;
  bool _ended = false;
  bool _left = false;

  // ignore: unused_field
  String? _pendingRoomCode;

  Room? _myActiveRoom;
  List<Room> _pastRooms = [];
  bool _checkingActiveRoom = true;

  bool _showPanel = true;

  List<Participant> _pending = [];
  List<Participant> _present = [];
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    final uri = Uri.parse(web.window.location.href);
    final roomCode = uri.queryParameters['room'];
    if (roomCode != null && roomCode.isNotEmpty) {
      _pendingRoomCode = roomCode;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _joinFromLink(roomCode),
      );
    } else {
      _restoreSession();
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkActiveRoom() async {
    setState(() => _checkingActiveRoom = true);
    try {
      final room = await client.room.myActiveRoom();
      if (!mounted) return;
      setState(() => _myActiveRoom = room);
    } catch (_) {}

    try {
      final past = await client.room.pastRooms();
      if (!mounted) return;
      setState(() => _pastRooms = past);
    } catch (_) {}

    if (!mounted) return;
    setState(() => _checkingActiveRoom = false);
  }

  // ---------- Saved session (survives refresh) ----------

  static const _kRoomCode = 'pairspace_roomCode';
  static const _kDisplayName = 'pairspace_displayName';

  Future<void> _saveSession(String code, String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kRoomCode, code);
      await prefs.setString(_kDisplayName, name);
    } catch (_) {}
  }

  Future<void> _clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kRoomCode);
      await prefs.remove(_kDisplayName);
    } catch (_) {}
  }

  /// On startup with no ?room= link: rejoin the saved room if there is one,
  /// otherwise fall back to the normal "my active room" check.
  Future<void> _restoreSession() async {
    String? code;
    String? name;
    try {
      final prefs = await SharedPreferences.getInstance();
      code = prefs.getString(_kRoomCode);
      name = prefs.getString(_kDisplayName);
    } catch (e) {
      debugPrint('restore: prefs read failed: $e');
    }
    debugPrint('restore(no link): saved=$code name=$name');

    if (code == null || name == null) {
      _checkActiveRoom();
      return;
    }
    final ok = await _joinRoom(code, name);
    debugPrint('restore(no link): join ok=$ok');
    if (!ok) {
      await _clearSession();
      if (mounted) _checkActiveRoom();
    }
  }

  Future<void> _joinFromLink(String linkCode) async {
    String? savedCode;
    String? savedName;
    try {
      final prefs = await SharedPreferences.getInstance();
      savedCode = prefs.getString(_kRoomCode);
      savedName = prefs.getString(_kDisplayName);
    } catch (e) {
      debugPrint('restore: prefs read failed: $e');
    }
    debugPrint(
      'restore(link): link=$linkCode saved=$savedCode name=$savedName',
    );

    if (savedCode == linkCode && savedName != null) {
      final ok = await _joinRoom(linkCode, savedName);
      debugPrint('restore(link): join ok=$ok');
      if (ok) return;
      await _clearSession();
      if (!mounted) return;
    }
    _promptJoin(linkCode);
  }
  // ---------- Name prompts ----------

  Future<void> _promptCreate() async {
    final name = await _askName(
      title: 'Your name',
      hint: 'How candidates will see you',
    );
    if (name == null) return;
    _createRoom(name);
  }

  Future<void> _promptJoin(String code) async {
    final name = await _askName(
      title: 'Your name',
      hint: 'How the interviewer will see you',
    );
    if (name == null) {
      setState(() => _pendingRoomCode = null);
      return;
    }
    _joinRoom(code, name);
  }

  Future<String?> _askName({required String title, required String hint}) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 40,
          decoration: InputDecoration(hintText: hint),
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  // ---------- Core actions ----------

  Future<void> _createRoom(String name) async {
    setState(() => _loading = true);
    try {
      final room = await client.room.createRoom(name);
      if (!mounted) return;

      // createRoom only returns the Room — fetch our own Participant row
      // (already created server-side) to get a real participantId.
      final participant = await client.room.joinRoom(room.code, name);
      _saveSession(room.code, name);
      if (!mounted) return;

      setState(() {
        _roomCode = room.code;
        _roomId = room.id;
        _participantId = participant.id;
        _isInterviewer = true;
        _loading = false;
      });
      _startPolling();
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showMessage('Failed to create room: $e');
    }
  }

  Future<bool> _joinRoom(String code, String name) async {
    setState(() => _loading = true);
    try {
      final participant = await client.room.joinRoom(code, name);
      if (!mounted) return false;
      _saveSession(code, name);

      if (participant.status == ParticipantStatus.pending) {
        setState(() {
          _roomCode = code;
          _roomId = participant.roomId;
          _participantId = participant.id;
          _isInterviewer = false;
          _isPending = true;
          _left = false;
          _loading = false;
        });
        _pollForAdmission();
        return true;
      }

      setState(() {
        _roomCode = code;
        _roomId = participant.roomId;
        _participantId = participant.id;
        _isInterviewer = participant.role == ParticipantRole.interviewer;
        _isPending = false;
        _left = false;
        _loading = false;
      });
      _startPolling();
      return true;
    } catch (e) {
      if (!mounted) return false;
      setState(() => _loading = false);
      _showMessage('Failed to join room: $e');
      return false;
    }
  }

  /// Rejoin whatever room this person was last in (either role), reusing
  /// the stored code. Always re-asks for a name, kept simple.
  Future<void> _rejoin() async {
    if (_roomCode == null) return;
    final name = await _askName(
      title: 'Your name',
      hint: _isInterviewer
          ? 'How candidates will see you'
          : 'How the interviewer will see you',
    );
    if (name == null) return;
    _joinRoom(_roomCode!, name);
  }

  // ---------- Polling ----------

  Future<void> _pollForAdmission() async {
    while (mounted && _isPending) {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted || !_isPending) return;

      final ended = await client.room.isRoomEnded(_roomId!);
      if (!mounted) return;
      if (ended) {
        _clearSession();
        setState(() {
          _isPending = false;
          _ended = true;
        });
        return;
      }

      final participant = await client.room.checkStatus(_participantId!);
      if (!mounted) return;

      if (participant.status == ParticipantStatus.admitted) {
        setState(() => _isPending = false);
        _startPolling();
        return;
      }
      if (participant.status == ParticipantStatus.denied) {
        _clearSession();
        setState(() {
          _isPending = false;
          _roomCode = null;
        });
        _showMessage('The interviewer denied your request to join.');
        return;
      }
    }
  }

  void _startPolling() {
    _refresh();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _refresh());
  }

  Future<void> _refresh() async {
    if (_roomId == null || _ended || _left) return;
    try {
      final ended = await client.room.isRoomEnded(_roomId!);
      if (!mounted) return;
      if (ended) {
        _pollTimer?.cancel();
        _clearSession();
        setState(() => _ended = true);
        return;
      }

      final present = await client.room.admittedParticipants(_roomId!);
      if (!mounted) return;
      setState(() => _present = present);

      if (_isInterviewer) {
        final pending = await client.room.pendingParticipants(_roomId!);
        if (!mounted) return;
        setState(() => _pending = pending);
      }
    } catch (_) {}
  }

  // ---------- Admit / deny ----------

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

  // ---------- Leave / End ----------

  Future<void> _confirmLeave() async {
    final confirmed = await _confirmDialog(
      title: 'Leave meeting?',
      body: 'You can rejoin later using the same link.',
      confirmLabel: 'Leave',
    );
    if (confirmed != true) return;

    _pollTimer?.cancel();
    _clearSession();
    try {
      if (_participantId != null) await client.room.leaveRoom(_participantId!);
    } catch (_) {}
    if (!mounted) return;
    // Keep _roomCode so the "left" screen can offer a rejoin.
    setState(() => _left = true);
  }

  Future<void> _confirmEnd() async {
    final confirmed = await _confirmDialog(
      title: 'End meeting for everyone?',
      body: 'This closes the room. No one will be able to rejoin.',
      confirmLabel: 'End meeting',
      danger: true,
    );
    if (confirmed != true) return;

    _pollTimer?.cancel();
    try {
      await client.room.endRoom(_roomId!);
    } catch (e) {
      _showMessage('Failed to end meeting: $e');
      return;
    }
    if (!mounted) return;
    _clearSession();
    setState(() => _ended = true);
  }

  // Monaco's iframe swallows clicks meant for dialogs, so pause it while one is open.
  Future<bool?> _confirmDialog({
    required String title,
    required String body,
    required String confirmLabel,
    bool danger = false,
  }) async {
    final monaco = activeMonacoController;
    await monaco?.setInteractionEnabled(false);
    try {
      return await _showConfirmDialog(
        title: title,
        body: body,
        confirmLabel: confirmLabel,
        danger: danger,
      );
    } finally {
      await monaco?.setInteractionEnabled(true);
    }
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String body,
    required String confirmLabel,
    bool danger = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: danger
                ? FilledButton.styleFrom(backgroundColor: Colors.red)
                : null,
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  // ---------- Clipboard ----------

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

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    final inRoom =
        !_loading && !_isPending && !_ended && !_left && _roomCode != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PairSpace'),
        actions: [
          if (inRoom)
            IconButton(
              tooltip: _showPanel ? 'Show canvas' : 'Show room info',
              icon: Icon(_showPanel ? Icons.brush : Icons.people),
              onPressed: () => setState(() => _showPanel = !_showPanel),
            ),
          TextButton(
            onPressed: widget.onSignOut,
            child: const Text('Sign out'),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_left) return _buildLeftScreen();
    if (_ended) return _buildEndedScreen();
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_isPending) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Waiting for the interviewer to admit you…'),
          ],
        ),
      );
    }

    if (_roomCode == null) {
      if (_checkingActiveRoom) {
        return const Center(child: CircularProgressIndicator());
      }
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_myActiveRoom != null) ...[
              ElevatedButton.icon(
                onPressed: _loading ? null : _rejoinOwnActiveRoom,
                icon: const Icon(Icons.login),
                label: Text('Rejoin your room (${_myActiveRoom!.code})'),
              ),
              const SizedBox(height: 12),
              const Text('or'),
              const SizedBox(height: 12),
            ],
            ElevatedButton(
              onPressed: _loading ? null : _promptCreate,
              child: const Text('Create room'),
            ),
            if (_pastRooms.isNotEmpty) ...[
              const SizedBox(height: 32),
              const Text(
                'Past meetings',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 420,
                  maxHeight: 320,
                ),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final r in _pastRooms)
                      ListTile(
                        dense: true,
                        leading: const Icon(Icons.history, size: 18),
                        title: Text(_fmtDate(r.createdAt)),
                        subtitle: Text(
                          '${r.endedAt!.difference(r.createdAt).inMinutes} min',
                        ),
                        trailing: TextButton(
                          onPressed: () =>
                              web.window.open('/recap/${r.code}', '_blank'),
                          child: const Text('View recap'),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;

        final canvas = Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              VideoSection(
                roomId: _roomId!,
                participantId: _participantId!,
                isCaller: _isInterviewer,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, c) {
                    final workspace = <Widget>[
                      Expanded(child: CodeEditorPanel(roomId: _roomId!)),
                      const SizedBox(width: 12, height: 12),
                      Expanded(child: CanvasSection(roomId: _roomId!)),
                    ];
                    // Side by side when there's room, stacked otherwise.
                    return c.maxWidth >= 700
                        ? Row(children: workspace)
                        : Column(children: workspace);
                  },
                ),
              ),
            ],
          ),
        );

        final panel = SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _buildInfoPanel(),
        );

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: canvas),
              SizedBox(
                width: 320,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: panel,
                ),
              ),
            ],
          );
        }

        return IndexedStack(
          index: _showPanel ? 0 : 1,
          children: [panel, canvas],
        );
      },
    );
  }

  Future<void> _rejoinOwnActiveRoom() async {
    if (_myActiveRoom == null) return;
    _roomCode = _myActiveRoom!.code;
    await _rejoin();
  }

  Widget _buildLeftScreen() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('You left the meeting.'),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _rejoin,
            icon: const Icon(Icons.login),
            label: const Text('Rejoin'),
          ),
          if (_isInterviewer) ...[
            const SizedBox(height: 12),
            const Text('or'),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _left = false;
                  _roomCode = null;
                  _roomId = null;
                });
                _checkActiveRoom();
              },
              child: const Text('Create a new room'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEndedScreen() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('This meeting has ended.'),
          const SizedBox(height: 16),
          if (_isInterviewer && _roomCode != null) ...[
            FilledButton.icon(
              onPressed: () => web.window.open('/recap/$_roomCode', '_blank'),
              icon: const Icon(Icons.description_outlined),
              label: const Text('View recap'),
            ),
            const SizedBox(height: 8),
          ],
          if (_isInterviewer)
            TextButton(
              onPressed: () {
                setState(() {
                  _ended = false;
                  _roomCode = null;
                  _roomId = null;
                });
                _checkActiveRoom();
              },
              child: const Text('Create a new room'),
            )
          else
            const Text('Contact the interviewer for a new invite if needed.'),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) {
    final l = d.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${l.year}-${two(l.month)}-${two(l.day)} ${two(l.hour)}:${two(l.minute)}';
  }

  Widget _buildInfoPanel() {
    final interviewerPresent = _present.any(
      (p) => p.role == ParticipantRole.interviewer,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isInterviewer ? 'Room created' : 'Joined room',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          _isInterviewer ? 'You are the interviewer' : 'You are the candidate',
        ),
        const SizedBox(height: 12),
        SelectableText(
          _roomCode!,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        if (_isInterviewer)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: _copyRoomCode,
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Copy Code'),
              ),
              ElevatedButton.icon(
                onPressed: _copyInviteLink,
                icon: const Icon(Icons.link, size: 16),
                label: const Text('Copy Invite Link'),
              ),
            ],
          ),
        if (!_isInterviewer && !interviewerPresent) ...[
          const SizedBox(height: 12),
          const Text(
            'The interviewer has left the room.',
            style: TextStyle(color: Colors.orange),
          ),
        ],
        const SizedBox(height: 20),
        const Divider(),
        Text(
          'In this room (${_present.length})',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ..._present.map(
          (p) => ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.person, size: 18),
            title: Text(p.displayName),
            trailing: Text(
              p.role == ParticipantRole.interviewer
                  ? 'Interviewer'
                  : 'Candidate',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
        ),
        if (_isInterviewer) ...[
          const SizedBox(height: 16),
          const Divider(),
          Text(
            'Waiting to join (${_pending.length})',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (_pending.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'No one is waiting right now.',
                style: TextStyle(fontSize: 13),
              ),
            )
          else
            ..._pending.map(
              (p) => Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  dense: true,
                  title: Text(p.displayName),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                        tooltip: 'Admit',
                        onPressed: () => _admit(p),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.cancel,
                          color: Colors.red,
                          size: 20,
                        ),
                        tooltip: 'Deny',
                        onPressed: () => _deny(p),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          children: [
            OutlinedButton.icon(
              onPressed: _confirmLeave,
              icon: const Icon(Icons.logout, size: 16),
              label: const Text('Leave'),
            ),
            if (_isInterviewer)
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: _confirmEnd,
                icon: const Icon(Icons.call_end, size: 16),
                label: const Text('End meeting'),
              ),
          ],
        ),
      ],
    );
  }
}
