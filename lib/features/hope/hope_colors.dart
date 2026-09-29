import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

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

  // Preferred brand aliases
  static const primary = purple;
  static const primaryDark = purpleDark;
  static const primaryMid = purpleMid;
  static const soft = purpleSoft;
}
