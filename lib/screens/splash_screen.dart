/*

SPLASH SCREEN - This will show App logo and check for auth.
===========================================================

unauthenticated -> Login Screen
authenticated   -> Notes Screen

*/

import 'package:flutter/material.dart';
import 'package:notes_app_supabase/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // get auth service instance
  final AuthService _authService = AuthService();

  // method - check if user logged in or not
  Future<void> _checkAuth() async {
    // delay 2s to show splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // check if user logged in then navigate appropriate screen
    if (_authService.currentUser != null) {
      // user is logged in
      Navigator.of(context).pushReplacementNamed('/notes');
    } else {
      // if not, navigate to login screen
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // logo
            Icon(Icons.note_alt_outlined, size: 100, color: Colors.grey),

            SizedBox(height: 16),

            // app name
            Text(
              "Notes App",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),

            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
