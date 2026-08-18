import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';
import '../data/draw_repository.dart';
import '../domain/draw_round.dart';

final drawRepositoryProvider = Provider.family<DrawRepository, String>((ref, tournamentId) {
  return DrawRepository(ref.watch(firestoreProvider), tournamentId);
});

final drawListProvider = StreamProvider.family<List<DrawRound>, String>((ref, tournamentId) {
  return ref.watch(drawRepositoryProvider(tournamentId)).watchAll();
});
