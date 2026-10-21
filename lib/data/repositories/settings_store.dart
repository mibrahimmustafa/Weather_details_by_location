import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_info.dart';
import '../models/app_settings.dart';

/// Reads and writes [AppSettings] to local storage.
class SettingsStore {
  SettingsStore(this._prefs);

  final SharedPreferences _prefs;

  AppSettings read() {
    // Storage can hold anything (old versions, other tools, hand-edited data),
    // so every step is guarded: corrupt preferences must never block the app.
    try {
      final raw = _prefs.getString(StorageKeys.settings);
      if (raw != null) {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          return AppSettings.fromJson(decoded);
        }
      }
    } on Object {
      // Fall through to device defaults.
    }
    return AppSettings(localeCode: _deviceLanguage());
  }

  Future<bool> write(AppSettings settings) =>
      _prefs.setString(StorageKeys.settings, jsonEncode(settings.toJson()));

  static String _deviceLanguage() {
    final locales = WidgetsBinding.instance.platformDispatcher.locales;
    for (final locale in locales) {
      if (locale.languageCode == 'ar') return 'ar';
      if (locale.languageCode == 'en') return 'en';
    }
    return 'en';
  }
}
