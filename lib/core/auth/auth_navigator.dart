import 'package:flutter/material.dart';

import '../../features/auth/login_screen.dart';
import '../../features/kid_listo/kid_listo_welcome_screen.dart';
import '../models/post.dart';

/// Centralized auth navigation: login gate ↔ signed-in app entry.
class AuthNavigator {
  AuthNavigator._();

  static void goToLogin(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => const LoginScreen(asAuthGate: true),
      ),
      (_) => false,
    );
  }

  static void enterApp(
    BuildContext context, {
    List<Post> posts = const [],
  }) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => KidListoWelcomeScreen(initialPosts: posts),
      ),
      (_) => false,
    );
  }
}
