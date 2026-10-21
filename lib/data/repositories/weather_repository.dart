import '../../core/errors/app_failure.dart';
import '../../domain/geo.dart';
import '../models/city.dart';
import '../models/storm.dart';
import '../models/weather_bundle.dart';
import '../parsers/air_quality_parser.dart';
import '../parsers/forecast_parser.dart';
import '../parsers/storm_parser.dart';
import '../services/air_quality_api.dart';
import '../services/forecast_api.dart';
import '../services/storm_api.dart';
import 'weather_cache.dart';

typedef Clock = DateTime Function();

/// Coordinates the three public APIs, merges their output and provides
/// stale-while-offline behaviour.
class WeatherRepository {
  WeatherRepository({
    required this.forecastApi,
    required this.airQualityApi,
    required this.stormApi,
    required this.cache,
    this.cacheTtl = const Duration(minutes: 10),
    Clock? clock,
  }) : _clock = clock ?? (() => DateTime.now().toUtc());

  final ForecastApi forecastApi;
  final AirQualityApi airQualityApi;
  final StormApi stormApi;
  final WeatherCache cache;
  final Duration cacheTtl;
  final Clock _clock;

  Future<WeatherBundle> load(City city, {bool forceRefresh = false}) async {
    final cached = cache.read(city.id);
    final samePlace =
        cached != null &&
        distanceKm(
              cached.latitude,
              cached.longitude,
              city.latitude,
              city.longitude,
            ) <
            5;

    if (!forceRefresh && samePlace && cached.isFresh(cacheTtl, _clock())) {
      return _build(city, cached);
    }

    try {
      final forecastFuture = forecastApi.fetchRaw(city);
      final airFuture = _optional(airQualityApi.fetchRaw(city));
      final stormFuture = _optional(stormApi.fetchRaw());

      final forecastRaw = await forecastFuture;
      final airRaw = await airFuture;
      final stormRaw = await stormFuture;

      final payload = CachedWeatherPayload(
        fetchedAt: _clock(),
        latitude: city.latitude,
        longitude: city.longitude,
        forecast: forecastRaw,
        air: airRaw,
        storms: stormRaw,
      );

      final bundle = _build(city, payload);
      await cache.write(city.id, payload: payload);
      return bundle;
    } catch (error) {
      if (samePlace) {
        try {
          return _build(city, cached, isFromCache: true);
        } on Object {
          // Fall through to the original error.
        }
      }
      if (error is AppFailure) rethrow;
      throw AppFailure(FailureKind.unknown, debugMessage: error.toString());
    }
  }

  /// Removes cached data, e.g. when the user changes measurement system is
  /// irrelevant, but a manual "clear cache" action could use it.
  Future<void> clearCache() => cache.clear();

  WeatherBundle _build(
    City city,
    CachedWeatherPayload payload, {
    bool isFromCache = false,
  }) {
    try {
      final forecast = ForecastParser.parse(payload.forecast);
      final airSnapshot = payload.air == null
          ? null
          : AirQualityParser.parse(payload.air!);

      final hourly = <HourlyPoint>[
        for (final point in forecast.hourly)
          HourlyPoint(
            timeUtc: point.timeUtc,
            temperatureC: point.temperatureC,
            precipitationProbability: point.precipitationProbability,
            precipitationMm: point.precipitationMm,
            weatherCode: point.weatherCode,
            windSpeedKmh: point.windSpeedKmh,
            visibilityKm: point.visibilityKm,
            dustUgM3: airSnapshot
                ?.hourlyDust[point.timeUtc.millisecondsSinceEpoch ~/ 1000],
            pm10: airSnapshot
                ?.hourlyPm10[point.timeUtc.millisecondsSinceEpoch ~/ 1000],
          ),
      ];

      var stormsAvailable = payload.storms != null;
      List<Storm> storms = const [];
      if (payload.storms != null) {
        try {
          storms = StormParser.parse(
            payload.storms!,
            latitude: city.latitude,
            longitude: city.longitude,
          );
        } on Object {
          stormsAvailable = false;
          storms = const [];
        }
      }

      return WeatherBundle(
        city: city,
        timezoneId: forecast.timezoneId,
        utcOffsetSeconds: forecast.utcOffsetSeconds,
        fetchedAt: payload.fetchedAt,
        current: forecast.current,
        hourly: hourly,
        daily: forecast.daily,
        air: airSnapshot?.current ?? AirQuality.empty,
        storms: storms,
        stormsAvailable: stormsAvailable,
        isFromCache: isFromCache,
      );
    } on AppFailure {
      rethrow;
    } on Object catch (error) {
      throw AppFailure(FailureKind.malformed, debugMessage: error.toString());
    }
  }

  Future<Map<String, dynamic>?> _optional(
    Future<Map<String, dynamic>> request,
  ) async {
    try {
      return await request;
    } on Object {
      return null;
    }
  }
}
