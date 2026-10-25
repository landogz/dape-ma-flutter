import 'package:flutter/material.dart';

import '../options/app_option_icons.dart';
import '../utils/api_url.dart';
import 'translation_catalog.dart';

class TranslationGlyph extends StatelessWidget {
  const TranslationGlyph({
    super.key,
    required this.translationKey,
    required this.fallbackIcon,
    required this.color,
    this.size = 22,
  });

  final String translationKey;
  final IconData fallbackIcon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: TranslationCatalog.instance,
      builder: (context, _) => _paint(),
    );
  }

  Widget _paint() {
    final visual = TranslationCatalog.visual(translationKey);
    final remoteUrl = ApiUrl.resolve(visual?.imageUrl);
    final icon = appOptionIcon(visual?.icon, fallback: fallbackIcon);

    Widget fallback() => Icon(icon, color: color, size: size);

    if (remoteUrl != null) {
      return Image.network(
        remoteUrl,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => fallback(),
      );
    }

    return fallback();
  }
}
