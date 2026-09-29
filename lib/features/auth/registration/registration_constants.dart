import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class RegistrationPersona {
  const RegistrationPersona({
    required this.key,
    required this.icon,
  });

  final String key;
  final IconData icon;
}

class RegistrationInterest {
  const RegistrationInterest({
    required this.key,
    required this.icon,
    required this.accent,
    required this.tint,
  });

  final String key;
  final IconData icon;
  final Color accent;
  final Color tint;
}

class RegistrationConstants {
  RegistrationConstants._();

  static const personas = <RegistrationPersona>[
    RegistrationPersona(key: 'student', icon: Icons.school_outlined),
    RegistrationPersona(key: 'parent', icon: Icons.family_restroom_outlined),
    RegistrationPersona(key: 'teacher', icon: Icons.menu_book_outlined),
    RegistrationPersona(key: 'youth_leader', icon: Icons.star_outline_rounded),
    RegistrationPersona(key: 'health_worker', icon: Icons.favorite_outline),
    RegistrationPersona(key: 'concerned_citizen', icon: Icons.flag_outlined),
  ];

  static const pronouns = <String>[
    'she_her',
    'he_him',
    'they_them',
    'ze_hir',
    'prefer_not',
    'others',
  ];

  static const interests = <RegistrationInterest>[
    RegistrationInterest(
      key: 'knowledge',
      icon: Icons.menu_book_rounded,
      accent: AppColors.mediumElectricBlue,
      tint: AppColors.softBlue,
    ),
    RegistrationInterest(
      key: 'community',
      icon: Icons.groups_rounded,
      accent: AppColors.fireEngineRed,
      tint: AppColors.softRed,
    ),
    RegistrationInterest(
      key: 'wellness',
      icon: Icons.favorite_border_rounded,
      accent: AppColors.brightGold,
      tint: AppColors.softGold,
    ),
    RegistrationInterest(
      key: 'stories',
      icon: Icons.edit_note_rounded,
      accent: AppColors.nileBlue,
      tint: AppColors.softBlue,
    ),
    RegistrationInterest(
      key: 'support',
      icon: Icons.forum_outlined,
      accent: AppColors.accentPurple,
      tint: AppColors.softPurple,
    ),
    RegistrationInterest(
      key: 'events',
      icon: Icons.calendar_month_outlined,
      accent: AppColors.mediumElectricBlue,
      tint: AppColors.softBlue,
    ),
    RegistrationInterest(
      key: 'opportunities',
      icon: Icons.person_search_outlined,
      accent: AppColors.nileBlue,
      tint: AppColors.softBlue,
    ),
    RegistrationInterest(
      key: 'advocacy',
      icon: Icons.campaign_outlined,
      accent: AppColors.fireEngineRed,
      tint: AppColors.softRed,
    ),
  ];
}
