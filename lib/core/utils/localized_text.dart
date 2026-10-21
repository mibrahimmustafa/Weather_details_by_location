import '../../domain/alerts.dart';
import '../../domain/environment_levels.dart';
import '../../domain/weather_condition.dart';
import '../../l10n/app_localizations.dart';
import '../errors/app_failure.dart';

String failureMessage(AppLocalizations l10n, Object? error) {
  if (error is AppFailure) {
    return switch (error.kind) {
      FailureKind.network => l10n.errorNetwork,
      FailureKind.timeout => l10n.errorTimeout,
      FailureKind.server => l10n.errorServer,
      FailureKind.rateLimited => l10n.errorRateLimited,
      FailureKind.malformed => l10n.errorMalformed,
      FailureKind.noCity => l10n.errorNoCity,
      FailureKind.locationDenied => l10n.locationDenied,
      FailureKind.locationDeniedForever => l10n.locationDeniedForever,
      FailureKind.locationServiceDisabled => l10n.locationServiceDisabled,
      FailureKind.locationTimeout => l10n.locationTimeout,
      FailureKind.locationFailed => l10n.locationFailed,
      FailureKind.unknown => l10n.errorUnknown,
    };
  }
  return l10n.errorUnknown;
}

String conditionLabel(AppLocalizations l10n, WeatherCondition condition) {
  return switch (condition) {
    WeatherCondition.clear => l10n.conditionClear,
    WeatherCondition.mainlyClear => l10n.conditionMainlyClear,
    WeatherCondition.partlyCloudy => l10n.conditionPartlyCloudy,
    WeatherCondition.cloudy => l10n.conditionCloudy,
    WeatherCondition.fog => l10n.conditionFog,
    WeatherCondition.drizzle => l10n.conditionDrizzle,
    WeatherCondition.rain => l10n.conditionRain,
    WeatherCondition.heavyRain => l10n.conditionHeavyRain,
    WeatherCondition.freezingRain => l10n.conditionFreezingRain,
    WeatherCondition.snow => l10n.conditionSnow,
    WeatherCondition.thunderstorm => l10n.conditionThunderstorm,
    WeatherCondition.dust => l10n.conditionDust,
    WeatherCondition.unknown => l10n.conditionUnknown,
  };
}

/// Localized "why this matters" copy for the alert types.
String alertTitle(AppLocalizations l10n, AlertKind kind) {
  return switch (kind) {
    AlertKind.heat => l10n.alertHeatTitle,
    AlertKind.cold => l10n.alertColdTitle,
    AlertKind.wind => l10n.alertWindTitle,
    AlertKind.rain => l10n.alertRainTitle,
    AlertKind.dust => l10n.alertDustTitle,
    AlertKind.uv => l10n.alertUvTitle,
    AlertKind.thunder => l10n.alertThunderTitle,
    AlertKind.storm => l10n.alertStormTitle,
  };
}

String alertBody(
  AppLocalizations l10n,
  AlertKind kind,
  String value, {
  String? name,
}) {
  return switch (kind) {
    AlertKind.heat => l10n.alertHeatBody(value),
    AlertKind.cold => l10n.alertColdBody(value),
    AlertKind.wind => l10n.alertWindBody(value),
    AlertKind.rain => l10n.alertRainBody(value),
    AlertKind.dust => l10n.alertDustBody(value),
    AlertKind.uv => l10n.alertUvBody(value),
    AlertKind.thunder => l10n.alertThunderBody,
    AlertKind.storm => l10n.alertStormBody(name ?? '', value),
  };
}

String dustLevelLabel(AppLocalizations l10n, DustLevel level) {
  return switch (level) {
    DustLevel.low => l10n.dustLow,
    DustLevel.moderate => l10n.dustModerate,
    DustLevel.high => l10n.dustHigh,
    DustLevel.veryHigh => l10n.dustVeryHigh,
  };
}

String dustAdvice(AppLocalizations l10n, DustLevel level) {
  return switch (level) {
    DustLevel.low => l10n.dustAdviceLow,
    DustLevel.moderate => l10n.dustAdviceModerate,
    DustLevel.high => l10n.dustAdviceHigh,
    DustLevel.veryHigh => l10n.dustAdviceVeryHigh,
  };
}

String uvLevelLabel(AppLocalizations l10n, UvLevel level) {
  return switch (level) {
    UvLevel.low => l10n.uvLow,
    UvLevel.moderate => l10n.uvModerate,
    UvLevel.high => l10n.uvHigh,
    UvLevel.veryHigh => l10n.uvVeryHigh,
    UvLevel.extreme => l10n.uvExtreme,
  };
}

String aqiLevelLabel(AppLocalizations l10n, AqiLevel level) {
  return switch (level) {
    AqiLevel.good => l10n.good,
    AqiLevel.moderate => l10n.moderate,
    AqiLevel.unhealthySensitive => l10n.unhealthySensitive,
    AqiLevel.unhealthy => l10n.unhealthy,
    AqiLevel.veryUnhealthy => l10n.veryUnhealthy,
    AqiLevel.hazardous => l10n.hazardous,
  };
}
