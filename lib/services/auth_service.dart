// lib/services/auth_service.dart
// This service handles all Firebase Authentication operations.
// It is the ONLY file that talks directly to FirebaseAuth.
// The UI never calls Firebase directly — it calls this service.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  // Private instances — only this service touches Firebase directly
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of Firebase auth state changes (logged in / logged out)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // The currently signed-in Firebase user (null if not logged in)
  User? get currentUser => _auth.currentUser;

  /// Sign up a new user with email and password.
  /// Also creates a user profile document in Firestore.
  /// Sends a verification email after registration.
  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    // Step 1: Create account in Firebase Auth
    UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Step 2: Update the display name in Firebase Auth
    await credential.user!.updateDisplayName(displayName);

    // Step 3: Send email verification
    await credential.user!.sendEmailVerification();

    // Step 4: Create a matching profile document in Firestore
    UserModel userProfile = UserModel(
      uid: credential.user!.uid,
      email: email,
      displayName: displayName,
    );
    await _firestore
        .collection('users')
        .doc(credential.user!.uid)
        .set(userProfile.toMap());
  }

  /// Log in an existing user.
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Log out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Check if the current user has verified their email.
  /// We reload the user first to get the latest verification status.
  Future<bool> isEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  /// Fetch the user profile from Firestore.
  Future<UserModel?> getUserProfile(String uid) async {
    DocumentSnapshot doc =
        await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  /// Update the notification preference for a user in Firestore.
  Future<void> updateNotificationPreference(
      String uid, bool enabled) async {
    await _firestore.collection('users').doc(uid).update({
      'notificationsEnabled': enabled,
    });
  }
}
