class StandingEntry {
  const StandingEntry({
    required this.teamId,
    required this.teamName,
    required this.points,
    required this.wins,
    required this.losses,
    required this.scoresFor,
    required this.scoresAgainst,
  });

  final String teamId;
  final String teamName;
  final int points;
  final int wins;
  final int losses;
  final int scoresFor;
  final int scoresAgainst;

  StandingEntry copyWith({
    String? teamId,
    String? teamName,
    int? points,
    int? wins,
    int? losses,
    int? scoresFor,
    int? scoresAgainst,
  }) {
    return StandingEntry(
      teamId: teamId ?? this.teamId,
      teamName: teamName ?? this.teamName,
      points: points ?? this.points,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      scoresFor: scoresFor ?? this.scoresFor,
      scoresAgainst: scoresAgainst ?? this.scoresAgainst,
    );
  }
}
