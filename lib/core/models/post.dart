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
  final int likesCount;
  final int commentsCount;
  final bool isLiked;

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
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
  });

  Post copyWith({
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
  }) {
    return Post(
      id: id,
      title: title,
      excerpt: excerpt,
      content: content,
      imageUrl: imageUrl,
      youtubeUrl: youtubeUrl,
      categorySlug: categorySlug,
      categoryName: categoryName,
      authorName: authorName,
      publishedAt: publishedAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    final bodyOrContent = (json['content'] ?? json['body']) as String? ?? '';
    final excerptStr = json['excerpt'] as String? ?? '';
    return Post(
      id: json['id'] as int,
      title: json['title'] as String,
      excerpt: excerptStr,
      content: bodyOrContent,
      imageUrl: (json['media_url'] ?? json['image_url']) as String?,
      youtubeUrl: json['youtube_url'] as String?,
      categorySlug: (json['category']?['slug'] ?? '') as String,
      categoryName: (json['category']?['name'] ?? '') as String,
      authorName: (json['author']?['name'] ?? 'DAPE-MA') as String,
      publishedAt: json['publish_date'] != null
          ? DateTime.tryParse(json['publish_date'] as String)
          : null,
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
    );
  }
}
