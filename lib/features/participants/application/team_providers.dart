import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';
import '../data/team_repository.dart';
import '../domain/team.dart';

final teamRepositoryProvider = Provider.family<TeamRepository, String>((ref, tournamentId) {
  return TeamRepository(ref.watch(firestoreProvider), tournamentId);
});

final teamListProvider = StreamProvider.family<List<Team>, String>((ref, tournamentId) {
  return ref.watch(teamRepositoryProvider(tournamentId)).watchAll();
});
