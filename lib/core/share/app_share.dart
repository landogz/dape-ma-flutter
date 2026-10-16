import 'package:share_plus/share_plus.dart';

import '../analytics/analytics_client.dart';

class AppShare {
  AppShare._();

  static Future<void> item({
    required String title,
    required String url,
    int? postId,
  }) async {
    await Share.share('$title\n$url', subject: title);
    if (postId != null) {
      await AnalyticsClient.instance.trackShare(postId);
    }
  }
}
