import 'dart:convert';

import 'package:ajwaa/app.dart';
import 'package:ajwaa/core/constants/app_info.dart';
import 'package:ajwaa/core/network/api_client.dart';
import 'package:ajwaa/data/models/app_settings.dart';
import 'package:ajwaa/data/repositories/settings_store.dart';
import 'package:ajwaa/l10n/app_localizations.dart';
import 'package:ajwaa/presentation/home/home_screen.dart';
import 'package:ajwaa/presentation/sheets/city_picker_sheet.dart';
import 'package:ajwaa/presentation/sheets/settings_sheet.dart';
import 'package:ajwaa/presentation/sheets/welcome_sheet.dart';
import 'package:ajwaa/state/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fixtures.dart';

ApiClient _client() {
  return ApiClient(
    client: MockClient((request) async {
      final path = request.url.path;
      final body = path.contains('air-quality')
          ? airQualityFixture()
          : path.contains('events')
          ? eonetWrapper()
          : path.contains('/v1/search')
          ? geocodingFixture()
          : path.contains('reverse-geocode')
          ? reverseGeocodeFixture()
          : forecastFixture();
      return http.Response(
        jsonEncode(body),
        200,
        headers: {'content-type': 'application/json'},
      );
    }),
    maxAttempts: 1,
    delay: (_) async {},
  );
}

Future<SharedPreferences> _prefs({
  String locale = 'en',
  bool seenWelcome = true,
}) async {
  SharedPreferences.setMockInitialValues({
    StorageKeys.settings: jsonEncode({
      'localeCode': locale,
      'unitSystem': 'metric',
      'themeMode': 'system',
      'hasSeenWelcome': seenWelcome,
    }),
  });
  return SharedPreferences.getInstance();
}

Future<void> _pumpApp(WidgetTester tester, SharedPreferences prefs) async {
  final api = _client();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        apiClientProvider.overrideWithValue(api),
        stormClientProvider.overrideWithValue(api),
      ],
      child: const AjwaaApp(),
    ),
  );
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 120));
  }
}

/// Pumps a fixed number of short frames; repeating animations make
/// `pumpAndSettle` unusable here.
Future<void> _settle(WidgetTester tester, [int frames = 14]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 90));
  }
}

MockClient _noStorms() =>
    MockClient((_) async => throw http.ClientException('x'));

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
  });

  testWidgets('settings sheet switches theme, units and language', (
    tester,
  ) async {
    final prefs = await _prefs();
    await _pumpApp(tester, prefs);

    final l10n = lookupAppLocalizations(const Locale('en'));
    await tester.tap(find.byTooltip(l10n.a11ySettings));
    await _settle(tester);

    expect(find.byType(SettingsSheet), findsOneWidget);
    expect(find.text(l10n.settings), findsOneWidget);

    // Dark theme.
    await tester.tap(find.text(l10n.themeDark));
    await _settle(tester);
    expect(SettingsStore(prefs).read().themeMode, ThemeMode.dark);

    // Imperial units.
    await tester.tap(find.text(l10n.unitsImperial));
    await _settle(tester);
    expect(SettingsStore(prefs).read().unitSystem.name, 'imperial');

    // Arabic, which must mirror the whole app.
    await tester.tap(find.text(l10n.arabic));
    await _settle(tester);
    expect(SettingsStore(prefs).read().localeCode, 'ar');

    final context = tester.element(find.byType(HomeScreen));
    expect(Directionality.of(context), TextDirection.rtl);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('city picker searches and adds a city', (tester) async {
    final prefs = await _prefs();
    await _pumpApp(tester, prefs);

    final l10n = lookupAppLocalizations(const Locale('en'));
    await tester.tap(find.byTooltip(l10n.a11ySearch));
    await _settle(tester);

    expect(find.byType(CityPickerSheet), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Lon');
    // The picker debounces for 380 ms before hitting the network.
    await tester.pump(const Duration(milliseconds: 420));
    await _settle(tester);

    expect(find.text('London'), findsOneWidget);

    await tester.tap(find.text('London'));
    await _settle(tester, 20);

    expect(find.byType(CityPickerSheet), findsNothing);
    expect(find.text('London'), findsWidgets);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('welcome sheet is shown once and remembers the dismissal', (
    tester,
  ) async {
    final prefs = await _prefs(seenWelcome: false);

    // Storms are decorative: make them fail fast so the sheet appears quickly.
    final api = _client();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          apiClientProvider.overrideWithValue(api),
          stormClientProvider.overrideWithValue(
            ApiClient(client: _noStorms(), maxAttempts: 1, delay: (_) async {}),
          ),
        ],
        child: const AjwaaApp(),
      ),
    );
    await _settle(tester, 20);

    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(find.byType(WelcomeSheet), findsOneWidget);
    expect(find.text(l10n.welcomeTitle), findsOneWidget);

    await tester.tap(find.text(l10n.continueWithout));
    await _settle(tester, 20);

    expect(SettingsStore(prefs).read().hasSeenWelcome, isTrue);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('data source and about sheets open from settings', (
    tester,
  ) async {
    // A tall surface keeps every settings tile on screen at once.
    tester.view.physicalSize = const Size(900, 1500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final prefs = await _prefs();
    await _pumpApp(tester, prefs);

    final l10n = lookupAppLocalizations(const Locale('en'));
    await tester.tap(find.byTooltip(l10n.a11ySettings));
    await _settle(tester);

    await tester.tap(find.text(l10n.dataSources));
    await _settle(tester);
    expect(find.text('NASA EONET — ${l10n.stormsTitle}'), findsOneWidget);

    // Back out of the provider sheet.
    Navigator.of(tester.element(find.byType(HomeScreen))).pop();
    await _settle(tester);

    await tester.tap(find.text(l10n.aboutTitle));
    await _settle(tester);
    expect(find.text(l10n.appName), findsWidgets);
    expect(find.text(l10n.brandTitle), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a corrupt settings payload still boots the app', (tester) async {
    SharedPreferences.setMockInitialValues({
      StorageKeys.settings: '{"localeCode":',
    });
    final prefs = await SharedPreferences.getInstance();

    await _pumpApp(tester, prefs);

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
  });

  test('AppSettings defaults are metric, system theme and unseen welcome', () {
    const settings = AppSettings();
    expect(settings.unitSystem.name, 'metric');
    expect(settings.themeMode, ThemeMode.system);
    expect(settings.hasSeenWelcome, isFalse);
  });
}
