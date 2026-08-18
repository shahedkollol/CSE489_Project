class Venue {
  const Venue({
    required this.id,
    required this.name,
    required this.building,
    required this.capacity,
  });

  final String id;
  final String name;
  final String building;
  final int capacity;

  factory Venue.fromFirestore(String id, Map<String, dynamic> data) {
    return Venue(
      id: id,
      name: data['name'] as String? ?? '',
      building: data['building'] as String? ?? '',
      capacity: (data['capacity'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'building': building,
        'capacity': capacity,
      };

  Venue copyWith({String? id, String? name, String? building, int? capacity}) {
    return Venue(
      id: id ?? this.id,
      name: name ?? this.name,
      building: building ?? this.building,
      capacity: capacity ?? this.capacity,
    );
  }
}
