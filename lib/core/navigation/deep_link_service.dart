import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

import '../../features/contests/detail/contest_detail_screen.dart';
import '../../features/hope/events/hope_event_detail_screen.dart';
import '../../features/post_detail/post_detail_screen.dart';
import '../../features/post_engagement/post_engagement_service.dart';

class DeepLinkService {
  DeepLinkService._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final AppLinks _appLinks = AppLinks();
  static Uri? _pending;
  static bool _listening = false;

  static Future<void> init() async {
    if (_listening) return;
    _listening = true;

    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) {
        _pending = initial;
      }
    } catch (_) {}

    _appLinks.uriLinkStream.listen((uri) {
      if (navigatorKey.currentState == null) {
        _pending = uri;
        return;
      }
      open(uri);
    });
  }

  static Future<void> consumePending() async {
    final uri = _pending;
    _pending = null;
    if (uri != null) {
      await open(uri);
    }
  }

  static Future<void> open(Uri uri) async {
    final parsed = _parse(uri);
    if (parsed == null) return;

    final nav = navigatorKey.currentState;
    if (nav == null) {
      _pending = uri;
      return;
    }

    final type = parsed.$1;
    final key = parsed.$2;

    if (type == 'posts') {
      try {
        final post = await PostEngagementService.fetchPost(key);
        await nav.push(
          MaterialPageRoute<void>(
            builder: (_) => PostDetailScreen(post: post),
          ),
        );
      } catch (_) {}
      return;
    }

    if (type == 'events') {
      final id = int.tryParse(key);
      await nav.push(
        MaterialPageRoute<void>(
          builder: (_) => HopeEventDetailScreen(eventId: id ?? 0, eventKey: key),
        ),
      );
      return;
    }

    if (type == 'contests') {
      final id = int.tryParse(key);
      await nav.push(
        MaterialPageRoute<void>(
          builder: (_) =>
              ContestDetailScreen(contestId: id ?? 0, contestKey: key),
        ),
      );
    }
  }

  static (String, String)? _parse(Uri uri) {
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();

    if (uri.scheme == 'dapema') {
      final type = uri.host.toLowerCase();
      final key = segments.isNotEmpty
          ? segments.first
          : uri.path.replaceAll('/', '');
      if (key.isEmpty) return null;
      if (type == 'posts' || type == 'events' || type == 'contests') {
        return (type, key);
      }
      return null;
    }

    if (segments.length < 2) return null;
    final type = segments[0].toLowerCase();
    final key = segments[1];
    if (key.isEmpty) return null;
    if (type == 'posts' || type == 'events' || type == 'contests') {
      return (type, key);
    }
    return null;
  }
}
