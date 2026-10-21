import '../../core/constants/app_info.dart';
import '../../core/network/api_client.dart';
import '../models/city.dart';

/// Raw Open-Meteo forecast requests.
class ForecastApi {
  ForecastApi(this._client);

  final ApiClient _client;

  static const List<String> _currentFields = [
    'temperature_2m',
    'relative_humidity_2m',
    'apparent_temperature',
    'is_day',
    'precipitation',
    'rain',
    'showers',
    'snowfall',
    'weather_code',
    'cloud_cover',
    'pressure_msl',
    'wind_speed_10m',
    'wind_direction_10m',
    'wind_gusts_10m',
  ];

  static const List<String> _hourlyFields = [
    'temperature_2m',
    'precipitation_probability',
    'precipitation',
    'weather_code',
    'wind_speed_10m',
    'visibility',
  ];

  static const List<String> _dailyFields = [
    'weather_code',
    'temperature_2m_max',
    'temperature_2m_min',
    'sunrise',
    'sunset',
    'uv_index_max',
    'precipitation_sum',
    'precipitation_probability_max',
    'wind_speed_10m_max',
  ];

  Future<Map<String, dynamic>> fetchRaw(City city) {
    final uri = Uri.parse(ApiEndpoints.forecast).replace(
      queryParameters: {
        'latitude': city.latitude.toStringAsFixed(4),
        'longitude': city.longitude.toStringAsFixed(4),
        'current': _currentFields.join(','),
        'hourly': _hourlyFields.join(','),
        'daily': _dailyFields.join(','),
        'timezone': 'auto',
        'forecast_days': '7',
        'timeformat': 'unixtime',
        'temperature_unit': 'celsius',
        'wind_speed_unit': 'kmh',
        'precipitation_unit': 'mm',
      },
    );
    return _client.getJson(uri);
  }
}
