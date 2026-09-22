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
      accent: AppColors.primaryBlue,
      tint: Color(0xFFE8F1FA),
    ),
    RegistrationInterest(
      key: 'community',
      icon: Icons.groups_rounded,
      accent: AppColors.accentRed,
      tint: Color(0xFFFDE8E9),
    ),
    RegistrationInterest(
      key: 'wellness',
      icon: Icons.favorite_border_rounded,
      accent: Color(0xFFEAB308),
      tint: Color(0xFFFEF9C3),
    ),
    RegistrationInterest(
      key: 'stories',
      icon: Icons.edit_note_rounded,
      accent: Color(0xFFEA580C),
      tint: Color(0xFFFFEDD5),
    ),
    RegistrationInterest(
      key: 'support',
      icon: Icons.forum_outlined,
      accent: AppColors.accentPurple,
      tint: Color(0xFFF3E8FF),
    ),
    RegistrationInterest(
      key: 'events',
      icon: Icons.calendar_month_outlined,
      accent: AppColors.primaryBlue,
      tint: Color(0xFFE8F1FA),
    ),
    RegistrationInterest(
      key: 'opportunities',
      icon: Icons.person_search_outlined,
      accent: Color(0xFFDB2777),
      tint: Color(0xFFFCE7F3),
    ),
    RegistrationInterest(
      key: 'advocacy',
      icon: Icons.campaign_outlined,
      accent: Color(0xFF0D9488),
      tint: Color(0xFFCCFBF1),
    ),
  ];
}
