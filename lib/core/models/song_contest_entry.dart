class SongContestEntry {
  final int id;
  final int? songContestId;
  final int? userId;
  final String title;
  final String artistName;
  final String entryType;
  final String? description;
  final String? lyrics;
  final String? mediaUrl;
  final String? coverImageUrl;
  final String? region;
  final String status;
  final String? adminNotes;

  SongContestEntry({
    required this.id,
    this.songContestId,
    this.userId,
    required this.title,
    required this.artistName,
    required this.entryType,
    this.description,
    this.lyrics,
    this.mediaUrl,
    this.coverImageUrl,
    this.region,
    required this.status,
    this.adminNotes,
  });

  bool get isPlaylist => entryType == 'playlist';
  bool get isSong => entryType == 'song';
  bool get hasMedia => mediaUrl != null && mediaUrl!.trim().isNotEmpty;

  bool get isYoutube {
    final url = mediaUrl?.toLowerCase() ?? '';
    return url.contains('youtube.com') || url.contains('youtu.be');
  }

  factory SongContestEntry.fromJson(Map<String, dynamic> json) {
    return SongContestEntry(
      id: json['id'] as int,
      songContestId: json['song_contest_id'] is int
          ? json['song_contest_id'] as int
          : int.tryParse('${json['song_contest_id'] ?? ''}'),
      userId: json['user_id'] is int
          ? json['user_id'] as int
          : int.tryParse('${json['user_id'] ?? ''}'),
      title: json['title'] as String? ?? '',
      artistName: json['artist_name'] as String? ?? '',
      entryType: json['entry_type'] as String? ?? 'song',
      description: json['description'] as String?,
      lyrics: json['lyrics'] as String?,
      mediaUrl: json['media_url'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      region: json['region'] as String?,
      status: json['status'] as String? ?? 'pending',
      adminNotes: json['admin_notes'] as String?,
    );
  }
}
