import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/accessibility/accessibility_controller.dart';
import 'core/accessibility/accessibility_scope.dart';
import 'core/analytics/analytics_client.dart';
import 'core/auth/auth_service.dart';
import 'core/l10n/app_locale.dart';
import 'core/options/app_option_catalog.dart';
import 'core/l10n/locale_controller.dart';
import 'core/l10n/locale_scope.dart';
import 'core/l10n/translation_catalog.dart';
import 'core/moderation/blocked_word_catalog.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/deep_link_service.dart';
import 'features/push/push_notification_service.dart';
import 'features/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Never block the first frame forever on Android (secure storage / prefs /
  // network hangs previously left users on a blank black launch window).
  await _safeStartup();

  runApp(const DapeMaApp());
}

Future<void> _safeStartup() async {
  Future<void> withTimeout(Future<void> future, String label) async {
    try {
      await future.timeout(const Duration(seconds: 4));
    } catch (error, stack) {
      debugPrint('[Startup] $label failed/timed out: $error\n$stack');
    }
  }

  await withTimeout(LocaleController.instance.load(), 'locale');
  await withTimeout(AuthService.restoreUserScope(), 'auth scope');
  await withTimeout(AccessibilityController.instance.load(), 'accessibility');
  // Refresh user-scoped prefs once we can reach /me (optional, non-blocking).
  AuthService.bindCurrentUser();
  await withTimeout(
    PushNotificationService.instance.initialize(),
    'push',
  );
  await withTimeout(DeepLinkService.init(), 'deep links');
  await withTimeout(AppOptionCatalog.prefetch(), 'app options');
  await withTimeout(TranslationCatalog.prefetch(), 'translations');
  await withTimeout(BlockedWordCatalog.prefetch(), 'blocked words');
  await withTimeout(AnalyticsClient.instance.bootstrap(), 'analytics');
}

class DapeMaApp extends StatefulWidget {
  const DapeMaApp({super.key});

  @override
  State<DapeMaApp> createState() => _DapeMaAppState();
}

class _DapeMaAppState extends State<DapeMaApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    TranslationCatalog.startLiveSync();
    BlockedWordCatalog.startLiveSync();
    AppOptionCatalog.startLiveSync();
  }

  @override
  void dispose() {
    TranslationCatalog.stopLiveSync();
    BlockedWordCatalog.stopLiveSync();
    AppOptionCatalog.stopLiveSync();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      TranslationCatalog.resumeLiveSync();
      BlockedWordCatalog.resumeLiveSync();
      AppOptionCatalog.resumeLiveSync();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      TranslationCatalog.pauseLiveSync();
      BlockedWordCatalog.pauseLiveSync();
      AppOptionCatalog.pauseLiveSync();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        LocaleController.instance,
        AccessibilityController.instance,
        TranslationCatalog.instance,
        BlockedWordCatalog.instance,
        AppOptionCatalog.instance,
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
              navigatorKey: DeepLinkService.navigatorKey,
              navigatorObservers: [AnalyticsNavigatorObserver()],
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
