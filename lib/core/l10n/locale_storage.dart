import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'app_locale.dart';

class LocaleStorage {
  LocaleStorage._();

  static const _localeKey = 'dape_ma_locale';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<AppLocale> read() async {
    final code = await _storage.read(key: _localeKey);

    return AppLocale.fromCode(code);
  }

  static Future<void> write(AppLocale locale) {
    return _storage.write(key: _localeKey, value: locale.code);
  }
}
