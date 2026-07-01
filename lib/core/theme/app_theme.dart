import 'package:flutter/material.dart';

import 'app_colors.dart';

ThemeData buildLightTheme() {
  final base = ThemeData.light();

  return base.copyWith(
    primaryColor: AppColors.primaryBlue,
    scaffoldBackgroundColor: const Color(0xFFF3F4F6),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.textPrimaryLight,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardLight,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.primaryBlue,
      secondary: AppColors.secondaryBlue,
      error: AppColors.accentRed,
      background: const Color(0xFFF3F4F6),
    ),
  );
}

