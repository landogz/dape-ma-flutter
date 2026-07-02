import 'package:flutter/material.dart';

enum AppLocale {
  en,
  tl;

  String get code => name;

  Locale get flutterLocale => Locale(code == 'tl' ? 'fil' : 'en');

  String get displayName => switch (this) {
        AppLocale.en => 'English',
        AppLocale.tl => 'Filipino',
      };

  String get nativeName => switch (this) {
        AppLocale.en => 'English',
        AppLocale.tl => 'Tagalog',
      };

  static const List<AppLocale> supported = [AppLocale.en, AppLocale.tl];

  static const List<Locale> flutterLocales = [
    Locale('en'),
    Locale('fil'),
  ];

  static AppLocale fromCode(String? code) {
    if (code == 'tl' || code == 'fil') {
      return AppLocale.tl;
    }

    return AppLocale.en;
  }
}
