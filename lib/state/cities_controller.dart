import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/suggested_cities.dart';
import '../core/utils/json_read.dart';
import '../data/models/city.dart';
import '../data/repositories/cities_store.dart';
import '../domain/geo.dart';
import 'providers.dart';
import 'settings_controller.dart';

class CitiesState {
  const CitiesState({required this.cities, required this.selectedId});

  final List<City> cities;
  final String? selectedId;

  City? get selected =>
      firstWhereOrNull(cities, (city) => city.id == selectedId) ??
      (cities.isEmpty ? null : cities.first);

  bool get canRemove => cities.length > 1;

  CitiesState copyWith({List<City>? cities, String? selectedId}) => CitiesState(
    cities: cities ?? this.cities,
    selectedId: selectedId ?? this.selectedId,
  );
}

final citiesProvider = NotifierProvider<CitiesController, CitiesState>(
  CitiesController.new,
);

final selectedCityProvider = Provider<City?>(
  (ref) => ref.watch(citiesProvider).selected,
);

class CitiesController extends Notifier<CitiesState> {
  @override
  CitiesState build() {
    final stored = ref.watch(citiesStoreProvider).read();
    if (stored != null) {
      return CitiesState(
        cities: List.unmodifiable(stored.cities),
        selectedId: stored.selectedId,
      );
    }
    final language = ref.read(settingsProvider).localeCode;
    final seed = defaultCityFor(language);
    return CitiesState(cities: [seed], selectedId: seed.id);
  }

  /// Adds a city and selects it. Returns `false` when it already existed.
  bool add(City city) {
    final existing = _findSimilar(city);
    if (existing != null) {
      select(existing.id);
      return false;
    }
    final cities = [...state.cities, city];
    state = CitiesState(cities: List.unmodifiable(cities), selectedId: city.id);
    _persist();
    return true;
  }

  void select(String cityId) {
    if (state.selectedId == cityId) return;
    if (!state.cities.any((city) => city.id == cityId)) return;
    state = state.copyWith(selectedId: cityId);
    _persist();
  }

  bool remove(String cityId) {
    if (state.cities.length <= 1) return false;
    final cities = state.cities.where((city) => city.id != cityId).toList();
    if (cities.length == state.cities.length) return false;
    final selectedId = state.selectedId == cityId
        ? cities.first.id
        : state.selectedId;
    state = CitiesState(
      cities: List.unmodifiable(cities),
      selectedId: selectedId,
    );
    _persist();
    return true;
  }

  /// Replaces (or adds) the GPS city without creating duplicates.
  void updateCurrentLocation(City city) {
    final cities = [...state.cities];
    final index = cities.indexWhere(
      (item) => item.id == City.currentLocationId,
    );
    if (index >= 0) {
      cities[index] = city;
    } else {
      cities.insert(0, city);
    }
    state = CitiesState(
      cities: List.unmodifiable(cities),
      selectedId: City.currentLocationId,
    );
    _persist();
  }

  City? _findSimilar(City candidate) {
    for (final city in state.cities) {
      if (city.id == candidate.id) return city;
      final sameName =
          city.name.trim().toLowerCase() == candidate.name.trim().toLowerCase();
      final veryClose =
          distanceKm(
            city.latitude,
            city.longitude,
            candidate.latitude,
            candidate.longitude,
          ) <
          3;
      if (veryClose || (sameName && city.country == candidate.country)) {
        return city;
      }
    }
    return null;
  }

  void _persist() {
    unawaited(
      ref
          .read(citiesStoreProvider)
          .write(
            CitiesSnapshot(cities: state.cities, selectedId: state.selectedId),
          ),
    );
  }
}
