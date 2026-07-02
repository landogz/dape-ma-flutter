import 'package:dio/dio.dart';

import '../../core/auth/auth_service.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/network/endpoints.dart';
import '../../core/utils/json_parsers.dart';

class ReviewService {
  ReviewService._();

  static String friendlyError(Object error, String action, AppStrings l10n) {
    if (error is DioException) {
      final code = error.response?.statusCode;
      if (code == 401) {
        return l10n.loginRequired(action);
      }
    }
    return l10n.actionFailed(action);
  }

  static Future<({
    int rating,
    int reviewsCount,
    double averageRating,
  })> submitPostReview(
    int postId,
    int rating,
    String comment,
  ) async {
    final res = await AuthService.authedPost<Map<String, dynamic>>(
      Endpoints.reviews,
      data: <String, dynamic>{
        'target_type': 'post',
        'target_id': postId,
        'rating': rating,
        'comment': comment,
      },
    );
    final root = res.data ?? <String, dynamic>{};
    final data = root['data'] is Map<String, dynamic>
        ? root['data'] as Map<String, dynamic>
        : <String, dynamic>{};
    final summary = data['summary'] is Map<String, dynamic>
        ? data['summary'] as Map<String, dynamic>
        : <String, dynamic>{};
    final userReview = summary['user_review'];
    final submittedRating = userReview is Map<String, dynamic>
        ? parseJsonInt(userReview['rating'], rating)
        : rating;

    return (
      rating: submittedRating,
      reviewsCount: parseJsonInt(summary['reviews_count']),
      averageRating: parseJsonDouble(summary['average_rating']),
    );
  }
}
