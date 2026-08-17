import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/loading_view.dart';
import '../application/tournament_providers.dart';
import '../domain/tournament.dart';

/// The shell everything else attaches to. Once participants/draw/motions
/// exist, their tiles below become live links scoped to this tournamentId
/// (e.g. `/admin/tournaments/$tournamentId/participants`) instead of the
/// disabled placeholders they are for now.
class TournamentDashboardPage extends ConsumerWidget {
  const TournamentDashboardPage({super.key, required this.tournamentId});

  final String tournamentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournamentAsync = ref.watch(tournamentByIdProvider(tournamentId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin'),
        ),
        title: tournamentAsync.when(
          data: (tournament) => Text(tournament?.name ?? 'Tournament'),
          loading: () => const Text('Tournament'),
          error: (_, __) => const Text('Tournament'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit tournament',
            onPressed: () => context.go('/admin/tournaments/$tournamentId/edit'),
          ),
        ],
      ),
      body: tournamentAsync.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(message: 'Could not load this tournament.\n$error'),
        data: (tournament) {
          if (tournament == null) {
            return const Center(child: Text('This tournament no longer exists.'));
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Chip(
                  label: Text(
                    '${tournament.format.label} \u00b7 ${tournament.format.teamsPerRoom} teams per room',
                  ),
                ),
                const SizedBox(height: 20),
                Text('Set up next', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.3,
                    children: const [
                      _ComingSoonTile(icon: Icons.groups_outlined, label: 'Participants'),
                      _ComingSoonTile(icon: Icons.place_outlined, label: 'Venues'),
                      _ComingSoonTile(icon: Icons.grid_view_outlined, label: 'Draw'),
                      _ComingSoonTile(icon: Icons.forum_outlined, label: 'Motions'),
                      _ComingSoonTile(icon: Icons.fact_check_outlined, label: 'Ballots'),
                      _ComingSoonTile(icon: Icons.bar_chart_outlined, label: 'Standings'),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ComingSoonTile extends StatelessWidget {
  const _ComingSoonTile({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.grey.shade600),
            const SizedBox(height: 8),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 2),
            Text(
              'Coming next',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
