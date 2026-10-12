import 'package:flutter/material.dart';
import '../widgets/pairspace_logo.dart';

class LandingScreen extends StatefulWidget {
  final VoidCallback onSignIn;
  final VoidCallback onGetStarted;
  final VoidCallback onCreateRoom;
  final VoidCallback onJoinRoom;

  const LandingScreen({
    super.key,
    required this.onSignIn,
    required this.onGetStarted,
    required this.onCreateRoom,
    required this.onJoinRoom,
  });

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToFeatures() {
    _scrollController.animateTo(
      600,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF334155)),
        ),
        title: const Row(
          children: [
            PairSpaceLogo(size: 24, fontSize: 18, isDark: true),
            SizedBox(width: 10),
            Text('About PairSpace', style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PairSpace is an enterprise-grade collaborative interview suite.',
              style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 13, height: 1.5),
            ),
            SizedBox(height: 12),
            Text('• High-Performance Serverpod Backend', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
            Text('• Real-time WebRTC Audio & Video Calls', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
            Text('• Synchronized VS Code (Monaco) Editor', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
            Text('• Vector Whiteboard & Architecture Canvas', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
            Text('• Anti-Cheating & Integrity Focus Radar', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
          ],
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF4F46E5)),
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 960;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1D), // Dark navy space background
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.4, -0.2),
              radius: 1.4,
              colors: [
                Color(0xFF131D3B), // subtle blue-indigo glow
                Color(0xFF0A0F1D),
              ],
            ),
          ),
          child: Column(
            children: [
              // 1. Top Dark Navigation Bar
              _buildNavbar(context, isDesktop),

              // 2. Hero Section (Left copy, Right large 3D perspective preview)
              _buildHero(context, isDesktop),

              const SizedBox(height: 30),

              // 3. Feature Highlights Bar at the bottom
              _buildFeatureHighlights(context, isDesktop),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavbar(BuildContext context, bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 24,
        vertical: 24,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const PairSpaceLogo(size: 32, fontSize: 20, isDark: true),
          if (isDesktop)
            Row(
              children: [
                _navItem('Home', isActive: true, onTap: () {
                  _scrollController.animateTo(0, duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
                }),
                _navItem('Features', onTap: _scrollToFeatures),
                _navItem('About', onTap: () => _showAboutDialog(context)),
              ],
            ),
          Row(
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFE2E8F0),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Color(0xFF334155)),
                  ),
                ),
                onPressed: widget.onSignIn,
                child: const Text('Sign In', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: widget.onGetStarted,
                  child: const Text('Get Started', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navItem(String title, {bool isActive = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: isActive ? Colors.white : const Color(0xFF94A3B8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF94A3B8),
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context, bool isDesktop) {
    if (isDesktop) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 32),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left Content
            Expanded(
              flex: 5,
              child: _buildHeroLeftContent(),
            ),
            const SizedBox(width: 48),
            // Right 3D Perspective Curved Workspace Mockup
            Expanded(
              flex: 6,
              child: _buildHeroPreviewImage(),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          children: [
            _buildHeroLeftContent(),
            const SizedBox(height: 40),
            _buildHeroPreviewImage(),
          ],
        ),
      );
    }
  }

  Widget _buildHeroLeftContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Headline: "Better Interviews.\nTogether."
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 54,
              fontWeight: FontWeight.w800,
              height: 1.12,
              letterSpacing: -1.5,
              color: Colors.white,
            ),
            children: [
              TextSpan(text: 'Better Interviews.\n'),
              TextSpan(
                text: 'Together.',
                style: TextStyle(color: Color(0xFF818CF8)), // Violet-indigo accent
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Subtitle
        const Text(
          'PairSpace is a collaborative technical interview platform where you can code, whiteboard, and solve problems together in real time.',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF94A3B8),
            height: 1.55,
          ),
        ),
        const SizedBox(height: 36),

        // Action Buttons: "Create a Room ->" and "Join a Room"
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF7C3AED)],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: widget.onCreateRoom,
                child: const Text(
                  'Create a Room  →',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 16),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF334155), width: 1.2),
                backgroundColor: const Color(0xFF131D33).withValues(alpha: 0.6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: widget.onJoinRoom,
              child: const Text(
                'Join a Room',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroPreviewImage() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withValues(alpha: 0.25),
              blurRadius: 50,
              spreadRadius: 4,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 400,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              border: Border.all(color: const Color(0xFF334155), width: 1.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                // Workspace mockup top header
                Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  color: const Color(0xFF1E293B),
                  child: Row(
                    children: [
                      const PairSpaceLogo(size: 20, fontSize: 13, isDark: true),
                      const SizedBox(width: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('Room: ABC123', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
                      ),
                      const Spacer(),
                      // Avatars
                      const Row(
                        children: [
                          CircleAvatar(radius: 10, backgroundColor: Colors.indigo, child: Text('Y', style: TextStyle(fontSize: 9, color: Colors.white))),
                          SizedBox(width: 3),
                          CircleAvatar(radius: 10, backgroundColor: Colors.purple, child: Text('A', style: TextStyle(fontSize: 9, color: Colors.white))),
                        ],
                      ),
                    ],
                  ),
                ),
                // Split Mockup: Left Editor, Right Whiteboard
                Expanded(
                  child: Row(
                    children: [
                      // Dark Monaco Editor
                      Expanded(
                        flex: 6,
                        child: Container(
                          color: const Color(0xFF0F172A),
                          padding: const EdgeInsets.all(16),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('1  class Solution {', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontFamily: 'monospace')),
                              Text('2    int twoSum(List<int> nums, int target) {', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 11, fontFamily: 'monospace')),
                              Text('3      Map<int, int> map = {};', style: TextStyle(color: Color(0xFFA78BFA), fontSize: 11, fontFamily: 'monospace')),
                              Text('4      for (int i = 0; i < nums.length; i++) {', style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 11, fontFamily: 'monospace')),
                              Text('5        int comp = target - nums[i];', style: TextStyle(color: Color(0xFFF472B6), fontSize: 11, fontFamily: 'monospace')),
                              Text('6        if (map.containsKey(comp)) {', style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 11, fontFamily: 'monospace')),
                              Text('7          return [map[comp]!, i];', style: TextStyle(color: Color(0xFF34D399), fontSize: 11, fontFamily: 'monospace')),
                              Text('8        }', style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 11, fontFamily: 'monospace')),
                              Text('9        map[nums[i]] = i;', style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 11, fontFamily: 'monospace')),
                              Text('10     }', style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 11, fontFamily: 'monospace')),
                              Text('11     return [];', style: TextStyle(color: Color(0xFF34D399), fontSize: 11, fontFamily: 'monospace')),
                              Text('12   }', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontFamily: 'monospace')),
                              Text('13 }', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontFamily: 'monospace')),
                            ],
                          ),
                        ),
                      ),
                      // Divider
                      Container(width: 1.5, color: const Color(0xFF334155)),
                      // Whiteboard Canvas
                      Expanded(
                        flex: 5,
                        child: Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _box('Client\n(Web/Mobile)'),
                                  const Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF64748B)),
                                  _box('API\n(Backend)'),
                                  const Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF64748B)),
                                  Column(
                                    children: [
                                      _box('Database'),
                                      const SizedBox(height: 4),
                                      _box('Cache'),
                                    ],
                                  ),
                                ],
                              ),
                              const Spacer(),
                              const Text(
                                'Flow:\n1. User sends request\n2. API processes\n3. Store in DB + Cache\n4. Return response',
                                style: TextStyle(fontSize: 9.5, color: Color(0xFF475569), fontFamily: 'monospace', height: 1.35),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _box(String text) {
    return Container(
      margin: const EdgeInsets.all(3),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF6366F1), width: 1.2),
      ),
      child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
    );
  }

  Widget _buildFeatureHighlights(BuildContext context, bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 64 : 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _featurePill(Icons.edit_calendar_outlined, 'Real-time Collaboration', 'Code & whiteboard together'),
          _featurePill(Icons.shield_outlined, 'Secure & Reliable', 'Built with Serverpod'),
          _featurePill(Icons.devices_outlined, 'Works Everywhere', 'Web, Desktop, Mobile'),
        ],
      ),
    );
  }

  Widget _featurePill(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF131D33),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Icon(icon, color: const Color(0xFF818CF8), size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
          ],
        ),
      ],
    );
  }
}
