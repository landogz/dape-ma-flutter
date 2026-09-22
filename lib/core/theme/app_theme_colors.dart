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

  Color get inputFill =>
      isDarkMode ? const Color(0xFF1E293B) : Colors.white;

  Color get chipBackground =>
      isDarkMode ? const Color(0xFF334155) : Colors.white;

  Color get borderSubtle =>
      isDarkMode ? const Color(0xFF475569) : const Color(0xFFE5E7EB);

  Color get mutedSurface =>
      isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF3F4F6);

  Color get softBrandSurface => isDarkMode
      ? AppColors.primaryBlue.withValues(alpha: 0.22)
      : AppColors.primaryBlue.withValues(alpha: 0.08);
}
