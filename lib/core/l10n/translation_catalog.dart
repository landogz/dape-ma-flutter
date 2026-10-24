import 'package:flutter/foundation.dart';

import '../network/api_client.dart';
import '../network/endpoints.dart';
import 'app_locale.dart';

class TranslationCatalog extends ChangeNotifier {
  TranslationCatalog._();

  static final TranslationCatalog instance = TranslationCatalog._();

  static const _bibleKeys = {
    'bibleTitle',
    'searchBibleBooks',
    'oldTestament',
    'newTestament',
    'noBibleBooksFound',
    'bibleLoadFailed',
    'bibleLanguageNote',
    'chaptersLabel',
  };

  final Map<String, Map<String, String>> _byLocale = {
    'en': {},
    'tl': {},
  };
  Future<void>? _inFlight;

  bool get hasRemote =>
      _byLocale['en']!.isNotEmpty || _byLocale['tl']!.isNotEmpty;

  static String? value(String key, AppLocale locale) {
    if (_bibleKeys.contains(key)) {
      return null;
    }
    final map = instance._byLocale[locale.code] ?? const {};
    final remote = map[key];
    if (remote == null || remote.trim().isEmpty) {
      return null;
    }
    return remote;
  }

  static Future<void> prefetch({bool force = false}) {
    if (!force && instance.hasRemote) {
      return Future.value();
    }
    if (!force && instance._inFlight != null) {
      return instance._inFlight!;
    }

    instance._inFlight = instance._fetchBoth();
    return instance._inFlight!;
  }

  Future<void> _fetchBoth() async {
    try {
      await Future.wait([
        _fetchLocale('en'),
        _fetchLocale('tl'),
      ]);
      notifyListeners();
    } catch (_) {
      // Keep built-in AppStrings fallbacks when the catalog is offline.
    } finally {
      _inFlight = null;
    }
  }

  Future<void> _fetchLocale(String locale) async {
    final client = ApiClient();
    final response = await client.get<Map<String, dynamic>>(
      Endpoints.translations,
      query: {'locale': locale},
    );
    final data = response.data?['data'];
    if (data is! Map) {
      return;
    }
    final strings = data['strings'];
    if (strings is! Map) {
      return;
    }

    final next = <String, String>{};
    strings.forEach((key, value) {
      final name = key.toString();
      if (name.isEmpty || _bibleKeys.contains(name)) {
        return;
      }
      final text = value?.toString() ?? '';
      if (text.isEmpty) {
        return;
      }
      next[name] = text;
    });

    if (next.isNotEmpty) {
      _byLocale[locale] = next;
    }
  }
}
