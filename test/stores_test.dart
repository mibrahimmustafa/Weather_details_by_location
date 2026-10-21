import 'dart:convert';

import 'package:ajwaa/core/constants/app_info.dart';
import 'package:ajwaa/data/models/app_settings.dart';
import 'package:ajwaa/data/models/city.dart';
import 'package:ajwaa/data/repositories/cities_store.dart';
import 'package:ajwaa/data/repositories/settings_store.dart';
import 'package:ajwaa/domain/units.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  Future<void> seed(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    prefs = await SharedPreferences.getInstance();
  }

  group('SettingsStore', () {
    test('falls back to defaults when the payload is corrupt', () async {
      await seed({StorageKeys.settings: '{ this is not json'});
      final settings = SettingsStore(prefs).read();
      expect(settings.localeCode, anyOf('ar', 'en'));
      expect(settings.hasSeenWelcome, isFalse);
      expect(settings.unitSystem, UnitSystem.metric);
    });

    test('falls back to defaults when the payload is not an object', () async {
      await seed({
        StorageKeys.settings: jsonEncode(['not', 'an', 'object']),
      });
      expect(SettingsStore(prefs).read().localeCode, anyOf('ar', 'en'));
    });

    test('round trips every field', () async {
      await seed(const <String, Object>{});
      final store = SettingsStore(prefs);

      await store.write(
        const AppSettings(
          localeCode: 'en',
          unitSystem: UnitSystem.imperial,
          themeMode: ThemeMode.dark,
          hasSeenWelcome: true,
        ),
      );

      final restored = store.read();
      expect(restored.localeCode, 'en');
      expect(restored.unitSystem, UnitSystem.imperial);
      expect(restored.themeMode, ThemeMode.dark);
      expect(restored.hasSeenWelcome, isTrue);
    });

    test('coerces unknown enum names back to safe defaults', () async {
      await seed({
        StorageKeys.settings: jsonEncode({
          'localeCode': 'fr',
          'unitSystem': 'martian',
          'themeMode': 'sepia',
          'hasSeenWelcome': 'yes',
        }),
      });

      final restored = SettingsStore(prefs).read();
      expect(restored.localeCode, 'ar');
      expect(restored.unitSystem, UnitSystem.metric);
      expect(restored.themeMode, ThemeMode.system);
      expect(restored.hasSeenWelcome, isFalse);
    });
  });

  group('CitiesStore', () {
    test('returns null when nothing has been stored', () async {
      await seed(const <String, Object>{});
      expect(CitiesStore(prefs).read(), isNull);
    });

    test('skips malformed entries and keeps the rest', () async {
      await seed({
        StorageKeys.cities: jsonEncode({
          'cities': [
            {
              'id': 'cairo',
              'name': 'Cairo',
              'latitude': 30.04,
              'longitude': 31.24,
            },
            {'id': 'broken', 'name': 'Broken'},
            42,
          ],
          'selectedId': 'cairo',
        }),
      });

      final snapshot = CitiesStore(prefs).read();
      expect(snapshot, isNotNull);
      expect(snapshot!.cities, hasLength(1));
      expect(snapshot.cities.single.name, 'Cairo');
      expect(snapshot.selectedId, 'cairo');
    });

    test('repairs a selected id that no longer exists', () async {
      await seed({
        StorageKeys.cities: jsonEncode({
          'cities': [
            {
              'id': 'cairo',
              'name': 'Cairo',
              'latitude': 30.04,
              'longitude': 31.24,
            },
          ],
          'selectedId': 'deleted-city',
        }),
      });

      final snapshot = CitiesStore(prefs).read();
      expect(snapshot!.selectedId, 'cairo');
    });

    test('returns null when the payload is corrupt', () async {
      await seed({StorageKeys.cities: '[not, a, map]'});
      expect(CitiesStore(prefs).read(), isNull);
    });

    test('round trips a snapshot', () async {
      await seed(const <String, Object>{});
      final store = CitiesStore(prefs);
      const cairo = City(
        id: 'cairo',
        name: 'Cairo',
        latitude: 30.0444,
        longitude: 31.2357,
        country: 'Egypt',
        countryCode: 'EG',
        timezone: 'Africa/Cairo',
      );

      await store.write(
        const CitiesSnapshot(cities: [cairo], selectedId: 'cairo'),
      );
      final restored = store.read();
      expect(restored!.cities.single.name, 'Cairo');
      expect(restored.cities.single.timezone, 'Africa/Cairo');
      expect(restored.selectedId, 'cairo');
    });
  });
}
