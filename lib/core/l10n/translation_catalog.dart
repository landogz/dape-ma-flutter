import 'dart:async';

import 'package:flutter/foundation.dart';

import '../network/api_client.dart';
import '../network/endpoints.dart';
import '../utils/api_url.dart';
import 'app_locale.dart';
import 'translation_visual.dart';

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
  final Map<String, TranslationVisual> _assets = {};
  Future<void>? _inFlight;
  Timer? _syncTimer;
  String? _version;
  bool _paused = false;

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

  static TranslationVisual? visual(String key) {
    final asset = instance._assets[key];
    if (asset == null) return null;
    if (!asset.hasImage && !asset.hasIcon) return null;
    return asset;
  }

  static String? imageUrl(String key) => visual(key)?.imageUrl;

  static String? icon(String key) => visual(key)?.icon;

  static Future<void> prefetch({bool force = false}) {
    if (!force && instance.hasRemote) {
      return Future.value();
    }
    if (instance._inFlight != null && !force) {
      return instance._inFlight!;
    }

    final run = instance._fetchBoth();
    instance._inFlight = run;
    return run.whenComplete(() {
      if (identical(instance._inFlight, run)) {
        instance._inFlight = null;
      }
    });
  }

  static void startLiveSync() {
    instance._paused = false;
    instance._syncTimer?.cancel();
    instance._syncTimer = Timer.periodic(
      const Duration(seconds: 20),
      (_) {
        if (instance._paused) return;
        prefetch(force: true);
      },
    );
  }

  static void pauseLiveSync() {
    instance._paused = true;
  }

  static void resumeLiveSync() {
    instance._paused = false;
    prefetch(force: true);
  }

  static void stopLiveSync() {
    instance._syncTimer?.cancel();
    instance._syncTimer = null;
  }

  Future<void> _fetchBoth() async {
    try {
      final nextAssets = <String, TranslationVisual>{};
      String? nextVersion;
      await Future.wait([
        _fetchLocale('en', nextAssets, (version) {
          nextVersion ??= version;
        }),
        _fetchLocale('tl', nextAssets, (version) {
          nextVersion ??= version;
        }),
      ]);

      if (nextVersion != null &&
          nextVersion == _version &&
          hasRemote &&
          nextAssets.length == _assets.length) {
        return;
      }

      _version = nextVersion;
      _assets
        ..clear()
        ..addAll(nextAssets);
      notifyListeners();
    } catch (_) {
      // Keep built-in AppStrings fallbacks when the catalog is offline.
    }
  }

  Future<void> _fetchLocale(
    String locale,
    Map<String, TranslationVisual> nextAssets,
    void Function(String? version) onVersion,
  ) async {
    final client = ApiClient();
    final response = await client.get<Map<String, dynamic>>(
      Endpoints.translations,
      query: {'locale': locale},
    );
    final data = response.data?['data'];
    if (data is! Map) {
      return;
    }

    onVersion(data['version']?.toString());

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

    final assets = data['assets'];
    if (assets is Map) {
      assets.forEach((key, value) {
        final name = key.toString();
        if (name.isEmpty || value is! Map) {
          return;
        }
        final visual = TranslationVisual.fromJson(
          Map<String, dynamic>.from(value),
        );
        if (!visual.hasImage && !visual.hasIcon) {
          return;
        }
        nextAssets[name] = TranslationVisual(
          imageUrl: _stampUrl(
            ApiUrl.resolve(visual.imageUrl),
            data['version']?.toString(),
          ),
          icon: visual.icon,
        );
      });
    }
  }

  String? _stampUrl(String? url, String? version) {
    if (url == null || url.isEmpty) return url;
    final parsed = Uri.tryParse(url);
    if (parsed == null) return url;
    final stamp =
        (version != null && version.isNotEmpty) ? version : _version;
    if (stamp == null || stamp.isEmpty) return url;
    final query = Map<String, String>.from(parsed.queryParameters);
    query['v'] = stamp;
    return parsed.replace(queryParameters: query).toString();
  }
}
