class Team {
  const Team({
    required this.id,
    required this.name,
    required this.shortName,
    required this.institution,
  });

  final String id;
  final String name;
  final String shortName;
  final String institution;

  factory Team.fromFirestore(String id, Map<String, dynamic> data) {
    return Team(
      id: id,
      name: data['name'] as String? ?? '',
      shortName: data['shortName'] as String? ?? '',
      institution: data['institution'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'shortName': shortName,
        'institution': institution,
      };

  Team copyWith({String? id, String? name, String? shortName, String? institution}) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      institution: institution ?? this.institution,
    );
  }
}
