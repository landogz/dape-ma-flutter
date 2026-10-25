import 'package:flutter/material.dart';

import '../../options/app_option_icons.dart';
import '../../utils/api_url.dart';
import '../translation_catalog.dart';

/// Illustration driven by an App Translations key (image, then icon, then
/// bundled asset). Rebuilds when the admin catalog refreshes.
class TranslationArt extends StatelessWidget {
  const TranslationArt({
    super.key,
    required this.translationKey,
    this.assetFallback,
    this.iconFallback,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.color,
    this.errorBuilder,
  });

  final String translationKey;
  final String? assetFallback;
  final IconData? iconFallback;
  final double? width;
  final double? height;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final Color? color;
  final ImageErrorWidgetBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: TranslationCatalog.instance,
      builder: (context, _) => _paint(context),
    );
  }

  Widget _paint(BuildContext context) {
    final visual = TranslationCatalog.visual(translationKey);
    final remoteUrl = ApiUrl.resolve(visual?.imageUrl);
    final icon = appOptionIcon(
      visual?.icon,
      fallback: iconFallback ?? Icons.image_outlined,
    );

    Widget iconWidget() {
      if (iconFallback == null && visual?.hasIcon != true) {
        return const SizedBox.shrink();
      }
      return Icon(
        icon,
        color: color,
        size: (height ?? width ?? 40) * 0.72,
      );
    }

    Widget assetImage() {
      final asset = assetFallback;
      if (asset == null || asset.isEmpty) {
        return iconWidget();
      }
      return Image.asset(
        asset,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        errorBuilder: errorBuilder ??
            (context, error, stackTrace) => iconWidget(),
      );
    }

    if (remoteUrl != null) {
      return Image.network(
        remoteUrl,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        errorBuilder: (context, error, stackTrace) => assetImage(),
      );
    }

    if (visual?.hasIcon == true) {
      return iconWidget();
    }

    return assetImage();
  }
}
