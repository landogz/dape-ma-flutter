import '../utils/json_parsers.dart';

class PostComment {
  final int id;
  final int userId;
  final String body;
  final String authorName;
  final DateTime? createdAt;

  const PostComment({
    required this.id,
    required this.userId,
    required this.body,
    required this.authorName,
    required this.createdAt,
  });

  PostComment copyWith({String? body}) {
    return PostComment(
      id: id,
      userId: userId,
      body: body ?? this.body,
      authorName: authorName,
      createdAt: createdAt,
    );
  }

  factory PostComment.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final userMap = user is Map<String, dynamic> ? user : <String, dynamic>{};
    return PostComment(
      id: parseJsonInt(json['id']),
      userId: parseJsonInt(
        json['user_id'],
        parseJsonInt(userMap['id']),
      ),
      body: parseJsonString(json['body'] ?? json['content']),
      authorName: parseJsonString(userMap['name'], 'User'),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(parseJsonString(json['created_at']))
          : null,
    );
  }
}
