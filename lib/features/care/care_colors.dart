import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Care module palette — aligned to DAPE-MA brand (blues + Bright Gold CTA).
///
/// Legacy `teal*` / `calm*` field names kept so existing screens update
/// visually without renaming every call site.
class CareColors {
  CareColors._();

  /// Primary brand (was teal)
  static const teal = AppColors.mediumElectricBlue;
  static const tealDark = AppColors.nileBlue;
  static const tealMid = Color(0xFF1A6BB0);

  /// Soft surfaces
  static const mint = AppColors.softBlue;
  static const mintSoft = AppColors.lightBackground;
  static const mintBar = Color(0xFFD6E8F5);
  static const cardFill = Color(0xFFF0F6FB);
  static const cardBorder = AppColors.softBlueBorder;

  /// Text
  static const greenText = AppColors.textPrimaryLight;
  static const heading = AppColors.nileBlue;
  static const mutedText = AppColors.textSecondaryLight;

  /// Deep contrast cards / Daily Reflection
  static const forestDeep = AppColors.nileBlue;
  static const forest = AppColors.nileBlue;
  static const forestMid = AppColors.mediumElectricBlue;

  /// Action accent — Bright Gold CTAs
  static const accentGold = AppColors.brightGold;
  static const accentGoldText = AppColors.nileBlue;

  /// Legacy aliases used elsewhere in Care sub-screens
  static const leaf = tealMid;
  static const calmForest = tealDark;
  static const calmForestMid = teal;
  static const calmMint = Color(0xFF8BB8D9);
  static const calmMintBtn = Color(0xFF6FA3CC);
  static const calmMintCard = AppColors.softBlue;
  static const calmBg = AppColors.lightBackground;
  static const calmMuted = mutedText;
  static const calmRing = AppColors.softBlueBorder;

  // Preferred brand aliases
  static const primary = teal;
  static const primaryDark = tealDark;
  static const primaryMid = tealMid;
}
