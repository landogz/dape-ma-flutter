import 'package:share_plus/share_plus.dart';

import '../analytics/analytics_client.dart';

class AppShare {
  AppShare._();

  static Future<void> item({
    required String url,
    int? postId,
  }) async {
    final uri = Uri.tryParse(url);
    if (uri != null && (uri.isScheme('https') || uri.isScheme('http'))) {
      await Share.shareUri(uri);
    } else {
      await Share.share(url);
    }
    if (postId != null) {
      await AnalyticsClient.instance.trackShare(postId);
    }
  }
}
