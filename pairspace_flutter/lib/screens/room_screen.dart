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
import 'integrity_monitor.dart';
import 'integrity_log_panel.dart';
import 'countdown_timer.dart';
import 'room_setup_screen.dart';
import '../widgets/pairspace_logo.dart';
import '../theme/pairspace_colors.dart';

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
  bool _timeUpShown = false;
  String _activeWorkspaceView = 'split'; // 'split', 'code', 'board'
  bool _leftSidebarExpanded = true;
  bool _showVideoStrip = true;

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

  Future<void> _openRecap(int roomId) async {
    // Open the tab first (inside the click), or the browser may block it.
    final tab = web.window.open('about:blank', '_blank');
    try {
      final url = await client.room.recapUrl(roomId);
      tab?.location.href = url;
    } catch (_) {
      tab?.close();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the recap')),
      );
    }
  }

  Future<void> _goToRecap() async {
    final roomId = _roomId;
    if (roomId == null) return;
    try {
      final url = await client.room.recapUrl(roomId);
      if (!mounted) return;
      web.window.location.href = url;
    } catch (_) {
      _showMessage('Could not open the recap');
    }
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

  Future<void> _createRoom(String name, int minutes) async {
    setState(() => _loading = true);
    try {
      final room = await client.room.createRoom(name, minutes);
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
    await _endNow();
  }

  Future<void> _endNow() async {
    try {
      await client.room.endRoom(_roomId!);
    } catch (e) {
      _showMessage('Failed to end meeting: $e');
      return;
    }
    _pollTimer?.cancel();
    if (!mounted) return;
    _clearSession();
    setState(() => _ended = true);
    if (_isInterviewer) await _goToRecap();
  }

  Future<void> _onTimeUp() async {
    if (!mounted || _timeUpShown || _ended || _left) return;
    _timeUpShown = true;

    final monaco = activeMonacoController;
    await monaco?.setInteractionEnabled(false);
    bool endNow = false;
    try {
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.timer_off_outlined, size: 40),
          title: const Text("Time's up"),
          content: Text(
            _isInterviewer
                ? 'The scheduled time for this interview has ended. '
                      'You can keep going or end the meeting for everyone.'
                : 'The scheduled time for this interview has ended. '
                      'The interviewer may wrap up shortly.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(_isInterviewer ? 'Keep going' : 'OK'),
            ),
            if (_isInterviewer)
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('End meeting'),
              ),
          ],
        ),
      );
      endNow = result == true;
    } finally {
      await monaco?.setInteractionEnabled(true);
    }
    if (endNow && mounted) await _endNow();
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

    if (inRoom) {
      return Theme(
        data: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF0F172A),
          colorScheme: const ColorScheme.dark(
            primary: PairSpaceColors.primary,
            surface: Color(0xFF1E293B),
          ),
          dividerColor: const Color(0xFF334155),
        ),
        child: Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          body: _buildBody(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
      return RoomSetupScreen(
        myActiveRoom: _myActiveRoom,
        pastRooms: _pastRooms,
        onRejoinActiveRoom: _rejoinOwnActiveRoom,
        onOpenRecap: _openRecap,
        onCreateRoom: (name, minutes) async {
          await _createRoom(name, minutes);
        },
        onJoinRoom: (code, name) async {
          return await _joinRoom(code, name);
        },
      );
    }

    return Row(
      children: [
        // 1. Left Animated Navigation Sidebar
        AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOutCubic,
          width: _leftSidebarExpanded ? 210 : 64,
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            border: Border(
              right: BorderSide(color: Color(0xFF1E293B), width: 1.2),
            ),
          ),
          child: _buildLeftSidebar(),
        ),

        // 2. Main Area (Top Meeting Bar + Workspace Panels + Animated Right Panel)
        Expanded(
          child: Column(
            children: [
              _buildTopMeetingToolbar(),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Center Workspace Canvas
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            if (!_isInterviewer)
                              IntegrityMonitorHost(roomId: _roomId!),
                            AnimatedSize(
                              duration: const Duration(milliseconds: 280),
                              curve: Curves.easeInOutCubic,
                              child: _showVideoStrip
                                  ? Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        VideoSection(
                                          roomId: _roomId!,
                                          participantId: _participantId!,
                                          isCaller: _isInterviewer,
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                    )
                                  : const SizedBox.shrink(),
                            ),
                            if (_isInterviewer) ...[
                              IntegrityLogPanel(roomId: _roomId!),
                              const SizedBox(height: 8),
                            ],
                            Expanded(child: _buildActiveWorkspace()),
                          ],
                        ),
                      ),
                    ),

                    // 3. Right Animated Side Panel (Participants & Lobby)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeInOutCubic,
                      width: _showPanel ? 340 : 0,
                      child: ClipRect(
                        child: OverflowBox(
                          minWidth: 340,
                          maxWidth: 340,
                          alignment: Alignment.topRight,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFF1E293B),
                              border: Border(
                                left: BorderSide(color: Color(0xFF334155)),
                              ),
                            ),
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(16),
                              child: _buildInfoPanel(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeftSidebar() {
    return Container(
      color: const Color(0xFF0F172A),
      padding: EdgeInsets.symmetric(
        horizontal: _leftSidebarExpanded ? 14 : 10,
        vertical: 14,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo & Collapse/Expand Toggle
          Row(
            mainAxisAlignment: _leftSidebarExpanded
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.center,
            children: [
              if (_leftSidebarExpanded) ...[
                const PairSpaceLogo(size: 24, fontSize: 16, isDark: true),
                IconButton(
                  tooltip: 'Collapse sidebar',
                  icon: const Icon(
                    Icons.menu_open_rounded,
                    color: Color(0xFF94A3B8),
                    size: 18,
                  ),
                  onPressed: () => setState(() => _leftSidebarExpanded = false),
                ),
              ] else ...[
                IconButton(
                  tooltip: 'Expand sidebar',
                  icon: const Icon(
                    Icons.menu_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _leftSidebarExpanded = true),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),

          // Connection status & Room Code badge
          if (_leftSidebarExpanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'CONNECTED',
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _roomCode ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Copy Room Code',
                        icon: const Icon(
                          Icons.copy_rounded,
                          size: 13,
                          color: Color(0xFF94A3B8),
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: _copyRoomCode,
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            Center(
              child: Tooltip(
                message: 'Connected · Room: $_roomCode',
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 18),

          // Navigation Section
          _sidebarNavItem(
            icon: Icons.splitscreen_rounded,
            label: 'Split View',
            isActive: _activeWorkspaceView == 'split',
            onTap: () => setState(() => _activeWorkspaceView = 'split'),
          ),
          _sidebarNavItem(
            icon: Icons.code_rounded,
            label: 'Code Editor',
            isActive: _activeWorkspaceView == 'code',
            onTap: () => setState(() => _activeWorkspaceView = 'code'),
          ),
          _sidebarNavItem(
            icon: Icons.brush_outlined,
            label: 'Whiteboard',
            isActive: _activeWorkspaceView == 'board',
            onTap: () => setState(() => _activeWorkspaceView = 'board'),
          ),
          _sidebarNavItem(
            icon: Icons.people_alt_rounded,
            label: 'Participants',
            isActive: _showPanel,
            badge: _present.isNotEmpty ? '${_present.length}' : null,
            badgeColor: _pending.isNotEmpty
                ? const Color(0xFFF59E0B)
                : const Color(0xFF4F46E5),
            onTap: () => setState(() => _showPanel = !_showPanel),
          ),
          if (_isInterviewer)
            _sidebarNavItem(
              icon: Icons.radar_rounded,
              label: 'Focus Radar',
              isActive: false,
              badge: _pending.isNotEmpty ? 'Lobby (${_pending.length})' : null,
              badgeColor: const Color(0xFFEF4444),
              onTap: () => setState(() => _showPanel = true),
            ),

          const Spacer(),

          // Leave Room button
          if (_leftSidebarExpanded)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFEF4444)),
                  backgroundColor: const Color(0xFF1E293B),
                  foregroundColor: const Color(0xFFEF4444),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _confirmLeave,
                icon: const Icon(Icons.logout_rounded, size: 16),
                label: const Text(
                  'Leave Room',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          else
            Center(
              child: IconButton(
                tooltip: 'Leave Room',
                icon: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFEF4444),
                  size: 20,
                ),
                onPressed: _confirmLeave,
              ),
            ),
        ],
      ),
    );
  }

  Widget _sidebarNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    String? badge,
    Color? badgeColor,
  }) {
    if (!_leftSidebarExpanded) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Tooltip(
          message: label,
          preferBelow: false,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF4F46E5) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: isActive ? Colors.white : const Color(0xFF94A3B8),
                  ),
                  if (badge != null)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: badgeColor ?? const Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 8,
                          minHeight: 8,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF4F46E5) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        visualDensity: const VisualDensity(vertical: -2),
        onTap: onTap,
        leading: Icon(
          icon,
          size: 18,
          color: isActive ? Colors.white : const Color(0xFF94A3B8),
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFFCBD5E1),
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
        trailing: badge != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor ?? const Color(0xFF334155),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildTopMeetingToolbar() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(
          bottom: BorderSide(color: Color(0xFF1E293B), width: 1.2),
        ),
      ),
      child: Row(
        children: [
          // View selector pills
          _topViewPill('split', 'Split View', Icons.splitscreen_rounded),
          const SizedBox(width: 6),
          _topViewPill('code', 'Code Editor', Icons.code_rounded),
          const SizedBox(width: 6),
          _topViewPill('board', 'Whiteboard', Icons.brush_outlined),

          const Spacer(),

          // Video Section toggle button
          IconButton(
            tooltip: _showVideoStrip ? 'Hide Video Tiles' : 'Show Video Tiles',
            icon: Icon(
              _showVideoStrip
                  ? Icons.videocam_rounded
                  : Icons.videocam_off_rounded,
              color: _showVideoStrip ? Colors.white : const Color(0xFF94A3B8),
              size: 20,
            ),
            onPressed: () => setState(() => _showVideoStrip = !_showVideoStrip),
          ),
          const SizedBox(width: 4),

          // Session Timer
          if (_roomId != null)
            CountdownTimer(roomId: _roomId!, onTimeUp: _onTimeUp),
          const SizedBox(width: 10),

          // Share / Invite link
          IconButton(
            tooltip: 'Copy Invite Link',
            icon: const Icon(
              Icons.share_outlined,
              color: Colors.white,
              size: 19,
            ),
            onPressed: _copyInviteLink,
          ),

          // Side panel toggle button
          IconButton(
            tooltip: _showPanel
                ? 'Hide Side Panel'
                : 'Show Participants & Info',
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  _showPanel
                      ? Icons.view_sidebar_rounded
                      : Icons.view_sidebar_outlined,
                  color: _showPanel ? const Color(0xFF818CF8) : Colors.white,
                  size: 20,
                ),
                if (_pending.isNotEmpty)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => setState(() => _showPanel = !_showPanel),
          ),
          const SizedBox(width: 8),

          // Quick Leave / End button
          if (_isInterviewer)
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _confirmEnd,
              icon: const Icon(Icons.call_end, size: 16),
              label: const Text(
                'End',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            )
          else
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFEF4444)),
                backgroundColor: const Color(0xFF1E293B),
                foregroundColor: const Color(0xFFEF4444),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _confirmLeave,
              icon: const Icon(Icons.call_end, size: 16),
              label: const Text(
                'Leave',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _topViewPill(String id, String label, IconData icon) {
    final active = _activeWorkspaceView == id;
    return GestureDetector(
      onTap: () => setState(() => _activeWorkspaceView = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF4F46E5) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? const Color(0xFF6366F1) : const Color(0xFF334155),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: active ? Colors.white : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveWorkspace() {
    switch (_activeWorkspaceView) {
      case 'code':
        return _codeCard();
      case 'board':
        return _boardCard();
      case 'split':
      default:
        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 720;
            if (isWide) {
              return Row(
                children: [
                  Expanded(flex: 5, child: _codeCard()),
                  const SizedBox(width: 10),
                  Expanded(flex: 5, child: _boardCard()),
                ],
              );
            } else {
              return Column(
                children: [
                  Expanded(child: _codeCard()),
                  const SizedBox(height: 10),
                  Expanded(child: _boardCard()),
                ],
              );
            }
          },
        );
    }
  }

  Widget _codeCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      clipBehavior: Clip.antiAlias,
      child: CodeEditorPanel(roomId: _roomId!),
    );
  }

  Widget _boardCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      clipBehavior: Clip.antiAlias,
      child: CanvasSection(roomId: _roomId!),
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
          const Icon(Icons.check_circle_outline, size: 48),
          const SizedBox(height: 12),
          const Text(
            'The meeting has ended.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          if (_isInterviewer && _roomId != null) ...[
            // Fallback in case the automatic redirect doesn't happen.
            FilledButton.icon(
              onPressed: _goToRecap,
              icon: const Icon(Icons.description_outlined),
              label: const Text('View recap'),
            ),
            const SizedBox(height: 12),
          ],
          OutlinedButton(
            onPressed: _backToHome,
            child: const Text('Back to home'),
          ),
        ],
      ),
    );
  }

  void _backToHome() {
    setState(() {
      _ended = false;
      _roomCode = null;
      _roomId = null;
    });
    _checkActiveRoom();
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
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _isInterviewer ? 'You are the interviewer' : 'You are the candidate',
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ROOM CODE',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              SelectableText(
                _roomCode!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: Colors.white,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (_isInterviewer)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0F172A),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: _copyRoomCode,
                icon: const Icon(Icons.copy, size: 15),
                label: const Text(
                  'Copy Code',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF334155),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: _copyInviteLink,
                icon: const Icon(Icons.link, size: 15),
                label: const Text(
                  'Copy Invite Link',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
            ],
          ),
        if (!_isInterviewer && !interviewerPresent) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF451A03),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFB45309)),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFFBBF24),
                  size: 18,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'The interviewer has left the room.',
                    style: TextStyle(color: Color(0xFFFDE68A), fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        const Divider(color: Color(0xFF334155)),
        const SizedBox(height: 8),
        Text(
          'In this room (${_present.length})',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        ..._present.map(
          (p) => Container(
            margin: const EdgeInsets.symmetric(vertical: 3),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Row(
              children: [
                const Icon(Icons.person, size: 18, color: Color(0xFF38BDF8)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    p.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF475569)),
                  ),
                  child: Text(
                    p.role == ParticipantRole.interviewer
                        ? 'Interviewer'
                        : 'Candidate',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isInterviewer) ...[
          const SizedBox(height: 16),
          const Divider(color: Color(0xFF334155)),
          const SizedBox(height: 8),
          Text(
            'Waiting to join (${_pending.length})',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          if (_pending.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'No one is waiting right now.',
                style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              ),
            )
          else
            ..._pending.map(
              (p) => Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 18,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        p.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.check_circle,
                        color: Color(0xFF22C55E),
                        size: 22,
                      ),
                      tooltip: 'Admit',
                      onPressed: () => _admit(p),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.cancel,
                        color: Color(0xFFEF4444),
                        size: 22,
                      ),
                      tooltip: 'Deny',
                      onPressed: () => _deny(p),
                    ),
                  ],
                ),
              ),
            ),
        ],
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF475569)),
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF0F172A),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _confirmLeave,
              icon: const Icon(Icons.logout, size: 16, color: Colors.white),
              label: const Text(
                'Leave',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (_isInterviewer)
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _confirmEnd,
                icon: const Icon(Icons.call_end, size: 16, color: Colors.white),
                label: const Text(
                  'End meeting',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
