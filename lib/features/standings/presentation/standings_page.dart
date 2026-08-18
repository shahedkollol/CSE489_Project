import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/loading_view.dart';
import '../../participants/application/team_providers.dart';
import '../application/standing_providers.dart';

class StandingsPage extends ConsumerWidget {
  const StandingsPage({super.key, required this.tournamentId});

  final String tournamentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final standings = ref.watch(standingsProvider(tournamentId));
    final teamsAsync = ref.watch(teamListProvider(tournamentId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin/tournaments/$tournamentId'),
        ),
        title: const Text('Standings'),
      ),
      body: teamsAsync.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(message: 'Could not load teams.\n$error'),
        data: (_) {
          if (standings.isEmpty) {
            return const Center(child: Text('Publish at least one ballot to see standings.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: standings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final entry = standings[index];
              return Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(entry.teamName),
                  subtitle: Text('${entry.wins}W • ${entry.losses}L • ${entry.scoresFor}-${entry.scoresAgainst}'),
                  trailing: Text('${entry.points} pts', style: Theme.of(context).textTheme.titleMedium),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
