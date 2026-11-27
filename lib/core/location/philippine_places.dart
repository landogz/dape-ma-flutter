import 'dart:convert';

import 'package:flutter/services.dart';

import '../auth/auth_service.dart';
import '../network/endpoints.dart';

/// Cascading PH Region → Province → City/Municipality catalog.
///
/// Prefers live PSA PSGC via Laravel `/locations/*` (token stays server-side).
/// Falls back to the bundled asset when the API is unreachable.
class PhilippinePlaces {
  PhilippinePlaces._();

  static const assetPath = 'assets/location/ph_places.json';

  static Map<String, Map<String, List<String>>>? _tree;
  static Future<void>? _loading;
  static bool _useApi = false;

  static List<_PsgcPlace> _regions = const [];
  static final Map<int, List<_PsgcPlace>> _provincesByReg = {};
  static final Map<int, List<_PsgcPlace>> _citiesByPrv = {};
  static final Map<String, Future<void>> _provinceLoads = {};
  static final Map<String, Future<void>> _cityLoads = {};

  static bool get isReady => _useApi ? _regions.isNotEmpty : _tree != null;

  static Future<void> ensureLoaded() {
    if (isReady) return Future.value();
    return _loading ??= _bootstrap().whenComplete(() => _loading = null);
  }

  static Future<void> _bootstrap() async {
    try {
      final items = await _fetchItems(Endpoints.locationsRegions);
      if (items.isNotEmpty) {
        _regions = items;
        _useApi = true;
        return;
      }
    } catch (_) {
      // Fall through to bundled asset.
    }
    await _loadAsset();
    _useApi = false;
  }

  static Future<void> _loadAsset() async {
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      _tree = {};
      return;
    }
    final next = <String, Map<String, List<String>>>{};
    for (final regionEntry in decoded.entries) {
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
    _tree = next;
  }

  static List<String> regions() {
    if (_useApi) {
      return _regions.map((place) => place.name).toList(growable: false);
    }
    final tree = _tree;
    if (tree == null) return const [];
    return tree.keys.toList(growable: false);
  }

  static List<String> provincesFor(String? region) {
    if (_useApi) {
      final reg = _regCodeFor(region);
      if (reg == null) return const [];
      return (_provincesByReg[reg] ?? const [])
          .map((place) => place.name)
          .toList(growable: false);
    }
    final tree = _tree;
    if (tree == null || region == null || region.isEmpty) return const [];
    return tree[region]?.keys.toList(growable: false) ?? const [];
  }

  static List<String> citiesFor(String? region, String? province) {
    if (_useApi) {
      final place = _provincePlace(region, province);
      if (place?.prv == null) return const [];
      final cities = _citiesByPrv[place!.prv!] ?? const [];
      if (cities.isNotEmpty) {
        return cities.map((item) => item.name).toList(growable: false);
      }
      // NCR / HUC: province row is the city.
      return province == null || province.isEmpty
          ? const []
          : [province];
    }
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

  /// Load provinces for [region] when using the live PSGC API.
  static Future<List<String>> ensureProvinces(String? region) async {
    await ensureLoaded();
    if (!_useApi) return provincesFor(region);
    final reg = _regCodeFor(region);
    if (reg == null) return const [];
    final key = 'reg-$reg';
    await (_provinceLoads[key] ??= _loadProvinces(reg).whenComplete(() {
      _provinceLoads.remove(key);
    }));
    return provincesFor(region);
  }

  /// Load cities for [province] when using the live PSGC API.
  static Future<List<String>> ensureCities(
    String? region,
    String? province,
  ) async {
    await ensureLoaded();
    if (!_useApi) return citiesFor(region, province);
    final place = _provincePlace(region, province);
    final prv = place?.prv;
    if (prv == null) return const [];
    final key = 'prv-$prv';
    await (_cityLoads[key] ??= _loadCities(prv, province).whenComplete(() {
      _cityLoads.remove(key);
    }));
    return citiesFor(region, province);
  }

  static Future<void> _loadProvinces(int reg) async {
    if (_provincesByReg.containsKey(reg)) return;
    final items = await _fetchItems(
      Endpoints.locationsProvinces,
      query: {'reg': reg},
    );
    _provincesByReg[reg] = items;
  }

  static Future<void> _loadCities(int prv, String? provinceName) async {
    if (_citiesByPrv.containsKey(prv)) return;
    final items = await _fetchItems(
      Endpoints.locationsCities,
      query: {
        'prv': prv,
        if (provinceName != null && provinceName.isNotEmpty)
          'province_name': provinceName,
      },
    );
    _citiesByPrv[prv] = items;
  }

  static Future<List<_PsgcPlace>> _fetchItems(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final res = await AuthService.authedGet<Map<String, dynamic>>(
      path,
      query: query,
    );
    final root = res.data ?? <String, dynamic>{};
    final data = root['data'];
    if (data is! Map) return const [];
    final rawItems = data['items'];
    if (rawItems is! List) return const [];
    return rawItems
        .whereType<Map>()
        .map(_PsgcPlace.fromJson)
        .where((place) => place.name.isNotEmpty)
        .toList(growable: false);
  }

  /// Best-effort map of free-text / GPS labels onto catalog values.
  static Future<({String? region, String? province, String? city})> matchAsync({
    String? region,
    String? province,
    String? city,
  }) async {
    await ensureLoaded();
    final matchedRegion = _matchOne(regions(), region);
    final provinces = await ensureProvinces(matchedRegion);
    final matchedProvince = _matchOne(provinces, province) ??
        _matchOne(provinces, city);
    final cities = await ensureCities(matchedRegion, matchedProvince);
    final matchedCity = _matchOne(cities, city) ??
        _matchOne(cities, province) ??
        (cities.length == 1 ? cities.first : null);
    return (
      region: matchedRegion,
      province: matchedProvince,
      city: matchedCity,
    );
  }

  /// Sync match — asset mode only, or already-cached API rows.
  static ({String? region, String? province, String? city}) match({
    String? region,
    String? province,
    String? city,
  }) {
    final matchedRegion = _matchOne(regions(), region);
    final matchedProvince = _matchOne(provincesFor(matchedRegion), province) ??
        _matchOne(provincesFor(matchedRegion), city);
    final matchedCity = _matchOne(
          citiesFor(matchedRegion, matchedProvince),
          city,
        ) ??
        _matchOne(citiesFor(matchedRegion, matchedProvince), province);
    return (
      region: matchedRegion,
      province: matchedProvince,
      city: matchedCity,
    );
  }

  static int? _regCodeFor(String? region) {
    if (region == null || region.isEmpty) return null;
    for (final place in _regions) {
      if (place.name == region) return place.reg;
    }
    final matched = _matchOne(regions(), region);
    if (matched == null) return null;
    for (final place in _regions) {
      if (place.name == matched) return place.reg;
    }
    return null;
  }

  static _PsgcPlace? _provincePlace(String? region, String? province) {
    final reg = _regCodeFor(region);
    if (reg == null || province == null || province.isEmpty) return null;
    final list = _provincesByReg[reg] ?? const [];
    for (final place in list) {
      if (place.name == province) return place;
    }
    final matched = _matchOne(
      list.map((item) => item.name).toList(growable: false),
      province,
    );
    if (matched == null) return null;
    for (final place in list) {
      if (place.name == matched) return place;
    }
    return null;
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

class _PsgcPlace {
  const _PsgcPlace({
    required this.code,
    required this.name,
    this.reg,
    this.prv,
  });

  final String code;
  final String name;
  final int? reg;
  final int? prv;

  factory _PsgcPlace.fromJson(Map raw) {
    int? asInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value > 0 ? value : null;
      final parsed = int.tryParse(value.toString());
      if (parsed == null || parsed <= 0) return null;
      return parsed;
    }

    return _PsgcPlace(
      code: raw['code']?.toString() ?? '',
      name: raw['name']?.toString().trim() ?? '',
      reg: asInt(raw['reg']),
      prv: asInt(raw['prv']),
    );
  }
}
