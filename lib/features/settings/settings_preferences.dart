import 'package:shared_preferences/shared_preferences.dart';

/// Device-local preferences, scoped per signed-in user.
class SettingsPreferences {
  SettingsPreferences._();

  static const _guestScope = 'guest';
  static String _scope = _guestScope;

  static const _allowNotifications = 'settings_allow_notifications';
  static const _notifyArticles = 'settings_notify_articles';
  static const _notifyAchievements = 'settings_notify_achievements';
  static const _notifyEvents = 'settings_notify_events';
  static const _notifyUpdates = 'settings_notify_updates';
  static const _quietHours = 'settings_quiet_hours';
  static const _darkMode = 'settings_dark_mode';
  static const _highContrast = 'settings_high_contrast';
  static const _readAloud = 'settings_read_aloud';
  static const _captions = 'settings_captions';
  static const _reduceMotion = 'settings_reduce_motion';
  static const _textScale = 'settings_text_scale';

  static Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  static String get currentScope => _scope;

  /// Call after login/logout so each account keeps its own settings.
  static Future<void> setUserScope(String? userId) async {
    final normalized = (userId == null || userId.trim().isEmpty)
        ? _guestScope
        : 'u_${userId.trim()}';
    _scope = normalized;
  }

  static String _key(String key) => '${_scope}_$key';

  static Future<bool> getBool(String key, {bool fallback = false}) async {
    final prefs = await _prefs;
    return prefs.getBool(_key(key)) ?? fallback;
  }

  static Future<void> setBool(String key, bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_key(key), value);
  }

  static Future<double> getTextScale() async {
    final prefs = await _prefs;
    return prefs.getDouble(_key(_textScale)) ?? 1.0;
  }

  static Future<void> setTextScale(double value) async {
    final prefs = await _prefs;
    await prefs.setDouble(_key(_textScale), value.clamp(0.9, 1.4));
  }

  static String get allowNotifications => _allowNotifications;
  static String get notifyArticles => _notifyArticles;
  static String get notifyAchievements => _notifyAchievements;
  static String get notifyEvents => _notifyEvents;
  static String get notifyUpdates => _notifyUpdates;
  static String get quietHours => _quietHours;
  static String get darkMode => _darkMode;
  static String get highContrast => _highContrast;
  static String get readAloud => _readAloud;
  static String get captions => _captions;
  static String get reduceMotion => _reduceMotion;
}
