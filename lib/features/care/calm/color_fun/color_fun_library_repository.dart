import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/models/color_fun_worksheet.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';

/// CMS Color Fun worksheets from `/color-fun-worksheets`.
/// Polls so admin Color Fun Library changes reflect on the mobile app.
class ColorFunLibraryRepository extends ChangeNotifier {
  ColorFunLibraryRepository._();

  static final ColorFunLibraryRepository instance = ColorFunLibraryRepository._();

  List<ColorFunWorksheet> _worksheets = const [];
  String _signature = '';
  Future<void>? _inFlight;
  Timer? _syncTimer;
  bool _paused = false;
  DateTime? _cachedAt;
  bool _loading = false;

  static const _ttl = Duration(seconds: 20);

  List<ColorFunWorksheet> get worksheets => List.unmodifiable(_worksheets);

  bool get hasRemote => _worksheets.isNotEmpty;

  bool get isLoading => _loading && _worksheets.isEmpty;

  static Future<void> prefetch({bool force = false}) {
    if (!force &&
        instance._worksheets.isNotEmpty &&
        instance._cachedAt != null &&
        DateTime.now().difference(instance._cachedAt!) < _ttl) {
      return Future.value();
    }
    if (!force && instance._inFlight != null) {
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

  Future<List<ColorFunWorksheet>> fetchWorksheets({bool forceRefresh = false}) async {
    await prefetch(force: forceRefresh);
    return worksheets;
  }

  Future<void> _fetch() async {
    _loading = true;
    notifyListeners();
    try {
      final res = await ApiClient().get<Map<String, dynamic>>(
        Endpoints.colorFunWorksheets,
      );
      final data = res.data?['data'];
      final next = data is List
          ? data
              .whereType<Map>()
              .map((item) => ColorFunWorksheet.fromJson(Map<String, dynamic>.from(item)))
              .where((item) => item.id > 0 && item.hasImage)
              .toList(growable: false)
          : const <ColorFunWorksheet>[];

      final signature = _signatureFor(next);
      _cachedAt = DateTime.now();
      _loading = false;

      if (signature == _signature) {
        notifyListeners();
        return;
      }

      _worksheets = next;
      _signature = signature;
      notifyListeners();
    } catch (_) {
      _loading = false;
      _cachedAt = DateTime.now();
      notifyListeners();
    }
  }

  static String _signatureFor(List<ColorFunWorksheet> items) {
    final buffer = StringBuffer();
    for (final item in items) {
      buffer
        ..write(item.id)
        ..write(':')
        ..write(item.title)
        ..write(':')
        ..write(item.category)
        ..write(':')
        ..write(item.imageUrl)
        ..write(':')
        ..write(item.sortOrder)
        ..write(';');
    }
    return buffer.toString();
  }
}
