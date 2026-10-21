import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_info.dart';
import '../../core/utils/json_read.dart';

class CachedWeatherPayload {
  const CachedWeatherPayload({
    required this.fetchedAt,
    required this.latitude,
    required this.longitude,
    required this.forecast,
    this.air,
    this.storms,
  });

  final DateTime fetchedAt;
  final double latitude;
  final double longitude;
  final Map<String, dynamic> forecast;
  final Map<String, dynamic>? air;
  final Map<String, dynamic>? storms;

  bool isFresh(Duration ttl, DateTime now) => now.difference(fetchedAt) < ttl;

  Map<String, dynamic> toJson() => {
    'fetchedAt': fetchedAt.millisecondsSinceEpoch,
    'latitude': latitude,
    'longitude': longitude,
    'forecast': forecast,
    'air': air,
    'storms': storms,
  };

  static CachedWeatherPayload? fromJson(Map<String, dynamic> json) {
    final forecast = readMap(json['forecast']);
    if (forecast.isEmpty) return null;
    final fetched = readIntOrNull(json['fetchedAt']);
    final latitude = readDoubleOrNull(json['latitude']);
    final longitude = readDoubleOrNull(json['longitude']);
    if (fetched == null || latitude == null || longitude == null) return null;
    return CachedWeatherPayload(
      fetchedAt: DateTime.fromMillisecondsSinceEpoch(fetched, isUtc: true),
      latitude: latitude,
      longitude: longitude,
      forecast: forecast,
      air: json['air'] is Map<String, dynamic>
          ? json['air'] as Map<String, dynamic>
          : null,
      storms: json['storms'] is Map<String, dynamic>
          ? json['storms'] as Map<String, dynamic>
          : null,
    );
  }
}

/// Offline-first storage for the raw API payloads.
///
/// Raw caching avoids a second serialization layer: parsing always goes through
/// the same tested parsers, whether data came from the network or disk.
class WeatherCache {
  WeatherCache(this._prefs);

  static const int _maxEntries = 8;

  final SharedPreferences _prefs;

  CachedWeatherPayload? read(String cityId) {
    final raw = _prefs.getString('${StorageKeys.weatherCachePrefix}$cityId');
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return CachedWeatherPayload.fromJson(decoded);
    } on FormatException {
      return null;
    }
  }

  Future<void> write(
    String cityId, {
    required CachedWeatherPayload payload,
  }) async {
    try {
      await _prefs.setString(
        '${StorageKeys.weatherCachePrefix}$cityId',
        jsonEncode(payload.toJson()),
      );
      await _prune();
    } on Object {
      // Caching is best-effort; a full disk must not break the forecast.
    }
  }

  Future<void> clear() async {
    for (final key in _prefs.getKeys().toList()) {
      if (key.startsWith(StorageKeys.weatherCachePrefix)) {
        await _prefs.remove(key);
      }
    }
  }

  Future<void> _prune() async {
    final entries = <({String key, int fetchedAt})>[];
    for (final key in _prefs.getKeys()) {
      if (!key.startsWith(StorageKeys.weatherCachePrefix)) continue;
      final raw = _prefs.getString(key);
      if (raw == null) continue;
      try {
        final decoded = jsonDecode(raw);
        final fetchedAt = decoded is Map<String, dynamic>
            ? readInt(decoded['fetchedAt'])
            : 0;
        entries.add((key: key, fetchedAt: fetchedAt));
      } on FormatException {
        continue;
      }
    }
    if (entries.length <= _maxEntries) return;
    entries.sort((a, b) => b.fetchedAt.compareTo(a.fetchedAt));
    for (final entry in entries.skip(_maxEntries)) {
      await _prefs.remove(entry.key);
    }
  }
}
