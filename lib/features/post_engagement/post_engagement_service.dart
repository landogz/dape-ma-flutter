import 'package:dio/dio.dart';

import '../../core/auth/auth_service.dart';
import '../../core/models/post.dart';
import '../../core/models/post_comment.dart';
import '../../core/network/api_client.dart';
import '../../core/network/endpoints.dart';
import '../../core/utils/json_parsers.dart';

class PostEngagementService {
  PostEngagementService._();

  static String friendlyError(Object error, String action) {
    if (error is DioException) {
      final code = error.response?.statusCode;
      if (code == 404) {
        return 'Likes and comments need the latest server update. Deploy Laravel and run php artisan migrate.';
      }
      if (code == 401) {
        return 'Please log in to $action.';
      }
      if (code == 403) {
        return 'You can only manage your own comments.';
      }
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout) {
        return 'No internet connection. Check your network and try again.';
      }
    }
    return 'Could not $action. Try again.';
  }

  static Future<Post> fetchPost(int postId) async {
    final token = await AuthService.getToken();
    final res = await ApiClient(token: token).get<Map<String, dynamic>>(
      Endpoints.postDetail(postId),
    );
    final root = res.data ?? <String, dynamic>{};
    final data = root['data'] is Map<String, dynamic>
        ? root['data'] as Map<String, dynamic>
        : <String, dynamic>{};
    return Post.fromJson(data);
  }

  static Future<({bool liked, int likesCount})> toggleLike(int postId) async {
    final res = await AuthService.authedPost<Map<String, dynamic>>(
      Endpoints.postLike(postId),
    );
    final root = res.data ?? <String, dynamic>{};
    final data = root['data'] is Map<String, dynamic>
        ? root['data'] as Map<String, dynamic>
        : <String, dynamic>{};
    return (
      liked: parseJsonBool(data['liked']),
      likesCount: parseJsonInt(data['likes_count']),
    );
  }

  static Future<({List<PostComment> comments, bool hasMore})> fetchComments(
    int postId, {
    int page = 1,
  }) async {
    final res = await ApiClient().get<Map<String, dynamic>>(
      Endpoints.postComments(postId),
      query: <String, dynamic>{'page': page},
    );
    final root = res.data ?? <String, dynamic>{};
    final data = root['data'];
    List<dynamic> raw = const [];
    var hasMore = false;

    if (data is Map<String, dynamic>) {
      raw = data['data'] as List<dynamic>? ?? const [];
      final currentPage = parseJsonInt(data['current_page'], 1);
      final lastPage = parseJsonInt(data['last_page'], 1);
      hasMore = currentPage < lastPage;
    } else if (data is List<dynamic>) {
      raw = data;
    }

    final comments = <PostComment>[];
    for (final item in raw) {
      if (item is! Map<String, dynamic>) continue;
      try {
        comments.add(PostComment.fromJson(item));
      } catch (_) {
        // Skip malformed rows instead of failing the whole list.
      }
    }

    return (comments: comments, hasMore: hasMore);
  }

  static Future<PostComment> postComment(int postId, String body) async {
    final res = await AuthService.authedPost<Map<String, dynamic>>(
      Endpoints.postComments(postId),
      data: <String, dynamic>{'body': body},
    );
    final root = res.data ?? <String, dynamic>{};
    final data = root['data'] is Map<String, dynamic>
        ? root['data'] as Map<String, dynamic>
        : <String, dynamic>{};
    return PostComment.fromJson(data);
  }

  static Future<PostComment> updateComment(
    int postId,
    int commentId,
    String body,
  ) async {
    final res = await AuthService.authedPut<Map<String, dynamic>>(
      Endpoints.postComment(postId, commentId),
      data: <String, dynamic>{'body': body},
    );
    final root = res.data ?? <String, dynamic>{};
    final data = root['data'] is Map<String, dynamic>
        ? root['data'] as Map<String, dynamic>
        : <String, dynamic>{};
    return PostComment.fromJson(data);
  }

  static Future<int> deleteComment(int postId, int commentId) async {
    final res = await AuthService.authedDelete<Map<String, dynamic>>(
      Endpoints.postComment(postId, commentId),
    );
    final root = res.data ?? <String, dynamic>{};
    final data = root['data'] is Map<String, dynamic>
        ? root['data'] as Map<String, dynamic>
        : <String, dynamic>{};
    return parseJsonInt(data['comments_count']);
  }
}
