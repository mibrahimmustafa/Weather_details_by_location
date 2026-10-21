import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/network/api_client.dart';
import '../data/repositories/cities_store.dart';
import '../data/repositories/settings_store.dart';
import '../data/repositories/weather_cache.dart';
import '../data/repositories/weather_repository.dart';
import '../data/services/air_quality_api.dart';
import '../data/services/forecast_api.dart';
import '../data/services/geocoding_api.dart';
import '../data/services/location_service.dart';
import '../data/services/storm_api.dart';

/// Injected from `main()` so every controller can read preferences
/// synchronously and the first frame is already correct.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('SharedPreferences must be overridden'),
);

final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient();
  ref.onDispose(client.dispose);
  return client;
});

/// Storms are decorative-but-useful secondary data: fail fast instead of
/// delaying the forecast.
final stormClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient(timeout: const Duration(seconds: 8), maxAttempts: 1);
  ref.onDispose(client.dispose);
  return client;
});

final forecastApiProvider = Provider<ForecastApi>(
  (ref) => ForecastApi(ref.watch(apiClientProvider)),
);

final airQualityApiProvider = Provider<AirQualityApi>(
  (ref) => AirQualityApi(ref.watch(apiClientProvider)),
);

final stormApiProvider = Provider<StormApi>(
  (ref) => StormApi(ref.watch(stormClientProvider)),
);

final geocodingApiProvider = Provider<GeocodingApi>(
  (ref) => GeocodingApi(ref.watch(apiClientProvider)),
);

final locationServiceProvider = Provider<LocationService>(
  (ref) => LocationService(),
);

final weatherCacheProvider = Provider<WeatherCache>(
  (ref) => WeatherCache(ref.watch(sharedPreferencesProvider)),
);

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return WeatherRepository(
    forecastApi: ref.watch(forecastApiProvider),
    airQualityApi: ref.watch(airQualityApiProvider),
    stormApi: ref.watch(stormApiProvider),
    cache: ref.watch(weatherCacheProvider),
  );
});

final settingsStoreProvider = Provider<SettingsStore>(
  (ref) => SettingsStore(ref.watch(sharedPreferencesProvider)),
);

final citiesStoreProvider = Provider<CitiesStore>(
  (ref) => CitiesStore(ref.watch(sharedPreferencesProvider)),
);
