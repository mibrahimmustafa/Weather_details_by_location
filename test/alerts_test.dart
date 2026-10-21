import 'package:ajwaa/data/models/city.dart';
import 'package:ajwaa/data/models/storm.dart';
import 'package:ajwaa/data/models/weather_bundle.dart';
import 'package:ajwaa/domain/alerts.dart';
import 'package:flutter_test/flutter_test.dart';

final DateTime _base = DateTime.utc(2026, 10, 21, 9);

WeatherBundle bundleWith({
  double feelsLike = 25,
  double windSpeed = 10,
  double windGust = 12,
  double precipitation = 0,
  double nextSixHours = 0,
  double dust = 0,
  double pm10 = 0,
  double uv = 0,
  int weatherCode = 0,
  List<Storm> storms = const [],
}) {
  final hourly = [
    for (var i = 0; i < 3; i++)
      HourlyPoint(
        timeUtc: _base.add(Duration(hours: i)),
        temperatureC: 25,
        precipitationProbability: nextSixHours > 0 ? 70 : 5,
        precipitationMm: nextSixHours / 3,
        weatherCode: weatherCode,
        windSpeedKmh: windSpeed,
        visibilityKm: 10,
      ),
  ];

  return WeatherBundle(
    city: const City(
      id: 'cairo',
      name: 'Cairo',
      latitude: 30.04,
      longitude: 31.24,
    ),
    timezoneId: 'Africa/Cairo',
    utcOffsetSeconds: 7200,
    fetchedAt: _base,
    current: CurrentWeather(
      timeUtc: _base,
      temperatureC: 27,
      feelsLikeC: feelsLike,
      relativeHumidity: 40,
      precipitationMm: precipitation,
      rainMm: precipitation,
      showersMm: 0,
      snowfallCm: 0,
      weatherCode: weatherCode,
      isDay: true,
      cloudCover: 10,
      pressureHpa: 1012,
      windSpeedKmh: windSpeed,
      windDirectionDeg: 315,
      windGustKmh: windGust,
      visibilityKm: 10,
      uvIndex: uv,
      dewPointC: 12,
    ),
    hourly: hourly,
    daily: [
      DailyPoint(
        dateUtc: DateTime.utc(2026, 10, 21),
        weatherCode: 0,
        temperatureMaxC: 33,
        temperatureMinC: 22,
        sunriseUtc: DateTime.utc(2026, 10, 21, 4),
        sunsetUtc: DateTime.utc(2026, 10, 21, 16),
        uvIndexMax: uv,
        precipitationSumMm: nextSixHours,
        precipitationProbabilityMax: 70,
        windSpeedMaxKmh: windSpeed,
      ),
    ],
    air: AirQuality(dust: dust, pm10: pm10, uvIndex: uv),
    storms: storms,
    stormsAvailable: true,
  );
}

List<AlertKind> kindsFor(WeatherBundle bundle) =>
    buildWeatherAlerts(bundle).map((alert) => alert.kind).toList();

void main() {
  group('buildWeatherAlerts', () {
    test('is empty for calm weather', () {
      expect(buildWeatherAlerts(bundleWith()), isEmpty);
    });

    test('flags extreme heat with escalating severity', () {
      final warning = buildWeatherAlerts(bundleWith(feelsLike: 40)).single;
      expect(warning.kind, AlertKind.heat);
      expect(warning.severity, AlertSeverity.warning);

      final severe = buildWeatherAlerts(bundleWith(feelsLike: 45)).single;
      expect(severe.severity, AlertSeverity.severe);
    });

    test('flags severe cold', () {
      final alert = buildWeatherAlerts(bundleWith(feelsLike: -3)).single;
      expect(alert.kind, AlertKind.cold);
      expect(alert.severity, AlertSeverity.warning);
      expect(
        buildWeatherAlerts(bundleWith(feelsLike: -14)).single.severity,
        AlertSeverity.severe,
      );
    });

    test('uses the higher of wind speed and gusts', () {
      final alert = buildWeatherAlerts(bundleWith(windSpeed: 30, windGust: 72))
          .single;
      expect(alert.kind, AlertKind.wind);
      expect(alert.severity, AlertSeverity.severe);
      expect(alert.value, 72);
    });

    test('flags heavy rain from the next six hours', () {
      final alert = buildWeatherAlerts(bundleWith(nextSixHours: 26)).single;
      expect(alert.kind, AlertKind.rain);
      expect(alert.severity, AlertSeverity.severe);
    });

    test('flags dust and UV', () {
      expect(kindsFor(bundleWith(dust: 60)), contains(AlertKind.dust));
      expect(kindsFor(bundleWith(dust: 160)), contains(AlertKind.dust));
      expect(kindsFor(bundleWith(uv: 9)), contains(AlertKind.uv));
      expect(kindsFor(bundleWith(uv: 12)), contains(AlertKind.uv));
    });

    test('flags thunderstorms', () {
      final alert = buildWeatherAlerts(bundleWith(weatherCode: 96)).single;
      expect(alert.kind, AlertKind.thunder);
      expect(alert.severity, AlertSeverity.severe);
    });

    test('flags nearby cyclones and sorts by severity', () {
      final bundle = bundleWith(
        feelsLike: 40,
        storms: [
          Storm(
            id: 's1',
            name: 'Cyclone Test',
            alertLevel: StormAlertLevel.orange,
            country: 'Testland',
            latitude: 20,
            longitude: 60,
            distanceKm: 420,
            maxWindKmh: 120,
          ),
        ],
      );
      final alerts = buildWeatherAlerts(bundle);
      expect(alerts.map((alert) => alert.kind), contains(AlertKind.storm));
      expect(alerts.first.severity, AlertSeverity.severe);
    });

    test('ignores distant cyclones', () {
      final bundle = bundleWith(
        storms: [
          Storm(
            id: 's2',
            name: 'Far Cyclone',
            alertLevel: StormAlertLevel.green,
            country: 'Nowhere',
            latitude: -20,
            longitude: -160,
            distanceKm: 9000,
            maxWindKmh: 60,
          ),
        ],
      );
      expect(kindsFor(bundle), isNot(contains(AlertKind.storm)));
    });
  });
}
