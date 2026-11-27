import 'dart:convert';

import 'package:flutter/services.dart';

import '../auth/auth_service.dart';
import '../network/endpoints.dart';

/// Cascading PH Region → Province → City/Municipality catalog.
///
/// Prefers Laravel `/locations/tree` (PSA snapshot, server-side token).
/// Falls back to the bundled asset when the API is unreachable.
class PhilippinePlaces {
  PhilippinePlaces._();

  static const assetPath = 'assets/location/ph_places.json';

  static Map<String, Map<String, List<String>>>? _tree;
  static Future<void>? _loading;

  static bool get isReady => _tree != null;

  static Future<void> ensureLoaded() {
    if (_tree != null) return Future.value();
    return _loading ??= _bootstrap().whenComplete(() => _loading = null);
  }

  static Future<void> _bootstrap() async {
    try {
      final res = await AuthService.authedGet<Map<String, dynamic>>(
        Endpoints.locationsTree,
      );
      final root = res.data ?? <String, dynamic>{};
      final data = root['data'];
      if (data is Map && data['tree'] is Map) {
        final parsed = _parseTree(data['tree'] as Map);
        if (parsed.isNotEmpty) {
          _tree = parsed;
          return;
        }
      }
    } catch (_) {
      // Fall through to bundled asset.
    }
    await _loadAsset();
  }

  static Future<void> _loadAsset() async {
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw);
    _tree = decoded is Map ? _parseTree(decoded) : {};
  }

  static Map<String, Map<String, List<String>>> _parseTree(Map raw) {
    final next = <String, Map<String, List<String>>>{};
    for (final regionEntry in raw.entries) {
      final region = regionEntry.key.toString();
      final provincesRaw = regionEntry.value;
      if (provincesRaw is! Map) continue;
      final provinces = <String, List<String>>{};
      for (final provinceEntry in provincesRaw.entries) {
        final province = provinceEntry.key.toString();
        final citiesRaw = provinceEntry.value;
        if (citiesRaw is! List) continue;
        provinces[province] = citiesRaw
            .map((item) => item.toString().trim())
            .where((item) => item.isNotEmpty)
            .toList(growable: false);
      }
      next[region] = provinces;
    }
    return next;
  }

  static List<String> regions() {
    final tree = _tree;
    if (tree == null) return const [];
    return tree.keys.toList(growable: false);
  }

  static List<String> provincesFor(String? region) {
    final tree = _tree;
    if (tree == null || region == null || region.isEmpty) return const [];
    return tree[region]?.keys.toList(growable: false) ?? const [];
  }

  static List<String> citiesFor(String? region, String? province) {
    final tree = _tree;
    if (tree == null ||
        region == null ||
        region.isEmpty ||
        province == null ||
        province.isEmpty) {
      return const [];
    }
    return tree[region]?[province] ?? const [];
  }

  /// Best-effort map of free-text / GPS labels onto catalog values.
  static ({String? region, String? province, String? city}) match({
    String? region,
    String? province,
    String? city,
  }) {
    final matchedRegion = _matchOne(regions(), region);
    final matchedProvince = _matchOne(provincesFor(matchedRegion), province) ??
        _matchOne(provincesFor(matchedRegion), city);
    final cities = citiesFor(matchedRegion, matchedProvince);
    final matchedCity = _matchOne(cities, city) ??
        _matchOne(cities, province) ??
        (cities.length == 1 ? cities.first : null);
    return (
      region: matchedRegion,
      province: matchedProvince,
      city: matchedCity,
    );
  }

  static String? _matchOne(List<String> options, String? raw) {
    final needle = _normalize(raw);
    if (needle.isEmpty || options.isEmpty) return null;

    for (final option in options) {
      if (_normalize(option) == needle) return option;
    }

    String? containsHit;
    for (final option in options) {
      final hay = _normalize(option);
      if (hay.contains(needle) || needle.contains(hay)) {
        if (containsHit == null || option.length < containsHit.length) {
          containsHit = option;
        }
      }
    }
    return containsHit;
  }

  static String _normalize(String? value) {
    if (value == null) return '';
    var text = value.toLowerCase().trim();
    text = text
        .replaceAll(RegExp(r'[^a-z0-9ñ\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    text = text
        .replaceFirst(RegExp(r'^region\s+[ivxlcdm0-9]+\s*'), '')
        .replaceFirst(RegExp(r'^city of\s+'), '')
        .replaceFirst(RegExp(r'\s+city$'), '')
        .replaceFirst(RegExp(r'^province of\s+'), '')
        .replaceFirst(RegExp(r'\s+province$'), '')
        .replaceFirst(RegExp(r'^municipality of\s+'), '')
        .trim();
    return text;
  }
}
