import 'package:ajwaa/core/utils/formatters.dart';
import 'package:ajwaa/domain/environment_levels.dart';
import 'package:ajwaa/domain/units.dart';
import 'package:ajwaa/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
  });

  group('Units', () {
    test('converts temperature, wind and distance', () {
      expect(Units.temperature(0, UnitSystem.imperial), closeTo(32, 0.001));
      expect(Units.temperature(100, UnitSystem.imperial), closeTo(212, 0.001));
      expect(Units.wind(100, UnitSystem.imperial), closeTo(62.1371, 0.001));
      expect(Units.distance(10, UnitSystem.imperial), closeTo(6.21371, 0.001));
      expect(
        Units.precipitation(25.4, UnitSystem.imperial),
        closeTo(1, 0.0001),
      );
      expect(Units.temperature(21, UnitSystem.metric), 21);
      expect(Units.fromCode('imperial'), UnitSystem.imperial);
      expect(Units.fromCode(null), UnitSystem.metric);
    });
  });

  group('Fmt', () {
    final l10n = AppLocalizationsEn();
    final metric = Fmt(l10n: l10n, units: UnitSystem.metric, locale: 'en');
    final imperial = Fmt(l10n: l10n, units: UnitSystem.imperial, locale: 'en');

    test('formats values in both systems', () {
      expect(metric.temperature(31.4), '31°');
      expect(imperial.temperature(0), '32°');
      expect(metric.wind(14), '14 km/h');
      expect(imperial.wind(100), '62 mph');
      expect(metric.percent(55), '55%');
      expect(metric.pressure(1012.5), '1,013 hPa');
      expect(metric.dust(62), '62 µg/m³');
    });

    test('formats the city clock and GMT offset', () {
      final local = DateTime.utc(2026, 10, 21, 9, 5);
      expect(metric.clock(local), '09:05');
      expect(metric.clock(local, seconds: true), '09:05:00');
      expect(metric.clockFromUtc(DateTime.utc(2026, 10, 21, 7), 7200), '09:00');
      expect(metric.gmtOffset(7200), 'GMT+02');
      expect(metric.gmtOffset(-18000), 'GMT-05');
      expect(metric.gmtOffset(19800), 'GMT+05:30');
    });

    test('maps wind degrees to compass points', () {
      expect(metric.direction(0), 'N');
      expect(metric.direction(45), 'NE');
      expect(metric.direction(180), 'S');
      expect(metric.direction(359), 'N');
      expect(metric.direction(270), 'W');
    });

    test('formats relative update times', () {
      final now = DateTime.now().toUtc();
      expect(metric.relativeUpdated(now), l10n.justNow);
      expect(
        metric.relativeUpdated(now.subtract(const Duration(minutes: 5))),
        l10n.updatedMinutesAgo(5),
      );
    });
  });

  group('environment levels', () {
    test('classifies dust, UV and AQI', () {
      expect(dustLevelFor(10), DustLevel.low);
      expect(dustLevelFor(35), DustLevel.moderate);
      expect(dustLevelFor(75), DustLevel.high);
      expect(dustLevelFor(220), DustLevel.veryHigh);

      expect(uvLevelFor(1), UvLevel.low);
      expect(uvLevelFor(4), UvLevel.moderate);
      expect(uvLevelFor(7), UvLevel.high);
      expect(uvLevelFor(9), UvLevel.veryHigh);
      expect(uvLevelFor(12), UvLevel.extreme);

      expect(aqiLevelFor(20), AqiLevel.good);
      expect(aqiLevelFor(120), AqiLevel.unhealthySensitive);
      expect(aqiLevelFor(180), AqiLevel.unhealthy);
      expect(aqiLevelFor(450), AqiLevel.hazardous);
    });
  });
}
