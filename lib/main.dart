import 'package:flutter/material.dart';

import 'core/l10n/app_locale.dart';
import 'core/l10n/locale_controller.dart';
import 'core/l10n/locale_scope.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocaleController.instance.load();
  runApp(const DapeMaApp());
}

class DapeMaApp extends StatelessWidget {
  const DapeMaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocaleController.instance,
      builder: (context, _) {
        final controller = LocaleController.instance;

        return LocaleScope(
          controller: controller,
          child: MaterialApp(
            title: 'DAPE-MA Mobile',
            debugShowCheckedModeBanner: false,
            theme: buildLightTheme(),
            locale: controller.locale.flutterLocale,
            supportedLocales: AppLocale.flutterLocales,
            home: const SplashScreen(),
          ),
        );
      },
    );
  }
}
