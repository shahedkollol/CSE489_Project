import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/loading_view.dart';
import '../../ballots/application/ballot_providers.dart';
import '../../participants/application/team_providers.dart';
import '../../tournaments/application/tournament_providers.dart';

class PublicHomePage extends ConsumerWidget {
  const PublicHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournamentsAsync = ref.watch(tournamentListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Public results')),
      body: tournamentsAsync.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(message: 'Could not load results.\n$error'),
        data: (tournaments) {
          final visible = <dynamic>[];
          for (final tournament in tournaments) {
            final ballots = ref.watch(publishedBallotListProvider(tournament.id)).valueOrNull ?? const [];
            if (ballots.isNotEmpty) {
              visible.add(tournament);
            }
          }

          if (visible.isEmpty) {
            return const Center(child: Text('No public results have been released yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: visible.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final tournament = visible[index];
              final published = ref.watch(publishedBallotListProvider(tournament.id)).valueOrNull ?? const [];
              final teams = ref.watch(teamListProvider(tournament.id)).valueOrNull ?? const [];
              final teamNameMap = {for (final team in teams) team.id: team.name};

              final scores = <String, Map<String, int>>{};
              for (final ballot in published) {
                final govCurrent = scores[ballot.govTeamId] ?? {'points': 0, 'for': 0, 'against': 0};
                final oppCurrent = scores[ballot.oppTeamId] ?? {'points': 0, 'for': 0, 'against': 0};

                scores[ballot.govTeamId] = {
                  'points': govCurrent['points']! + (ballot.govScore > ballot.oppScore ? 3 : (ballot.govScore == ballot.oppScore ? 1 : 0)),
                  'for': govCurrent['for']! + ballot.govScore,
                  'against': govCurrent['against']! + ballot.oppScore,
                };
                scores[ballot.oppTeamId] = {
                  'points': oppCurrent['points']! + (ballot.oppScore > ballot.govScore ? 3 : (ballot.oppScore == ballot.govScore ? 1 : 0)),
                  'for': oppCurrent['for']! + ballot.oppScore,
                  'against': oppCurrent['against']! + ballot.govScore,
                };
              }

              final rows = scores.entries.toList()
                ..sort((a, b) => (b.value['points'] ?? 0).compareTo(a.value['points'] ?? 0));

              return Card(
                margin: EdgeInsets.zero,
                child: ExpansionTile(
                  title: Text(tournament.name),
                  subtitle: Text('${published.length} released ballots'),
                  children: [
                    if (rows.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No released standings yet.'),
                      )
                    else
                      ...rows.map((entry) {
                        final name = teamNameMap[entry.key] ?? 'Unknown team';
                        final stats = entry.value;
                        return ListTile(
                          title: Text(name),
                          trailing: Text('${stats['points']} pts'),
                          subtitle: Text('${stats['for']}-${stats['against']}'),
                        );
                      }),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
