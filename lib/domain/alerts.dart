import '../data/models/weather_bundle.dart';

enum AlertSeverity { info, warning, severe }

enum AlertKind { heat, cold, wind, rain, dust, uv, thunder, storm }

class WeatherAlert {
  const WeatherAlert({
    required this.kind,
    required this.severity,
    this.value,
    this.stormName,
    this.distanceKm,
  });

  final AlertKind kind;
  final AlertSeverity severity;

  /// Metric value interpreted according to [kind]: °C for heat/cold,
  /// km/h for wind, mm for rain, µg/m³ for dust, index for UV.
  final double? value;
  final String? stormName;
  final double? distanceKm;
}

/// Derives practical, localized-able alerts from a weather snapshot.
///
/// Thresholds follow common meteorological practice (WMO/Beaufort/WHO) and are
/// deliberately conservative: the goal is actionable awareness, not alarmism.
List<WeatherAlert> buildWeatherAlerts(WeatherBundle bundle) {
  final alerts = <WeatherAlert>[];
  final current = bundle.current;

  final feels = current.feelsLikeC;
  if (feels >= 38) {
    alerts.add(
      WeatherAlert(
        kind: AlertKind.heat,
        severity: feels >= 43 ? AlertSeverity.severe : AlertSeverity.warning,
        value: feels,
      ),
    );
  }

  if (feels <= 0) {
    alerts.add(
      WeatherAlert(
        kind: AlertKind.cold,
        severity: feels <= -10 ? AlertSeverity.severe : AlertSeverity.warning,
        value: feels,
      ),
    );
  }

  final wind = current.windGustKmh >= current.windSpeedKmh
      ? current.windGustKmh
      : current.windSpeedKmh;
  if (wind >= 40) {
    alerts.add(
      WeatherAlert(
        kind: AlertKind.wind,
        severity: wind >= 70 ? AlertSeverity.severe : AlertSeverity.warning,
        value: wind,
      ),
    );
  }

  final nextSix = bundle.precipitationNext(hours: 6);
  if (current.precipitationMm >= 2.5 || nextSix >= 10) {
    final severe = current.precipitationMm >= 8 || nextSix >= 25;
    alerts.add(
      WeatherAlert(
        kind: AlertKind.rain,
        severity: severe ? AlertSeverity.severe : AlertSeverity.warning,
        value: nextSix >= current.precipitationMm
            ? nextSix
            : current.precipitationMm,
      ),
    );
  }

  final dust = bundle.air.dust ?? 0;
  final pm10 = bundle.air.pm10 ?? 0;
  final dustValue = dust > 0 ? dust : pm10;
  if (dust >= 50 || pm10 >= 150) {
    alerts.add(
      WeatherAlert(
        kind: AlertKind.dust,
        severity: dust >= 150 || pm10 >= 300
            ? AlertSeverity.severe
            : AlertSeverity.warning,
        value: dustValue,
      ),
    );
  }

  final uv = bundle.air.uvIndex ?? current.uvIndex;
  if (uv >= 8) {
    alerts.add(
      WeatherAlert(
        kind: AlertKind.uv,
        severity: uv >= 11 ? AlertSeverity.severe : AlertSeverity.warning,
        value: uv,
      ),
    );
  }

  if (current.weatherCode >= 95) {
    alerts.add(
      WeatherAlert(
        kind: AlertKind.thunder,
        severity: current.weatherCode >= 96
            ? AlertSeverity.severe
            : AlertSeverity.warning,
      ),
    );
  }

  final storm = bundle.nearestStorm;
  if (storm != null && storm.distanceKm <= 1000) {
    alerts.add(
      WeatherAlert(
        kind: AlertKind.storm,
        severity: storm.distanceKm <= 500
            ? AlertSeverity.severe
            : AlertSeverity.warning,
        stormName: storm.name,
        distanceKm: storm.distanceKm,
      ),
    );
  }

  alerts.sort((a, b) {
    final bySeverity = b.severity.index.compareTo(a.severity.index);
    return bySeverity != 0 ? bySeverity : a.kind.index.compareTo(b.kind.index);
  });
  return alerts;
}
