class Post {
  final int id;
  final String title;
  final String excerpt;
  final String content;
  final String? imageUrl;
  final String? youtubeUrl;
  final String categorySlug;
  final String categoryName;
  final String authorName;
  final DateTime? publishedAt;

  Post({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.content,
    required this.imageUrl,
    required this.youtubeUrl,
    required this.categorySlug,
    required this.categoryName,
    required this.authorName,
    required this.publishedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    // API may send 'body' (Laravel) or 'content'; excerpt may be absent
    final bodyOrContent = (json['content'] ?? json['body']) as String? ?? '';
    final excerptStr = json['excerpt'] as String? ?? '';
    return Post(
      id: json['id'] as int,
      title: json['title'] as String,
      excerpt: excerptStr,
      content: bodyOrContent,
      // Backend uses media_url; keep image_url as a fallback for safety.
      imageUrl: (json['media_url'] ?? json['image_url']) as String?,
      youtubeUrl: json['youtube_url'] as String?,
      categorySlug: (json['category']?['slug'] ?? '') as String,
      categoryName: (json['category']?['name'] ?? '') as String,
      authorName: (json['author']?['name'] ?? 'DAPE-MA') as String,
      publishedAt: json['publish_date'] != null
          ? DateTime.tryParse(json['publish_date'] as String)
          : null,
    );
  }
}

