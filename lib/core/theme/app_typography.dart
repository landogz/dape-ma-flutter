import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Brand typography — Montserrat (alternative to Gotham).
///
/// Titles: Bold 28–32px, line height 1.2–1.3
/// Headers: Semi-Bold 20–24px, line height 1.3
/// Body: Regular 14–16px, line height 1.0–1.5
class AppTypography {
  AppTypography._();

  static String? get fontFamily => GoogleFonts.montserrat().fontFamily;

  static TextStyle _style({
    required FontWeight fontWeight,
    required double fontSize,
    required double height,
    Color? color,
    double? letterSpacing,
  }) {
    return GoogleFonts.montserrat(
      fontWeight: fontWeight,
      fontSize: fontSize,
      height: height,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextTheme textTheme([TextTheme? base]) {
    final seed = base ?? ThemeData(useMaterial3: true).textTheme;

    return seed.copyWith(
      displayLarge: _style(
        fontWeight: FontWeight.w700,
        fontSize: 32,
        height: 1.25,
        letterSpacing: -0.2,
      ),
      displayMedium: _style(
        fontWeight: FontWeight.w700,
        fontSize: 30,
        height: 1.25,
      ),
      displaySmall: _style(
        fontWeight: FontWeight.w700,
        fontSize: 28,
        height: 1.25,
      ),
      headlineLarge: _style(
        fontWeight: FontWeight.w700,
        fontSize: 28,
        height: 1.25,
      ),
      headlineMedium: _style(
        fontWeight: FontWeight.w600,
        fontSize: 24,
        height: 1.3,
      ),
      headlineSmall: _style(
        fontWeight: FontWeight.w600,
        fontSize: 22,
        height: 1.3,
      ),
      titleLarge: _style(
        fontWeight: FontWeight.w600,
        fontSize: 22,
        height: 1.3,
      ),
      titleMedium: _style(
        fontWeight: FontWeight.w600,
        fontSize: 20,
        height: 1.3,
      ),
      titleSmall: _style(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        height: 1.3,
      ),
      bodyLarge: _style(
        fontWeight: FontWeight.w400,
        fontSize: 16,
        height: 1.5,
      ),
      bodyMedium: _style(
        fontWeight: FontWeight.w400,
        fontSize: 14,
        height: 1.5,
      ),
      bodySmall: _style(
        fontWeight: FontWeight.w400,
        fontSize: 12,
        height: 1.4,
      ),
      labelLarge: _style(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        height: 1.3,
      ),
      labelMedium: _style(
        fontWeight: FontWeight.w500,
        fontSize: 12,
        height: 1.3,
      ),
      labelSmall: _style(
        fontWeight: FontWeight.w500,
        fontSize: 11,
        height: 1.3,
      ),
    );
  }

  static TextStyle title({Color? color}) => _style(
        fontWeight: FontWeight.w700,
        fontSize: 28,
        height: 1.25,
        color: color,
      );

  static TextStyle header({Color? color}) => _style(
        fontWeight: FontWeight.w600,
        fontSize: 20,
        height: 1.3,
        color: color,
      );

  static TextStyle body({Color? color, double fontSize = 14}) => _style(
        fontWeight: FontWeight.w400,
        fontSize: fontSize,
        height: 1.5,
        color: color,
      );
}
