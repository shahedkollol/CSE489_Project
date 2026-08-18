import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';
import '../data/motion_repository.dart';
import '../domain/motion.dart';

final motionRepositoryProvider = Provider.family<MotionRepository, String>((ref, tournamentId) {
  return MotionRepository(ref.watch(firestoreProvider), tournamentId);
});

final motionListProvider = StreamProvider.family<List<Motion>, String>((ref, tournamentId) {
  return ref.watch(motionRepositoryProvider(tournamentId)).watchAll();
});
