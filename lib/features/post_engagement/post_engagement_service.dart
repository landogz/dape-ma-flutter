import '../../core/auth/auth_service.dart';
import '../../core/models/post_comment.dart';
import '../../core/network/api_client.dart';
import '../../core/network/endpoints.dart';

class PostEngagementService {
  PostEngagementService._();

  static Future<({bool liked, int likesCount})> toggleLike(int postId) async {
    final res = await AuthService.authedPost<Map<String, dynamic>>(
      Endpoints.postLike(postId),
    );
    final root = res.data ?? <String, dynamic>{};
    final data = root['data'] is Map<String, dynamic>
        ? root['data'] as Map<String, dynamic>
        : <String, dynamic>{};
    return (
      liked: data['liked'] as bool? ?? false,
      likesCount: data['likes_count'] as int? ?? 0,
    );
  }

  static Future<List<PostComment>> fetchComments(int postId) async {
    final res = await ApiClient().get<Map<String, dynamic>>(
      Endpoints.postComments(postId),
    );
    final root = res.data ?? <String, dynamic>{};
    final data = root['data'];
    List<dynamic> raw = const [];
    if (data is Map<String, dynamic>) {
      raw = data['data'] as List<dynamic>? ?? const [];
    } else if (data is List<dynamic>) {
      raw = data;
    }
    return raw
        .map((e) => PostComment.fromJson(e as Map<String, dynamic>))
        .toList();
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
}
