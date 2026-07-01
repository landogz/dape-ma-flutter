import 'dart:io';

import 'package:dio/dio.dart';

import '../network/api_client.dart';
import '../network/endpoints.dart';

/// Fire-and-forget analytics for the mobile app.
/// Events use standard types (`post_view`, `search`, etc.) plus a `platform`
/// field so the admin analytics dashboard can attribute traffic to iOS/Android.
class AnalyticsClient {
  AnalyticsClient._();

  static final AnalyticsClient instance = AnalyticsClient._();

  String? get _platform {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return null;
  }

  Future<void> trackPostView(int postId) async {
    await _sendEvent('post_view', postId: postId);
  }

  Future<void> trackSearch() async {
    await _sendEvent('search');
  }

  Future<void> trackBookmark(int postId) async {
    await _sendEvent('bookmark', postId: postId);
  }

  Future<void> trackShare(int postId) async {
    await _sendEvent('share', postId: postId);
  }

  Future<void> trackReview(int postId) async {
    await _sendEvent('review', postId: postId);
  }

  Future<void> trackLike(int postId) async {
    await _sendEvent('post_like', postId: postId);
  }

  Future<void> _sendEvent(
    String eventType, {
    int? postId,
  }) async {
    final platform = _platform;
    if (platform == null) {
      return;
    }

    try {
      final api = ApiClient();
      await api.post<Map<String, dynamic>>(
        Endpoints.analyticsEvents,
        data: <String, dynamic>{
          'event_type': eventType,
          'platform': platform,
          'post_id': ?postId,
        },
      );
    } on DioException {
      // Analytics must never break UX.
    }
  }
}
