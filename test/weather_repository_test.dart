import 'dart:convert';

import 'package:ajwaa/core/constants/app_info.dart';
import 'package:ajwaa/core/errors/app_failure.dart';
import 'package:ajwaa/core/network/api_client.dart';
import 'package:ajwaa/data/models/city.dart';
import 'package:ajwaa/data/repositories/weather_cache.dart';
import 'package:ajwaa/data/repositories/weather_repository.dart';
import 'package:ajwaa/data/services/air_quality_api.dart';
import 'package:ajwaa/data/services/forecast_api.dart';
import 'package:ajwaa/data/services/storm_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fixtures.dart';

const City cairo = City(
  id: 'cairo',
  name: 'Cairo',
  latitude: 30.04,
  longitude: 31.24,
);

CachedWeatherPayload payloadAt(DateTime fetchedAt, {double latitude = 30.04}) {
  return CachedWeatherPayload(
    fetchedAt: fetchedAt,
    latitude: latitude,
    longitude: 31.24,
    forecast: forecastFixture(),
    air: airQualityFixture(),
    storms: eonetWrapper(),
  );
}

WeatherRepository repositoryWith(http.Client client, SharedPreferences prefs) {
  final api = ApiClient(client: client, maxAttempts: 1, delay: (_) async {});
  return WeatherRepository(
    forecastApi: ForecastApi(api),
    airQualityApi: AirQualityApi(api),
    stormApi: StormApi(api),
    cache: WeatherCache(prefs),
  );
}

MockClient networkClient() {
  return MockClient((request) async {
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
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  test('fresh cache avoids the network entirely', () async {
    await WeatherCache(prefs)
        .write(cairo.id, payload: payloadAt(DateTime.now().toUtc()));

    final repository = repositoryWith(
      MockClient((_) async => throw StateError('network must not be used')),
      prefs,
    );

    final bundle = await repository.load(cairo);
    expect(bundle.isFromCache, isFalse);
    expect(bundle.current.temperatureC, closeTo(31.4, 0.001));
    expect(bundle.hourly, hasLength(3));
    expect(bundle.city.id, 'cairo');
  });

  test('stale cache is served when the network fails', () async {
    await WeatherCache(prefs).write(
      cairo.id,
      payload: payloadAt(
        DateTime.now().toUtc().subtract(const Duration(hours: 3)),
      ),
    );

    final repository = repositoryWith(
      MockClient((_) async => throw http.ClientException('offline')),
      prefs,
    );

    final bundle = await repository.load(cairo);
    expect(bundle.isFromCache, isTrue);
    expect(bundle.current.temperatureC, closeTo(31.4, 0.001));
    expect(bundle.storms, isNotEmpty);
  });

  test('moved location ignores a stale cache entry', () async {
    await WeatherCache(prefs).write(
      cairo.id,
      payload: payloadAt(
        DateTime.now().toUtc().subtract(const Duration(hours: 3)),
        latitude: 10,
      ),
    );

    final repository = repositoryWith(networkClient(), prefs);
    final bundle = await repository.load(cairo);
    expect(bundle.isFromCache, isFalse);
    expect(bundle.current.temperatureC, closeTo(31.4, 0.001));
  });

  test('force refresh bypasses a fresh cache', () async {
    await WeatherCache(prefs)
        .write(cairo.id, payload: payloadAt(DateTime.now().toUtc()));

    final repository = repositoryWith(networkClient(), prefs);
    final bundle = await repository.load(cairo, forceRefresh: true);
    expect(bundle.isFromCache, isFalse);
    expect(bundle.air.dust, closeTo(62, 0.001));
  });

  test('no cache and a broken payload surfaces a malformed failure', () async {
    final repository = repositoryWith(
      MockClient(
        (_) async => http.Response(
          'not json',
          200,
          headers: {'content-type': 'application/json'},
        ),
      ),
      prefs,
    );

    await expectLater(
      repository.load(cairo),
      throwsA(
        isA<AppFailure>().having(
          (failure) => failure.kind,
          'kind',
          FailureKind.malformed,
        ),
      ),
    );
  });

  test('cache entries survive a write/read round trip', () async {
    final cache = WeatherCache(prefs);
    await cache.write(cairo.id, payload: payloadAt(DateTime.utc(2026, 10, 21)));
    final restored = cache.read(cairo.id);
    expect(restored, isNotNull);
    expect(restored!.latitude, closeTo(30.04, 0.001));
    expect(restored.forecast['timezone'], 'Africa/Cairo');

    await cache.clear();
    expect(cache.read(cairo.id), isNull);
  });

  test('storage keys are namespaced and versioned', () {
    expect(StorageKeys.weatherCachePrefix, startsWith('ajwaa.'));
  });
}
