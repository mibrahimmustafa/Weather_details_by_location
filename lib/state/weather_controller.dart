import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/errors/app_failure.dart';
import '../data/models/weather_bundle.dart';
import 'cities_controller.dart';
import 'providers.dart';

final weatherProvider = AsyncNotifierProvider<WeatherController, WeatherBundle>(
  WeatherController.new,
);

class WeatherController extends AsyncNotifier<WeatherBundle> {
  @override
  Future<WeatherBundle> build() async {
    final city = ref.watch(selectedCityProvider);
    if (city == null) {
      throw const AppFailure(FailureKind.noCity);
    }
    return ref.watch(weatherRepositoryProvider).load(city);
  }

  /// Force-refreshes the current city while keeping the existing data visible.
  /// Errors are rethrown so the UI can show a localized snackbar.
  Future<void> refresh() async {
    final city = ref.read(selectedCityProvider);
    if (city == null) {
      throw const AppFailure(FailureKind.noCity);
    }
    try {
      final data = await ref
          .read(weatherRepositoryProvider)
          .load(city, forceRefresh: true);
      state = AsyncData(data);
    } catch (error, stackTrace) {
      if (!state.hasValue) {
        state = AsyncError(error, stackTrace);
      }
      rethrow;
    }
  }
}
