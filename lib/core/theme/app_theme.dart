import 'package:flutter/material.dart';

import 'app_colors.dart';

ThemeData buildLightTheme({bool highContrast = false}) {
  final base = ThemeData.light(useMaterial3: true);
  final primary = highContrast ? const Color(0xFF003366) : AppColors.primaryBlue;
  final secondary =
      highContrast ? const Color(0xFF001F3F) : AppColors.secondaryBlue;
  final text = highContrast ? Colors.black : AppColors.textPrimaryLight;

  return base.copyWith(
    brightness: Brightness.light,
    primaryColor: primary,
    scaffoldBackgroundColor:
        highContrast ? Colors.white : const Color(0xFFF3F4F6),
    appBarTheme: AppBarTheme(
      backgroundColor: highContrast ? Colors.white : Colors.transparent,
      foregroundColor: text,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: highContrast ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: highContrast
            ? const BorderSide(color: Colors.black, width: 1.4)
            : BorderSide.none,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    dividerColor: highContrast ? Colors.black : const Color(0xFFE5E7EB),
    textTheme: base.textTheme.apply(
      bodyColor: text,
      displayColor: text,
    ),
    colorScheme: base.colorScheme.copyWith(
      brightness: Brightness.light,
      primary: primary,
      secondary: secondary,
      error: AppColors.accentRed,
      surface: Colors.white,
      onSurface: text,
    ),
  );
}

ThemeData buildDarkTheme({bool highContrast = false}) {
  final base = ThemeData.dark(useMaterial3: true);
  final bg = highContrast ? Colors.black : AppColors.darkBackground;
  final card = highContrast ? const Color(0xFF111111) : AppColors.cardDark;
  final text = highContrast ? Colors.white : AppColors.textPrimaryDark;
  final primary =
      highContrast ? const Color(0xFF66B2FF) : AppColors.primaryBlue;

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
      titleTextStyle: TextStyle(
        color: text,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
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
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: card,
      hintStyle: TextStyle(color: text.withValues(alpha: 0.55)),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: const Color(0xFF334155),
      selectedColor: primary,
      labelStyle: TextStyle(color: text),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
      side: const BorderSide(color: Color(0xFF475569)),
    ),
    dividerColor: highContrast ? Colors.white70 : const Color(0xFF374151),
    textTheme: base.textTheme.apply(
      bodyColor: text,
      displayColor: text,
    ),
    iconTheme: IconThemeData(color: text),
    colorScheme: base.colorScheme.copyWith(
      brightness: Brightness.dark,
      primary: primary,
      secondary: AppColors.accentPurple,
      error: AppColors.accentRed,
      surface: card,
      onSurface: text,
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
