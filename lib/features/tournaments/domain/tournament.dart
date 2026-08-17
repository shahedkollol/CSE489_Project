/// BP = British Parliamentary (4 teams per room).
/// AP = Asian Parliamentary (2 teams per room).
/// This is the single flag that makes every downstream feature - draw
/// generation, ballot entry layout, standings - format-aware.
enum TournamentFormat { bp, ap }

extension TournamentFormatX on TournamentFormat {
  static TournamentFormat fromName(String? name) {
    return TournamentFormat.values.firstWhere(
      (f) => f.short == (name ?? 'BP').toUpperCase(),
      orElse: () => TournamentFormat.bp,
    );
  }

  String get short => this == TournamentFormat.bp ? 'BP' : 'AP';

  String get label =>
      this == TournamentFormat.bp ? 'British Parliamentary' : 'Asian Parliamentary';

  int get teamsPerRoom => this == TournamentFormat.bp ? 4 : 2;
}

class Tournament {
  const Tournament({
    required this.id,
    required this.name,
    required this.slug,
    required this.format,
  });

  final String id;
  final String name;

  /// URL-safe identifier, used on the public results site.
  final String slug;

  final TournamentFormat format;

  factory Tournament.fromFirestore(String id, Map<String, dynamic> data) {
    return Tournament(
      id: id,
      name: data['name'] as String? ?? '',
      slug: data['slug'] as String? ?? '',
      format: TournamentFormatX.fromName(data['format'] as String?),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'slug': slug,
        'format': format.short,
      };

  Tournament copyWith({String? name, String? slug, TournamentFormat? format}) {
    return Tournament(
      id: id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      format: format ?? this.format,
    );
  }
}
