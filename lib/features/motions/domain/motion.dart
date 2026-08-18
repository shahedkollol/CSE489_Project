class Motion {
  const Motion({
    required this.id,
    required this.text,
    required this.info,
    required this.round,
  });

  final String id;
  final String text;
  final String info;
  final int round;

  factory Motion.fromFirestore(String id, Map<String, dynamic> data) {
    return Motion(
      id: id,
      text: data['text'] as String? ?? '',
      info: data['info'] as String? ?? '',
      round: (data['round'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'text': text,
        'info': info,
        'round': round,
      };

  Motion copyWith({String? id, String? text, String? info, int? round}) {
    return Motion(
      id: id ?? this.id,
      text: text ?? this.text,
      info: info ?? this.info,
      round: round ?? this.round,
    );
  }
}
