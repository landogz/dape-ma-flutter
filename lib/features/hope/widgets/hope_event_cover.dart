import 'package:flutter/material.dart';

import '../events/hope_event.dart';

/// Shared event photo used on the Hope hub, list, detail, and carousel.
///
/// Admin covers are used when present. Otherwise the same bundled banner is
/// shown for that event everywhere, so Featured never disagrees with the
/// event page.
class HopeEventCover extends StatelessWidget {
  const HopeEventCover({
    super.key,
    this.event,
    this.fallbackIndex = 0,
    this.fit = BoxFit.cover,
    this.colorFilter,
  });

  final HopeEvent? event;
  final int fallbackIndex;
  final BoxFit fit;
  final ColorFilter? colorFilter;

  static const fallbacks = [
    'assets/hope/hope_banner_caravan.png',
    'assets/hope/hope_banner_celebration.png',
    'assets/hope/hope_banner_scout_run.png',
    'assets/hope/hope_banner_workshop.png',
  ];

  static String assetFor(HopeEvent? event, {int index = 0}) {
    if (event == null || event.id <= 0) {
      return fallbacks[index % fallbacks.length];
    }
    return fallbacks[(event.id - 1) % fallbacks.length];
  }

  @override
  Widget build(BuildContext context) {
    final asset = assetFor(event, index: fallbackIndex);
    final url = event?.coverUrl;
    final image = (url != null && url.isNotEmpty)
        ? Image.network(
            url,
            fit: fit,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, _, _) => Image.asset(
              asset,
              fit: fit,
              width: double.infinity,
              height: double.infinity,
            ),
          )
        : Image.asset(
            asset,
            fit: fit,
            width: double.infinity,
            height: double.infinity,
          );

    if (colorFilter == null) {
      return image;
    }

    return ColorFiltered(colorFilter: colorFilter!, child: image);
  }
}
