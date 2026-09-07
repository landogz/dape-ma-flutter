class ContestEntry {
  final int id;
  final int? contestId;
  final int? userId;
  final String title;
  final String creatorName;
  final String? entryType;
  final String? description;
  final String? lyrics;
  final String? mediaUrl;
  final String? coverImageUrl;
  final String? posterImageUrl;
  final String? videoUrl;
  final String? thumbnailUrl;
  final String? region;
  final String status;
  final String? adminNotes;

  ContestEntry({
    required this.id,
    this.contestId,
    this.userId,
    required this.title,
    required this.creatorName,
    this.entryType,
    this.description,
    this.lyrics,
    this.mediaUrl,
    this.coverImageUrl,
    this.posterImageUrl,
    this.videoUrl,
    this.thumbnailUrl,
    this.region,
    required this.status,
    this.adminNotes,
  });

  bool get hasMedia => mediaUrl != null && mediaUrl!.trim().isNotEmpty;

  bool get hasPoster {
    final url = posterImageUrl ?? coverImageUrl ?? mediaUrl;
    return url != null && url.trim().isNotEmpty;
  }

  bool get hasVideo {
    final url = videoUrl ?? mediaUrl;
    return url != null && url.trim().isNotEmpty;
  }

  String? get effectiveMediaUrl =>
      mediaUrl ?? videoUrl ?? posterImageUrl ?? coverImageUrl;

  String? get effectivePosterUrl =>
      posterImageUrl ?? coverImageUrl ?? mediaUrl;

  String? get effectiveVideoUrl => videoUrl ?? mediaUrl;

  bool get isYoutube {
    final url = (effectiveMediaUrl ?? '').toLowerCase();
    return url.contains('youtube.com') || url.contains('youtu.be');
  }

  factory ContestEntry.fromJson(Map<String, dynamic> json) {
    return ContestEntry(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      contestId: json['contest_id'] is int
          ? json['contest_id'] as int
          : int.tryParse('${json['contest_id'] ?? ''}'),
      userId: json['user_id'] is int
          ? json['user_id'] as int
          : int.tryParse('${json['user_id'] ?? ''}'),
      title: json['title'] as String? ?? '',
      creatorName: (json['creator_name'] as String?) ??
          (json['artist_name'] as String?) ??
          '',
      entryType: json['entry_type'] as String?,
      description: json['description'] as String?,
      lyrics: json['lyrics'] as String?,
      mediaUrl: json['media_url'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      posterImageUrl: json['poster_image_url'] as String?,
      videoUrl: json['video_url'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      region: json['region'] as String?,
      status: json['status'] as String? ?? 'pending',
      adminNotes: json['admin_notes'] as String?,
    );
  }
}
