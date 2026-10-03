import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Care module palette — wired to [AppColors] / Color Branding guide.
///
/// Core: Medium Electric Blue `#055498`, Nile Blue `#123a60`,
/// Fire Engine Red `#CE2028`, Bright Gold `#FBD116`.
///
/// Legacy `teal*` / `calm*` / `forest*` names kept so existing screens
/// pick up brand colors without renaming every call site.
class CareColors {
  CareColors._();

  // —— Brand primaries ——
  static const primary = AppColors.mediumElectricBlue;
  static const primaryDark = AppColors.nileBlue;
  static const primaryMid = AppColors.primaryBorder;
  static const accent = AppColors.fireEngineRed;
  static const highlight = AppColors.brightGold;

  /// Official brand header / hero gradient
  static const brandGradient = AppColors.primaryGradient;

  // —— Legacy aliases → brand ——
  static const teal = primary;
  static const tealDark = primaryDark;
  static const tealMid = primaryMid;

  static const mint = AppColors.softBlue;
  static const mintSoft = AppColors.lightBackground;
  static const mintBar = AppColors.softBlue;
  static const cardFill = AppColors.cardLight;
  static const cardBorder = AppColors.softBlueBorder;

  static const greenText = AppColors.textPrimaryLight;
  static const heading = AppColors.nileBlue;
  static const mutedText = AppColors.textSecondaryLight;

  static const forestDeep = AppColors.nileBlue;
  static const forest = AppColors.nileBlue;
  static const forestMid = AppColors.mediumElectricBlue;

  static const accentGold = AppColors.brightGold;
  static const accentGoldText = AppColors.nileBlue;
  static const accentGoldBorder = AppColors.brightGoldBorder;

  static const leaf = primaryMid;
  static const calmForest = primaryDark;
  static const calmForestMid = primary;
  static const calmMint = Color(0xFF8BB8D9); // soft Medium Electric Blue tint
  static const calmMintBtn = Color(0xFF6FA3CC); // mid brand blue for calm CTAs
  static const calmMintCard = AppColors.softBlue;
  static const calmBg = AppColors.lightBackground;
  static const calmMuted = mutedText;
  static const calmRing = AppColors.softBlueBorder;
}
