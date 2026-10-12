import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../client.dart';
import '../widgets/pairspace_logo.dart';

class SignInScreen extends StatefulWidget {
  final Widget child;
  final VoidCallback? onBackToLanding;

  const SignInScreen({
    super.key,
    required this.child,
    this.onBackToLanding,
  });

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _isSignedIn = false;

  @override
  void initState() {
    super.initState();
    try {
      client.auth.authInfoListenable.addListener(_updateSignedInState);
      _isSignedIn = client.auth.isAuthenticated;
    } catch (_) {}
  }

  @override
  void dispose() {
    try {
      client.auth.authInfoListenable.removeListener(_updateSignedInState);
    } catch (_) {}
    super.dispose();
  }

  void _updateSignedInState() {
    if (!mounted) return;
    setState(() {
      _isSignedIn = client.auth.isAuthenticated;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isSignedIn) {
      return widget.child;
    }

    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 900;

    return Scaffold(
      backgroundColor: Colors.white,
      body: isDesktop ? _buildDesktopSplit() : _buildMobileLayout(),
    );
  }

  Widget _buildDesktopSplit() {
    return Row(
      children: [
        Expanded(
          flex: 6,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 72, vertical: 48),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: _buildLoginForm(),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: Container(
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF5F3FF), Color(0xFFEDE9FE)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: const EdgeInsets.all(56),
            child: _buildRightPromoPanel(),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: _buildLoginForm(),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            if (widget.onBackToLanding != null) ...[
              IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFF64748B),
                  size: 20,
                ),
                onPressed: widget.onBackToLanding,
              ),
              const SizedBox(width: 4),
            ],
            const PairSpaceLogo(size: 32, fontSize: 20),
          ],
        ),
        const SizedBox(height: 36),
        const Text(
          'Welcome to PairSpace',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Sign in or create your account',
          style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 28),
        SignInWidget(
          client: client,
          onAuthenticated: _updateSignedInState,
          onError: (error) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Authentication failed: $error'),
                backgroundColor: const Color(0xFFEF4444),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRightPromoPanel() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Build • Practice • Grow',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Collaborate with peers, get real-time feedback,\nand ace your technical interviews.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 48),
          Container(
            width: 320,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 28,
                  bottom: 24,
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 22,
                        backgroundColor: Color(0xFF6366F1),
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 50,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.code_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                Positioned(
                  right: 28,
                  bottom: 24,
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 22,
                        backgroundColor: Color(0xFF3B82F6),
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 50,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
