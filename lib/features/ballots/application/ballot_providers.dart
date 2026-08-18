import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';
import '../data/ballot_repository.dart';
import '../domain/ballot_result.dart';

final ballotRepositoryProvider = Provider.family<BallotRepository, String>((ref, tournamentId) {
  return BallotRepository(ref.watch(firestoreProvider), tournamentId);
});

final ballotListProvider = StreamProvider.family<List<BallotResult>, String>((ref, tournamentId) {
  return ref.watch(ballotRepositoryProvider(tournamentId)).watchAll();
});

final publishedBallotListProvider = StreamProvider.family<List<BallotResult>, String>((ref, tournamentId) {
  return ref.watch(ballotRepositoryProvider(tournamentId)).watchPublished();
});
