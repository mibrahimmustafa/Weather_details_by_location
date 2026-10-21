import 'package:flutter/material.dart';

import '../../domain/units.dart';

/// User preferences, persisted as a single small JSON document.
@immutable
class AppSettings {
  const AppSettings({
    this.localeCode = 'ar',
    this.unitSystem = UnitSystem.metric,
    this.themeMode = ThemeMode.system,
    this.hasSeenWelcome = false,
  });

  final String localeCode;
  final UnitSystem unitSystem;
  final ThemeMode themeMode;
  final bool hasSeenWelcome;

  bool get isArabic => localeCode == 'ar';
  Locale get locale => Locale(localeCode);

  AppSettings copyWith({
    String? localeCode,
    UnitSystem? unitSystem,
    ThemeMode? themeMode,
    bool? hasSeenWelcome,
  }) {
    return AppSettings(
      localeCode: localeCode ?? this.localeCode,
      unitSystem: unitSystem ?? this.unitSystem,
      themeMode: themeMode ?? this.themeMode,
      hasSeenWelcome: hasSeenWelcome ?? this.hasSeenWelcome,
    );
  }

  Map<String, dynamic> toJson() => {
    'localeCode': localeCode,
    'unitSystem': unitSystem.name,
    'themeMode': themeMode.name,
    'hasSeenWelcome': hasSeenWelcome,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final themeName = json['themeMode'];
    final themeMode = ThemeMode.values.firstWhere(
      (mode) => mode.name == themeName,
      orElse: () => ThemeMode.system,
    );
    return AppSettings(
      localeCode: json['localeCode'] == 'en' ? 'en' : 'ar',
      unitSystem: Units.fromCode(json['unitSystem'] as String?),
      themeMode: themeMode,
      hasSeenWelcome: json['hasSeenWelcome'] == true,
    );
  }
}
