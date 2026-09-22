import 'package:flutter/foundation.dart';

import '../../features/settings/settings_preferences.dart';

class AccessibilityController extends ChangeNotifier {
  AccessibilityController._();

  static final AccessibilityController instance = AccessibilityController._();

  bool _loaded = false;
  bool _darkMode = false;
  bool _highContrast = false;
  bool _readAloud = false;
  bool _captions = false;
  bool _reduceMotion = false;
  double _textScale = 1.0;

  bool get isLoaded => _loaded;
  bool get darkMode => _darkMode;
  bool get highContrast => _highContrast;
  bool get readAloud => _readAloud;
  bool get captions => _captions;
  bool get reduceMotion => _reduceMotion;
  double get textScale => _textScale;

  Future<void> load() async {
    _darkMode = await SettingsPreferences.getBool(SettingsPreferences.darkMode);
    _highContrast =
        await SettingsPreferences.getBool(SettingsPreferences.highContrast);
    _readAloud = await SettingsPreferences.getBool(SettingsPreferences.readAloud);
    _captions = await SettingsPreferences.getBool(SettingsPreferences.captions);
    _reduceMotion =
        await SettingsPreferences.getBool(SettingsPreferences.reduceMotion);
    _textScale = await SettingsPreferences.getTextScale();
    _loaded = true;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    notifyListeners();
    await SettingsPreferences.setBool(SettingsPreferences.darkMode, value);
  }

  Future<void> setHighContrast(bool value) async {
    _highContrast = value;
    notifyListeners();
    await SettingsPreferences.setBool(SettingsPreferences.highContrast, value);
  }

  Future<void> setReadAloud(bool value) async {
    _readAloud = value;
    notifyListeners();
    await SettingsPreferences.setBool(SettingsPreferences.readAloud, value);
  }

  Future<void> setCaptions(bool value) async {
    _captions = value;
    notifyListeners();
    await SettingsPreferences.setBool(SettingsPreferences.captions, value);
  }

  Future<void> setReduceMotion(bool value) async {
    _reduceMotion = value;
    notifyListeners();
    await SettingsPreferences.setBool(SettingsPreferences.reduceMotion, value);
  }

  Future<void> setTextScale(double value) async {
    _textScale = value.clamp(0.9, 1.4);
    notifyListeners();
    await SettingsPreferences.setTextScale(_textScale);
  }

  /// Live preview without waiting for Save (not persisted until [setTextScale]).
  void previewTextScale(double value) {
    final next = value.clamp(0.9, 1.4);
    if (_textScale == next) return;
    _textScale = next;
    notifyListeners();
  }
}
