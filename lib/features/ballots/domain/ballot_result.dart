class BallotResult {
  const BallotResult({
    required this.id,
    required this.roundNumber,
    required this.govTeamId,
    required this.oppTeamId,
    required this.govScore,
    required this.oppScore,
    required this.note,
    required this.isPublished,
  });

  final String id;
  final int roundNumber;
  final String govTeamId;
  final String oppTeamId;
  final int govScore;
  final int oppScore;
  final String note;
  final bool isPublished;

  factory BallotResult.fromFirestore(String id, Map<String, dynamic> data) {
    return BallotResult(
      id: id,
      roundNumber: (data['roundNumber'] as num?)?.toInt() ?? 1,
      govTeamId: data['govTeamId'] as String? ?? '',
      oppTeamId: data['oppTeamId'] as String? ?? '',
      govScore: (data['govScore'] as num?)?.toInt() ?? 0,
      oppScore: (data['oppScore'] as num?)?.toInt() ?? 0,
      note: data['note'] as String? ?? '',
      isPublished: data['isPublished'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'roundNumber': roundNumber,
        'govTeamId': govTeamId,
        'oppTeamId': oppTeamId,
        'govScore': govScore,
        'oppScore': oppScore,
        'note': note,
        'isPublished': isPublished,
      };

  BallotResult copyWith({
    String? id,
    int? roundNumber,
    String? govTeamId,
    String? oppTeamId,
    int? govScore,
    int? oppScore,
    String? note,
    bool? isPublished,
  }) {
    return BallotResult(
      id: id ?? this.id,
      roundNumber: roundNumber ?? this.roundNumber,
      govTeamId: govTeamId ?? this.govTeamId,
      oppTeamId: oppTeamId ?? this.oppTeamId,
      govScore: govScore ?? this.govScore,
      oppScore: oppScore ?? this.oppScore,
      note: note ?? this.note,
      isPublished: isPublished ?? this.isPublished,
    );
  }
}
