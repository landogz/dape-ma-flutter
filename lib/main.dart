import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/accessibility/accessibility_controller.dart';
import 'core/accessibility/accessibility_scope.dart';
import 'core/auth/auth_service.dart';
import 'core/l10n/app_locale.dart';
import 'core/l10n/locale_controller.dart';
import 'core/l10n/locale_scope.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocaleController.instance.load();
  await AuthService.restoreUserScope();
  await AccessibilityController.instance.load();
  // Refresh user-scoped prefs once we can reach /me (optional, non-blocking).
  AuthService.bindCurrentUser();
  runApp(const DapeMaApp());
}

class DapeMaApp extends StatelessWidget {
  const DapeMaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        LocaleController.instance,
        AccessibilityController.instance,
      ]),
      builder: (context, _) {
        final localeController = LocaleController.instance;
        final a11y = AccessibilityController.instance;
        final light = buildLightTheme(highContrast: a11y.highContrast);
        final dark = buildDarkTheme(highContrast: a11y.highContrast);

        final theme = (a11y.darkMode ? dark : light).copyWith(
          pageTransitionsTheme: a11y.reduceMotion
              ? reduceMotionTransitions()
              : const PageTransitionsTheme(),
        );

        return LocaleScope(
          controller: localeController,
          child: AccessibilityScope(
            controller: a11y,
            child: MaterialApp(
              title: 'DAPE-MA Mobile',
              debugShowCheckedModeBanner: false,
              theme: theme,
              darkTheme: dark.copyWith(
                pageTransitionsTheme: a11y.reduceMotion
                    ? reduceMotionTransitions()
                    : const PageTransitionsTheme(),
              ),
              themeMode: a11y.darkMode ? ThemeMode.dark : ThemeMode.light,
              locale: localeController.locale.flutterLocale,
              supportedLocales: AppLocale.flutterLocales,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              builder: (context, child) {
                final media = MediaQuery.of(context);
                final scale = a11y.textScale.clamp(0.9, 1.4);
                // iOS edge-to-edge can report padding.top == 0 while viewPadding
                // still has the status-bar inset. SafeArea reads `padding`, so
                // restore it here or every screen will collide with the notch.
                final padding = media.padding;
                final viewPadding = media.viewPadding;
                // Always honor the larger of padding vs viewPadding so SafeArea
                // and manual insets work under iOS edge-to-edge.
                final restoredPadding = EdgeInsets.only(
                  left: padding.left > viewPadding.left
                      ? padding.left
                      : viewPadding.left,
                  top: padding.top > viewPadding.top
                      ? padding.top
                      : viewPadding.top,
                  right: padding.right > viewPadding.right
                      ? padding.right
                      : viewPadding.right,
                  bottom: padding.bottom > viewPadding.bottom
                      ? padding.bottom
                      : viewPadding.bottom,
                );
                return MediaQuery(
                  data: media.copyWith(
                    padding: restoredPadding,
                    // App text size replaces system scaling so pages stay consistent.
                    textScaler: TextScaler.linear(scale),
                    disableAnimations: a11y.reduceMotion,
                    boldText: a11y.highContrast ? true : media.boldText,
                  ),
                  child: child ?? const SizedBox.shrink(),
                );
              },
              home: const SplashScreen(),
            ),
          ),
        );
      },
    );
  }
}
