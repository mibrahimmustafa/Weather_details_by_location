/**
 * Open-Meteo geocoding (search) and BigDataCloud reverse geocoding.
 * Both are free and key-less; results are normalized into the app's City shape.
 */
import { API } from '../config.js';
import { getJSON, buildUrl } from './http.js';

const TIMEZONE_FALLBACK = (() => {
  try {
    return Intl.DateTimeFormat().resolvedOptions().timeZone || 'UTC';
  } catch {
    return 'UTC';
  }
})();

function normalizeResult(result, language) {
  if (!result || typeof result !== 'object') return null;
  const latitude = Number(result.latitude);
  const longitude = Number(result.longitude);
  if (!Number.isFinite(latitude) || !Number.isFinite(longitude)) return null;
  const name = String(result.name || '').trim();
  if (!name) return null;
  return {
    id: `geo-${result.id ?? `${latitude.toFixed(3)}-${longitude.toFixed(3)}`}`,
    name,
    nameEn: language === 'en' ? name : name,
    country: String(result.country || ''),
    countryEn: String(result.country || ''),
    countryCode: String(result.country_code || '').toUpperCase(),
    admin1: String(result.admin1 || ''),
    latitude,
    longitude,
    timezone: result.timezone || TIMEZONE_FALLBACK,
    source: 'search',
  };
}

export async function searchCities(query, language = 'en', { signal } = {}) {
  const trimmed = String(query || '').trim();
  if (trimmed.length < 2) return [];
  const url = buildUrl(API.geocoding, {
    name: trimmed,
    count: 10,
    language: language === 'ar' ? 'ar' : 'en',
    format: 'json',
  });
  const data = await getJSON(url, { signal });
  const results = Array.isArray(data?.results) ? data.results : [];
  const seen = new Set();
  return results
    .map((result) => normalizeResult(result, language))
    .filter((city) => {
      if (!city) return false;
      const key = `${city.latitude.toFixed(2)}:${city.longitude.toFixed(2)}`;
      if (seen.has(key)) return false;
      seen.add(key);
      return true;
    });
}

export async function reverseGeocode(latitude, longitude, language = 'en', { signal } = {}) {
  const url = buildUrl(API.reverseGeocoding, {
    latitude,
    longitude,
    localityLanguage: language === 'ar' ? 'ar' : 'en',
  });
  let data;
  try {
    data = await getJSON(url, { signal, timeout: 12_000, retries: 1 });
  } catch {
    return null;
  }
  if (!data || typeof data !== 'object') return null;
  const name = String(
    data.city
    || data.locality
    || data.principalSubdivision
    || data.localityInfo?.administrative?.[0]?.name
    || '',
  ).trim();
  return {
    name: name || '',
    country: String(data.countryName || ''),
    countryCode: String(data.countryCode || '').toUpperCase(),
    admin1: String(data.principalSubdivision || ''),
  };
}

export { TIMEZONE_FALLBACK };
