/// WMO weather interpretation codes, grouped into the conditions the UI
/// actually renders. Grouping keeps the presentation layer simple and makes
/// the mapping easy to unit-test.
enum WeatherCondition {
  clear,
  mainlyClear,
  partlyCloudy,
  cloudy,
  fog,
  drizzle,
  rain,
  heavyRain,
  freezingRain,
  snow,
  thunderstorm,
  dust,
  unknown;

  bool get isRainy =>
      this == drizzle ||
      this == rain ||
      this == heavyRain ||
      this == freezingRain ||
      this == thunderstorm;

  bool get isSnowy => this == snow;

  bool get isDusty => this == dust;

  bool get isStormy => this == thunderstorm;
}

WeatherCondition conditionFromWmoCode(int code) {
  switch (code) {
    case 0:
      return WeatherCondition.clear;
    case 1:
      return WeatherCondition.mainlyClear;
    case 2:
      return WeatherCondition.partlyCloudy;
    case 3:
      return WeatherCondition.cloudy;
    case 45:
    case 48:
      return WeatherCondition.fog;
    case 51:
    case 53:
    case 55:
      return WeatherCondition.drizzle;
    case 56:
    case 57:
    case 66:
    case 67:
      return WeatherCondition.freezingRain;
    case 61:
    case 63:
      return WeatherCondition.rain;
    case 65:
      return WeatherCondition.heavyRain;
    case 71:
    case 73:
    case 75:
    case 77:
    case 85:
    case 86:
      return WeatherCondition.snow;
    case 80:
    case 81:
      return WeatherCondition.rain;
    case 82:
      return WeatherCondition.heavyRain;
    case 95:
    case 96:
    case 99:
      return WeatherCondition.thunderstorm;
    case 30:
    case 31:
    case 32:
    case 33:
    case 34:
    case 35:
      return WeatherCondition.dust;
    default:
      return WeatherCondition.unknown;
  }
}
