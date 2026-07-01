import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';

void main() {
  runApp(const DapeMaApp());
}

class DapeMaApp extends StatelessWidget {
  const DapeMaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DAPE-MA Mobile',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      home: const SplashScreen(),
    );
  }
}

