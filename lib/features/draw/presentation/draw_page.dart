import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/loading_view.dart';
import '../../participants/application/team_providers.dart';
import '../../participants/domain/team.dart';
import '../../venues/application/venue_providers.dart';
import '../../venues/domain/venue.dart';
import '../application/draw_providers.dart';
import '../domain/draw_round.dart';

class DrawPage extends ConsumerWidget {
  const DrawPage({super.key, required this.tournamentId});

  final String tournamentId;

  Future<void> _generateRound(BuildContext context, WidgetRef ref) async {
    final teamsAsync = ref.read(teamListProvider(tournamentId));
    final venuesAsync = ref.read(venueListProvider(tournamentId));
    final teams = teamsAsync.valueOrNull ?? <Team>[];
    final venues = venuesAsync.valueOrNull ?? <Venue>[];

    if (teams.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least two teams before generating a draw.')),
      );
      return;
    }

    final repository = ref.read(drawRepositoryProvider(tournamentId));
    final currentRounds = ref.read(drawListProvider(tournamentId)).valueOrNull ?? <DrawRound>[];
    final nextRoundNumber = currentRounds.isEmpty ? 1 : currentRounds.map((round) => round.roundNumber).reduce((a, b) => a > b ? a : b) + 1;

    final round = DrawRound.generateRound(
      roundNumber: nextRoundNumber,
      teamIds: teams.map((team) => team.id).toList(),
      venueIds: venues.map((venue) => venue.id).toList(),
    );

    await repository.create(round);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamsAsync = ref.watch(teamListProvider(tournamentId));
    final venuesAsync = ref.watch(venueListProvider(tournamentId));
    final roundsAsync = ref.watch(drawListProvider(tournamentId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin/tournaments/$tournamentId'),
        ),
        title: const Text('Draw'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _generateRound(context, ref),
        icon: const Icon(Icons.grid_view_outlined),
        label: const Text('Generate round'),
      ),
      body: teamsAsync.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(message: 'Could not load teams.\n$error'),
        data: (teams) {
          if (teams.length < 2) {
            return const Center(child: Text('Add at least two teams to generate a draw.'));
          }

          return venuesAsync.when(
            loading: () => const LoadingView(),
            error: (error, _) => ErrorView(message: 'Could not load venues.\n$error'),
            data: (venues) {
              final teamMap = {for (final team in teams) team.id: team};
              final venueMap = {for (final venue in venues) venue.id: venue};

              return roundsAsync.when(
                loading: () => const LoadingView(),
                error: (error, _) => ErrorView(message: 'Could not load draws.\n$error'),
                data: (rounds) {
                  if (rounds.isEmpty) {
                    return const Center(child: Text('No draw generated yet.'));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                    itemCount: rounds.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final round = rounds[index];
                      return Card(
                        margin: EdgeInsets.zero,
                        child: ExpansionTile(
                          title: Text('Round ${round.roundNumber}'),
                          children: [
                            if (round.pairings.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(16),
                                child: Text('No debates in this round.'),
                              )
                            else
                              ...round.pairings.map((pairing) {
                                final gov = teamMap[pairing.govTeamId];
                                final opp = teamMap[pairing.oppTeamId];
                                final venue = venueMap[pairing.venueId];
                                return ListTile(
                                  title: Text(
                                    '${gov?.name ?? 'Unknown'} vs ${opp?.name ?? 'Unknown'}',
                                  ),
                                  subtitle: Text(
                                    venue != null ? 'Venue: ${venue.name}' : 'No venue assigned',
                                  ),
                                );
                              }),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
