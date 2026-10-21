/// Classifications shared by the details grid, charts and alerts.
enum DustLevel { low, moderate, high, veryHigh }

enum UvLevel { low, moderate, high, veryHigh, extreme }

enum AqiLevel {
  good,
  moderate,
  unhealthySensitive,
  unhealthy,
  veryUnhealthy,
  hazardous,
}

DustLevel dustLevelFor(double microgramsPerCubicMetre) {
  if (microgramsPerCubicMetre < 20) return DustLevel.low;
  if (microgramsPerCubicMetre < 50) return DustLevel.moderate;
  if (microgramsPerCubicMetre < 100) return DustLevel.high;
  return DustLevel.veryHigh;
}

UvLevel uvLevelFor(double index) {
  if (index < 3) return UvLevel.low;
  if (index < 6) return UvLevel.moderate;
  if (index < 8) return UvLevel.high;
  if (index < 11) return UvLevel.veryHigh;
  return UvLevel.extreme;
}

AqiLevel aqiLevelFor(int usAqi) {
  if (usAqi <= 50) return AqiLevel.good;
  if (usAqi <= 100) return AqiLevel.moderate;
  if (usAqi <= 150) return AqiLevel.unhealthySensitive;
  if (usAqi <= 200) return AqiLevel.unhealthy;
  if (usAqi <= 300) return AqiLevel.veryUnhealthy;
  return AqiLevel.hazardous;
}
