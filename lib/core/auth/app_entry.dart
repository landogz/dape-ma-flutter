import 'package:flutter/material.dart';

import '../../features/account/force_change_password/force_change_password_screen.dart';
import '../../features/account/profile/profile_completeness.dart';
import '../../features/kid_listo/kid_listo_welcome_screen.dart';
import '../../features/shell/main_shell_screen.dart';
import '../models/post.dart';
import '../network/endpoints.dart';
import 'auth_navigator.dart';
import 'auth_service.dart';

/// Chooses Profile setup vs Kid Listo as the first signed-in screen.
class AppEntry {
  AppEntry._();

  static Future<bool> _profileIsComplete() async {
    try {
      final res = await AuthService.authedGet<Map<String, dynamic>>(
        Endpoints.me,
      );
      final root = res.data ?? <String, dynamic>{};
      final user = root['data'] is Map<String, dynamic>
          ? root['data'] as Map<String, dynamic>
          : root;
      return ProfileCompleteness.isCompleteFromUser(user);
    } catch (_) {
      return false;
    }
  }

  static Future<Widget> screen({List<Post> posts = const []}) async {
    if (AuthService.mustChangePassword) {
      return ForceChangePasswordScreen(initialPosts: posts);
    }

    final complete = await _profileIsComplete();
    if (!complete) {
      AuthNavigator.markProfileSetup(posts: posts);
      return MainShellScreen(
        initialPosts: posts,
        initialTab: 4,
        completeProfileFirst: true,
      );
    }

    AuthNavigator.clearProfileSetup();
    return KidListoWelcomeScreen(initialPosts: posts);
  }

  static Future<void> enter(
    BuildContext context, {
    List<Post> posts = const [],
  }) async {
    final page = await screen(posts: posts);
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => page),
      (_) => false,
    );
  }
}
