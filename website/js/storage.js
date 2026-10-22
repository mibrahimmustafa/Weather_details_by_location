/**
 * localStorage wrapper. Every read is defensive: a corrupted value must never
 * break the app, it simply falls back to defaults.
 */
import { STORAGE_KEYS, CACHE, LIMITS, DEFAULT_CITY, LOCALES, THEMES, UNIT_SYSTEMS } from './config.js';

export function safeRead(key) {
  try {
    const raw = window.localStorage.getItem(key);
    if (raw == null) return null;
    return JSON.parse(raw);
  } catch {
    return null;
  }
}

export function safeWrite(key, value) {
  try {
    window.localStorage.setItem(key, JSON.stringify(value));
    return true;
  } catch {
    return false;
  }
}

export function safeRemove(key) {
  try {
    window.localStorage.removeItem(key);
  } catch {
    /* best effort */
  }
}

export function storageAvailable() {
  try {
    const probe = '__ajwaa_probe__';
    window.localStorage.setItem(probe, '1');
    window.localStorage.removeItem(probe);
    return true;
  } catch {
    return false;
  }
}

/* -------------------------------- settings -------------------------------- */

export function defaultSettings() {
  const browserLocale = typeof navigator !== 'undefined' && /^ar\b/i.test(navigator.language || '') ? 'ar' : 'en';
  return {
    localeCode: browserLocale,
    unitSystem: 'metric',
    themeMode: 'system',
    hasSeenWelcome: false,
  };
}

export function readSettings() {
  const fallback = defaultSettings();
  const raw = safeRead(STORAGE_KEYS.settings);
  if (!raw || typeof raw !== 'object') return fallback;
  return {
    localeCode: LOCALES[raw.localeCode] ? raw.localeCode : fallback.localeCode,
    unitSystem: UNIT_SYSTEMS.includes(raw.unitSystem) ? raw.unitSystem : fallback.unitSystem,
    themeMode: THEMES.includes(raw.themeMode) ? raw.themeMode : fallback.themeMode,
    hasSeenWelcome: raw.hasSeenWelcome === true,
  };
}

export function writeSettings(settings) {
  return safeWrite(STORAGE_KEYS.settings, settings);
}

/* --------------------------------- cities --------------------------------- */

function isValidCity(city) {
  return Boolean(
    city
    && typeof city.id === 'string'
    && city.id.length > 0
    && typeof city.name === 'string'
    && Number.isFinite(Number(city.latitude))
    && Number.isFinite(Number(city.longitude))
    && Math.abs(Number(city.latitude)) <= 90
    && Math.abs(Number(city.longitude)) <= 180,
  );
}

export function sanitizeCity(city) {
  if (!isValidCity(city)) return null;
  return {
    id: String(city.id),
    name: String(city.name),
    nameEn: typeof city.nameEn === 'string' && city.nameEn ? city.nameEn : String(city.name),
    country: typeof city.country === 'string' ? city.country : '',
    countryEn: typeof city.countryEn === 'string' ? city.countryEn : (typeof city.country === 'string' ? city.country : ''),
    countryCode: typeof city.countryCode === 'string' ? city.countryCode.toUpperCase() : '',
    admin1: typeof city.admin1 === 'string' ? city.admin1 : '',
    latitude: Number(city.latitude),
    longitude: Number(city.longitude),
    timezone: typeof city.timezone === 'string' ? city.timezone : '',
    source: typeof city.source === 'string' ? city.source : 'search',
  };
}

export function readCities() {
  const raw = safeRead(STORAGE_KEYS.cities);
  const selected = safeRead(STORAGE_KEYS.selectedCity);
  const cities = Array.isArray(raw?.cities)
    ? raw.cities.map(sanitizeCity).filter(Boolean).slice(0, LIMITS.savedCities)
    : [];
  const selectedId = typeof selected === 'string' && cities.some((city) => city.id === selected)
    ? selected
    : (typeof raw?.selectedId === 'string' && cities.some((city) => city.id === raw.selectedId) ? raw.selectedId : null);
  return { cities, selectedId };
}

export function writeCities(cities, selectedId) {
  safeWrite(STORAGE_KEYS.cities, { cities: cities.slice(0, LIMITS.savedCities), selectedId: selectedId || null });
  if (selectedId) safeWrite(STORAGE_KEYS.selectedCity, selectedId);
}

export function ensureDefaultCity(cities) {
  if (cities.length > 0) return cities;
  return [{ ...DEFAULT_CITY }];
}

/* ------------------------------- onboarding ------------------------------- */

export function readOnboardingSeen() {
  const value = safeRead(STORAGE_KEYS.onboarding);
  return value === true;
}

export function writeOnboardingSeen() {
  safeWrite(STORAGE_KEYS.onboarding, true);
}

/* ---------------------------------- cache --------------------------------- */

export function cacheKey(cityId) {
  return `${STORAGE_KEYS.weatherPrefix}${cityId}`;
}

export function readCache(cityId) {
  const raw = safeRead(cacheKey(cityId));
  if (!raw || typeof raw !== 'object') return null;
  if (!raw.forecast || typeof raw.forecast !== 'object') return null;
  if (!Number.isFinite(Number(raw.fetchedAt))) return null;
  return {
    fetchedAt: Number(raw.fetchedAt),
    latitude: Number(raw.latitude),
    longitude: Number(raw.longitude),
    forecast: raw.forecast,
    air: raw.air && typeof raw.air === 'object' ? raw.air : null,
    storms: Array.isArray(raw.storms) ? raw.storms : null,
    stormsUnavailable: raw.stormsUnavailable === true,
  };
}

export function writeCache(cityId, bundle) {
  const payload = {
    fetchedAt: bundle.fetchedAt,
    latitude: bundle.latitude,
    longitude: bundle.longitude,
    forecast: bundle.forecast,
    air: bundle.air ?? null,
    storms: bundle.storms ?? null,
    stormsUnavailable: bundle.stormsUnavailable === true,
  };
  const ok = safeWrite(cacheKey(cityId), payload);
  pruneCaches();
  return ok;
}

export function pruneCaches(max = CACHE.maxCities) {
  try {
    const entries = [];
    for (let i = 0; i < window.localStorage.length; i += 1) {
      const key = window.localStorage.key(i);
      if (!key || !key.startsWith(STORAGE_KEYS.weatherPrefix)) continue;
      const parsed = safeRead(key);
      entries.push({ key, fetchedAt: Number(parsed?.fetchedAt) || 0 });
    }
    entries.sort((a, b) => b.fetchedAt - a.fetchedAt);
    entries.slice(max).forEach((entry) => safeRemove(entry.key));
  } catch {
    /* best effort */
  }
}

export function isCacheFresh(cache, city, now = Date.now()) {
  if (!cache) return false;
  if (!Number.isFinite(cache.fetchedAt)) return false;
  if (now - cache.fetchedAt > CACHE.ttlMs) return false;
  const movedLat = Math.abs(Number(cache.latitude) - Number(city.latitude));
  const movedLon = Math.abs(Number(cache.longitude) - Number(city.longitude));
  // Coarse guard: ~0.045° latitude is 5 km. Longitude shrinks with latitude.
  const latKm = movedLat * 111;
  const lonKm = movedLon * 111 * Math.cos((Number(city.latitude) * Math.PI) / 180);
  return Math.hypot(latKm, lonKm) <= CACHE.movementKm;
}

export function resetPreferences() {
  safeRemove(STORAGE_KEYS.settings);
  safeRemove(STORAGE_KEYS.onboarding);
}
