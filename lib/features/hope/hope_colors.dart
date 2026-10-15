import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_colors.dart';

/// Hope module palette — aligned to DAPE-MA brand blues.
///
/// Field names `purple*` are kept as aliases so existing screens pick up
/// Medium Electric Blue / Nile Blue without renaming every call site.
class HopeColors {
  HopeColors._();

  static const purple = AppColors.mediumElectricBlue;
  static const purpleDark = AppColors.nileBlue;
  static const purpleMid = Color(0xFF1A6BB0);
  static const purpleSoft = AppColors.softBlue;
  static const pageBg = AppColors.lightBackground;
  static const cardBorder = AppColors.softBlueBorder;
  static const muted = AppColors.textSecondaryLight;
  static const bodyText = AppColors.nileBlue;
  static const slotsGreen = Color(0xFF16A34A);
  static const chipInactive = Color(0xFFF3F4F6);

  static Color pageBgOf(BuildContext context) => context.pageBackground;

  static Color mutedOf(BuildContext context) => context.textSecondary;

  static Color bodyOf(BuildContext context) =>
      context.isDarkMode ? context.textPrimary : bodyText;

  static Color chipInactiveOf(BuildContext context) => context.chipBackground;

  static Color cardBorderOf(BuildContext context) =>
      context.isDarkMode ? context.borderSubtle : cardBorder;

  static Color cardFillOf(BuildContext context) => context.cardBackground;

  static Color softOf(BuildContext context) =>
      context.pastelPanel(purpleSoft);

  static Color headingOf(BuildContext context) =>
      context.isDarkMode ? context.textPrimary : purple;

  // Preferred brand aliases
  static const primary = purple;
  static const primaryDark = purpleDark;
  static const primaryMid = purpleMid;
  static const soft = purpleSoft;
}
