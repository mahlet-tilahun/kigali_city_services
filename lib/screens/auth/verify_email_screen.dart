// lib/screens/auth/verify_email_screen.dart
// Shown after signup when email is not yet verified.
// Polls Firebase every 3 seconds to check if the user has verified their email.
// Once verified, AuthWrapper automatically routes to MainScreen.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Check every 3 seconds if the user has clicked the verification link
    _timer = Timer.periodic(const Duration(seconds: 3), (_) async {
      await context.read<AuthProvider>().firebaseUser?.reload();
      // notifyListeners is called inside AuthProvider via authStateChanges
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final email = authProvider.firebaseUser?.email ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF1A2B4A),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.mark_email_unread,
                  size: 80,
                  color: Colors.amber,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Verify Your Email',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'We sent a verification link to:\n$email\n\nPlease check your inbox and click the link.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 32),
                const CircularProgressIndicator(color: Colors.amber),
                const SizedBox(height: 16),
                const Text(
                  'Waiting for verification...',
                  style: TextStyle(color: Colors.white54),
                ),
                const SizedBox(height: 32),
                TextButton(
                  onPressed: () => authProvider.signOut(),
                  child: const Text(
                    'Use a different account',
                    style: TextStyle(color: Colors.amber),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
