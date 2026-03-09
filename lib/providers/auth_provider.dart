// This is the state management layer for authentication.
// It uses the Provider package to expose auth state to the entire widget tree.
// The UI listens to this provider — it never calls AuthService directly.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // State variables
  User? _firebaseUser; // Raw Firebase user object
  UserModel? _userProfile; // Our custom user profile from Firestore
  bool _isLoading = false;
  String? _errorMessage;

  // Public getters — widgets read these to build their UI
  User? get firebaseUser => _firebaseUser;
  UserModel? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _firebaseUser != null;
  bool get isEmailVerified => _firebaseUser?.emailVerified ?? false;

  AuthProvider() {
    // Listen to Firebase auth state changes.
    // When user logs in or out, we update our state automatically.
    _authService.authStateChanges.listen((User? user) async {
      _firebaseUser = user;
      if (user != null) {
        // Reload to get the latest email verification status
        await user.reload();
        _firebaseUser = _authService.currentUser;
        // Fetch the user profile from Firestore
        _userProfile = await _authService.getUserProfile(user.uid);
      } else {
        _userProfile = null;
      }
      notifyListeners(); // Tell all listening widgets to rebuild
    });
  }

  /// Call this to sign up a new user.
  /// Sets loading/error states so the UI can show a spinner or error message.
  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getReadableError(e.code);
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  /// Call this to sign in an existing user.
  Future<void> signIn({required String email, required String password}) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authService.signIn(email: email, password: password);
      // Reload to check if email is verified
      await _firebaseUser?.reload();
      _firebaseUser = _authService.currentUser;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getReadableError(e.code);
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await _authService.signOut();
  }

  /// Toggle notifications preference and save it to Firestore.
  Future<void> toggleNotifications(bool value) async {
    if (_userProfile == null) return;
    _userProfile = _userProfile!.copyWith(notificationsEnabled: value);
    notifyListeners();
    await _authService.updateNotificationPreference(_userProfile!.uid, value);
  }

  // Private helpers
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Convert Firebase error codes to user-friendly messages
  String _getReadableError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Authentication error: $code';
    }
  }
}
