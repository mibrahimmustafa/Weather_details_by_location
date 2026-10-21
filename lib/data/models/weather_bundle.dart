import '../../core/utils/json_read.dart';
import '../../domain/weather_condition.dart';
import '../models/city.dart';
import 'storm.dart';

/// Immutable weather snapshot for one city at one moment.
///
/// All timestamps are UTC instants. Local city time is derived by adding
/// [utcOffsetSeconds], which the weather API reports for the city (including
/// daylight-saving changes). This avoids relying on the device time zone.
class WeatherBundle {
  const WeatherBundle({
    required this.city,
    required this.timezoneId,
    required this.utcOffsetSeconds,
    required this.fetchedAt,
    required this.current,
    required this.hourly,
    required this.daily,
    required this.air,
    this.storms = const [],
    this.stormsAvailable = false,
    this.isFromCache = false,
  });

  final City city;
  final String timezoneId;
  final int utcOffsetSeconds;
  final DateTime fetchedAt;
  final CurrentWeather current;
  final List<HourlyPoint> hourly;
  final List<DailyPoint> daily;
  final AirQuality air;
  final List<Storm> storms;
  final bool stormsAvailable;
  final bool isFromCache;

  WeatherCondition get condition => conditionFromWmoCode(current.weatherCode);

  DateTime get localNow =>
      DateTime.now().toUtc().add(Duration(seconds: utcOffsetSeconds));

  WeatherBundle copyWith({
    List<Storm>? storms,
    bool? stormsAvailable,
    bool? isFromCache,
    DateTime? fetchedAt,
    AirQuality? air,
  }) {
    return WeatherBundle(
      city: city,
      timezoneId: timezoneId,
      utcOffsetSeconds: utcOffsetSeconds,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      current: current,
      hourly: hourly,
      daily: daily,
      air: air ?? this.air,
      storms: storms ?? this.storms,
      stormsAvailable: stormsAvailable ?? this.stormsAvailable,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  int dayKey(DateTime instantUtc) {
    final local = instantUtc.add(Duration(seconds: utcOffsetSeconds));
    return local.year * 10000 + local.month * 100 + local.day;
  }

  DailyPoint? get today {
    if (daily.isEmpty) return null;
    final key = dayKey(DateTime.now().toUtc());
    return firstWhereOrNull(daily, (day) => dayKey(day.dateUtc) == key) ??
        daily.first;
  }

  /// Hourly points from the start of the current hour onwards.
  List<HourlyPoint> upcomingHours({int count = 24, DateTime? fromUtc}) {
    if (hourly.isEmpty) return const [];
    final now = (fromUtc ?? DateTime.now().toUtc()).toUtc();
    final start = DateTime.utc(now.year, now.month, now.day, now.hour);
    final result = hourly
        .where((point) => !point.timeUtc.isBefore(start))
        .take(count)
        .toList(growable: false);
    return result.isEmpty ? hourly.take(count).toList(growable: false) : result;
  }

  /// Total liquid precipitation expected in the next [hours] hours.
  double precipitationNext({int hours = 24, DateTime? fromUtc}) {
    var total = 0.0;
    for (final point in upcomingHours(count: hours, fromUtc: fromUtc)) {
      total += point.precipitationMm;
    }
    return total;
  }

  /// Index (within the current hour list) of the first meaningful rain, or
  /// `null` when no rain is expected.
  int? hoursUntilRain({int withinHours = 24}) {
    final points = upcomingHours(count: withinHours);
    for (var i = 0; i < points.length; i++) {
      if (points[i].precipitationMm >= 0.15 ||
          points[i].precipitationProbability >= 55) {
        return i;
      }
    }
    return null;
  }

  bool isDaylightAt(DateTime instantUtc) {
    final day = firstWhereOrNull(
      daily,
      (item) => dayKey(item.dateUtc) == dayKey(instantUtc),
    );
    final sunrise = day?.sunriseUtc;
    final sunset = day?.sunsetUtc;
    if (sunrise == null || sunset == null) {
      final localHour = instantUtc
          .add(Duration(seconds: utcOffsetSeconds))
          .hour;
      return localHour >= 6 && localHour < 18;
    }
    return instantUtc.isAfter(sunrise) && instantUtc.isBefore(sunset);
  }

  /// Nearest active storm, or `null` if none have been reported.
  Storm? get nearestStorm => storms.isEmpty
      ? null
      : storms.reduce((a, b) => a.distanceKm <= b.distanceKm ? a : b);
}

class CurrentWeather {
  const CurrentWeather({
    required this.timeUtc,
    required this.temperatureC,
    required this.feelsLikeC,
    required this.relativeHumidity,
    required this.precipitationMm,
    required this.rainMm,
    required this.showersMm,
    required this.snowfallCm,
    required this.weatherCode,
    required this.isDay,
    required this.cloudCover,
    required this.pressureHpa,
    required this.windSpeedKmh,
    required this.windDirectionDeg,
    required this.windGustKmh,
    required this.visibilityKm,
    required this.uvIndex,
    required this.dewPointC,
  });

  final DateTime timeUtc;
  final double temperatureC;
  final double feelsLikeC;
  final double relativeHumidity;
  final double precipitationMm;
  final double rainMm;
  final double showersMm;
  final double snowfallCm;
  final int weatherCode;
  final bool isDay;
  final double cloudCover;
  final double pressureHpa;
  final double windSpeedKmh;
  final double windDirectionDeg;
  final double windGustKmh;
  final double visibilityKm;
  final double uvIndex;
  final double dewPointC;
}

class HourlyPoint {
  const HourlyPoint({
    required this.timeUtc,
    required this.temperatureC,
    required this.precipitationProbability,
    required this.precipitationMm,
    required this.weatherCode,
    required this.windSpeedKmh,
    required this.visibilityKm,
    this.dustUgM3,
    this.pm10,
  });

  final DateTime timeUtc;
  final double temperatureC;
  final int precipitationProbability;
  final double precipitationMm;
  final int weatherCode;
  final double windSpeedKmh;
  final double visibilityKm;
  final double? dustUgM3;
  final double? pm10;
}

class DailyPoint {
  const DailyPoint({
    required this.dateUtc,
    required this.weatherCode,
    required this.temperatureMaxC,
    required this.temperatureMinC,
    required this.sunriseUtc,
    required this.sunsetUtc,
    required this.uvIndexMax,
    required this.precipitationSumMm,
    required this.precipitationProbabilityMax,
    required this.windSpeedMaxKmh,
  });

  final DateTime dateUtc;
  final int weatherCode;
  final double temperatureMaxC;
  final double temperatureMinC;
  final DateTime? sunriseUtc;
  final DateTime? sunsetUtc;
  final double uvIndexMax;
  final double precipitationSumMm;
  final int precipitationProbabilityMax;
  final double windSpeedMaxKmh;
}

class AirQuality {
  const AirQuality({
    this.pm10,
    this.pm25,
    this.dust,
    this.usAqi,
    this.europeanAqi,
    this.uvIndex,
  });

  static const AirQuality empty = AirQuality();

  final double? pm10;
  final double? pm25;
  final double? dust;
  final int? usAqi;
  final int? europeanAqi;
  final double? uvIndex;

  bool get hasData =>
      pm10 != null || pm25 != null || dust != null || usAqi != null;
}

/// Parsed forecast payload (weather model only).
class ForecastSnapshot {
  const ForecastSnapshot({
    required this.timezoneId,
    required this.utcOffsetSeconds,
    required this.current,
    required this.hourly,
    required this.daily,
  });

  final String timezoneId;
  final int utcOffsetSeconds;
  final CurrentWeather current;
  final List<HourlyPoint> hourly;
  final List<DailyPoint> daily;
}

/// Parsed air-quality payload.
class AirSnapshot {
  const AirSnapshot({
    required this.current,
    required this.hourlyDust,
    required this.hourlyPm10,
  });

  final AirQuality current;
  final Map<int, double> hourlyDust;
  final Map<int, double> hourlyPm10;
}
