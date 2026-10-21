import 'dart:convert';

import 'package:ajwaa/app.dart';
import 'package:ajwaa/core/constants/app_info.dart';
import 'package:ajwaa/core/network/api_client.dart';
import 'package:ajwaa/l10n/app_localizations.dart';
import 'package:ajwaa/presentation/home/home_screen.dart';
import 'package:ajwaa/state/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fixtures.dart';

ApiClient _successClient() {
  return ApiClient(
    client: MockClient((request) async {
      final path = request.url.path;
      final body = path.contains('air-quality')
          ? airQualityFixture()
          : path.contains('events')
          ? eonetWrapper()
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

ApiClient _failingClient() {
  return ApiClient(
    client: MockClient((_) async => throw http.ClientException('offline')),
    maxAttempts: 1,
    delay: (_) async {},
  );
}

Future<SharedPreferences> _prefsFor(String locale) async {
  SharedPreferences.setMockInitialValues({
    StorageKeys.settings: jsonEncode({
      'localeCode': locale,
      'unitSystem': 'metric',
      'themeMode': 'system',
      'hasSeenWelcome': true,
    }),
  });
  return SharedPreferences.getInstance();
}

Future<void> _pumpApp(
  WidgetTester tester, {
  required SharedPreferences prefs,
  required ApiClient api,
}) async {
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
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 120));
  }
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
  });

  testWidgets('renders the English home screen with live weather', (
    tester,
  ) async {
    final prefs = await _prefsFor('en');
    await _pumpApp(tester, prefs: prefs, api: _successClient());

    expect(find.text('Ajwaa'), findsWidgets);
    expect(find.textContaining('31°'), findsWidgets);
    expect(find.text('Cairo'), findsWidgets);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('switches to Arabic and mirrors the layout', (tester) async {
    final prefs = await _prefsFor('ar');
    await _pumpApp(tester, prefs: prefs, api: _successClient());

    expect(find.text('أجواء'), findsWidgets);
    final context = tester.element(find.byType(HomeScreen));
    expect(Directionality.of(context), TextDirection.rtl);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('shows a localized error view with retry when offline', (
    tester,
  ) async {
    final prefs = await _prefsFor('en');
    await _pumpApp(tester, prefs: prefs, api: _failingClient());

    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(find.text(l10n.retry), findsOneWidget);
    expect(find.text(l10n.errorNetwork), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });
}
