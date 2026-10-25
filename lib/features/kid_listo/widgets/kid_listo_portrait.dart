import 'package:flutter/material.dart';

import '../../../core/l10n/translation_catalog.dart';
import '../../../core/utils/api_url.dart';

/// Kid Listo portrait. Uses the admin upload on `kidListoLogo`, then any
/// image on `careKidListo`, then the bundled PNG.
class KidListoPortrait extends StatelessWidget {
  const KidListoPortrait({
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.errorBuilder,
  });

  static const assetPath = 'assets/kid_listo/kid_listo_logo.png';
  static const translationKey = 'kidListoLogo';
  static const careCardKey = 'careKidListo';

  final double? width;
  final double? height;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final ImageErrorWidgetBuilder? errorBuilder;

  String? get _remoteUrl {
    final primary = TranslationCatalog.visual(translationKey);
    final fallback = TranslationCatalog.visual(careCardKey);
    return ApiUrl.resolve(primary?.imageUrl) ??
        ApiUrl.resolve(fallback?.imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: TranslationCatalog.instance,
      builder: (context, _) => _buildImage(),
    );
  }

  Widget _buildImage() {
    Widget assetImage() => Image.asset(
          assetPath,
          width: width,
          height: height,
          fit: fit,
          alignment: alignment,
          errorBuilder: errorBuilder,
        );

    final url = _remoteUrl;
    if (url != null) {
      return Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        errorBuilder: (context, error, stackTrace) => assetImage(),
      );
    }

    return assetImage();
  }
}
