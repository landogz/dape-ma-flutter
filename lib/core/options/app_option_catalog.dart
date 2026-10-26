import 'package:flutter/material.dart';

import '../../features/auth/registration/registration_constants.dart';
import '../../features/diary/widgets/journal_wizard/journal_constants.dart';
import '../l10n/locale_controller.dart';
import '../network/api_client.dart';
import '../network/endpoints.dart';
import '../theme/app_colors.dart';
import 'app_option_icons.dart';
import 'app_option_item.dart';

class AppOptionCatalog {
  AppOptionCatalog._();

  static const pronounsGroup = 'pronouns';
  static const personaGroup = 'persona';
  static const journalSkyGroup = 'journal_sky';
  static const journalFeelingGroup = 'journal_feeling';
  static const journalImpactGroup = 'journal_impact';

  static Map<String, List<AppOptionItem>> _byGroup = {};
  static Future<void>? _inFlight;

  static bool get hasRemote => _byGroup.isNotEmpty;

  static Future<void> prefetch({String? locale, bool force = false}) {
    if (!force && _byGroup.isNotEmpty) {
      return Future.value();
    }
    if (!force && _inFlight != null) {
      return _inFlight!;
    }

    _inFlight = _fetch(locale: locale);
    return _inFlight!;
  }

  static Future<void> _fetch({String? locale}) async {
    try {
      final client = ApiClient();
      final response = await client.get<Map<String, dynamic>>(
        Endpoints.appOptions,
        query: {
          'locale': locale ?? LocaleController.instance.locale.code,
        },
      );
      final data = response.data?['data'];
      if (data is! List) {
        return;
      }

      final next = <String, List<AppOptionItem>>{};
      for (final raw in data) {
        if (raw is! Map) continue;
        final group = (raw['key'] ?? '').toString();
        final options = raw['options'];
        if (group.isEmpty || options is! List) continue;

        next[group] = options
            .whereType<Map>()
            .map((item) {
              final map = Map<String, dynamic>.from(item);
              final fallbackIcon = _fallbackIconFor(group);
              return AppOptionItem.fromJson(
                map,
                fallbackIcon: appOptionIcon(
                  map['icon']?.toString(),
                  fallback: fallbackIcon,
                ),
                fallbackAccent: parseHexColor(map['accent']?.toString()),
              );
            })
            .where((item) => item.key.isNotEmpty)
            .toList();
      }

      if (next.isNotEmpty) {
        _byGroup = next;
      }
    } catch (_) {
      // Keep built-in fallbacks.
    } finally {
      _inFlight = null;
    }
  }

  static List<AppOptionItem> pronouns() {
    final remote = _byGroup[pronounsGroup];
    if (remote != null && remote.isNotEmpty) {
      return remote;
    }
    return RegistrationConstants.pronouns
        .map(
          (item) => AppOptionItem(
            key: item.key,
            labelEn: item.labelEn,
            labelTl: item.labelTl,
          ),
        )
        .toList();
  }

  static List<AppOptionItem> personas() {
    final remote = _byGroup[personaGroup];
    if (remote != null && remote.isNotEmpty) {
      return remote;
    }
    return RegistrationConstants.personas
        .map(
          (item) => AppOptionItem(
            key: item.key,
            labelEn: item.labelEn,
            labelTl: item.labelTl,
            icon: item.icon,
          ),
        )
        .toList();
  }

  static List<JournalSkyOption> skies() {
    final remote = _byGroup[journalSkyGroup];
    if (remote == null || remote.isEmpty) {
      return JournalConstants.skyOptions;
    }
    return remote
        .map(
          (item) => JournalSkyOption(
            key: item.key,
            labelEn: item.labelEn,
            labelTl: item.labelTl,
            subtitleEn: item.subtitleEn,
            subtitleTl: item.subtitleTl,
            icon: item.icon,
            iconName: item.iconName,
            accent: item.accent ?? AppColors.primaryBlue,
          ),
        )
        .toList();
  }

  static List<JournalFeelingOption> feelings() {
    final remote = _byGroup[journalFeelingGroup];
    if (remote == null || remote.isEmpty) {
      return JournalConstants.feelingOptions;
    }
    return remote
        .map(
          (item) => JournalFeelingOption(
            key: item.key,
            labelEn: item.labelEn,
            labelTl: item.labelTl,
            accent: item.accent,
            icon: hasAppOptionIconName(item.iconName) ? item.icon : null,
          ),
        )
        .toList();
  }

  static List<JournalImpactOption> impacts() {
    final remote = _byGroup[journalImpactGroup];
    if (remote == null || remote.isEmpty) {
      return JournalConstants.impactOptions;
    }
    return remote
        .map(
          (item) => JournalImpactOption(
            key: item.key,
            labelEn: item.labelEn,
            labelTl: item.labelTl,
            icon: item.icon,
          ),
        )
        .toList();
  }

  static JournalSkyOption? skyByKey(String? key) {
    if (key == null || key.isEmpty) return null;
    for (final option in skies()) {
      if (option.key == key) return option;
    }
    return JournalConstants.skyByKey(key);
  }

  static JournalImpactOption? impactByKey(String? key) {
    if (key == null || key.isEmpty) return null;
    for (final option in impacts()) {
      if (option.key == key) return option;
    }
    return JournalConstants.impactByKey(key);
  }

  static String feelingLabel(String key, {required bool isTagalog}) {
    for (final option in feelings()) {
      if (option.key.toLowerCase() == key.toLowerCase()) {
        return isTagalog ? option.labelTl : option.labelEn;
      }
    }
    return JournalConstants.feelingLabel(key, isTagalog: isTagalog);
  }

  static String impactLabel(String? key, {required bool isTagalog}) {
    final option = impactByKey(key);
    if (option == null) return key ?? '';
    return isTagalog ? option.labelTl : option.labelEn;
  }

  static Color accentForSky(String? sky) {
    return skyByKey(sky)?.accent ?? JournalConstants.accentForSky(sky);
  }

  static IconData _fallbackIconFor(String group) {
    return switch (group) {
      personaGroup => Icons.person_outline,
      journalSkyGroup => Icons.palette_outlined,
      journalImpactGroup => Icons.place_outlined,
      _ => Icons.label_outline,
    };
  }
}
