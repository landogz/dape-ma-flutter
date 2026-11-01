import 'dart:ui';

import 'package:share_plus/share_plus.dart';

import '../analytics/analytics_client.dart';

class AppShare {
  AppShare._();

  static Future<void> item({
    required String url,
    int? postId,
    String? resourceType,
    int? resourceId,
    Rect? sharePositionOrigin,
  }) async {
    await Share.share(
      url,
      sharePositionOrigin:
          sharePositionOrigin ?? const Rect.fromLTWH(0, 0, 1, 1),
    );
    if (postId != null) {
      await AnalyticsClient.instance.trackShare(postId);
      return;
    }
    if (resourceType != null && resourceId != null) {
      await AnalyticsClient.instance.trackCatalogShare(
        resourceType: resourceType,
        resourceId: resourceId,
      );
    }
  }
}
