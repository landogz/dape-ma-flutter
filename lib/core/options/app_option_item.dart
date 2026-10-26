import 'package:flutter/material.dart';

class AppOptionItem {
  const AppOptionItem({
    required this.key,
    required this.labelEn,
    required this.labelTl,
    this.subtitleEn = '',
    this.subtitleTl = '',
    this.iconName,
    this.accentHex,
    this.icon = Icons.label_outline,
    this.accent,
    this.sortOrder = 0,
  });

  final String key;
  final String labelEn;
  final String labelTl;
  final String subtitleEn;
  final String subtitleTl;
  final String? iconName;
  final String? accentHex;
  final IconData icon;
  final Color? accent;
  final int sortOrder;

  String label({required bool isTagalog}) =>
      isTagalog ? (labelTl.isNotEmpty ? labelTl : labelEn) : labelEn;

  String subtitle({required bool isTagalog}) =>
      isTagalog ? (subtitleTl.isNotEmpty ? subtitleTl : subtitleEn) : subtitleEn;

  factory AppOptionItem.fromJson(
    Map<String, dynamic> json, {
    required IconData fallbackIcon,
    Color? fallbackAccent,
  }) {
    return AppOptionItem(
      key: (json['key'] ?? '').toString(),
      labelEn: (json['label_en'] ?? json['label'] ?? '').toString(),
      labelTl: (json['label_tl'] ?? json['label'] ?? '').toString(),
      subtitleEn: (json['subtitle_en'] ?? json['subtitle'] ?? '').toString(),
      subtitleTl: (json['subtitle_tl'] ?? json['subtitle'] ?? '').toString(),
      iconName: () {
        final raw = json['icon']?.toString().trim();
        if (raw == null || raw.isEmpty) {
          return null;
        }
        return raw;
      }(),
      accentHex: json['accent']?.toString(),
      icon: fallbackIcon,
      accent: fallbackAccent,
      sortOrder: json['sort_order'] is int
          ? json['sort_order'] as int
          : int.tryParse('${json['sort_order'] ?? 0}') ?? 0,
    );
  }
}
