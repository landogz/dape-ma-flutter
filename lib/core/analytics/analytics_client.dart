import 'dart:io';

import 'package:dio/dio.dart';

import '../network/api_client.dart';
import '../network/endpoints.dart';

class AnalyticsClient {
  AnalyticsClient._();

  static final AnalyticsClient instance = AnalyticsClient._();

  String get _platform {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'unknown';
  }

  Future<void> trackPostView(int postId) async {
    await _sendEvent('post_view_${_platform}', postId: postId);
  }

  Future<void> trackSearch(String query) async {
    // Store query length only to avoid sending full text if not desired
    await _sendEvent('search_${_platform}');
  }

  Future<void> _sendEvent(
    String eventType, {
    int? postId,
  }) async {
    try {
      final api = ApiClient();
      await api.post<Map<String, dynamic>>(
        Endpoints.analyticsEvents,
        data: {
          'event_type': eventType,
          if (postId != null) 'post_id': postId,
        },
      );
    } on DioException {
      // Swallow errors – analytics should never break UX
    }
  }
}

