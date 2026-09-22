import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// API keys and display metadata for journal reflection options.
class JournalSkyOption {
  const JournalSkyOption({
    required this.key,
    required this.labelEn,
    required this.labelTl,
    required this.subtitleEn,
    required this.subtitleTl,
    required this.icon,
    required this.accent,
  });

  final String key;
  final String labelEn;
  final String labelTl;
  final String subtitleEn;
  final String subtitleTl;
  final IconData icon;
  final Color accent;
}

class JournalFeelingOption {
  const JournalFeelingOption({
    required this.key,
    required this.labelEn,
    required this.labelTl,
  });

  final String key;
  final String labelEn;
  final String labelTl;
}

class JournalImpactOption {
  const JournalImpactOption({
    required this.key,
    required this.labelEn,
    required this.labelTl,
    required this.icon,
  });

  final String key;
  final String labelEn;
  final String labelTl;
  final IconData icon;
}

class JournalConstants {
  JournalConstants._();

  static const skyOptions = <JournalSkyOption>[
    JournalSkyOption(
      key: 'clear_skies',
      labelEn: 'Clear Skies',
      labelTl: 'Maaliwalas',
      subtitleEn: 'Steady and bright today.',
      subtitleTl: 'Matatag at maliwanag ngayon.',
      icon: Icons.wb_sunny_outlined,
      accent: Color(0xFFFBD116),
    ),
    JournalSkyOption(
      key: 'passing_mist',
      labelEn: 'Passing Mist',
      labelTl: 'Pasadong ulap',
      subtitleEn: 'A little unclear, but moving.',
      subtitleTl: 'Medyo malabo, pero gumagalaw.',
      icon: Icons.cloud_queue_outlined,
      accent: Color(0xFF94A3B8),
    ),
    JournalSkyOption(
      key: 'overcast',
      labelEn: 'Overcast',
      labelTl: 'Maulap',
      subtitleEn: 'Heavy, but you are still here.',
      subtitleTl: 'Mabigat, pero nandito ka pa.',
      icon: Icons.cloud_outlined,
      accent: Color(0xFF64748B),
    ),
    JournalSkyOption(
      key: 'stormy',
      labelEn: 'Stormy',
      labelTl: 'Mabagyo',
      subtitleEn: 'Rough weather — be gentle with yourself.',
      subtitleTl: 'Masungit ang panahon — maging mahinahon sa sarili.',
      icon: Icons.thunderstorm_outlined,
      accent: Color(0xFF055498),
    ),
  ];

  static const feelingOptions = <JournalFeelingOption>[
    JournalFeelingOption(key: 'Grounded', labelEn: 'Grounded', labelTl: 'Nakatuntong'),
    JournalFeelingOption(key: 'Restless', labelEn: 'Restless', labelTl: 'Hindi mapakali'),
    JournalFeelingOption(key: 'Grateful', labelEn: 'Grateful', labelTl: 'Nagpapasalamat'),
    JournalFeelingOption(key: 'Anxious', labelEn: 'Anxious', labelTl: 'Balisa'),
    JournalFeelingOption(key: 'Peaceful', labelEn: 'Peaceful', labelTl: 'Payapa'),
    JournalFeelingOption(key: 'Triggered', labelEn: 'Triggered', labelTl: 'Na-trigger'),
    JournalFeelingOption(key: 'Hopeful', labelEn: 'Hopeful', labelTl: 'Umaasa'),
    JournalFeelingOption(key: 'Lonely', labelEn: 'Lonely', labelTl: 'Nangungulila'),
    JournalFeelingOption(key: 'Motivated', labelEn: 'Motivated', labelTl: 'Motibado'),
    JournalFeelingOption(key: 'Overwhelmed', labelEn: 'Overwhelmed', labelTl: 'Nalulula'),
  ];

  static const impactOptions = <JournalImpactOption>[
    JournalImpactOption(
      key: 'connection_circle',
      labelEn: 'Connection & Circle',
      labelTl: 'Koneksyon at bilog',
      icon: Icons.groups_outlined,
    ),
    JournalImpactOption(
      key: 'cravings_urges',
      labelEn: 'Cravings & Urges',
      labelTl: 'Cravings at urges',
      icon: Icons.waves_outlined,
    ),
    JournalImpactOption(
      key: 'routine_sleep',
      labelEn: 'Routine & Sleep',
      labelTl: 'Routine at tulog',
      icon: Icons.bedtime_outlined,
    ),
    JournalImpactOption(
      key: 'environment_triggers',
      labelEn: 'Environment & Triggers',
      labelTl: 'Kapaligiran at triggers',
      icon: Icons.place_outlined,
    ),
    JournalImpactOption(
      key: 'self_care_reflection',
      labelEn: 'Self-Care & Reflection',
      labelTl: 'Self-care at refleksiyon',
      icon: Icons.self_improvement_outlined,
    ),
  ];

  static JournalSkyOption? skyByKey(String? key) {
    if (key == null || key.isEmpty) return null;
    for (final o in skyOptions) {
      if (o.key == key) return o;
    }
    return null;
  }

  static JournalImpactOption? impactByKey(String? key) {
    if (key == null || key.isEmpty) return null;
    for (final o in impactOptions) {
      if (o.key == key) return o;
    }
    return null;
  }

  static Color accentForSky(String? sky) {
    return skyByKey(sky)?.accent ?? AppColors.primaryBlue;
  }
}
