import 'package:flutter/material.dart';

import 'heroicon_material.dart';

IconData appOptionIcon(String? name, {required IconData fallback}) {
  if (name == null || name.trim().isEmpty) {
    return fallback;
  }
  var key = name.trim();
  if (key.startsWith('solid/')) {
    key = key.substring(6);
  }
  final heroicon = heroiconMaterialIcon(key);
  if (heroicon != null) {
    return heroicon;
  }
  return switch (key) {
    'school_outlined' => Icons.school_outlined,
    'family_restroom_outlined' => Icons.family_restroom_outlined,
    'menu_book_outlined' => Icons.menu_book_outlined,
    'star_outline_rounded' => Icons.star_outline_rounded,
    'favorite_outline' => Icons.favorite_outline,
    'flag_outlined' => Icons.flag_outlined,
    'work_outline' => Icons.work_outline,
    'volunteer_activism_outlined' => Icons.volunteer_activism_outlined,
    'volunteer_activism_rounded' => Icons.volunteer_activism_rounded,
    'handshake_outlined' => Icons.handshake_outlined,
    'handshake_rounded' => Icons.handshake_rounded,
    'spa_outlined' => Icons.spa_outlined,
    'auto_awesome_outlined' => Icons.auto_awesome_outlined,
    'menu_book_rounded' => Icons.menu_book_rounded,
    'medical_services_outlined' => Icons.medical_services_outlined,
    'wb_sunny_outlined' => Icons.wb_sunny_outlined,
    'cloud_queue_outlined' => Icons.cloud_queue_outlined,
    'cloud_outlined' => Icons.cloud_outlined,
    'thunderstorm_outlined' => Icons.thunderstorm_outlined,
    'water_drop_outlined' => Icons.water_drop_outlined,
    'air' => Icons.air,
    'groups_outlined' => Icons.groups_outlined,
    'waves_outlined' => Icons.waves_outlined,
    'bedtime_outlined' => Icons.bedtime_outlined,
    'place_outlined' => Icons.place_outlined,
    'self_improvement_outlined' => Icons.self_improvement_outlined,
    'home_outlined' => Icons.home_outlined,
    'home_rounded' => Icons.home_rounded,
    'groups_rounded' => Icons.groups_rounded,
    'help_outline_rounded' => Icons.help_outline_rounded,
    'help_rounded' => Icons.help_rounded,
    'person_rounded' => Icons.person_rounded,
    'fitness_center_outlined' => Icons.fitness_center_outlined,
    'restaurant_outlined' => Icons.restaurant_outlined,
    'label_outline' => Icons.label_outline,
    'person_outline' => Icons.person_outline,
    _ => fallback,
  };
}

Color? parseHexColor(String? raw) {
  if (raw == null) return null;
  var hex = raw.trim();
  if (hex.isEmpty) return null;
  if (hex.startsWith('#')) {
    hex = hex.substring(1);
  }
  if (hex.length == 6) {
    hex = 'FF$hex';
  }
  if (hex.length != 8) return null;
  final value = int.tryParse(hex, radix: 16);
  if (value == null) return null;
  return Color(value);
}
