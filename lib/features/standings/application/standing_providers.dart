import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ballots/application/ballot_providers.dart';
import '../../participants/application/team_providers.dart';
import '../domain/standing_entry.dart';

final standingsProvider = Provider.family<List<StandingEntry>, String>((ref, tournamentId) {
  final ballots = ref.watch(ballotListProvider(tournamentId)).valueOrNull ?? [];
  final teams = ref.watch(teamListProvider(tournamentId)).valueOrNull ?? [];

  final standings = <String, StandingEntry>{};
  for (final team in teams) {
    standings[team.id] = StandingEntry(
      teamId: team.id,
      teamName: team.name,
      points: 0,
      wins: 0,
      losses: 0,
      scoresFor: 0,
      scoresAgainst: 0,
    );
  }

  for (final ballot in ballots.where((entry) => entry.isPublished)) {
    final currentGov = standings[ballot.govTeamId] ??
        StandingEntry(
          teamId: ballot.govTeamId,
          teamName: ballot.govTeamId,
          points: 0,
          wins: 0,
          losses: 0,
          scoresFor: 0,
          scoresAgainst: 0,
        );
    final currentOpp = standings[ballot.oppTeamId] ??
        StandingEntry(
          teamId: ballot.oppTeamId,
          teamName: ballot.oppTeamId,
          points: 0,
          wins: 0,
          losses: 0,
          scoresFor: 0,
          scoresAgainst: 0,
        );

    if (ballot.govScore > ballot.oppScore) {
      standings[ballot.govTeamId] = currentGov.copyWith(
        points: currentGov.points + 3,
        wins: currentGov.wins + 1,
        scoresFor: currentGov.scoresFor + ballot.govScore,
        scoresAgainst: currentGov.scoresAgainst + ballot.oppScore,
      );
      standings[ballot.oppTeamId] = currentOpp.copyWith(
        losses: currentOpp.losses + 1,
        scoresFor: currentOpp.scoresFor + ballot.oppScore,
        scoresAgainst: currentOpp.scoresAgainst + ballot.govScore,
      );
    } else if (ballot.oppScore > ballot.govScore) {
      standings[ballot.oppTeamId] = currentOpp.copyWith(
        points: currentOpp.points + 3,
        wins: currentOpp.wins + 1,
        scoresFor: currentOpp.scoresFor + ballot.oppScore,
        scoresAgainst: currentOpp.scoresAgainst + ballot.govScore,
      );
      standings[ballot.govTeamId] = currentGov.copyWith(
        losses: currentGov.losses + 1,
        scoresFor: currentGov.scoresFor + ballot.govScore,
        scoresAgainst: currentGov.scoresAgainst + ballot.oppScore,
      );
    } else {
      standings[ballot.govTeamId] = currentGov.copyWith(
        points: currentGov.points + 1,
        scoresFor: currentGov.scoresFor + ballot.govScore,
        scoresAgainst: currentGov.scoresAgainst + ballot.oppScore,
      );
      standings[ballot.oppTeamId] = currentOpp.copyWith(
        points: currentOpp.points + 1,
        scoresFor: currentOpp.scoresFor + ballot.oppScore,
        scoresAgainst: currentOpp.scoresAgainst + ballot.govScore,
      );
    }
  }

  final values = standings.values.toList();
  values.sort((a, b) {
    if (a.points != b.points) return b.points.compareTo(a.points);
    if (a.scoresFor != b.scoresFor) return b.scoresFor.compareTo(a.scoresFor);
    return a.teamName.compareTo(b.teamName);
  });
  return values;
});
