import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_info.dart';
import '../models/city.dart';

class CitiesSnapshot {
  const CitiesSnapshot({required this.cities, required this.selectedId});

  final List<City> cities;
  final String? selectedId;
}

/// Persists the user's city list and current selection as one JSON document.
class CitiesStore {
  CitiesStore(this._prefs);

  final SharedPreferences _prefs;

  CitiesSnapshot? read() {
    final String? raw;
    try {
      raw = _prefs.getString(StorageKeys.cities);
    } on Object {
      return null;
    }
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      final cities = <City>[];
      for (final item in (decoded['cities'] as List? ?? const [])) {
        if (item is Map<String, dynamic>) {
          try {
            cities.add(City.fromJson(item));
          } on Object {
            // Skip malformed entries instead of losing the whole list.
          }
        }
      }
      if (cities.isEmpty) return null;
      final selectedId = decoded['selectedId'] as String?;
      return CitiesSnapshot(
        cities: cities,
        selectedId: cities.any((city) => city.id == selectedId)
            ? selectedId
            : cities.first.id,
      );
    } on Object {
      return null;
    }
  }

  Future<void> write(CitiesSnapshot snapshot) {
    return _prefs.setString(
      StorageKeys.cities,
      jsonEncode({
        'cities': snapshot.cities.map((city) => city.toJson()).toList(),
        'selectedId': snapshot.selectedId,
      }),
    );
  }
}
