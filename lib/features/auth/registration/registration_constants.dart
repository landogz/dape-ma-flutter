import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class RegistrationPersona {
  const RegistrationPersona({
    required this.key,
    required this.icon,
    required this.labelEn,
    required this.labelTl,
  });

  final String key;
  final IconData icon;
  final String labelEn;
  final String labelTl;
}

class RegistrationPronoun {
  const RegistrationPronoun({
    required this.key,
    required this.labelEn,
    required this.labelTl,
  });

  final String key;
  final String labelEn;
  final String labelTl;
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
    RegistrationPersona(
      key: 'student',
      icon: Icons.school_outlined,
      labelEn: 'Student',
      labelTl: 'Estudyante',
    ),
    RegistrationPersona(
      key: 'parent',
      icon: Icons.family_restroom_outlined,
      labelEn: 'Parent',
      labelTl: 'Magulang',
    ),
    RegistrationPersona(
      key: 'teacher',
      icon: Icons.menu_book_outlined,
      labelEn: 'Teacher',
      labelTl: 'Guro',
    ),
    RegistrationPersona(
      key: 'youth_leader',
      icon: Icons.star_outline_rounded,
      labelEn: 'Youth Leader',
      labelTl: 'Youth Leader',
    ),
    RegistrationPersona(
      key: 'health_worker',
      icon: Icons.favorite_outline,
      labelEn: 'Health Worker',
      labelTl: 'Health Worker',
    ),
    RegistrationPersona(
      key: 'concerned_citizen',
      icon: Icons.flag_outlined,
      labelEn: 'Concerned Citizen',
      labelTl: 'Concerned Citizen',
    ),
  ];

  static const pronouns = <RegistrationPronoun>[
    RegistrationPronoun(key: 'she_her', labelEn: 'She/Her', labelTl: 'She/Her'),
    RegistrationPronoun(key: 'he_him', labelEn: 'He/Him', labelTl: 'He/Him'),
    RegistrationPronoun(
      key: 'they_them',
      labelEn: 'They/Them',
      labelTl: 'They/Them',
    ),
    RegistrationPronoun(key: 'ze_hir', labelEn: 'Ze/Hir', labelTl: 'Ze/Hir'),
    RegistrationPronoun(
      key: 'prefer_not',
      labelEn: 'Prefer not to say',
      labelTl: 'Ayaw sabihin',
    ),
    RegistrationPronoun(key: 'others', labelEn: 'Others', labelTl: 'Iba pa'),
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
