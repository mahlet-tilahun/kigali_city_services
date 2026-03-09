// Entry point of the app.
// Sets up Firebase, registers all providers, and decides
// whether to show the login screen or the main app.

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/places_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/verify_email_screen.dart';
import 'screens/main_screen.dart';
import 'firebase_options.dart';

void main() async {
  // Required before calling any Firebase methods
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Register all providers here so any widget in the tree can access them
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PlacesProvider()),
      ],
      child: MaterialApp(
        title: 'Kigali City Services',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1A2B4A), // Dark navy blue
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1A2B4A),
            foregroundColor: Colors.white,
          ),
        ),
        // AuthWrapper decides which screen to show based on auth state
        home: const AuthWrapper(),
      ),
    );
  }
}

/// Listens to the AuthProvider and routes the user appropriately.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isLoggedIn) {
      // Not logged in → show login screen
      return const LoginScreen();
    }

    if (!authProvider.isEmailVerified) {
      // Logged in but email not verified → show verification screen
      return const VerifyEmailScreen();
    }

    // Logged in and verified → start listening to Firestore and show main app
    final placesProvider = context.read<PlacesProvider>();
    placesProvider.startListening(authProvider.firebaseUser!.uid);

    return const MainScreen();
  }
}
