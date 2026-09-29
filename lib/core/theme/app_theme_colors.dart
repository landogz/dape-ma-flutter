import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Theme-aware colors so screens stay readable in light and dark mode.
extension AppThemeColors on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get pageBackground => Theme.of(this).scaffoldBackgroundColor;

  Color get cardBackground => Theme.of(this).cardColor;

  Color get textPrimary =>
      isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

  Color get textSecondary =>
      isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

  Color get brandPrimary => AppColors.mediumElectricBlue;

  Color get brandSecondary => AppColors.nileBlue;

  Color get brandAccent => AppColors.brightGold;

  Color get brandDanger => AppColors.fireEngineRed;

  Color get inputFill =>
      isDarkMode ? AppColors.cardDark : AppColors.cardLight;

  Color get chipBackground =>
      isDarkMode ? const Color(0xFF334155) : AppColors.cardLight;

  Color get borderSubtle =>
      isDarkMode ? const Color(0xFF475569) : const Color(0xFFE5E7EB);

  Color get mutedSurface =>
      isDarkMode ? AppColors.cardDark : AppColors.lightBackground;

  Color get softBrandSurface => isDarkMode
      ? AppColors.mediumElectricBlue.withValues(alpha: 0.22)
      : AppColors.mediumElectricBlue.withValues(alpha: 0.08);
}
