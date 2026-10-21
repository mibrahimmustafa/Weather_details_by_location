import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../../core/errors/app_failure.dart';

/// GPS / browser geolocation with typed, user-safe failures.
class LocationService {
  Future<({double latitude, double longitude})> currentPosition() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        throw const AppFailure(FailureKind.locationServiceDisabled);
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        throw const AppFailure(FailureKind.locationDeniedForever);
      }
      if (permission == LocationPermission.denied) {
        throw const AppFailure(FailureKind.locationDenied);
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 22),
        ),
      );
      return (latitude: position.latitude, longitude: position.longitude);
    } on AppFailure {
      rethrow;
    } on TimeoutException {
      throw const AppFailure(FailureKind.locationTimeout);
    } on LocationServiceDisabledException {
      throw const AppFailure(FailureKind.locationServiceDisabled);
    } on PermissionDeniedException {
      throw const AppFailure(FailureKind.locationDenied);
    } on Object catch (error) {
      throw AppFailure(
        FailureKind.locationFailed,
        debugMessage: error.toString(),
      );
    }
  }

  Future<bool> openSettings() => Geolocator.openAppSettings();
}
