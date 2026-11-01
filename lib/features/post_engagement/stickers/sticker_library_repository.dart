import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/models/sticker_pack.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/endpoints.dart';
import 'kid_listo_stickers.dart';

/// CMS sticker packs from `/sticker-packs`.
/// Polls so admin Sticker Library changes reflect on the mobile app.
class StickerLibraryRepository extends ChangeNotifier {
  StickerLibraryRepository._();

  static final StickerLibraryRepository instance = StickerLibraryRepository._();

  List<StickerPack> _packs = const [];
  String _signature = '';
  Future<void>? _inFlight;
  Timer? _syncTimer;
  bool _paused = false;
  DateTime? _cachedAt;

  static const _ttl = Duration(seconds: 20);

  List<StickerPack> get packs => List.unmodifiable(_packs);

  List<StickerItem> get stickers =>
      _packs.expand((pack) => pack.stickers).toList(growable: false);

  bool get hasRemote => _packs.isNotEmpty;

  static Future<void> prefetch({bool force = false}) {
    if (!force &&
        instance._packs.isNotEmpty &&
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

  Future<List<StickerPack>> fetchPacks({bool forceRefresh = false}) async {
    await prefetch(force: forceRefresh);
    return packs;
  }

  /// Flat list of remote stickers across active packs, or empty when offline/empty.
  Future<List<StickerItem>> fetchStickers({bool forceRefresh = false}) async {
    final next = await fetchPacks(forceRefresh: forceRefresh);
    return next.expand((pack) => pack.stickers).toList(growable: false);
  }

  Future<void> _fetch() async {
    try {
      final res = await ApiClient().get<Map<String, dynamic>>(
        Endpoints.stickerPacks,
      );
      final data = res.data?['data'];
      final next = data is List
          ? data
              .whereType<Map>()
              .map((item) => StickerPack.fromJson(Map<String, dynamic>.from(item)))
              .where((pack) => pack.stickers.isNotEmpty)
              .toList(growable: false)
          : const <StickerPack>[];

      final signature = _packsSignature(next);
      _cachedAt = DateTime.now();

      if (signature == _signature) {
        return;
      }

      _packs = next;
      _signature = signature;
      notifyListeners();
    } catch (_) {
      // Keep last good cache (or empty) so the picker can fall back to bundled stickers.
      _cachedAt = DateTime.now();
    }
  }

  static String _packsSignature(List<StickerPack> packs) {
    final buffer = StringBuffer();
    for (final pack in packs) {
      buffer
        ..write(pack.id)
        ..write(':')
        ..write(pack.name)
        ..write(':')
        ..write(pack.slug)
        ..write('|');
      for (final sticker in pack.stickers) {
        buffer
          ..write(sticker.id)
          ..write(':')
          ..write(sticker.name)
          ..write(':')
          ..write(sticker.imageUrl)
          ..write(';');
      }
      buffer.write('/');
    }
    return buffer.toString();
  }

  Future<File> fileFromRemote(StickerItem sticker) async {
    final dir = await getTemporaryDirectory();
    final uri = Uri.parse(sticker.imageUrl);
    final ext = _extensionFromPath(uri.path) ?? 'png';
    // Include URL hash so replaced CMS images are not stuck on an old temp file.
    final urlKey = sticker.imageUrl.hashCode.abs();
    final file = File('${dir.path}/sticker-remote-${sticker.id}-$urlKey.$ext');
    if (await file.exists() && await file.length() > 0) {
      return file;
    }

    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 45),
      responseType: ResponseType.bytes,
      validateStatus: (code) => code != null && code >= 200 && code < 400,
    ));
    final response = await dio.get<List<int>>(sticker.imageUrl);
    final bytes = response.data;
    if (bytes == null || bytes.isEmpty) {
      throw StateError('Empty sticker download');
    }
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  Future<File> fileFromAsset(String asset) {
    return KidListoStickers.fileFromAsset(asset);
  }

  String? _extensionFromPath(String path) {
    final name = path.split('/').last;
    final dot = name.lastIndexOf('.');
    if (dot < 0 || dot == name.length - 1) {
      return null;
    }
    final ext = name.substring(dot + 1).toLowerCase();
    if (ext.length > 5) {
      return null;
    }
    return ext;
  }
}
