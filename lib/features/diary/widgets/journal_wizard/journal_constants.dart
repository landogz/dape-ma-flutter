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
    this.accent,
  });

  final String key;
  final String labelEn;
  final String labelTl;
  final Color? accent;
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
      key: 'sky_red',
      labelEn: 'Red',
      labelTl: 'Pula',
      subtitleEn: 'Light: Love · Dark: Anger',
      subtitleTl: 'Liwanag: Pag-ibig · Dilim: Galit',
      icon: Icons.palette_outlined,
      accent: Color(0xFFCE2028),
    ),
    JournalSkyOption(
      key: 'sky_pink',
      labelEn: 'Pink',
      labelTl: 'Rosas',
      subtitleEn: 'Light: Happy, Optimistic, Imaginative',
      subtitleTl: 'Liwanag: Masaya, Optimista, Malikhain',
      icon: Icons.palette_outlined,
      accent: Color(0xFFEC4899),
    ),
    JournalSkyOption(
      key: 'sky_blue',
      labelEn: 'Blue',
      labelTl: 'Asul',
      subtitleEn: 'Light: Calm/Peaceful, Serenity · Dark: Aloofness, Sad',
      subtitleTl: 'Liwanag: Kalmado/Payapa, Katahimikan · Dilim: Distansya, Malungkot',
      icon: Icons.palette_outlined,
      accent: Color(0xFF055498),
    ),
    JournalSkyOption(
      key: 'sky_white',
      labelEn: 'White',
      labelTl: 'Puti',
      subtitleEn: 'Light: Imaginative',
      subtitleTl: 'Liwanag: Malikhain',
      icon: Icons.palette_outlined,
      accent: Color(0xFFFFFFFF),
    ),
    JournalSkyOption(
      key: 'sky_violet',
      labelEn: 'Violet',
      labelTl: 'Biolet',
      subtitleEn: 'Light: Reflective, Imaginative',
      subtitleTl: 'Liwanag: Mapagmuni, Malikhain',
      icon: Icons.palette_outlined,
      accent: Color(0xFF7C3AED),
    ),
    JournalSkyOption(
      key: 'sky_gray',
      labelEn: 'Gray',
      labelTl: 'Abo',
      subtitleEn: 'Light: Neutral, Balance · Dark: Overwhelmed, Unconfident, Lack of Energy',
      subtitleTl: 'Liwanag: Neutral, Balanse · Dilim: Nalulula, Walang kumpiyansa, Kakulangan sa enerhiya',
      icon: Icons.palette_outlined,
      accent: Color(0xFF64748B),
    ),
    JournalSkyOption(
      key: 'sky_purple',
      labelEn: 'Purple',
      labelTl: 'Lila',
      subtitleEn: 'Dark: Afraid',
      subtitleTl: 'Dilim: Takot',
      icon: Icons.palette_outlined,
      accent: Color(0xFF581C87),
    ),
    JournalSkyOption(
      key: 'sky_green',
      labelEn: 'Green',
      labelTl: 'Berde',
      subtitleEn: 'Light: Growth, Hope, Healing · Dark: Boredom, Sickness',
      subtitleTl: 'Liwanag: Paglago, Pag-asa, Paghilom · Dilim: Inip, Sakit',
      icon: Icons.palette_outlined,
      accent: Color(0xFF16A34A),
    ),
    JournalSkyOption(
      key: 'sky_orange',
      labelEn: 'Orange',
      labelTl: 'Kahel',
      subtitleEn: 'Light: Confidence · Dark: Anxious, Frustration',
      subtitleTl: 'Liwanag: Kumpiyansa · Dilim: Balisa, Frustrasyon',
      icon: Icons.palette_outlined,
      accent: Color(0xFFEA580C),
    ),
    JournalSkyOption(
      key: 'sky_yellow',
      labelEn: 'Yellow',
      labelTl: 'Dilaw',
      subtitleEn: 'Light: Happiness, Optimism, Cheerful',
      subtitleTl: 'Liwanag: Kaligayahan, Optimismo, Masayahin',
      icon: Icons.palette_outlined,
      accent: Color(0xFFFBD116),
    ),
    JournalSkyOption(
      key: 'sky_black',
      labelEn: 'Black',
      labelTl: 'Itim',
      subtitleEn: 'Light: Power · Dark: Mourning, Heaviness',
      subtitleTl: 'Liwanag: Kapangyarihan · Dilim: Pagluluksa, Bigat',
      icon: Icons.palette_outlined,
      accent: Color(0xFF0F172A),
    ),
  ];

  static const legacySkyOptions = <JournalSkyOption>[
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
    JournalFeelingOption(
      key: 'Grounded',
      labelEn: 'Grounded',
      labelTl: 'Nakatuntong',
      accent: Color(0xFF16A34A),
    ),
    JournalFeelingOption(
      key: 'Restless',
      labelEn: 'Restless',
      labelTl: 'Hindi mapakali',
      accent: Color(0xFFEA580C),
    ),
    JournalFeelingOption(
      key: 'Grateful',
      labelEn: 'Grateful',
      labelTl: 'Nagpapasalamat',
      accent: Color(0xFFFBD116),
    ),
    JournalFeelingOption(
      key: 'Anxious',
      labelEn: 'Anxious',
      labelTl: 'Balisa',
      accent: Color(0xFFEA580C),
    ),
    JournalFeelingOption(
      key: 'Peaceful',
      labelEn: 'Peaceful',
      labelTl: 'Payapa',
      accent: Color(0xFF055498),
    ),
    JournalFeelingOption(
      key: 'Triggered',
      labelEn: 'Triggered',
      labelTl: 'Na-trigger',
      accent: Color(0xFFCE2028),
    ),
    JournalFeelingOption(
      key: 'Hopeful',
      labelEn: 'Hopeful',
      labelTl: 'Umaasa',
      accent: Color(0xFF16A34A),
    ),
    JournalFeelingOption(
      key: 'Lonely',
      labelEn: 'Lonely',
      labelTl: 'Nangungulila',
      accent: Color(0xFF7C3AED),
    ),
    JournalFeelingOption(
      key: 'Motivated',
      labelEn: 'Motivated',
      labelTl: 'Motibado',
      accent: Color(0xFFEA580C),
    ),
    JournalFeelingOption(
      key: 'Overwhelmed',
      labelEn: 'Overwhelmed',
      labelTl: 'Nalulula',
      accent: Color(0xFF64748B),
    ),
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
    for (final o in legacySkyOptions) {
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

  static String feelingLabel(String key, {required bool isTagalog}) {
    for (final o in feelingOptions) {
      if (o.key.toLowerCase() == key.toLowerCase()) {
        return isTagalog ? o.labelTl : o.labelEn;
      }
    }
    return key;
  }

  static String impactLabel(String? key, {required bool isTagalog}) {
    final opt = impactByKey(key);
    if (opt == null) return key ?? '';
    return isTagalog ? opt.labelTl : opt.labelEn;
  }

  static Color accentForSky(String? sky) {
    return skyByKey(sky)?.accent ?? AppColors.primaryBlue;
  }
}
