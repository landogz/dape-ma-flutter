import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/models/sticker_pack.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/endpoints.dart';
import 'kid_listo_stickers.dart';

class StickerLibraryRepository {
  StickerLibraryRepository._();

  static final StickerLibraryRepository instance = StickerLibraryRepository._();

  List<StickerPack>? _cache;
  DateTime? _cachedAt;
  static const _ttl = Duration(minutes: 10);

  Future<List<StickerPack>> fetchPacks({bool forceRefresh = false}) async {
    final now = DateTime.now();
    if (!forceRefresh &&
        _cache != null &&
        _cachedAt != null &&
        now.difference(_cachedAt!) < _ttl) {
      return _cache!;
    }

    try {
      final res = await ApiClient().get<Map<String, dynamic>>(
        Endpoints.stickerPacks,
      );
      final data = res.data?['data'];
      final packs = data is List
          ? data
              .whereType<Map>()
              .map((item) => StickerPack.fromJson(Map<String, dynamic>.from(item)))
              .where((pack) => pack.stickers.isNotEmpty)
              .toList()
          : <StickerPack>[];

      if (packs.isNotEmpty) {
        _cache = packs;
        _cachedAt = now;
        return packs;
      }
    } catch (_) {
      // Fall through to bundled stickers.
    }

    return const [];
  }

  /// Flat list of remote stickers across active packs, or empty when offline/empty.
  Future<List<StickerItem>> fetchStickers({bool forceRefresh = false}) async {
    final packs = await fetchPacks(forceRefresh: forceRefresh);
    return packs.expand((pack) => pack.stickers).toList();
  }

  Future<File> fileFromRemote(StickerItem sticker) async {
    final dir = await getTemporaryDirectory();
    final uri = Uri.parse(sticker.imageUrl);
    final ext = _extensionFromPath(uri.path) ?? 'png';
    final file = File('${dir.path}/sticker-remote-${sticker.id}.$ext');
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
