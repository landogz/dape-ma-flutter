class MoodCheckin {
  const MoodCheckin({
    required this.id,
    required this.mood,
    required this.source,
    this.score,
    this.note,
    this.createdAt,
  });

  final int id;
  final String mood;
  final String source;
  final int? score;
  final String? note;
  final String? createdAt;

  factory MoodCheckin.fromJson(Map<String, dynamic> json) {
    return MoodCheckin(
      id: (json['id'] as num?)?.toInt() ?? 0,
      mood: (json['mood'] ?? '') as String,
      source: (json['source'] ?? 'care_hub') as String,
      score: (json['score'] as num?)?.toInt(),
      note: json['note'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }
}
