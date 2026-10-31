import 'dart:async';

import 'package:flutter/material.dart';

import '../../features/auth/registration/registration_constants.dart';
import '../../features/diary/widgets/journal_wizard/journal_constants.dart';
import '../l10n/locale_controller.dart';
import '../network/api_client.dart';
import '../network/endpoints.dart';
import '../theme/app_colors.dart';
import 'app_option_icons.dart';
import 'app_option_item.dart';

/// Lookups catalog from `/app-options` (pronouns, journal, care toolkits, …).
/// Polls so Active/Inactive changes in admin reflect on the mobile app.
class AppOptionCatalog extends ChangeNotifier {
  AppOptionCatalog._();

  static final AppOptionCatalog instance = AppOptionCatalog._();

  static const pronounsGroup = 'pronouns';
  static const personaGroup = 'persona';
  static const journalSkyGroup = 'journal_sky';
  static const journalFeelingGroup = 'journal_feeling';
  static const journalImpactGroup = 'journal_impact';
  static const careToolkitGroup = 'care_toolkit';
  static const careSupportGroup = 'care_support';

  Map<String, List<AppOptionItem>> _byGroup = {};
  Future<void>? _inFlight;
  Timer? _syncTimer;
  bool _paused = false;

  static bool get hasRemote => instance._byGroup.isNotEmpty;

  static Future<void> prefetch({String? locale, bool force = false}) {
    if (!force && instance._byGroup.isNotEmpty) {
      return Future.value();
    }
    if (!force && instance._inFlight != null) {
      return instance._inFlight!;
    }

    final run = instance._fetch(locale: locale);
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

  Future<void> _fetch({String? locale}) async {
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
        notifyListeners();
      }
    } catch (_) {
      // Keep built-in fallbacks.
    }
  }

  static List<AppOptionItem> pronouns() {
    final remote = instance._byGroup[pronounsGroup];
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
    final remote = instance._byGroup[personaGroup];
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
    final remote = instance._byGroup[journalSkyGroup];
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
    final remote = instance._byGroup[journalFeelingGroup];
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
    final remote = instance._byGroup[journalImpactGroup];
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

  /// Active Care Get Support categories from Lookups (`care_support`).
  static List<AppOptionItem> careSupportCategories() {
    final remote = instance._byGroup[careSupportGroup];
    if (remote != null) {
      return List<AppOptionItem>.from(remote);
    }
    return const [
      AppOptionItem(
        key: 'hotline',
        labelEn: '24/7 Hotlines',
        labelTl: '24/7 Hotlines',
        subtitleEn: 'Crisis and support hotlines',
        subtitleTl: 'Mga hotline para sa krisis at suporta',
        iconName: 'phone_outlined',
        icon: Icons.phone_outlined,
        sortOrder: 1,
      ),
      AppOptionItem(
        key: 'counseling',
        labelEn: 'Counseling',
        labelTl: 'Counseling',
        subtitleEn: 'Counseling and talk support',
        subtitleTl: 'Counseling at usapang tulong',
        iconName: 'chat_outlined',
        icon: Icons.chat_outlined,
        sortOrder: 2,
      ),
      AppOptionItem(
        key: 'crisis_emergency',
        labelEn: 'Crisis emergency',
        labelTl: 'Crisis emergency',
        subtitleEn: 'Emergency crisis banner',
        subtitleTl: 'Banner para sa emergency crisis',
        iconName: 'medical_services_outlined',
        icon: Icons.medical_services_outlined,
        sortOrder: 3,
      ),
      AppOptionItem(
        key: 'crisis_resource',
        labelEn: 'Crisis resources',
        labelTl: 'Crisis resources',
        subtitleEn: 'Crisis information resources',
        subtitleTl: 'Mga resource para sa crisis',
        iconName: 'life_ring_outlined',
        icon: Icons.support,
        sortOrder: 4,
      ),
    ];
  }

  /// Active Care Self-care Toolkit checks from Lookups (`care_toolkit`).
  /// Empty remote group means staff hid every toolkit — do not fall back.
  static List<AppOptionItem> careToolkits() {
    final remote = instance._byGroup[careToolkitGroup];
    if (remote != null) {
      return List<AppOptionItem>.from(remote);
    }
    return const [
      AppOptionItem(
        key: 'stress',
        labelEn: 'Stress Check',
        labelTl: 'Stress Check',
        subtitleEn: 'Understand your stress level',
        subtitleTl: 'Unawain ang antas ng stress mo',
        iconName: 'bolt_outlined',
        icon: Icons.bolt_outlined,
        sortOrder: 1,
      ),
      AppOptionItem(
        key: 'anxiety',
        labelEn: 'Anxiety Check',
        labelTl: 'Anxiety Check',
        subtitleEn: 'Check in on anxious feelings',
        subtitleTl: 'Suriin ang pakiramdam ng pagkabalisa',
        iconName: 'favorite_outline',
        icon: Icons.favorite_outline,
        sortOrder: 2,
      ),
      AppOptionItem(
        key: 'sleep',
        labelEn: 'Sleep Quality',
        labelTl: 'Kalidad ng Tulog',
        subtitleEn: 'See how well you are resting',
        subtitleTl: 'Tingnan kung gaano kahusay ang iyong pahinga',
        iconName: 'bedtime_outlined',
        icon: Icons.bedtime_outlined,
        sortOrder: 3,
      ),
    ];
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
      careToolkitGroup => Icons.favorite_outline,
      _ => Icons.label_outline,
    };
  }
}
