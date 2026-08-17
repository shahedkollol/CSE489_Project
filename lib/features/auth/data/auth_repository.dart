import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../domain/app_user.dart';

/// Thin wrapper around Firebase Auth and the `users/{uid}` Firestore doc.
/// Keeping this as a single repository means the rest of the app never
/// talks to `FirebaseAuth.instance` or `FirebaseFirestore.instance` directly.
class AuthRepository {
  AuthRepository(this._auth, this._firestore);

  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<fb.User?> authStateChanges() => _auth.authStateChanges();

  fb.User? get currentFirebaseUser => _auth.currentUser;

  Future<fb.UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() => _auth.signOut();

  /// One-off fetch, used e.g. right after sign-in.
  Future<AppUser?> fetchUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromFirestore(uid, doc.data()!);
  }

  /// Live stream, used by the router redirect and any screen that needs to
  /// react immediately if an admin changes this user's role.
  Stream<AppUser?> watchUserProfile(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map(
          (doc) => doc.exists ? AppUser.fromFirestore(uid, doc.data()!) : null,
        );
  }
}
