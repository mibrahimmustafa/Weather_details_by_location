/// Measurement system chosen by the user. All data is stored in metric units
/// and converted only at the presentation boundary.
enum UnitSystem { metric, imperial }

abstract final class Units {
  static double temperature(double celsius, UnitSystem system) =>
      system == UnitSystem.imperial ? celsius * 9 / 5 + 32 : celsius;

  static double wind(double kmh, UnitSystem system) =>
      system == UnitSystem.imperial ? kmh * 0.621371 : kmh;

  static double distance(double km, UnitSystem system) =>
      system == UnitSystem.imperial ? km * 0.621371 : km;

  static double precipitation(double mm, UnitSystem system) =>
      system == UnitSystem.imperial ? mm * 0.0393701 : mm;

  static String code(UnitSystem system) =>
      system == UnitSystem.imperial ? 'imperial' : 'metric';

  static UnitSystem fromCode(String? code) =>
      code == 'imperial' ? UnitSystem.imperial : UnitSystem.metric;
}
