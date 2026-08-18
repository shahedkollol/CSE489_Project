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
                    children: [
                      _FeatureTile(
                        icon: Icons.groups_outlined,
                        label: 'Participants',
                        onTap: () => context.go('/admin/tournaments/$tournamentId/participants'),
                      ),
                      _FeatureTile(
                        icon: Icons.place_outlined,
                        label: 'Venues',
                        onTap: () => context.go('/admin/tournaments/$tournamentId/venues'),
                      ),
                      _FeatureTile(
                        icon: Icons.grid_view_outlined,
                        label: 'Draw',
                        onTap: () => context.go('/admin/tournaments/$tournamentId/draw'),
                      ),
                      _FeatureTile(
                        icon: Icons.forum_outlined,
                        label: 'Motions',
                        onTap: () => context.go('/admin/tournaments/$tournamentId/motions'),
                      ),
                      _FeatureTile(
                        icon: Icons.fact_check_outlined,
                        label: 'Ballots',
                        onTap: () => context.go('/admin/tournaments/$tournamentId/ballots'),
                      ),
                      _FeatureTile(
                        icon: Icons.bar_chart_outlined,
                        label: 'Standings',
                        onTap: () => context.go('/admin/tournaments/$tournamentId/standings'),
                      ),
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

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 2),
              Text(
                onTap == null ? 'Coming next' : 'Open',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: onTap == null ? Colors.grey.shade600 : Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

