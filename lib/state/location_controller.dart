import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/errors/app_failure.dart';
import '../data/models/city.dart';
import 'cities_controller.dart';
import 'providers.dart';
import 'settings_controller.dart';

enum LocationStatus { idle, locating, found, failed }

class LocationState {
  const LocationState({
    this.status = LocationStatus.idle,
    this.city,
    this.error,
  });

  final LocationStatus status;
  final City? city;
  final AppFailure? error;

  bool get isLocating => status == LocationStatus.locating;
}

final locationProvider = NotifierProvider<LocationController, LocationState>(
  LocationController.new,
);

class LocationController extends Notifier<LocationState> {
  @override
  LocationState build() => const LocationState();

  /// Resolves GPS + reverse geocoding, then selects the result as a city.
  Future<void> locate() async {
    if (state.isLocating) return;
    state = const LocationState(status: LocationStatus.locating);

    try {
      final position = await ref
          .read(locationServiceProvider)
          .currentPosition();
      final language = ref.read(settingsProvider).localeCode;

      City city;
      try {
        city = await ref
            .read(geocodingApiProvider)
            .reverse(position.latitude, position.longitude, language: language);
      } on Object {
        // The forecast only needs coordinates; a missing place name is fine.
        city = City(
          id: City.currentLocationId,
          name: '',
          latitude: position.latitude,
          longitude: position.longitude,
          isCurrentLocation: true,
        );
      }

      ref.read(citiesProvider.notifier).updateCurrentLocation(city);
      state = LocationState(status: LocationStatus.found, city: city);
    } on AppFailure catch (error) {
      state = LocationState(status: LocationStatus.failed, error: error);
      rethrow;
    } on Object catch (error) {
      final failure = AppFailure(
        FailureKind.locationFailed,
        debugMessage: error.toString(),
      );
      state = LocationState(status: LocationStatus.failed, error: failure);
      throw failure;
    }
  }
}
