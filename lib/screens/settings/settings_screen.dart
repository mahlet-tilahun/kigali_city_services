// lib/screens/settings/settings_screen.dart
// Displays the user's profile information from Firestore.
// Includes a toggle for notification preferences (stored in Firestore).
// Has a logout button.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.userProfile;
    final firebaseUser = authProvider.firebaseUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: const Color(0xFF1A2B4A),
                      child: Text(
                        (user?.displayName ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? 'User',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          firebaseUser?.email ?? '',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              firebaseUser?.emailVerified == true
                                  ? Icons.verified
                                  : Icons.warning,
                              size: 14,
                              color: firebaseUser?.emailVerified == true
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              firebaseUser?.emailVerified == true
                                  ? 'Email Verified'
                                  : 'Email Not Verified',
                              style: TextStyle(
                                fontSize: 12,
                                color: firebaseUser?.emailVerified == true
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Preferences section
            const Text(
              'Preferences',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Card(
              child: SwitchListTile(
                title: const Text('Location Notifications'),
                subtitle: const Text('Get notified about services near you'),
                value: user?.notificationsEnabled ?? false,
                onChanged: (val) => authProvider.toggleNotifications(val),
                secondary: const Icon(Icons.notifications),
                activeThumbColor: Colors.amber,
              ),
            ),
            const SizedBox(height: 8),

            // Show notification status (local simulation)
            if (user?.notificationsEnabled == true)
              Card(
                color: Colors.amber.shade50,
                child: const ListTile(
                  leading: Icon(Icons.info_outline, color: Colors.amber),
                  title: Text('Notifications are enabled'),
                  subtitle: Text('You will be notified about nearby services.'),
                ),
              ),

            const Spacer(),

            // Logout button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () => authProvider.signOut(),
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Log Out',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
