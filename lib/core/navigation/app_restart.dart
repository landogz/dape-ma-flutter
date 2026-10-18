import 'package:flutter/material.dart';

import '../../features/splash/splash_screen.dart';

void restartFromSplash(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute<void>(builder: (_) => const SplashScreen()),
    (route) => false,
  );
}
