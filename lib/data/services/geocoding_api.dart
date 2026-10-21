import '../../core/constants/app_info.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/json_read.dart';
import '../models/city.dart';

/// City search and reverse geocoding.
class GeocodingApi {
  GeocodingApi(this._client);

  final ApiClient _client;

  Future<List<City>> search(String query, {required String language}) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return const [];

    final uri = Uri.parse(ApiEndpoints.geocoding).replace(
      queryParameters: {
        'name': trimmed,
        'count': '10',
        'language': language,
        'format': 'json',
      },
    );
    final json = await _client.getJson(uri);
    final results = readList(json['results']);

    final seen = <String>{};
    final cities = <City>[];
    for (final raw in results) {
      final map = readMap(raw);
      final latitude = readDoubleOrNull(map['latitude']);
      final longitude = readDoubleOrNull(map['longitude']);
      final name = readStringOrNull(map['name']);
      if (latitude == null || longitude == null || name == null) continue;

      final id = map['id'] is num
          ? 'geo_${readInt(map['id'])}'
          : 'geo_${latitude.toStringAsFixed(3)}_${longitude.toStringAsFixed(3)}';
      if (!seen.add(id)) continue;

      cities.add(
        City(
          id: id,
          name: name,
          latitude: latitude,
          longitude: longitude,
          country: readString(map['country']),
          admin1: readStringOrNull(map['admin1']),
          countryCode: readStringOrNull(map['country_code']),
          timezone: readStringOrNull(map['timezone']),
        ),
      );
    }
    return cities;
  }

  /// Reverse geocode via BigDataCloud's key-less client endpoint.
  Future<City> reverse(
    double latitude,
    double longitude, {
    required String language,
  }) async {
    final uri = Uri.parse(ApiEndpoints.reverseGeocoding).replace(
      queryParameters: {
        'latitude': latitude.toStringAsFixed(5),
        'longitude': longitude.toStringAsFixed(5),
        'localityLanguage': language,
      },
    );
    final json = await _client.getJson(uri);

    final city = readString(json['city']);
    final locality = readString(json['locality']);
    final subdivision = readString(json['principalSubdivision']);
    final name = city.isNotEmpty
        ? city
        : locality.isNotEmpty
        ? locality
        : subdivision;

    return City(
      id: City.currentLocationId,
      name: name,
      latitude: latitude,
      longitude: longitude,
      country: readString(json['countryName']),
      admin1: subdivision.isEmpty || subdivision == name ? null : subdivision,
      countryCode: readStringOrNull(json['countryCode']),
      timezone: _timezoneFrom(json),
      isCurrentLocation: true,
    );
  }

  static String? _timezoneFrom(Map<String, dynamic> json) {
    final localityInfo = readMap(json['localityInfo']);
    for (final raw in readList(localityInfo['informative'])) {
      final name = readString(readMap(raw)['name']);
      if (name.contains('/')) return name;
    }
    return null;
  }
}
