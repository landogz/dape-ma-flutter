import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/models/relaxing_music_track.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import 'relaxing_tracks.dart';

/// CMS relaxing tracks from `/relaxing-music-tracks`.
/// Falls back to bundled [kRelaxingTracks] when the API is empty or offline.
class RelaxingMusicRepository extends ChangeNotifier {
  RelaxingMusicRepository._();

  static final RelaxingMusicRepository instance = RelaxingMusicRepository._();

  List<RelaxingMusicTrackDto> _tracks = const [];
  String _signature = '';
  Future<void>? _inFlight;
  Timer? _syncTimer;
  bool _paused = false;
  DateTime? _cachedAt;
  bool _loading = false;

  static const _ttl = Duration(seconds: 20);

  List<RelaxingMusicTrackDto> get tracks => List.unmodifiable(_tracks);

  bool get hasRemote => _tracks.isNotEmpty;

  bool get isLoading => _loading && _tracks.isEmpty;

  static Future<void> prefetch({bool force = false}) {
    if (!force &&
        instance._tracks.isNotEmpty &&
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

  Future<List<PlayableRelaxingTrack>> fetchPlayable({bool forceRefresh = false}) async {
    await prefetch(force: forceRefresh);
    if (_tracks.isNotEmpty) {
      return _tracks
          .where((t) => t.audioUrl.isNotEmpty)
          .map(
            (t) => PlayableRelaxingTrack(
              id: 'remote-${t.id}',
              titleEn: t.title,
              titleTl: t.titleTl.isNotEmpty ? t.titleTl : t.title,
              audioUrl: t.audioUrl,
              asset: null,
            ),
          )
          .toList(growable: false);
    }

    return kRelaxingTracks
        .map(
          (t) => PlayableRelaxingTrack(
            id: t.id,
            titleEn: null,
            titleTl: null,
            audioUrl: null,
            asset: t.asset,
            bundled: t,
          ),
        )
        .toList(growable: false);
  }

  Future<void> _fetch() async {
    _loading = true;
    notifyListeners();
    try {
      final response = await ApiClient().get(Endpoints.relaxingMusicTracks);
      final raw = response.data;
      final list = raw is Map && raw['data'] is List
          ? (raw['data'] as List)
          : (raw is List ? raw : const []);
      final next = list
          .whereType<Map>()
          .map((row) => RelaxingMusicTrackDto.fromJson(Map<String, dynamic>.from(row)))
          .where((t) => t.audioUrl.isNotEmpty)
          .toList(growable: false);
      final signature = next.map((t) => '${t.id}:${t.audioUrl}:${t.title}').join('|');
      if (signature != _signature) {
        _signature = signature;
        _tracks = next;
        notifyListeners();
      }
      _cachedAt = DateTime.now();
    } catch (_) {
      // Keep last good list; UI falls back to bundled assets when empty.
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}

class PlayableRelaxingTrack {
  const PlayableRelaxingTrack({
    required this.id,
    required this.titleEn,
    required this.titleTl,
    required this.audioUrl,
    required this.asset,
    this.bundled,
  });

  final String id;
  final String? titleEn;
  final String? titleTl;
  final String? audioUrl;
  final String? asset;
  final RelaxingTrack? bundled;

  bool get isRemote => audioUrl != null && audioUrl!.isNotEmpty;

  String titleOf(AppStrings l10n) {
    if (bundled != null) {
      return bundled!.titleOf(l10n);
    }
    if (l10n.isTagalog) {
      final tl = titleTl?.trim();
      if (tl != null && tl.isNotEmpty) {
        return tl;
      }
    }
    final en = titleEn?.trim();
    if (en != null && en.isNotEmpty) {
      return en;
    }
    return titleTl?.trim().isNotEmpty == true ? titleTl!.trim() : 'Relaxing track';
  }
}
