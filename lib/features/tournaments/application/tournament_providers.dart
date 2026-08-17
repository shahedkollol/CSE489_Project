import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';
import '../data/tournament_repository.dart';
import '../domain/tournament.dart';

final tournamentRepositoryProvider = Provider<TournamentRepository>((ref) {
  return TournamentRepository(ref.watch(firestoreProvider));
});

/// All tournaments this admin can see. Every tournament is publicly
/// readable per firestore.rules, so this list isn't scoped further yet -
/// multi-admin ownership (only show tournaments *you* direct) is a
/// reasonable next refinement once the users collection tracks that.
final tournamentListProvider = StreamProvider<List<Tournament>>((ref) {
  return ref.watch(tournamentRepositoryProvider).watchAll();
});

/// A single tournament, kept live. Every tournament-scoped feature we
/// build next (participants, draw, motions...) will read the id from the
/// route and pull the tournament via this same family provider.
final tournamentByIdProvider = StreamProvider.family<Tournament?, String>((ref, id) {
  return ref.watch(tournamentRepositoryProvider).watchById(id);
});
