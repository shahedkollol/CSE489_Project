import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/loading_view.dart';
import '../../draw/application/draw_providers.dart';
import '../../draw/domain/draw_round.dart';
import '../../participants/application/team_providers.dart';
import '../../participants/domain/team.dart';
import '../application/ballot_providers.dart';
import '../domain/ballot_result.dart';

class BallotPage extends ConsumerWidget {
  const BallotPage({super.key, required this.tournamentId});

  final String tournamentId;

  Future<void> _showBallotDialog(
    BuildContext context,
    WidgetRef ref,
    DrawRound round,
    DebatePairing pairing,
  ) async {
    final teams = ref.read(teamListProvider(tournamentId)).valueOrNull ?? const <Team>[];
    final govTeam = teams.firstWhere(
      (team) => team.id == pairing.govTeamId,
      orElse: () => const Team(id: '', name: 'Unknown', shortName: 'UNK', institution: ''),
    );
    final oppTeam = teams.firstWhere(
      (team) => team.id == pairing.oppTeamId,
      orElse: () => const Team(id: '', name: 'Unknown', shortName: 'UNK', institution: ''),
    );

    final govScoreController = TextEditingController();
    final oppScoreController = TextEditingController();
    final noteController = TextEditingController();

    final ballots = ref.read(ballotListProvider(tournamentId)).valueOrNull ?? const <BallotResult>[];
    BallotResult? existing;
    for (final ballot in ballots) {
      if (ballot.roundNumber == round.roundNumber &&
          ballot.govTeamId == pairing.govTeamId &&
          ballot.oppTeamId == pairing.oppTeamId) {
        existing = ballot;
        break;
      }
    }

    if (existing != null) {
      govScoreController.text = existing.govScore.toString();
      oppScoreController.text = existing.oppScore.toString();
      noteController.text = existing.note;
    }

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('${govTeam.name} vs ${oppTeam.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: govScoreController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: govTeam.shortName,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: oppScoreController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: oppTeam.shortName,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteController,
                  minLines: 2,
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: 'Notes'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final govScore = int.tryParse(govScoreController.text) ?? 0;
                final oppScore = int.tryParse(oppScoreController.text) ?? 0;
                final note = noteController.text.trim();
                ref.read(ballotRepositoryProvider(tournamentId)).upsert(
                  roundNumber: round.roundNumber,
                  govTeamId: pairing.govTeamId,
                  oppTeamId: pairing.oppTeamId,
                  govScore: govScore,
                  oppScore: oppScore,
                  note: note,
                );
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ballot saved.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roundsAsync = ref.watch(drawListProvider(tournamentId));
    final teamsAsync = ref.watch(teamListProvider(tournamentId));
    final ballotsAsync = ref.watch(ballotListProvider(tournamentId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin/tournaments/$tournamentId'),
        ),
        title: const Text('Ballots'),
      ),
      body: roundsAsync.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(message: 'Could not load draw.\n$error'),
        data: (rounds) {
          if (rounds.isEmpty) {
            return const Center(child: Text('Generate a draw before entering ballots.'));
          }

          return teamsAsync.when(
            loading: () => const LoadingView(),
            error: (error, _) => ErrorView(message: 'Could not load teams.\n$error'),
            data: (teams) {
              final teamMap = {for (final team in teams) team.id: team};
              final ballots = ballotsAsync.valueOrNull ?? [];

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: rounds.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final round = rounds[index];
                  final published = ballots
                      .where((ballot) => ballot.roundNumber == round.roundNumber)
                      .any((ballot) => ballot.isPublished);

                  return Card(
                    margin: EdgeInsets.zero,
                    child: ExpansionTile(
                      title: Text('Round ${round.roundNumber}'),
                      trailing: Switch(
                        value: published,
                        onChanged: (value) async {
                          await ref
                              .read(ballotRepositoryProvider(tournamentId))
                              .publishRound(round.roundNumber, published: value);
                        },
                      ),
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
                            BallotResult? existing;
                            for (final ballot in ballots) {
                              if (ballot.roundNumber == round.roundNumber &&
                                  ballot.govTeamId == pairing.govTeamId &&
                                  ballot.oppTeamId == pairing.oppTeamId) {
                                existing = ballot;
                                break;
                              }
                            }

                            return ListTile(
                              title: Text('${gov?.name ?? 'Unknown'} vs ${opp?.name ?? 'Unknown'}'),
                              subtitle: existing == null
                                  ? const Text('No ballot entered')
                                  : Text(
                                      'Gov ${existing.govScore} – ${existing.oppScore} Opp${existing.note.isNotEmpty ? ' • ${existing.note}' : ''}',
                                    ),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () => _showBallotDialog(context, ref, round, pairing),
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
      ),
    );
  }
}
