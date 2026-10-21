import 'dart:math' as math;

import '../../core/utils/json_read.dart';
import '../models/weather_bundle.dart';

/// Parses Open-Meteo forecast responses. Pure functions keep this easy to test
/// with recorded fixtures.
class ForecastParser {
  static ForecastSnapshot parse(Map<String, dynamic> json) {
    final timezoneId = readString(json['timezone'], 'UTC');
    final utcOffsetSeconds = readInt(json['utc_offset_seconds']);
    final hourly = _parseHourly(readMap(json['hourly']));
    final daily = _parseDaily(readMap(json['daily']));
    final currentMap = readMap(json['current']);

    final currentTime =
        readUnixSeconds(currentMap['time']) ??
        (hourly.isNotEmpty ? hourly.first.timeUtc : DateTime.now().toUtc());

    final visibility = _visibilityAt(hourly, currentTime);
    final temperature = readDouble(currentMap['temperature_2m']);
    final humidity = readDouble(currentMap['relative_humidity_2m'], 50);

    final current = CurrentWeather(
      timeUtc: currentTime,
      temperatureC: temperature,
      feelsLikeC: readDouble(currentMap['apparent_temperature'], temperature),
      relativeHumidity: humidity,
      precipitationMm: readDouble(currentMap['precipitation']),
      rainMm: readDouble(currentMap['rain']),
      showersMm: readDouble(currentMap['showers']),
      snowfallCm: readDouble(currentMap['snowfall']),
      weatherCode: readInt(currentMap['weather_code']),
      isDay: currentMap['is_day'] == 1 || currentMap['is_day'] == true,
      cloudCover: readDouble(currentMap['cloud_cover']),
      pressureHpa: readDouble(currentMap['pressure_msl']),
      windSpeedKmh: readDouble(currentMap['wind_speed_10m']),
      windDirectionDeg: readDouble(currentMap['wind_direction_10m']),
      windGustKmh: readDouble(
        currentMap['wind_gusts_10m'],
        readDouble(currentMap['wind_speed_10m']),
      ),
      visibilityKm: visibility,
      uvIndex: daily.isNotEmpty ? daily.first.uvIndexMax : 0,
      dewPointC: _dewPoint(temperature, humidity),
    );

    return ForecastSnapshot(
      timezoneId: timezoneId,
      utcOffsetSeconds: utcOffsetSeconds,
      current: current,
      hourly: hourly,
      daily: daily,
    );
  }

  static List<HourlyPoint> _parseHourly(Map<String, dynamic> json) {
    final times = readList(json['time']);
    final temperatures = readList(json['temperature_2m']);
    final probabilities = readList(json['precipitation_probability']);
    final precipitation = readList(json['precipitation']);
    final codes = readList(json['weather_code']);
    final winds = readList(json['wind_speed_10m']);
    final visibility = readList(json['visibility']);

    final result = <HourlyPoint>[];
    for (var i = 0; i < times.length; i++) {
      final time = readUnixSeconds(times[i]);
      final temperature = readDoubleOrNull(_at(temperatures, i));
      if (time == null || temperature == null) continue;
      result.add(
        HourlyPoint(
          timeUtc: time,
          temperatureC: temperature,
          precipitationProbability: readInt(_at(probabilities, i)),
          precipitationMm: readDouble(_at(precipitation, i)),
          weatherCode: readInt(_at(codes, i)),
          windSpeedKmh: readDouble(_at(winds, i)),
          visibilityKm: readDouble(_at(visibility, i)) / 1000,
        ),
      );
    }
    return result;
  }

  static List<DailyPoint> _parseDaily(Map<String, dynamic> json) {
    final times = readList(json['time']);
    final codes = readList(json['weather_code']);
    final maxes = readList(json['temperature_2m_max']);
    final mins = readList(json['temperature_2m_min']);
    final sunrises = readList(json['sunrise']);
    final sunsets = readList(json['sunset']);
    final uv = readList(json['uv_index_max']);
    final precipitation = readList(json['precipitation_sum']);
    final probabilities = readList(json['precipitation_probability_max']);
    final winds = readList(json['wind_speed_10m_max']);

    final result = <DailyPoint>[];
    for (var i = 0; i < times.length; i++) {
      final date = readUnixSeconds(times[i]);
      if (date == null) continue;
      result.add(
        DailyPoint(
          dateUtc: date,
          weatherCode: readInt(_at(codes, i)),
          temperatureMaxC: readDouble(_at(maxes, i)),
          temperatureMinC: readDouble(_at(mins, i)),
          sunriseUtc: readUnixSeconds(_at(sunrises, i)),
          sunsetUtc: readUnixSeconds(_at(sunsets, i)),
          uvIndexMax: readDouble(_at(uv, i)),
          precipitationSumMm: readDouble(_at(precipitation, i)),
          precipitationProbabilityMax: readInt(_at(probabilities, i)),
          windSpeedMaxKmh: readDouble(_at(winds, i)),
        ),
      );
    }
    return result;
  }

  static double _visibilityAt(List<HourlyPoint> hourly, DateTime time) {
    if (hourly.isEmpty) return 10;
    final index = hourly.indexWhere((point) => point.timeUtc == time);
    if (index >= 0) return hourly[index].visibilityKm;
    final before = hourly.lastWhere(
      (point) => !point.timeUtc.isAfter(time),
      orElse: () => hourly.first,
    );
    return before.visibilityKm;
  }

  /// Magnus-Tetens approximation, accurate to ~0.4 °C for normal conditions.
  static double _dewPoint(double temperatureC, double humidity) {
    final rh = humidity.clamp(1.0, 100.0);
    const a = 17.625;
    const b = 243.04;
    final gamma = math.log(rh / 100) + (a * temperatureC) / (b + temperatureC);
    return (b * gamma) / (a - gamma);
  }

  static Object? _at(List<Object?> list, int index) =>
      index < list.length ? list[index] : null;
}
