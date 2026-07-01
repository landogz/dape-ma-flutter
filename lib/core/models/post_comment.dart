class PostComment {
  final int id;
  final String body;
  final String authorName;
  final DateTime? createdAt;

  const PostComment({
    required this.id,
    required this.body,
    required this.authorName,
    required this.createdAt,
  });

  factory PostComment.fromJson(Map<String, dynamic> json) {
    return PostComment(
      id: json['id'] as int,
      body: json['body'] as String? ?? '',
      authorName: (json['user']?['name'] ?? 'User') as String,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }
}
