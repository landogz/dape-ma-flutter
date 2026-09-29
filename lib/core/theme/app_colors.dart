import 'package:flutter/material.dart';

/// Official DAPE-MA brand palette.
///
/// Brand names: Medium Electric Blue, Nile Blue, Fire Engine Red, Bright Gold.
/// Legacy aliases (`primaryBlue`, etc.) kept for existing call sites.
class AppColors {
  AppColors._();

  // —— Official brand colors ——
  /// Medium Electric Blue — primary
  static const mediumElectricBlue = Color(0xFF055498);

  /// Nile Blue — secondary
  static const nileBlue = Color(0xFF123A60);

  /// Fire Engine Red — accent / alert
  static const fireEngineRed = Color(0xFFCE2028);

  /// Bright Gold — accent / highlight
  static const brightGold = Color(0xFFFBD116);

  /// Notices / supporting accent (not a core brand color)
  static const accentPurple = Color(0xFF7C3AED);

  // —— Legacy aliases (same hex) ——
  static const primaryBlue = mediumElectricBlue;
  static const secondaryBlue = nileBlue;
  static const accentRed = fireEngineRed;
  static const accentYellow = brightGold;

  // —— Borders for accents ——
  static const fireEngineRedBorder = Color(0xFFA01A1F);
  static const brightGoldBorder = Color(0xFFD4A017);
  static const primaryBorder = Color(0xFF044080);
  static const accentPurpleBorder = Color(0xFF6D28D9);

  // —— Soft brand tints ——
  static const softBlue = Color(0xFFE8F1FA);
  static const softBlueBorder = Color(0xFFB7D0EA);
  static const softRed = Color(0xFFFDE8E9);
  static const softGold = Color(0xFFFEF9C3);
  static const softPurple = Color(0xFFF3E8FF);

  // —— Backgrounds ——
  static const lightBackground = Color(0xFFF9FAFB);
  static const darkBackground = Color(0xFF0F172A);
  static const cardLight = Color(0xFFFFFFFF);
  static const cardDark = Color(0xFF1E293B);

  // —— Text ——
  static const textPrimaryLight = Color(0xFF0A0A0A);
  static const textSecondaryLight = Color(0xFF374151);
  static const textPrimaryDark = Color(0xFFF1F5F9);
  static const textSecondaryDark = Color(0xFF9CA3AF);

  // —— Gradients ——
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [mediumElectricBlue, nileBlue],
  );
}
