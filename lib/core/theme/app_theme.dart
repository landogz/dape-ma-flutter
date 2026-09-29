import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

ThemeData buildLightTheme({bool highContrast = false}) {
  final base = ThemeData.light(useMaterial3: true);
  final primary =
      highContrast ? const Color(0xFF003366) : AppColors.mediumElectricBlue;
  final secondary = highContrast ? const Color(0xFF001F3F) : AppColors.nileBlue;
  final text = highContrast ? Colors.black : AppColors.textPrimaryLight;
  final textTheme = AppTypography.textTheme(base.textTheme).apply(
    bodyColor: text,
    displayColor: text,
  );

  return base.copyWith(
    brightness: Brightness.light,
    primaryColor: primary,
    scaffoldBackgroundColor:
        highContrast ? Colors.white : AppColors.lightBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: highContrast ? Colors.white : Colors.transparent,
      foregroundColor: text,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppTypography.header(color: text),
      iconTheme: IconThemeData(color: text),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardLight,
      elevation: highContrast ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: highContrast
            ? const BorderSide(color: Colors.black, width: 1.4)
            : BorderSide.none,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        textStyle: AppTypography.body(fontSize: 14).copyWith(
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: AppTypography.body(fontSize: 14).copyWith(
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: Colors.white,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: primary),
    dividerColor: highContrast ? Colors.black : const Color(0xFFE5E7EB),
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    colorScheme: base.colorScheme.copyWith(
      brightness: Brightness.light,
      primary: primary,
      secondary: secondary,
      tertiary: AppColors.brightGold,
      error: AppColors.fireEngineRed,
      surface: AppColors.cardLight,
      onSurface: text,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onError: Colors.white,
    ),
  );
}

ThemeData buildDarkTheme({bool highContrast = false}) {
  final base = ThemeData.dark(useMaterial3: true);
  final bg = highContrast ? Colors.black : AppColors.darkBackground;
  final card = highContrast ? const Color(0xFF111111) : AppColors.cardDark;
  final text = highContrast ? Colors.white : AppColors.textPrimaryDark;
  final primary =
      highContrast ? const Color(0xFF66B2FF) : AppColors.mediumElectricBlue;
  final secondary = AppColors.nileBlue;
  final textTheme = AppTypography.textTheme(base.textTheme).apply(
    bodyColor: text,
    displayColor: text,
  );

  return base.copyWith(
    brightness: Brightness.dark,
    primaryColor: primary,
    scaffoldBackgroundColor: bg,
    canvasColor: bg,
    appBarTheme: AppBarTheme(
      backgroundColor: bg,
      foregroundColor: text,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: text),
      titleTextStyle: AppTypography.header(color: text),
    ),
    cardTheme: CardThemeData(
      color: card,
      elevation: highContrast ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: highContrast
            ? const BorderSide(color: Colors.white, width: 1.4)
            : BorderSide.none,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        textStyle: AppTypography.body(fontSize: 14).copyWith(
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: AppTypography.body(fontSize: 14).copyWith(
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: Colors.white,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: primary),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: card,
      hintStyle: TextStyle(
        color: text.withValues(alpha: 0.55),
        fontFamily: AppTypography.fontFamily,
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: const Color(0xFF334155),
      selectedColor: primary,
      labelStyle: TextStyle(color: text, fontFamily: AppTypography.fontFamily),
      secondaryLabelStyle: TextStyle(
        color: Colors.white,
        fontFamily: AppTypography.fontFamily,
      ),
      side: const BorderSide(color: Color(0xFF475569)),
    ),
    dividerColor: highContrast ? Colors.white70 : const Color(0xFF374151),
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    iconTheme: IconThemeData(color: text),
    colorScheme: base.colorScheme.copyWith(
      brightness: Brightness.dark,
      primary: primary,
      secondary: secondary,
      tertiary: AppColors.brightGold,
      error: AppColors.fireEngineRed,
      surface: card,
      onSurface: text,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onError: Colors.white,
    ),
  );
}

PageTransitionsTheme reduceMotionTransitions() {
  return const PageTransitionsTheme(
    builders: {
      TargetPlatform.android: _InstantPageTransitionsBuilder(),
      TargetPlatform.iOS: _InstantPageTransitionsBuilder(),
      TargetPlatform.macOS: _InstantPageTransitionsBuilder(),
    },
  );
}

class _InstantPageTransitionsBuilder extends PageTransitionsBuilder {
  const _InstantPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}
