import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pairspace_client/pairspace_client.dart';
import '../widgets/pairspace_logo.dart';
import '../widgets/buttons.dart';

class RoomSetupScreen extends StatefulWidget {
  final Future<void> Function(String name, int minutes) onCreateRoom;
  final Future<bool> Function(String code, String name) onJoinRoom;
  final VoidCallback? onBack;
  final Room? myActiveRoom;
  final Future<void> Function()? onRejoinActiveRoom;
  final List<Room> pastRooms;
  final Future<void> Function(int roomId)? onOpenRecap;

  const RoomSetupScreen({
    super.key,
    required this.onCreateRoom,
    required this.onJoinRoom,
    this.onBack,
    this.myActiveRoom,
    this.onRejoinActiveRoom,
    this.pastRooms = const [],
    this.onOpenRecap,
  });

  @override
  State<RoomSetupScreen> createState() => _RoomSetupScreenState();
}

class _RoomSetupScreenState extends State<RoomSetupScreen> {
  bool _isCreateTab = true;
  bool _isInterviewer = true;
  int _durationMinutes = 60;
  bool _isLoading = false;

  final _roomNameController = TextEditingController();
  final _joinCodeController = TextEditingController();
  final _displayNameController = TextEditingController();

  @override
  void dispose() {
    _roomNameController.dispose();
    _joinCodeController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    final name = _displayNameController.text.trim().isEmpty
        ? (_roomNameController.text.trim().isEmpty ? 'Interviewer' : _roomNameController.text.trim())
        : _displayNameController.text.trim();

    setState(() => _isLoading = true);
    try {
      await widget.onCreateRoom(name, _durationMinutes);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleJoin() async {
    final code = _joinCodeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a room code')),
      );
      return;
    }
    final name = _displayNameController.text.trim().isEmpty
        ? 'Candidate'
        : _displayNameController.text.trim();

    setState(() => _isLoading = true);
    try {
      await widget.onJoinRoom(code, name);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar (Clean White)
            _buildHeader(),

            // Expanded Full-Page Content (Uses full screen height and width)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 860),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Page Title & Subheading
                        Text(
                          _isCreateTab ? 'Create or Join a Room' : 'Join an Existing Room',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _isCreateTab
                              ? 'Start a new collaborative interview session or join with a room code.'
                              : 'Enter your invite code to begin the technical evaluation.',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Create / Join Tabs Switcher (Full Width)
                        _buildTabSwitcher(),
                        const SizedBox(height: 36),

                        // Main White Container Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(36),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6366F1).withValues(alpha: 0.05),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: _isCreateTab ? _buildCreateForm() : _buildJoinForm(),
                        ),

                        // Active / Past Meetings Section
                        if (widget.myActiveRoom != null || widget.pastRooms.isNotEmpty) ...[
                          const SizedBox(height: 36),
                          _buildPastRoomsSection(),
                        ],

                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (widget.onBack != null)
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF475569)),
                  onPressed: widget.onBack,
                ),
              const PairSpaceLogo(size: 32, fontSize: 20),
            ],
          ),
          // User avatar
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF6366F1), width: 1.5),
            ),
            child: const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFFEEF2FF),
              child: Icon(Icons.person, color: Color(0xFF6366F1), size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      width: double.infinity,
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _tabButton('Create Room', _isCreateTab, () {
              setState(() => _isCreateTab = true);
            }),
          ),
          Expanded(
            child: _tabButton('Join Room', !_isCreateTab, () {
              setState(() => _isCreateTab = false);
            }),
          ),
        ],
      ),
    );
  }

  Widget _tabButton(String title, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Role',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 16),

        // Role cards: Interviewer and Candidate (Expanded side by side)
        Row(
          children: [
            Expanded(
              child: _roleCard(
                title: 'Interviewer',
                desc: 'Create a room and invite candidates to conduct code and system design interviews.',
                icon: Icons.person_search_rounded,
                selected: _isInterviewer,
                onTap: () => setState(() => _isInterviewer = true),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _roleCard(
                title: 'Candidate',
                desc: 'Join a room as a candidate to demonstrate your problem-solving and coding skills.',
                icon: Icons.badge_outlined,
                selected: !_isInterviewer,
                onTap: () => setState(() => _isInterviewer = false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),

        // Display Name & Room Name in responsive 2-column or 1-column layout
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 600;
            final nameField = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Display Name',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _displayNameController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Alex Johnson',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
                    ),
                  ),
                ),
              ],
            );

            final roomField = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Room Name (Optional)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _roomNameController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Frontend Interview',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    suffixIcon: const Icon(Icons.meeting_room_outlined, size: 20, color: Color(0xFF94A3B8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
                    ),
                  ),
                ),
              ],
            );

            if (isWide) {
              return Row(
                children: [
                  Expanded(child: nameField),
                  const SizedBox(width: 20),
                  Expanded(child: roomField),
                ],
              );
            } else {
              return Column(
                children: [
                  nameField,
                  const SizedBox(height: 18),
                  roomField,
                ],
              );
            }
          },
        ),
        const SizedBox(height: 24),

        // Duration selector
        const Text(
          'Interview Duration',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [15, 30, 45, 60, 90].map((mins) {
            final isSelected = _durationMinutes == mins;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _durationMinutes = mins),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
                      width: isSelected ? 1.6 : 1,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: const Color(0xFF4F46E5).withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        mins >= 60
                            ? '${mins ~/ 60}h${mins % 60 > 0 ? " ${mins % 60}m" : ""}'
                            : '${mins}m',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Session',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white70 : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 36),

        // Create Room Button (Wide Primary Button)
        PrimaryButton(
          text: 'Create Room  →',
          height: 50,
          fullWidth: true,
          isLoading: _isLoading,
          onPressed: _handleCreate,
        ),
        const SizedBox(height: 14),

        const Center(
          child: Text(
            'Your unique room code will be generated and ready to share after creation.',
            style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          ),
        ),
      ],
    );
  }

  Widget _buildJoinForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Display Name',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _displayNameController,
          decoration: InputDecoration(
            hintText: 'e.g. Candidate Name',
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 20),

        const Text(
          'Room Code',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _joinCodeController,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: 'e.g. ABC123',
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            suffixIcon: const Icon(Icons.vpn_key_outlined, size: 20, color: Color(0xFF94A3B8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 32),

        PrimaryButton(
          text: 'Join Room  →',
          height: 50,
          fullWidth: true,
          isLoading: _isLoading,
          onPressed: _handleJoin,
        ),
        const SizedBox(height: 14),

        const Center(
          child: Text(
            'Ensure the interviewer has already started the session before joining.',
            style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          ),
        ),
      ],
    );
  }

  Widget _roleCard({
    required String title,
    required String desc,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEEF2FF) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0),
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? const Color(0xFF6366F1).withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFFE0E7FF) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: selected ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
                    size: 24,
                  ),
                ),
                if (selected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF6366F1),
                    size: 22,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: selected ? const Color(0xFF1E293B) : const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              desc,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPastRoomsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.myActiveRoom != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Active Room: ${widget.myActiveRoom!.code}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: widget.onRejoinActiveRoom,
                  child: const Text('Rejoin Room', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const Divider(height: 28),
          ],
          if (widget.pastRooms.isNotEmpty) ...[
            const Text(
              'Past Meeting History',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 12),
            ...widget.pastRooms.map((r) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: ListTile(
                    dense: true,
                    leading: const Icon(Icons.history, size: 20, color: Color(0xFF6366F1)),
                    title: Text(
                      'Room ${r.code}',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    subtitle: Text(
                      '${r.endedAt?.difference(r.createdAt).inMinutes ?? 0} minutes duration',
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Copy Code',
                          icon: const Icon(Icons.copy_rounded, size: 16, color: Color(0xFF64748B)),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: r.code));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Room code ${r.code} copied!')),
                            );
                          },
                        ),
                        TextButton(
                          onPressed: () {
                            if (r.id != null) widget.onOpenRecap?.call(r.id!);
                          },
                          child: const Text(
                            'View Recap',
                            style: TextStyle(
                              color: Color(0xFF6366F1),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ],
      ),
    );
  }
}
