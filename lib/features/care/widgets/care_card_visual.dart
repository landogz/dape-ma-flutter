import 'package:flutter/material.dart';

import '../../../core/l10n/widgets/translation_art.dart';
import '../care_colors.dart';

class CareCardVisual extends StatelessWidget {
  const CareCardVisual({
    super.key,
    required this.translationKey,
    required this.assetFallback,
    required this.iconFallback,
    this.height = 42,
    this.width,
  });

  final String translationKey;
  final String assetFallback;
  final IconData iconFallback;
  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return TranslationArt(
      translationKey: translationKey,
      assetFallback: assetFallback,
      iconFallback: iconFallback,
      height: height,
      width: width,
      color: CareColors.headingOf(context),
    );
  }
}
