import 'dart:math' as math;

/// Great-circle distance in kilometres between two coordinates.
double distanceKm(double lat1, double lon1, double lat2, double lon2) {
  const earthRadiusKm = 6371.0;
  final dLat = _toRadians(lat2 - lat1);
  final dLon = _toRadians(lon2 - lon1);
  final a =
      math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_toRadians(lat1)) *
          math.cos(_toRadians(lat2)) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);
  return 2 * earthRadiusKm * math.atan2(math.sqrt(a), math.sqrt(1 - a));
}

double _toRadians(double degrees) => degrees * math.pi / 180;
