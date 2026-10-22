/**
 * Environmental thresholds (dust, UV, AQI) and derived quantities.
 * Thresholds follow the original Ajwaa spec so the app stays comparable.
 */
export function dewPoint(temperatureC, relativeHumidity) {
  const t = Number(temperatureC);
  const rh = Number(relativeHumidity);
  if (!Number.isFinite(t) || !Number.isFinite(rh) || rh <= 0) return null;
  const a = 17.62;
  const b = 243.12;
  const gamma = Math.log(rh / 100) + (a * t) / (b + t);
  const dew = (b * gamma) / (a - gamma);
  return Number.isFinite(dew) ? dew : null;
}

export function dustLevel(value) {
  const v = Number(value);
  if (!Number.isFinite(v)) return null;
  if (v < 20) return 'low';
  if (v < 50) return 'medium';
  if (v < 100) return 'high';
  return 'veryHigh';
}

export function uvLevel(value) {
  const v = Number(value);
  if (!Number.isFinite(v)) return null;
  if (v < 3) return 'low';
  if (v < 6) return 'moderate';
  if (v < 8) return 'high';
  if (v < 11) return 'veryHigh';
  return 'extreme';
}

export function aqiLevel(value) {
  const v = Number(value);
  if (!Number.isFinite(v)) return null;
  if (v <= 50) return 'good';
  if (v <= 100) return 'moderate';
  if (v <= 150) return 'unhealthySensitive';
  if (v <= 200) return 'unhealthy';
  if (v <= 300) return 'veryUnhealthy';
  return 'hazardous';
}

export function dustAdvice(level) {
  return level ? `dust.advice.${level}` : 'dust.noData';
}

export function aqiAdvice(level) {
  return level ? `aqi.advice.${level}` : null;
}

export const SEVERITY_RANK = Object.freeze({ severe: 2, warning: 1, info: 0 });
