import 'package:flutter/material.dart';

class RehabCenter {
  final int id;
  final String name;
  final String? category;
  final String? categoryLabel;
  final String? categoryLabelTl;
  final Color? categoryColor;
  final String address;
  final String region;
  final String province;
  final String contact;
  final String? website;
  final double? latitude;
  final double? longitude;

  RehabCenter({
    required this.id,
    required this.name,
    this.category,
    this.categoryLabel,
    this.categoryLabelTl,
    this.categoryColor,
    required this.address,
    required this.region,
    required this.province,
    required this.contact,
    this.website,
    this.latitude,
    this.longitude,
  });

  bool get hasCoordinates =>
      latitude != null &&
      longitude != null &&
      latitude != 0 &&
      longitude != 0;

  String categoryDisplay({required bool isTagalog}) {
    if (isTagalog && (categoryLabelTl?.trim().isNotEmpty ?? false)) {
      return categoryLabelTl!.trim();
    }
    if (categoryLabel?.trim().isNotEmpty ?? false) {
      return categoryLabel!.trim();
    }
    final key = category?.trim() ?? '';
    if (key.isEmpty) return '';
    return key.replaceAll('_', ' ');
  }

  factory RehabCenter.fromJson(Map<String, dynamic> json) {
    return RehabCenter(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      category: json['category'] as String?,
      categoryLabel: json['category_label'] as String?,
      categoryLabelTl: json['category_label_tl'] as String?,
      categoryColor: _parseColor(json['category_color']),
      address: json['address'] as String? ?? '',
      region: json['region'] as String? ?? '',
      province: json['province'] as String? ?? '',
      contact: (json['contact'] ?? json['contact_number']) as String? ?? '',
      website: json['website'] as String?,
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static Color? _parseColor(dynamic value) {
    if (value == null) return null;
    var hex = value.toString().trim();
    if (hex.isEmpty) return null;
    if (hex.startsWith('#')) hex = hex.substring(1);
    if (hex.length == 6) {
      final parsed = int.tryParse(hex, radix: 16);
      if (parsed != null) return Color(0xFF000000 | parsed);
    }
    return null;
  }
}
