import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/app_settings.dart';
import '../domain/units.dart';
import 'providers.dart';

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);

class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    return ref.watch(settingsStoreProvider).read();
  }

  void setLocale(String localeCode) {
    if (state.localeCode == localeCode) return;
    state = state.copyWith(localeCode: localeCode);
    _persist();
  }

  void toggleLocale() => setLocale(state.isArabic ? 'en' : 'ar');

  void setUnitSystem(UnitSystem units) {
    if (state.unitSystem == units) return;
    state = state.copyWith(unitSystem: units);
    _persist();
  }

  void setThemeMode(ThemeMode mode) {
    if (state.themeMode == mode) return;
    state = state.copyWith(themeMode: mode);
    _persist();
  }

  void markWelcomeSeen() {
    if (state.hasSeenWelcome) return;
    state = state.copyWith(hasSeenWelcome: true);
    _persist();
  }

  void _persist() {
    ref.read(settingsStoreProvider).write(state);
  }
}
