/// Static application metadata and public endpoints.
abstract final class AppInfo {
  static const String name = 'Ajwaa';
  static const String arabicName = 'أجواء';
  static const String version = '1.0.0';
  static const String tagline = 'Weather & time, wherever you are';
  static const String repositoryUrl =
      'https://github.com/mibrahimmustafa/Weather_details_by_location';
  static const String openMeteoUrl = 'https://open-meteo.com';
  static const String gdacsUrl = 'https://www.gdacs.org';
  static const String bigDataCloudUrl = 'https://www.bigdatacloud.com';
}

/// Every remote endpoint used by the app, kept in one place.
abstract final class ApiEndpoints {
  static const String forecast = 'https://api.open-meteo.com/v1/forecast';
  static const String airQuality =
      'https://air-quality-api.open-meteo.com/v1/air-quality';
  static const String geocoding =
      'https://geocoding-api.open-meteo.com/v1/search';
  static const String reverseGeocoding =
      'https://api.bigdatacloud.net/data/reverse-geocode-client';
  static const String activeStorms =
      'https://www.gdacs.org/gdacsapi/api/events/geteventlist/SEARCH';
  static const String eonetStorms =
      'https://eonet.gsfc.nasa.gov/api/v3/events?category=severeStorms&status=open&days=60';
}

abstract final class StorageKeys {
  static const String settings = 'ajwaa.settings.v1';
  static const String cities = 'ajwaa.cities.v1';
  static const String selectedCity = 'ajwaa.selectedCity.v1';
  static const String onboardingSeen = 'ajwaa.onboardingSeen.v1';
  static const String weatherCachePrefix = 'ajwaa.weather.v1.';
}
