import '../utils/json_parsers.dart';
import '../../features/post_engagement/post_reaction.dart';

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
  final PostReactionType? userReaction;
  final Map<PostReactionType, int> reactionCounts;
  final bool commentsEnabled;
  final double averageRating;
  final int reviewsCount;
  final int? userRating;

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
    this.userReaction,
    Map<PostReactionType, int>? reactionCounts,
    this.commentsEnabled = true,
    this.averageRating = 0,
    this.reviewsCount = 0,
    this.userRating,
  }) : reactionCounts = reactionCounts ??
            {for (final type in PostReactionType.values) type: 0};

  Post copyWith({
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
    PostReactionType? userReaction,
    bool clearUserReaction = false,
    Map<PostReactionType, int>? reactionCounts,
    bool? commentsEnabled,
    double? averageRating,
    int? reviewsCount,
    int? userRating,
    bool clearUserRating = false,
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
      userReaction:
          clearUserReaction ? null : (userReaction ?? this.userReaction),
      reactionCounts: reactionCounts ?? this.reactionCounts,
      commentsEnabled: commentsEnabled ?? this.commentsEnabled,
      averageRating: averageRating ?? this.averageRating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      userRating: clearUserRating ? null : (userRating ?? this.userRating),
    );
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    final bodyOrContent = (json['content'] ?? json['body']) as String? ?? '';
    final excerptStr = json['excerpt'] as String? ?? '';
    final avg = json['average_rating'] ?? json['reviews_avg_rating'];
    final reviewCount = json['reviews_count'];
    final userReaction = postReactionFromApi(json['user_reaction'] as String?);
    final reactionCounts = parseReactionCounts(json['reaction_counts']);

    return Post(
      id: parseJsonInt(json['id']),
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
      likesCount: parseJsonInt(json['likes_count']),
      commentsCount: parseJsonInt(json['comments_count']),
      isLiked: parseJsonBool(json['is_liked']) || userReaction != null,
      userReaction: userReaction,
      reactionCounts: reactionCounts,
      commentsEnabled: json.containsKey('comments_enabled')
          ? parseJsonBool(json['comments_enabled'], true)
          : true,
      averageRating: parseJsonDouble(avg),
      reviewsCount: parseJsonInt(reviewCount),
      userRating: json['user_rating'] == null
          ? null
          : parseJsonInt(json['user_rating']),
    );
  }
}
