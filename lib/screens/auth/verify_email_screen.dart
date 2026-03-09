// lib/screens/auth/verify_email_screen.dart
// Shown after signup when email is not yet verified.
// Polls Firebase every 3 seconds to check if the user has verified their email.
// Once verified, AuthWrapper automatically routes to MainScreen.

// lib/screens/auth/verify_email_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  Timer? _timer;
  bool _resendEnabled = true;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) async {
      final authProvider = context.read<AuthProvider>();
      await authProvider.firebaseUser?.reload();
      // Force the provider to notify so AuthWrapper rebuilds
      await authProvider.checkEmailVerified();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Manually resend verification email
  Future<void> _resendEmail() async {
    setState(() => _resendEnabled = false);
    try {
      await context.read<AuthProvider>().firebaseUser?.sendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Verification email sent! Check your inbox and spam folder.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending email: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    // Wait 30 seconds before allowing resend again
    await Future.delayed(const Duration(seconds: 30));
    if (mounted) setState(() => _resendEnabled = true);
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
                  'We sent a verification link to:\n$email\n\nPlease check your inbox AND your spam/junk folder.',
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

                // Resend button
                // Manual continue button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await context.read<AuthProvider>().checkEmailVerified();
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('I have verified — Continue'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Resend button
                ElevatedButton.icon(
                  onPressed: _resendEnabled ? _resendEmail : null,
                  icon: const Icon(Icons.send),
                  label: Text(
                    _resendEnabled
                        ? 'Resend Verification Email'
                        : 'Wait 30 seconds...',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
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
