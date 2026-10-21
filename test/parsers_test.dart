import 'package:ajwaa/data/parsers/air_quality_parser.dart';
import 'package:ajwaa/data/parsers/forecast_parser.dart';
import 'package:ajwaa/data/parsers/storm_parser.dart';
import 'package:ajwaa/data/models/storm.dart';
import 'package:ajwaa/domain/weather_condition.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fixtures.dart';

void main() {
  group('conditionFromWmoCode', () {
    test('maps representative WMO codes', () {
      expect(conditionFromWmoCode(0), WeatherCondition.clear);
      expect(conditionFromWmoCode(2), WeatherCondition.partlyCloudy);
      expect(conditionFromWmoCode(63), WeatherCondition.rain);
      expect(conditionFromWmoCode(65), WeatherCondition.heavyRain);
      expect(conditionFromWmoCode(75), WeatherCondition.snow);
      expect(conditionFromWmoCode(95), WeatherCondition.thunderstorm);
      expect(conditionFromWmoCode(35), WeatherCondition.dust);
      expect(conditionFromWmoCode(9999), WeatherCondition.unknown);
    });
  });

  group('ForecastParser', () {
    test('parses current, hourly and daily values', () {
      final snapshot = ForecastParser.parse(forecastFixture());

      expect(snapshot.timezoneId, 'Africa/Cairo');
      expect(snapshot.utcOffsetSeconds, 7200);
      expect(snapshot.current.temperatureC, closeTo(31.4, 0.001));
      expect(snapshot.current.isDay, isTrue);
      expect(snapshot.current.weatherCode, 1);
      expect(snapshot.hourly, hasLength(3));
      expect(snapshot.daily, hasLength(3));
      // Visibility is taken from the hourly point matching the current time.
      expect(snapshot.current.visibilityKm, closeTo(24, 0.001));
      // UV falls back to the daily maximum when the current field is absent.
      expect(snapshot.current.uvIndex, closeTo(7.5, 0.001));
      // Dew point is always below the air temperature at 40% humidity.
      expect(
        snapshot.current.dewPointC,
        lessThan(snapshot.current.temperatureC),
      );
      expect(snapshot.daily[1].precipitationSumMm, closeTo(2.4, 0.001));
      expect(snapshot.daily[0].sunriseUtc, isNotNull);
    });

    test('tolerates missing arrays', () {
      final snapshot = ForecastParser.parse(const {});
      expect(snapshot.hourly, isEmpty);
      expect(snapshot.daily, isEmpty);
      expect(snapshot.current.temperatureC, 0);
    });
  });

  group('AirQualityParser', () {
    test('reads current values and hourly series', () {
      final snapshot = AirQualityParser.parse(airQualityFixture());
      expect(snapshot.current.dust, closeTo(62, 0.001));
      expect(snapshot.current.pm25, closeTo(22.1, 0.001));
      expect(snapshot.current.usAqi, 82);
      expect(snapshot.current.uvIndex, closeTo(6.2, 0.001));
      expect(snapshot.hourlyDust, hasLength(2));
      expect(snapshot.hourlyDust[kBaseEpoch], closeTo(62, 0.001));
      expect(snapshot.hourlyPm10, hasLength(2));
      expect(snapshot.current.hasData, isTrue);
    });
  });

  group('StormParser', () {
    test('parses EONET events and converts knots to km/h', () {
      final storms = StormParser.parse(
        eonetWrapper(),
        latitude: 30.04,
        longitude: 31.24,
      );
      expect(storms, hasLength(1));
      final storm = storms.single;
      expect(storm.name, 'Tropical Storm Ajwaa');
      expect(storm.maxWindKmh, closeTo(80 * 1.852, 0.01));
      // 148 km/h is hurricane strength -> red alert.
      expect(storm.alertLevel, StormAlertLevel.red);
      expect(storm.distanceKm, greaterThan(0));
      expect(storm.reportUrl, 'https://example.com/eonet-storm');
    });

    test('parses GDACS features and drops inactive events', () {
      final storms = StormParser.parse(
        gdacsWrapper(),
        latitude: 30.04,
        longitude: 31.24,
      );
      expect(storms, hasLength(1));
      final storm = storms.single;
      expect(storm.name, 'Cyclone GDACS');
      expect(storm.alertLevel, StormAlertLevel.orange);
      expect(storm.maxWindKmh, closeTo(90, 0.001));
      expect(storm.country, 'Testland');
      expect(storm.fromUtc, isNotNull);
    });
  });
}
