class PostReactor {
  final int id;
  final String name;
  final String? avatarUrl;
  final String reaction;
  final DateTime? reactedAt;

  const PostReactor({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.reaction,
    required this.reactedAt,
  });

  factory PostReactor.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : const <String, dynamic>{};

    return PostReactor(
      id: _asInt(json['id']),
      name: (user['name'] as String?)?.trim().isNotEmpty == true
          ? user['name'] as String
          : 'DAPE-MA user',
      avatarUrl: user['profile_image_url'] as String?,
      reaction: (json['reaction'] as String?) ?? 'like',
      reactedAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
