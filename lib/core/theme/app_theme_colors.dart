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

  /// Icons and selected labels on dark cards. Brand navy is unreadable there.
  Color get iconOnSurface =>
      isDarkMode ? AppColors.textPrimaryDark : AppColors.mediumElectricBlue;

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

  /// Headings on page/card surfaces (nile in light, light text in dark).
  Color get heading =>
      isDarkMode ? textPrimary : AppColors.nileBlue;

  Color get optionFill =>
      isDarkMode ? const Color(0xFF334155) : const Color(0xFFF9FAFB);

  /// Soft pastel tiles stay light in light mode; dark-tinted in dark mode
  /// so [textPrimary] remains readable on them.
  Color pastelPanel(Color lightPastel) => isDarkMode
      ? Color.alphaBlend(
          lightPastel.withValues(alpha: 0.28),
          cardBackground,
        )
      : lightPastel;
}
