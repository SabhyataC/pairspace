import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import 'client.dart';
import 'theme/pairspace_colors.dart';
import 'screens/landing_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/room_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await initializeClient();
  } catch (e) {
    debugPrint('Serverpod client initialize warning: $e');
  }
  runApp(const MyApp());
}

ThemeData _buildTheme(Brightness brightness) {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: PairSpaceColors.primary,
      primary: PairSpaceColors.primary,
      brightness: brightness,
    ),
    textTheme: GoogleFonts.interTextTheme(),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _showLanding = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PairSpace — Collaborative Technical Interviews',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: ThemeMode.light,
      home: _showLanding
          ? LandingScreen(
              onSignIn: () => setState(() => _showLanding = false),
              onGetStarted: () => setState(() => _showLanding = false),
              onCreateRoom: () => setState(() => _showLanding = false),
              onJoinRoom: () => setState(() => _showLanding = false),
            )
          : SignInScreen(
              onBackToLanding: () => setState(() => _showLanding = true),
              child: RoomScreen(
                onSignOut: () async {
                  try {
                    await client.auth.signOutDevice();
                  } catch (_) {}
                  if (mounted) {
                    setState(() => _showLanding = true);
                  }
                },
              ),
            ),
    );
  }
}
