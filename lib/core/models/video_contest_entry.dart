class VideoContestEntry {
  final int id;
  final int videoContestId;
  final String title;
  final String creatorName;
  final String? description;
  final String videoUrl;
  final String? thumbnailUrl;
  final String? region;
  final String status;

  VideoContestEntry({
    required this.id,
    required this.videoContestId,
    required this.title,
    required this.creatorName,
    this.description,
    required this.videoUrl,
    this.thumbnailUrl,
    this.region,
    required this.status,
  });

  factory VideoContestEntry.fromJson(Map<String, dynamic> json) {
    return VideoContestEntry(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      videoContestId: json['video_contest_id'] is int
          ? json['video_contest_id'] as int
          : int.tryParse('${json['video_contest_id']}') ?? 0,
      title: json['title'] as String? ?? '',
      creatorName: json['creator_name'] as String? ?? '',
      description: json['description'] as String?,
      videoUrl: json['video_url'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String?,
      region: json['region'] as String?,
      status: json['status'] as String? ?? 'pending',
    );
  }

  bool get hasVideo => videoUrl.trim().isNotEmpty;

  bool get isYoutube {
    final url = videoUrl.toLowerCase();
    return url.contains('youtube.com') || url.contains('youtu.be');
  }
}
