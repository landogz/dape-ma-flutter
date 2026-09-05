class PosterContestEntry {
  final int id;
  final int posterContestId;
  final String title;
  final String creatorName;
  final String? description;
  final String posterImageUrl;
  final String? region;
  final String status;

  PosterContestEntry({
    required this.id,
    required this.posterContestId,
    required this.title,
    required this.creatorName,
    this.description,
    required this.posterImageUrl,
    this.region,
    required this.status,
  });

  factory PosterContestEntry.fromJson(Map<String, dynamic> json) {
    return PosterContestEntry(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      posterContestId: json['poster_contest_id'] is int
          ? json['poster_contest_id'] as int
          : int.tryParse('${json['poster_contest_id']}') ?? 0,
      title: json['title'] as String? ?? '',
      creatorName: json['creator_name'] as String? ?? '',
      description: json['description'] as String?,
      posterImageUrl: json['poster_image_url'] as String? ?? '',
      region: json['region'] as String?,
      status: json['status'] as String? ?? 'pending',
    );
  }

  bool get hasImage => posterImageUrl.trim().isNotEmpty;
}
