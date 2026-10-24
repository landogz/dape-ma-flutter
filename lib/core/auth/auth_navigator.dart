import 'package:flutter/material.dart';

import '../../features/auth/login_screen.dart';
import '../models/post.dart';

/// Centralized auth navigation: login gate ↔ signed-in app entry.
class AuthNavigator {
  AuthNavigator._();

  /// When true, Profile should open Kid Listo as soon as it hits 100%.
  static bool pendingKidListoAfterProfile = false;

  static List<Post> pendingPosts = const [];

  static void markProfileSetup({List<Post> posts = const []}) {
    pendingKidListoAfterProfile = true;
    pendingPosts = posts;
  }

  static void clearProfileSetup() {
    pendingKidListoAfterProfile = false;
    pendingPosts = const [];
  }

  static void goToLogin(BuildContext context) {
    clearProfileSetup();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => const LoginScreen(asAuthGate: true),
      ),
      (_) => false,
    );
  }
}
