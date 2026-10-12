import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/pairspace_logo.dart';

class SessionRecapScreen extends StatefulWidget {
  final String roomCode;
  final String duration;
  final int participantsCount;
  final int codeEditsCount;
  final int whiteboardActionsCount;
  final VoidCallback? onDownload;
  final VoidCallback? onShare;
  final VoidCallback? onBackToHome;
  final String? codeSnippet;
  final Widget? whiteboardPreview;

  const SessionRecapScreen({
    super.key,
    this.roomCode = 'ABC123',
    this.duration = '45:00',
    this.participantsCount = 2,
    this.codeEditsCount = 8,
    this.whiteboardActionsCount = 6,
    this.onDownload,
    this.onShare,
    this.onBackToHome,
    this.codeSnippet,
    this.whiteboardPreview,
  });

  @override
  State<SessionRecapScreen> createState() => _SessionRecapScreenState();
}

class _SessionRecapScreenState extends State<SessionRecapScreen> {
  int _activeTab = 0; // 0: Summary, 1: Whiteboard, 2: Code, 3: Participants

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Deep navy background
      body: Row(
        children: [
          // Left Sidebar
          _buildRecapSidebar(context),

          // Main White/Light Container Card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 16, bottom: 16, right: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      _buildHeader(),
                      const SizedBox(height: 28),

                      // Content depends on active tab
                      if (_activeTab == 0) ...[
                        _buildStatsRow(),
                        const SizedBox(height: 32),
                        _buildPreviewsSection(),
                        const SizedBox(height: 28),
                        _buildCompletionBadge(),
                      ] else if (_activeTab == 1) ...[
                        _buildExpandedWhiteboardView(),
                      ] else if (_activeTab == 2) ...[
                        _buildExpandedCodeView(),
                      ] else ...[
                        _buildExpandedParticipantsView(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecapSidebar(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PairSpaceLogo(size: 26, fontSize: 18, isDark: true),
          const SizedBox(height: 20),

          // Room Code Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF334155)),
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
          const SizedBox(height: 28),

          // Sidebar Nav Items
          _sidebarItem(0, Icons.summarize_outlined, 'Summary'),
          _sidebarItem(1, Icons.brush_outlined, 'Whiteboard'),
          _sidebarItem(2, Icons.code_rounded, 'Code'),
          _sidebarItem(3, Icons.people_outline_rounded, 'Participants'),

          const Spacer(),

          // Back to Dashboard Button
          if (widget.onBackToHome != null) ...[
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF94A3B8),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onPressed: widget.onBackToHome,
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: const Text('Back to Home', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Download Action Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF334155)),
                backgroundColor: const Color(0xFF1E293B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                if (widget.onDownload != null) {
                  widget.onDownload!();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Session summary report downloaded.'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.download_rounded, color: Colors.white, size: 16),
              label: const Text(
                'Download',
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem(int index, IconData icon, String label) {
    final isActive = _activeTab == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF4F46E5) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        onTap: () => setState(() => _activeTab = index),
        leading: Icon(
          icon,
          color: isActive ? Colors.white : const Color(0xFF94A3B8),
          size: 18,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF94A3B8),
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _activeTab == 0
                  ? 'Session Recap'
                  : _activeTab == 1
                      ? 'Whiteboard Review'
                      : _activeTab == 2
                          ? 'Code Solution Review'
                          : 'Participants & Focus Signals',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _activeTab == 0
                  ? "Here's what you worked on during this interview."
                  : _activeTab == 1
                      ? 'Inspect the architecture diagram and whiteboard strokes.'
                      : _activeTab == 2
                          ? 'Review the code submitted during the collaborative session.'
                          : 'Review participant activity and integrity signals recorded.',
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Duration: ${widget.duration}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF475569),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              onPressed: () {
                if (widget.onShare != null) {
                  widget.onShare!();
                } else {
                  Clipboard.setData(ClipboardData(text: 'Session Recap: ${widget.roomCode}'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Recap link copied to clipboard!')),
                  );
                }
              },
              icon: const Icon(Icons.share_outlined, size: 15),
              label: const Text('Share', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: Icons.timer_outlined,
            iconColor: const Color(0xFF4F46E5),
            iconBg: const Color(0xFFEEF2FF),
            value: widget.duration,
            label: 'Total Duration',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _statCard(
            icon: Icons.people_outline_rounded,
            iconColor: const Color(0xFF0284C7),
            iconBg: const Color(0xFFE0F2FE),
            value: widget.participantsCount.toString(),
            label: 'Participants',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _statCard(
            icon: Icons.code_rounded,
            iconColor: const Color(0xFF7C3AED),
            iconBg: const Color(0xFFF3E8FF),
            value: widget.codeEditsCount.toString(),
            label: 'Code Edits',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _statCard(
            icon: Icons.edit_outlined,
            iconColor: const Color(0xFFD946EF),
            iconBg: const Color(0xFFFDF4FF),
            value: widget.whiteboardActionsCount.toString(),
            label: 'Whiteboard Actions',
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewsSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Final Whiteboard Preview
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.brush_outlined, size: 16, color: Color(0xFF4F46E5)),
                  const SizedBox(width: 8),
                  const Text(
                    'Whiteboard',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => setState(() => _activeTab = 1),
                    child: const Text('View Full  →', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                height: 280,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: widget.whiteboardPreview ?? _defaultWhiteboardMockup(),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),

        // Final Code Preview
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.code_rounded, size: 16, color: Color(0xFF4F46E5)),
                  const SizedBox(width: 8),
                  const Text(
                    'Code',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => setState(() => _activeTab = 2),
                    child: const Text('View Full  →', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                height: 280,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    children: [
                      Container(
                        height: 32,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        color: const Color(0xFF1E293B),
                        child: const Row(
                          children: [
                            Text(
                              'solution.py',
                              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontFamily: 'monospace'),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(14),
                          child: Text(
                            widget.codeSnippet ?? _defaultCode(),
                            style: const TextStyle(
                              color: Color(0xFF38BDF8),
                              fontSize: 11,
                              fontFamily: 'monospace',
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedWhiteboardView() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.brush, color: Color(0xFF4F46E5), size: 18),
              const SizedBox(width: 8),
              const Text(
                'High-Resolution Whiteboard Diagram',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${widget.whiteboardActionsCount} drawing actions recorded',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _defaultWhiteboardMockup(),
        ],
      ),
    );
  }

  Widget _buildExpandedCodeView() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const Icon(Icons.code, color: Color(0xFF818CF8), size: 18),
                const SizedBox(width: 8),
                const Text(
                  'solution.py — Submitted Code',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Copy Code',
                  icon: const Icon(Icons.copy_rounded, color: Colors.white, size: 16),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: widget.codeSnippet ?? _defaultCode()));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Code copied to clipboard!')),
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SelectableText(
              widget.codeSnippet ?? _defaultCode(),
              style: const TextStyle(
                color: Color(0xFFE2E8F0),
                fontSize: 13,
                fontFamily: 'monospace',
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedParticipantsView() {
    return Column(
      children: [
        _participantTile('Interviewer', 'Host / Caller', '45:00 active', const Color(0xFF6366F1)),
        const SizedBox(height: 12),
        _participantTile('Candidate', 'Joined via invite code', '44:12 active', const Color(0xFF10B981)),
      ],
    );
  }

  Widget _participantTile(String name, String role, String time, Color avatarColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: avatarColor,
            radius: 20,
            child: Text(name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
              const SizedBox(height: 2),
              Text(role, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(time, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
          ),
        ],
      ),
    );
  }

  static String _defaultCode() {
    return 'def two_sum(nums: list[int], target: int) -> list[int]:\n'
        '    seen = {}\n'
        '    for i, num in enumerate(nums):\n'
        '        complement = target - num\n'
        '        if complement in seen:\n'
        '            return [seen[complement], i]\n'
        '        seen[num] = i\n'
        '    return []\n';
  }

  Widget _defaultWhiteboardMockup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'System Design Architecture',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _diagramBox('Client\n(Web/Flutter)'),
            const Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFF94A3B8)),
            _diagramBox('API Gateway\n(Serverpod)'),
            const Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFF94A3B8)),
            Column(
              children: [
                _diagramBox('Database\n(PostgreSQL)'),
                const SizedBox(height: 8),
                _diagramBox('Media Relays\n(WebRTC)'),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Flow:\n1. Client requests interview session token\n2. Serverpod validates credentials & emits room stream\n3. WebRTC negotiates peer connection for audio/video\n4. Synchronized Monaco and canvas state persisted',
          style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontFamily: 'monospace', height: 1.45),
        ),
      ],
    );
  }

  Widget _diagramBox(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF6366F1), width: 1.4),
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
      ),
    );
  }

  Widget _buildCompletionBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E7FF)),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle_rounded, color: Color(0xFF4F46E5), size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Session completed successfully! All code edits, whiteboard drawings, and session telemetry have been saved.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4338CA),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
