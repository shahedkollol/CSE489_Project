import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../domain/app_user.dart';

// --- Firebase SDK instances --------------------------------------------

final firebaseAuthProvider = Provider<fb.FirebaseAuth>((ref) {
  return fb.FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// --- Repository -----------------------------------------------------------

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(firebaseAuthProvider), ref.watch(firestoreProvider));
});

// --- Derived auth state -----------------------------------------------

/// Raw Firebase auth state: null when signed out, a User once signed in.
final authStateChangesProvider = StreamProvider<fb.User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

/// The signed-in user's app-level profile (role, tournament, etc.), kept
/// live so a role change by an admin takes effect without a re-login.
/// This is what `app_router.dart` reads to decide where to send someone.
final currentUserProfileProvider = StreamProvider<AppUser?>((ref) {
  final firebaseUser = ref.watch(authStateChangesProvider).valueOrNull;
  if (firebaseUser == null) return Stream.value(null);
  return ref.watch(authRepositoryProvider).watchUserProfile(firebaseUser.uid);
});
