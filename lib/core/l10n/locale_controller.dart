import 'package:flutter/foundation.dart';

import 'app_locale.dart';
import 'locale_storage.dart';

class LocaleController extends ChangeNotifier {
  LocaleController._();

  static final LocaleController instance = LocaleController._();

  AppLocale _locale = AppLocale.en;
  bool _loaded = false;

  AppLocale get locale => _locale;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    _locale = await LocaleStorage.read();
    _loaded = true;
    notifyListeners();
  }

  Future<void> setLocale(AppLocale locale) async {
    if (_locale == locale) {
      return;
    }

    _locale = locale;
    await LocaleStorage.write(locale);
    notifyListeners();
  }
}
