import '../../core/constants/app_info.dart';
import '../../core/network/api_client.dart';
import '../models/city.dart';

/// Raw Open-Meteo air-quality requests (dust, PM10, PM2.5, AQI).
class AirQualityApi {
  AirQualityApi(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> fetchRaw(City city) {
    final uri = Uri.parse(ApiEndpoints.airQuality).replace(
      queryParameters: {
        'latitude': city.latitude.toStringAsFixed(4),
        'longitude': city.longitude.toStringAsFixed(4),
        'current': 'pm10,pm2_5,dust,us_aqi,european_aqi,uv_index',
        'hourly': 'dust,pm10',
        'timezone': 'auto',
        'forecast_days': '2',
        'timeformat': 'unixtime',
      },
    );
    return _client.getJson(uri);
  }
}
