import 'dart:async';

import 'package:flutter/foundation.dart';

import '../network/api_client.dart';
import '../network/endpoints.dart';

class BlockedWordCatalog extends ChangeNotifier {
  BlockedWordCatalog._();

  static final BlockedWordCatalog instance = BlockedWordCatalog._();

  final List<String> _words = [];
  Future<void>? _inFlight;
  Timer? _syncTimer;
  String? _version;
  bool _paused = false;

  List<String> get words => List.unmodifiable(_words);

  bool get hasRemote => _words.isNotEmpty;

  static Future<void> prefetch({bool force = false}) {
    if (!force && instance.hasRemote) {
      return Future.value();
    }
    if (instance._inFlight != null && !force) {
      return instance._inFlight!;
    }

    final run = instance._fetch();
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

  Future<void> _fetch() async {
    try {
      final response = await ApiClient().get<Map<String, dynamic>>(
        Endpoints.blockedWords,
      );
      final data = response.data?['data'];
      if (data is! Map) {
        return;
      }

      final version = data['version']?.toString();
      final raw = data['words'];
      final next = <String>[];
      if (raw is List) {
        for (final item in raw) {
          final word = item?.toString().trim().toLowerCase() ?? '';
          if (word.length < 2) {
            continue;
          }
          next.add(word);
        }
      }
      next.sort((a, b) => b.length.compareTo(a.length));

      if (version != null &&
          version == _version &&
          listEquals(_words, next)) {
        return;
      }

      _version = version;
      _words
        ..clear()
        ..addAll(next);
      notifyListeners();
    } catch (_) {
      // Keep the last successful list when offline.
    }
  }
}
