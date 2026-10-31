import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/auth_service.dart';
import '../network/api_client.dart';
import '../network/endpoints.dart';

/// Fire-and-forget analytics for the mobile app.
class AnalyticsClient with WidgetsBindingObserver {
  AnalyticsClient._();

  static final AnalyticsClient instance = AnalyticsClient._();

  static const _sessionKey = 'analytics_session_id';
  static const _sessionTouchedKey = 'analytics_session_touched_ms';
  static const _sessionTtl = Duration(minutes: 30);
  static const _flushEvery = 8;

  final List<Map<String, dynamic>> _queue = [];
  final Map<int, DateTime> _recentPostViews = {};
  String? _sessionId;
  String? _appVersion;
  bool _lifecycleBound = false;
  Timer? _flushTimer;
  bool _flushing = false;

  String? get _platform {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return null;
  }

  Future<void> bootstrap() async {
    if (_lifecycleBound) return;
    _lifecycleBound = true;
    WidgetsBinding.instance.addObserver(this);
    await _ensureSession(forceNew: false);
    await trackAppOpen();
    await trackSessionStart();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(() async {
        await _ensureSession(forceNew: false);
        await trackAppOpen();
      }());
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      unawaited(flush(force: true));
    }
  }

  Future<void> trackAppOpen() => _enqueue('app_open');

  Future<void> trackSessionStart() => _enqueue('session_start');

  Future<void> trackScreenView(String screenName) => _enqueue(
        'screen_view',
        screenName: screenName,
      );

  Future<void> trackPostView(int postId) async {
    final now = DateTime.now();
    final last = _recentPostViews[postId];
    if (last != null && now.difference(last) < const Duration(seconds: 2)) {
      return;
    }
    _recentPostViews[postId] = now;
    await _enqueue('post_view', postId: postId);
  }

  Future<void> trackTrainingView(int trainingId) async {
    await _enqueue(
      'training_view',
      resourceType: 'training',
      resourceId: trainingId,
    );
  }

  /// Legacy alias kept for call sites.
  Future<void> trackTrainingJoin(int trainingId) => trackTrainingView(trainingId);

  Future<void> trackIecView(int iecId) async {
    await _enqueue(
      'iec_view',
      resourceType: 'iec_material',
      resourceId: iecId,
    );
  }

  Future<void> trackSearch({String? query}) async {
    await _enqueue(
      'search',
      metadata: query == null || query.trim().isEmpty
          ? null
          : <String, dynamic>{'q_len': query.trim().length},
    );
  }

  Future<void> trackBookmark(int postId) async {
    await _enqueue('bookmark', postId: postId);
  }

  Future<void> trackShare(int postId) async {
    await _enqueue('share', postId: postId);
  }

  Future<void> trackReview(int postId) async {
    await _enqueue('review', postId: postId);
  }

  Future<void> trackLike(int postId) async {
    await _enqueue('post_like', postId: postId);
  }

  Future<void> trackComment(int postId) async {
    await _enqueue('post_comment', postId: postId);
  }

  Future<void> trackNotificationOpen({String? notificationId}) async {
    await _enqueue(
      'notification_open',
      metadata: notificationId == null
          ? null
          : <String, dynamic>{'notification_id': notificationId},
    );
  }

  Future<void> trackFeatureUse(String feature) async {
    await _enqueue(
      'feature_use',
      screenName: feature,
      metadata: <String, dynamic>{'feature': feature},
    );
  }

  Future<void> _enqueue(
    String eventType, {
    int? postId,
    String? resourceType,
    int? resourceId,
    String? screenName,
    Map<String, dynamic>? metadata,
  }) async {
    final platform = _platform;
    if (platform == null) return;

    await _ensureSession(forceNew: false);
    _appVersion ??= (await PackageInfo.fromPlatform()).version;

    _queue.add(<String, dynamic>{
      'event_type': eventType,
      'platform': platform,
      'session_id': _sessionId,
      'app_version': _appVersion,
      'device_category': 'mobile',
      'os_name': Platform.isIOS ? 'ios' : 'android',
      'occurred_at': DateTime.now().toUtc().toIso8601String(),
      'post_id': ?postId,
      'resource_type': ?resourceType,
      'resource_id': ?resourceId,
      'screen_name': ?screenName,
      'metadata': ?metadata,
    });

    if (_queue.length >= _flushEvery) {
      await flush(force: true);
    } else {
      _flushTimer?.cancel();
      _flushTimer = Timer(const Duration(seconds: 4), () {
        unawaited(flush(force: true));
      });
    }
  }

  Future<void> flush({bool force = false}) async {
    if (_flushing || _queue.isEmpty) return;
    if (!force && _queue.length < 2) return;
    _flushing = true;
    final batch = List<Map<String, dynamic>>.from(_queue);
    _queue.clear();
    try {
      final token = await AuthService.getToken();
      final api = ApiClient(
        token: token,
        extraHeaders: {
          'X-Session-Id': ?_sessionId,
        },
      );
      await api.post<Map<String, dynamic>>(
        Endpoints.analyticsEvents,
        data: <String, dynamic>{'events': batch},
      );
    } on DioException catch (error) {
      // Re-queue on failure (cap to avoid unbounded growth).
      if (_queue.length + batch.length < 100) {
        _queue.insertAll(0, batch);
      }
      assert(() {
        // ignore: avoid_print
        print(
          'Analytics batch failed: ${error.response?.statusCode} ${error.message}',
        );
        return true;
      }());
    } finally {
      _flushing = false;
    }
  }

  Future<void> _ensureSession({required bool forceNew}) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    final existing = prefs.getString(_sessionKey);
    final touched = prefs.getInt(_sessionTouchedKey) ?? 0;
    final expired = now - touched > _sessionTtl.inMilliseconds;

    if (forceNew || existing == null || existing.isEmpty || expired) {
      _sessionId = _newSessionId();
      await prefs.setString(_sessionKey, _sessionId!);
    } else {
      _sessionId = existing;
    }
    await prefs.setInt(_sessionTouchedKey, now);
  }

  String _newSessionId() {
    final rand = Random.secure();
    final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    String hex(int b) => b.toRadixString(16).padLeft(2, '0');
    final h = bytes.map(hex).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20)}';
  }
}

/// Navigator observer that emits screen_view for named routes / widget types.
class AnalyticsNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _track(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) _track(newRoute);
  }

  void _track(Route<dynamic> route) {
    final name = route.settings.name;
    if (name != null && name.isNotEmpty) {
      unawaited(AnalyticsClient.instance.trackScreenView(name));
      return;
    }
    final runtime = route.settings.arguments;
    if (runtime is String && runtime.isNotEmpty) {
      unawaited(AnalyticsClient.instance.trackScreenView(runtime));
    }
  }
}
