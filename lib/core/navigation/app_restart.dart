import 'package:flutter/material.dart';

import '../../features/splash/splash_screen.dart';
import 'fade_route.dart';

void restartFromSplash(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    fadeRoute<void>(const SplashScreen()),
    (route) => false,
  );
}
