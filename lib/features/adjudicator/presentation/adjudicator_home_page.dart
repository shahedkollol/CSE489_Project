import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';

/// Landing page for role == UserRole.adjudicator or UserRole.team. Stub:
/// the next build pass replaces this with the My Debates / Ballot Entry /
/// Feedback / Profile bottom-nav shell from the wireframes.
class AdjudicatorHomePage extends ConsumerWidget {
  const AdjudicatorHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentUserProfileProvider).valueOrNull;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My debates'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
      body: Center(
        child: Text('Signed in as ${profile?.displayName ?? profile?.email ?? '...'}'),
      ),
    );
  }
}
