import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';
import '../data/venue_repository.dart';
import '../domain/venue.dart';

final venueRepositoryProvider = Provider.family<VenueRepository, String>((ref, tournamentId) {
  return VenueRepository(ref.watch(firestoreProvider), tournamentId);
});

final venueListProvider = StreamProvider.family<List<Venue>, String>((ref, tournamentId) {
  return ref.watch(venueRepositoryProvider(tournamentId)).watchAll();
});
