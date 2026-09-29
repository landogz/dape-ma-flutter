import 'dart:convert';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../core/auth/auth_service.dart';
import '../../core/network/endpoints.dart';
import 'firebase_push_config.dart';

/// Background isolate entrypoint for FCM.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (!FirebasePushConfig.isConfigured) {
    return;
  }

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  } catch (_) {
    // Credentials may be missing on this build.
  }
}

class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _firebaseReady = false;
  GlobalKey<NavigatorState>? _navigatorKey;

  void attachNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    if (!FirebasePushConfig.isConfigured) {
      debugPrint(
        '[Push] Disabled — set FirebasePushConfig.isConfigured and add Firebase files. See docs/PUSH_NOTIFICATIONS.md',
      );
      return;
    }

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      _firebaseReady = true;
    } catch (error, stack) {
      debugPrint('[Push] Firebase.initializeApp failed: $error\n$stack');
      return;
    }

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    final messaging = FirebaseMessaging.instance;
    await _setupLocalNotifications();
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('[Push] Permission: ${settings.authorizationStatus}');

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpen);

    final initial = await messaging.getInitialMessage();
    if (initial != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleMessageOpen(initial);
      });
    }

    messaging.onTokenRefresh.listen((token) {
      _registerToken(token);
    });

    await syncTokenWithBackend();
  }

  Future<void> syncTokenWithBackend() async {
    if (!FirebasePushConfig.isConfigured || !_firebaseReady) {
      return;
    }

    final loggedIn = await AuthService.isLoggedIn();
    if (!loggedIn) {
      return;
    }

    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) {
        return;
      }
      await _registerToken(token);
    } catch (error) {
      debugPrint('[Push] getToken/register failed: $error');
    }
  }

  Future<void> _registerToken(String token) async {
    final platform = kIsWeb
        ? 'web'
        : Platform.isIOS
            ? 'ios'
            : Platform.isAndroid
                ? 'android'
                : 'web';

    try {
      await AuthService.authedPut<Map<String, dynamic>>(
        Endpoints.fcmToken,
        data: <String, dynamic>{
          'fcm_token': token,
          'platform': platform,
        },
      );
      debugPrint('[Push] Token registered ($platform)');
    } catch (error) {
      debugPrint('[Push] Token register API failed: $error');
    }
  }

  Future<void> _setupLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _local.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) {
          return;
        }
        try {
          final map = jsonDecode(payload) as Map<String, dynamic>;
          _openFromData(map);
        } catch (_) {}
      },
    );

    final androidPlugin = _local.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'dape_push',
        'DAPE-MA Alerts',
        description: 'Push notifications from DAPE-MA',
        importance: Importance.high,
      ),
    );

    if (!kIsWeb && Platform.isAndroid) {
      await androidPlugin?.requestNotificationsPermission();
    }
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    final title =
        notification?.title ?? message.data['title']?.toString() ?? 'DAPE-MA';
    final body = notification?.body ?? message.data['body']?.toString() ?? '';

    await _local.show(
      message.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'dape_push',
          'DAPE-MA Alerts',
          channelDescription: 'Push notifications from DAPE-MA',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void _handleMessageOpen(RemoteMessage message) {
    _openFromData(message.data);
  }

  void _openFromData(Map<String, dynamic> data) {
    final nav = _navigatorKey?.currentState;
    if (nav == null) {
      return;
    }

    debugPrint('[Push] Opened with data: $data');
  }
}
