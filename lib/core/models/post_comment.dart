import '../utils/json_parsers.dart';
import '../utils/api_url.dart';

class PostComment {
  final int id;
  final int? parentId;
  final int userId;
  final String body;
  final String authorName;
  final String? authorAvatarUrl;
  final DateTime? createdAt;
  final List<PostComment> replies;

  const PostComment({
    required this.id,
    this.parentId,
    required this.userId,
    required this.body,
    required this.authorName,
    this.authorAvatarUrl,
    required this.createdAt,
    this.replies = const [],
  });

  PostComment copyWith({
    String? body,
    List<PostComment>? replies,
  }) {
    return PostComment(
      id: id,
      parentId: parentId,
      userId: userId,
      body: body ?? this.body,
      authorName: authorName,
      authorAvatarUrl: authorAvatarUrl,
      createdAt: createdAt,
      replies: replies ?? this.replies,
    );
  }

  factory PostComment.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final userMap = user is Map<String, dynamic> ? user : <String, dynamic>{};
    final rawAvatar = userMap['profile_image_url'] as String?;
    final repliesRaw = json['replies'] as List<dynamic>? ?? const [];

    return PostComment(
      id: parseJsonInt(json['id']),
      parentId: json['parent_id'] == null
          ? null
          : parseJsonInt(json['parent_id']),
      userId: parseJsonInt(
        json['user_id'],
        parseJsonInt(userMap['id']),
      ),
      body: parseJsonString(json['body'] ?? json['content']),
      authorName: parseJsonString(userMap['name'], 'User'),
      authorAvatarUrl: ApiUrl.resolve(rawAvatar),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(parseJsonString(json['created_at']))
          : null,
      replies: repliesRaw
          .whereType<Map<String, dynamic>>()
          .map(PostComment.fromJson)
          .toList(),
    );
  }
}
