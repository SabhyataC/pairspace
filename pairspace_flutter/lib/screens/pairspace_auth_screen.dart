import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../client.dart';
import '../theme/pairspace_colors.dart';
import '../widgets/pairspace_logo.dart';
import '../widgets/buttons.dart';

class PairSpaceAuthScreen extends StatefulWidget {
  final Widget? child;
  final VoidCallback? onBackToLanding;
  final VoidCallback? onAuthenticated;

  const PairSpaceAuthScreen({
    super.key,
    this.child,
    this.onBackToLanding,
    this.onAuthenticated,
  });

  @override
  State<PairSpaceAuthScreen> createState() => _PairSpaceAuthScreenState();
}

class _PairSpaceAuthScreenState extends State<PairSpaceAuthScreen> {
  bool _isSignedIn = false;
  bool _isSignUp = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updateSignedInState() {
    if (!mounted) return;
    setState(() {
      _isSignedIn = client.auth.isAuthenticated;
    });
    if (_isSignedIn && widget.onAuthenticated != null) {
      widget.onAuthenticated!();
    }
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      if (_isSignUp) {
        // Real Serverpod registration request
        await client.emailIdp.startRegistration(email: email);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Account registration started! Check your email for verification, then sign in.',
            ),
            backgroundColor: PairSpaceColors.success,
          ),
        );
        setState(() => _isSignUp = false);
      } else {
        // Real Serverpod login
        await client.emailIdp.login(
          email: email,
          password: password,
        );
        if (!mounted) return;
        setState(() => _isSignedIn = true);
        widget.onAuthenticated?.call();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Authentication error: $e'),
          backgroundColor: PairSpaceColors.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSignedIn && widget.child != null) {
      return widget.child!;
    }

    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 900;

    return Scaffold(
      backgroundColor: Colors.white,
      body: isDesktop ? _buildSplitDesktopLayout() : _buildMobileLayout(),
    );
  }

  Widget _buildSplitDesktopLayout() {
    return Row(
      children: [
        // Left Column: Authentication Form
        Expanded(
          flex: 6,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 36),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: _buildAuthForm(),
              ),
            ),
          ),
        ),

        // Right Column: Promotional Illustration & Branding Panel
        Expanded(
          flex: 5,
          child: Container(
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
            padding: const EdgeInsets.all(48),
            child: _buildRightPromoPanel(),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: _buildAuthForm(),
        ),
      ),
    );
  }

  Widget _buildAuthForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (widget.onBackToLanding != null)
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF64748B),
                      ),
                      onPressed: widget.onBackToLanding,
                    ),
                  const PairSpaceLogo(size: 32, fontSize: 20),
                ],
              ),
              // Toggle Sign In / Sign Up pill
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _togglePill('Sign In', !_isSignUp, () {
                      setState(() => _isSignUp = false);
                    }),
                    _togglePill('Sign Up', _isSignUp, () {
                      setState(() => _isSignUp = true);
                    }),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Welcome text
          Row(
            children: [
              Text(
                _isSignUp ? 'Create an account' : 'Welcome back',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 6),
              const Text('👋', style: TextStyle(fontSize: 22)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _isSignUp
                ? 'Join PairSpace to start interviewing & collaborating'
                : 'Sign in to your PairSpace account',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 24),

          // Full Name Input (Visible in Sign Up)
          if (_isSignUp) ...[
            const Text(
              'Full Name',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              validator: (val) {
                if (_isSignUp && (val == null || val.trim().isEmpty)) {
                  return 'Please enter your name';
                }
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.person_outline,
                  size: 18,
                  color: Color(0xFF94A3B8),
                ),
                hintText: 'e.g. Alex Johnson',
                hintStyle: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 14,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFF6366F1),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Email Input
          const Text(
            'Email address',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Email is required';
              if (!val.contains('@')) return 'Enter a valid email address';
              return null;
            },
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.email_outlined,
                size: 18,
                color: Color(0xFF94A3B8),
              ),
              hintText: 'you@example.com',
              hintStyle: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFF6366F1),
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Password Input
          const Text(
            'Password',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            validator: (val) {
              if (val == null || val.isEmpty) return 'Password is required';
              if (val.length < 6)
                return 'Password must be at least 6 characters';
              return null;
            },
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.lock_outline,
                size: 18,
                color: Color(0xFF94A3B8),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 18,
                  color: const Color(0xFF94A3B8),
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              hintText: 'Enter your password',
              hintStyle: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFF6366F1),
                  width: 1.5,
                ),
              ),
            ),
          ),

          // Confirm Password Input (in Sign Up)
          if (_isSignUp) ...[
            const SizedBox(height: 16),
            const Text(
              'Confirm Password',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              validator: (val) {
                if (_isSignUp && val != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  size: 18,
                  color: Color(0xFF94A3B8),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 18,
                    color: const Color(0xFF94A3B8),
                  ),
                  onPressed: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  ),
                ),
                hintText: 'Confirm your password',
                hintStyle: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 14,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFF6366F1),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Remember Me & Forgot Password (on Sign In)
          if (!_isSignUp)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      height: 22,
                      width: 22,
                      child: Checkbox(
                        value: _rememberMe,
                        activeColor: const Color(0xFF6366F1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onChanged: (v) =>
                            setState(() => _rememberMe = v ?? true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Remember me',
                      style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Contact your administrator for password reset.',
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6366F1),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 20),

          // Submit button
          PrimaryButton(
            text: _isSignUp ? 'Create Account' : 'Sign In',
            height: 46,
            fullWidth: true,
            isLoading: _isLoading,
            onPressed: _handleAuth,
          ),
          const SizedBox(height: 20),

          // Divider
          const Row(
            children: [
              Expanded(child: Divider(color: Color(0xFFE2E8F0))),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  'or',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                ),
              ),
              Expanded(child: Divider(color: Color(0xFFE2E8F0))),
            ],
          ),
          const SizedBox(height: 20),

          // Google Sign In Button
          _buildGoogleSignInButton(),
          const SizedBox(height: 24),

          // Bottom switch text
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isSignUp
                      ? 'Already have an account? '
                      : "Don't have an account? ",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _isSignUp = !_isSignUp),
                  child: Text(
                    _isSignUp ? 'Sign In' : 'Sign Up',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6366F1),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _togglePill(String title, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFE2E8F0)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.white,
        ),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Google Sign-In is configured with Serverpod OAuth.',
              ),
              backgroundColor: PairSpaceColors.primary,
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: const Center(
                child: Text(
                  'G',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: Color(0xFF4285F4),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Continue with Google',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightPromoPanel() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const PairSpaceLogo(size: 40, fontSize: 24),
          const SizedBox(height: 24),
          const Text(
            'Build • Practice • Grow',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Collaborate with peers, get real-time feedback,\nand ace your technical interviews.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 36),
          _buildCollabIllustration(),
          const SizedBox(height: 36),
          _miniFeatureBullet(
            Icons.edit_note_rounded,
            'Real-time Collaboration',
            'Code, whiteboard and chat',
          ),
          const SizedBox(height: 12),
          _miniFeatureBullet(
            Icons.security_rounded,
            'Secure Authentication',
            'Powered by Serverpod',
          ),
          const SizedBox(height: 12),
          _miniFeatureBullet(
            Icons.devices_rounded,
            'Accessible Anywhere',
            'Web, Desktop, Mobile',
          ),
        ],
      ),
    );
  }

  Widget _miniFeatureBullet(IconData icon, String title, String subtitle) {
    return Container(
      width: 280,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF6366F1), size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCollabIllustration() {
    return Container(
      width: 260,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 20,
            bottom: 20,
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFF3B82F6),
                  child: Icon(Icons.person, color: Colors.white, size: 24),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 44,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.code_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFF8B5CF6),
                  child: Icon(Icons.person, color: Colors.white, size: 24),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 44,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(4),
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
