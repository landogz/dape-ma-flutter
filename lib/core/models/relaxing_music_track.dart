class RelaxingMusicTrackDto {
  const RelaxingMusicTrackDto({
    required this.id,
    required this.title,
    required this.titleTl,
    required this.audioUrl,
    this.durationSeconds,
    this.sortOrder = 0,
  });

  final int id;
  final String title;
  final String titleTl;
  final String audioUrl;
  final int? durationSeconds;
  final int sortOrder;

  factory RelaxingMusicTrackDto.fromJson(Map<String, dynamic> json) {
    return RelaxingMusicTrackDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] ?? '').toString(),
      titleTl: (json['title_tl'] ?? json['title'] ?? '').toString(),
      audioUrl: (json['audio_url'] ?? '').toString(),
      durationSeconds: (json['duration_seconds'] as num?)?.toInt(),
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }
}
