class DebatePairing {
  const DebatePairing({
    required this.govTeamId,
    required this.oppTeamId,
    this.venueId = '',
  });

  final String govTeamId;
  final String oppTeamId;
  final String venueId;

  factory DebatePairing.fromMap(Map<String, dynamic> map) {
    return DebatePairing(
      govTeamId: map['govTeamId'] as String? ?? '',
      oppTeamId: map['oppTeamId'] as String? ?? '',
      venueId: map['venueId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'govTeamId': govTeamId,
        'oppTeamId': oppTeamId,
        'venueId': venueId,
      };
}

class DrawRound {
  const DrawRound({
    required this.id,
    required this.roundNumber,
    required this.pairings,
  });

  final String id;
  final int roundNumber;
  final List<DebatePairing> pairings;

  factory DrawRound.fromFirestore(String id, Map<String, dynamic> data) {
    final rawPairings = (data['pairings'] as List? ?? const [])
        .map((entry) => DebatePairing.fromMap(Map<String, dynamic>.from(entry as Map)))
        .toList();

    return DrawRound(
      id: id,
      roundNumber: (data['roundNumber'] as num?)?.toInt() ?? 1,
      pairings: rawPairings,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'roundNumber': roundNumber,
        'pairings': pairings.map((pairing) => pairing.toMap()).toList(),
      };

  static DrawRound generateRound({
    required int roundNumber,
    required List<String> teamIds,
    required List<String> venueIds,
  }) {
    final teams = [...teamIds]..shuffle();
    final venues = [...venueIds];
    final pairings = <DebatePairing>[];

    for (var i = 0; i + 1 < teams.length; i += 2) {
      final venueId = venues.isEmpty ? '' : venues[i ~/ 2 % venues.length];
      pairings.add(
        DebatePairing(
          govTeamId: teams[i],
          oppTeamId: teams[i + 1],
          venueId: venueId,
        ),
      );
    }

    return DrawRound(
      id: '',
      roundNumber: roundNumber,
      pairings: pairings,
    );
  }
}
