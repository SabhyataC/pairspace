import 'package:flutter/material.dart';
import '../widgets/pairspace_logo.dart';

class WorkspaceScreen extends StatefulWidget {
  final String roomCode;
  final bool isConnected;
  final VoidCallback onLeaveRoom;
  final Widget? whiteboardWidget;
  final Widget? codeEditorWidget;
  final Widget? videoSectionWidget;
  final int participantsCount;

  const WorkspaceScreen({
    super.key,
    this.roomCode = 'ABC123',
    this.isConnected = true,
    required this.onLeaveRoom,
    this.whiteboardWidget,
    this.codeEditorWidget,
    this.videoSectionWidget,
    this.participantsCount = 2,
  });

  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  int _activeNavIndex = 0; // 0: Whiteboard, 1: Code Editor, 2: Participants, 3: Settings
  bool _whiteboardTabActive = true;
  bool _codeEditorTabActive = true;
  final TextEditingController _chatController = TextEditingController();

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Deep navy
      body: Row(
        children: [
          // Left Sidebar
          _buildLeftSidebar(),

          // Main Workspace Area
          Expanded(
            child: Column(
              children: [
                // Top Toolbar
                _buildTopToolbar(),

                // Center Split Panels: Whiteboard + Code Editor
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: _buildWorkspacePanels(),
                  ),
                ),

                // Bottom Collaboration & Chat Bar
                _buildBottomCollabBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftSidebar() {
    return Container(
      width: 220,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(
          right: BorderSide(color: Color(0xFF1E293B), width: 1.2),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PairSpaceLogo(size: 26, fontSize: 18, isDark: true),
          const SizedBox(height: 20),

          // Room Code tag & Connection indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Room: ${widget.roomCode}',
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Connection status pill
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isConnected ? const Color(0xFF10B981) : Colors.amber,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                widget.isConnected ? 'Connected' : 'Connecting...',
                style: TextStyle(
                  fontSize: 11,
                  color: widget.isConnected ? const Color(0xFF10B981) : Colors.amber,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Navigation Items
          _sidebarNavItem(0, Icons.brush_outlined, 'Whiteboard'),
          _sidebarNavItem(1, Icons.code_rounded, 'Code Editor'),
          _sidebarNavItem(
            2,
            Icons.people_outline_rounded,
            'Participants',
            badge: widget.participantsCount.toString(),
          ),
          _sidebarNavItem(3, Icons.settings_outlined, 'Settings'),

          const Spacer(),

          // Leave Room button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFEF4444)),
                backgroundColor: const Color(0xFF1E293B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: widget.onLeaveRoom,
              icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 16),
              label: const Text(
                'Leave Room',
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarNavItem(int index, IconData icon, String label, {String? badge}) {
    final active = _activeNavIndex == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF4F46E5) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        onTap: () => setState(() => _activeNavIndex = index),
        leading: Icon(
          icon,
          color: active ? Colors.white : const Color(0xFF94A3B8),
          size: 18,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : const Color(0xFF94A3B8),
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
        trailing: badge != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF334155),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }

  Widget _buildTopToolbar() {
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
          _topPill('Whiteboard', _whiteboardTabActive, () {
            setState(() => _whiteboardTabActive = !_whiteboardTabActive);
          }),
          const SizedBox(width: 8),
          _topPill('Code Editor', _codeEditorTabActive, () {
            setState(() => _codeEditorTabActive = !_codeEditorTabActive);
          }),

          const Spacer(),

          // Session Timer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              children: [
                Icon(Icons.timer_outlined, size: 14, color: Color(0xFF94A3B8)),
                SizedBox(width: 6),
                Text(
                  '00:32:45',
                  style: TextStyle(
                    color: Color(0xFFE2E8F0),
                    fontSize: 12,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Avatars Stack
          Row(
            children: [
              _avatarBadge(Colors.indigo, 'You'),
              const SizedBox(width: 4),
              _avatarBadge(Colors.purple, 'Alex'),
            ],
          ),
          const SizedBox(width: 14),

          // Camera / Mic Controls
          IconButton(
            icon: const Icon(Icons.mic_none_rounded, color: Color(0xFF94A3B8), size: 18),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.videocam_outlined, color: Color(0xFF94A3B8), size: 18),
            onPressed: () {},
          ),
          const SizedBox(width: 8),

          // Share Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onPressed: () {},
            icon: const Icon(Icons.share_outlined, size: 14),
            label: const Text('Share', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _topPill(String title, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF4F46E5) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }

  static Widget _avatarBadge(Color color, String name) {
    return CircleAvatar(
      radius: 13,
      backgroundColor: color,
      child: Text(
        name[0],
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildWorkspacePanels() {
    return Row(
      children: [
        // Left Whiteboard Panel
        if (_whiteboardTabActive)
          Expanded(
            flex: 5,
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: widget.whiteboardWidget ?? _buildInteractiveWhiteboardMock(),
              ),
            ),
          ),

        // Right Code Editor Panel
        if (_codeEditorTabActive)
          Expanded(
            flex: 5,
            child: Container(
              margin: const EdgeInsets.only(left: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: widget.codeEditorWidget ?? _buildInteractiveCodeEditorMock(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInteractiveWhiteboardMock() {
    return Column(
      children: [
        // Canvas Toolbar
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Row(
            children: [
              _toolIcon(Icons.near_me_outlined, isActive: true),
              _toolIcon(Icons.edit_outlined),
              _toolIcon(Icons.horizontal_rule_rounded),
              _toolIcon(Icons.arrow_right_alt_rounded),
              _toolIcon(Icons.crop_square_rounded),
              _toolIcon(Icons.text_fields_rounded),
              _toolIcon(Icons.auto_fix_normal_outlined),
              const Spacer(),
              const Text('100%', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              const SizedBox(width: 8),
              _toolIcon(Icons.undo_rounded),
              _toolIcon(Icons.redo_rounded),
            ],
          ),
        ),

        // Canvas Area
        Expanded(
          child: Stack(
            children: [
              // Drawings
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'System Design',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _canvasBox('Client\n(Web/Mobile)'),
                        const Icon(Icons.arrow_forward_rounded, size: 20, color: Color(0xFF64748B)),
                        _canvasBox('API\n(Backend)'),
                        const Icon(Icons.arrow_forward_rounded, size: 20, color: Color(0xFF64748B)),
                        Column(
                          children: [
                            _canvasBox('Database\n(PostgreSQL)'),
                            const SizedBox(height: 10),
                            _canvasBox('Cache\n(Redis)'),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Flow:\n1. User sends request\n2. API processes\n3. Store in DB + Cache\n4. Return response',
                      style: TextStyle(fontSize: 12, color: Color(0xFF475569), fontFamily: 'monospace', height: 1.45),
                    ),
                  ],
                ),
              ),

              // Participant cursor badges (You & Alex)
              Positioned(
                left: 140,
                top: 170,
                child: _cursorPill('You', const Color(0xFF8B5CF6)),
              ),
              Positioned(
                left: 230,
                top: 240,
                child: _cursorPill('Alex', const Color(0xFF10B981)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _cursorPill(String name, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.near_me, size: 14, color: color),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
          child: Text(
            name,
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _canvasBox(String text) {
    return Container(
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF6366F1), width: 1.4),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
      ),
    );
  }

  static Widget _toolIcon(IconData icon, {bool isActive = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFEEF2FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, size: 16, color: isActive ? const Color(0xFF4F46E5) : const Color(0xFF64748B)),
    );
  }

  Widget _buildInteractiveCodeEditorMock() {
    return Column(
      children: [
        // Editor Tab bar
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          color: const Color(0xFF1E293B),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: const BoxDecoration(
                  color: Color(0xFF0F172A),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
                ),
                child: const Row(
                  children: [
                    Text('main.dart', style: TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'monospace')),
                    SizedBox(width: 8),
                    Icon(Icons.close, size: 12, color: Color(0xFF94A3B8)),
                  ],
                ),
              ),
              const Spacer(),
              const Text('Dart', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
              const Icon(Icons.arrow_drop_down, color: Color(0xFF94A3B8), size: 16),
            ],
          ),
        ),

        // Editor Code Area
        const Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('1   class Solution {', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontFamily: 'monospace')),
                Text('2     int twoSum(List<int> nums, int target) {', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 12, fontFamily: 'monospace')),
                Text('3       Map<int, int> map = {};', style: TextStyle(color: Color(0xFFA78BFA), fontSize: 12, fontFamily: 'monospace')),
                Text('4       for (int i = 0; i < nums.length; i++) {', style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 12, fontFamily: 'monospace')),
                Text('5         int complement = target - nums[i];', style: TextStyle(color: Color(0xFFF472B6), fontSize: 12, fontFamily: 'monospace')),
                Text('6         if (map.containsKey(complement)) {', style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 12, fontFamily: 'monospace')),
                Text('7           return [map[complement]!, i];', style: TextStyle(color: Color(0xFF34D399), fontSize: 12, fontFamily: 'monospace')),
                Text('8         }', style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 12, fontFamily: 'monospace')),
                Text('9         map[nums[i]] = i;', style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 12, fontFamily: 'monospace')),
                Text('10      }', style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 12, fontFamily: 'monospace')),
                Text('11      return [];', style: TextStyle(color: Color(0xFF34D399), fontSize: 12, fontFamily: 'monospace')),
                Text('12    }', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontFamily: 'monospace')),
                Text('13  }', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontFamily: 'monospace')),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomCollabBar() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(
          top: BorderSide(color: Color(0xFF1E293B), width: 1.2),
        ),
      ),
      child: Row(
        children: [
          // Participants indicators
          const Text('Participants', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
          const SizedBox(width: 10),
          _miniParticipantPill('You', 'Host', const Color(0xFF6366F1)),
          const SizedBox(width: 8),
          _miniParticipantPill('Alex', 'Candidate', const Color(0xFF10B981)),

          const Spacer(),

          // Chat message input
          SizedBox(
            width: 320,
            height: 32,
            child: TextField(
              controller: _chatController,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send_rounded, size: 14, color: Color(0xFF6366F1)),
                  onPressed: () => _chatController.clear(),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniParticipantPill(String name, String role, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 4, backgroundColor: color),
          const SizedBox(width: 6),
          Text(name, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          Text(role, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9)),
        ],
      ),
    );
  }
}
