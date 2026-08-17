import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/loading_view.dart';
import '../../auth/application/auth_providers.dart';
import '../application/tournament_providers.dart';
import '../domain/tournament.dart';

/// Lands here for role == UserRole.admin. Real Tabbycat installs run many
/// tournaments from one instance, so this is a picker, not a single
/// tournament's settings page.
class TournamentListPage extends ConsumerWidget {
  const TournamentListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournamentsAsync = ref.watch(tournamentListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tournaments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/admin/tournaments/new'),
        icon: const Icon(Icons.add),
        label: const Text('New tournament'),
      ),
      body: tournamentsAsync.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(message: 'Could not load tournaments.\n$error'),
        data: (tournaments) {
          if (tournaments.isEmpty) {
            return const Center(
              child: Text('No tournaments yet. Create one to get started.'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            itemCount: tournaments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final tournament = tournaments[index];
              return Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  title: Text(tournament.name),
                  subtitle: Text(tournament.slug),
                  trailing: Chip(label: Text(tournament.format.short)),
                  onTap: () => context.go('/admin/tournaments/${tournament.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
