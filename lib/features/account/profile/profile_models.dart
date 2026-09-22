class ProfileSummary {
  const ProfileSummary({
    required this.name,
    required this.photoUrl,
    required this.memberSinceRaw,
    required this.isChampion,
    required this.lessonsCompleted,
    required this.articlesRead,
    required this.eventsJoined,
    required this.dayStreak,
    required this.bookmarksCount,
    required this.badges,
    required this.certificates,
    required this.gains,
    required this.lessonActivity,
    required this.articleActivity,
    required this.eventActivity,
  });

  final String name;
  final String? photoUrl;
  final String? memberSinceRaw;
  final bool isChampion;
  final int lessonsCompleted;
  final int articlesRead;
  final int eventsJoined;
  final int dayStreak;
  final int bookmarksCount;
  final List<ProfileBadge> badges;
  final List<ProfileCertificate> certificates;
  final List<ProfileGain> gains;
  final List<ProfileActivityItem> lessonActivity;
  final List<ProfileActivityItem> articleActivity;
  final List<ProfileActivityItem> eventActivity;

  factory ProfileSummary.fromJson(Map<String, dynamic> json) {
    final user = (json['user'] as Map?)?.cast<String, dynamic>() ?? {};
    final stats = (json['stats'] as Map?)?.cast<String, dynamic>() ?? {};
    final activity = (json['activity'] as Map?)?.cast<String, dynamic>() ?? {};

    return ProfileSummary(
      name: (user['name'] as String?)?.trim() ?? '',
      photoUrl: user['profile_image_url'] as String?,
      memberSinceRaw: user['created_at'] as String?,
      isChampion: user['is_champion'] == true,
      lessonsCompleted: _asInt(stats['lessons_completed']),
      articlesRead: _asInt(stats['articles_read']),
      eventsJoined: _asInt(stats['events_joined']),
      dayStreak: _asInt(stats['day_streak']),
      bookmarksCount: _asInt(stats['bookmarks_count']),
      badges: ((json['badges'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => ProfileBadge.fromJson(e.cast<String, dynamic>()))
          .toList(),
      certificates: ((json['certificates'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => ProfileCertificate.fromJson(e.cast<String, dynamic>()))
          .toList(),
      gains: ((json['gains'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => ProfileGain.fromJson(e.cast<String, dynamic>()))
          .toList(),
      lessonActivity: _activityList(activity['lessons']),
      articleActivity: _activityList(activity['articles']),
      eventActivity: _activityList(activity['events']),
    );
  }

  static List<ProfileActivityItem> _activityList(dynamic raw) {
    return ((raw as List?) ?? const [])
        .whereType<Map>()
        .map((e) => ProfileActivityItem.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }
}

class ProfileBadge {
  const ProfileBadge({
    required this.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.earned,
  });

  final String key;
  final String title;
  final String description;
  final String icon;
  final String color;
  final bool earned;

  factory ProfileBadge.fromJson(Map<String, dynamic> json) {
    return ProfileBadge(
      key: json['key'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? 'star',
      color: json['color'] as String? ?? '#055498',
      earned: json['earned'] == true,
    );
  }
}

class ProfileCertificate {
  const ProfileCertificate({
    required this.id,
    required this.title,
    required this.contestTitle,
    required this.status,
    required this.earnedAt,
    required this.mediaUrl,
  });

  final int id;
  final String title;
  final String? contestTitle;
  final String status;
  final String? earnedAt;
  final String? mediaUrl;

  factory ProfileCertificate.fromJson(Map<String, dynamic> json) {
    return ProfileCertificate(
      id: ProfileSummary._asInt(json['id']),
      title: json['title'] as String? ?? 'Certificate',
      contestTitle: json['contest_title'] as String?,
      status: json['status'] as String? ?? 'winner',
      earnedAt: json['earned_at'] as String?,
      mediaUrl: json['media_url'] as String?,
    );
  }
}

class ProfileGain {
  const ProfileGain({
    required this.id,
    required this.title,
    required this.contestTitle,
    required this.status,
    required this.entryType,
    required this.submittedAt,
    required this.mediaUrl,
  });

  final int id;
  final String title;
  final String? contestTitle;
  final String status;
  final String? entryType;
  final String? submittedAt;
  final String? mediaUrl;

  factory ProfileGain.fromJson(Map<String, dynamic> json) {
    return ProfileGain(
      id: ProfileSummary._asInt(json['id']),
      title: json['title'] as String? ?? 'Entry',
      contestTitle: json['contest_title'] as String?,
      status: json['status'] as String? ?? 'pending',
      entryType: json['entry_type'] as String?,
      submittedAt: json['submitted_at'] as String?,
      mediaUrl: json['media_url'] as String?,
    );
  }
}

class ProfileActivityItem {
  const ProfileActivityItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.status,
    required this.categorySlug,
  });

  final int id;
  final String title;
  final String? subtitle;
  final String type;
  final String? status;
  final String? categorySlug;

  factory ProfileActivityItem.fromJson(Map<String, dynamic> json) {
    return ProfileActivityItem(
      id: ProfileSummary._asInt(json['id']),
      title: json['title'] as String? ?? '',
      subtitle: (json['subtitle'] as String?) ??
          (json['category'] as String?) ??
          (json['contest_title'] as String?),
      type: json['type'] as String? ?? 'post',
      status: json['status'] as String?,
      categorySlug: json['category_slug'] as String?,
    );
  }
}
