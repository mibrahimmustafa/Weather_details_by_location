/**
 * Ajwaa — application configuration.
 * Every value here is public by design: the app ships without API keys.
 */

export const APP = Object.freeze({
  name: 'Ajwaa',
  nameAr: 'أجواء',
  taglineAr: 'الطقس والوقت، أينما كنت',
  taglineEn: 'Weather & time, wherever you are',
  version: '1.0.0',
  author: 'Mohamed Ibrahim Mustafa',
  repository: 'https://github.com/mibrahimmustafa/Weather_details_by_location',
});

export const API = Object.freeze({
  forecast: 'https://api.open-meteo.com/v1/forecast',
  airQuality: 'https://air-quality-api.open-meteo.com/v1/air-quality',
  geocoding: 'https://geocoding-api.open-meteo.com/v1/search',
  reverseGeocoding: 'https://api.bigdatacloud.net/data/reverse-geocode-client',
  eonet: 'https://eonet.gsfc.nasa.gov/api/v3/events',
  gdacs: 'https://www.gdacs.org/gdacsapi/api/events/geteventlist/SEARCH',
});

export const STORAGE_KEYS = Object.freeze({
  settings: 'ajwaa.settings.v1',
  cities: 'ajwaa.cities.v1',
  selectedCity: 'ajwaa.selectedCity.v1',
  onboarding: 'ajwaa.onboardingSeen.v1',
  weatherPrefix: 'ajwaa.weather.v1.',
});

export const CACHE = Object.freeze({
  ttlMs: 10 * 60 * 1000,
  maxCities: 8,
  movementKm: 5,
  autoRefreshMs: 10 * 60 * 1000,
});

export const NET = Object.freeze({
  timeoutMs: 18_000,
  retries: 2,
  retryDelayMs: 350,
});

export const LIMITS = Object.freeze({
  savedCities: 24,
  forecastDays: 7,
  hourlyHours: 24,
  storms: 4,
  searchResults: 10,
});

export const DEFAULT_CITY = Object.freeze({
  id: 'cairo',
  name: 'القاهرة',
  nameEn: 'Cairo',
  country: 'مصر',
  countryEn: 'Egypt',
  countryCode: 'EG',
  latitude: 30.0444,
  longitude: 31.2357,
  timezone: 'Africa/Cairo',
  source: 'default',
});

export const POPULAR_CITIES = Object.freeze([
  { id: 'riyadh', name: 'الرياض', nameEn: 'Riyadh', country: 'السعودية', countryEn: 'Saudi Arabia', countryCode: 'SA', latitude: 24.7136, longitude: 46.6753, timezone: 'Asia/Riyadh' },
  { id: 'dubai', name: 'دبي', nameEn: 'Dubai', country: 'الإمارات', countryEn: 'United Arab Emirates', countryCode: 'AE', latitude: 25.2048, longitude: 55.2708, timezone: 'Asia/Dubai' },
  { id: 'doha', name: 'الدوحة', nameEn: 'Doha', country: 'قطر', countryEn: 'Qatar', countryCode: 'QA', latitude: 25.2854, longitude: 51.531, timezone: 'Asia/Qatar' },
  { id: 'kuwait', name: 'الكويت', nameEn: 'Kuwait City', country: 'الكويت', countryEn: 'Kuwait', countryCode: 'KW', latitude: 29.3759, longitude: 47.9774, timezone: 'Asia/Kuwait' },
  { id: 'amman', name: 'عمّان', nameEn: 'Amman', country: 'الأردن', countryEn: 'Jordan', countryCode: 'JO', latitude: 31.9539, longitude: 35.9106, timezone: 'Asia/Amman' },
  { id: 'casablanca', name: 'الدار البيضاء', nameEn: 'Casablanca', country: 'المغرب', countryEn: 'Morocco', countryCode: 'MA', latitude: 33.5731, longitude: -7.5898, timezone: 'Africa/Casablanca' },
  { id: 'istanbul', name: 'إسطنبول', nameEn: 'Istanbul', country: 'تركيا', countryEn: 'Türkiye', countryCode: 'TR', latitude: 41.0082, longitude: 28.9784, timezone: 'Europe/Istanbul' },
  { id: 'london', name: 'لندن', nameEn: 'London', country: 'المملكة المتحدة', countryEn: 'United Kingdom', countryCode: 'GB', latitude: 51.5074, longitude: -0.1278, timezone: 'Europe/London' },
  { id: 'paris', name: 'باريس', nameEn: 'Paris', country: 'فرنسا', countryEn: 'France', countryCode: 'FR', latitude: 48.8566, longitude: 2.3522, timezone: 'Europe/Paris' },
  { id: 'new-york', name: 'نيويورك', nameEn: 'New York', country: 'الولايات المتحدة', countryEn: 'United States', countryCode: 'US', latitude: 40.7128, longitude: -74.006, timezone: 'America/New_York' },
  { id: 'tokyo', name: 'طوكيو', nameEn: 'Tokyo', country: 'اليابان', countryEn: 'Japan', countryCode: 'JP', latitude: 35.6762, longitude: 139.6503, timezone: 'Asia/Tokyo' },
  { id: 'sydney', name: 'سيدني', nameEn: 'Sydney', country: 'أستراليا', countryEn: 'Australia', countryCode: 'AU', latitude: -33.8688, longitude: 151.2093, timezone: 'Australia/Sydney' },
].map((city) => Object.freeze(city)));

export const LOCALES = Object.freeze({
  ar: { code: 'ar', intl: 'ar-EG-u-nu-latn', dir: 'rtl', label: 'العربية', short: 'AR' },
  en: { code: 'en', intl: 'en-GB', dir: 'ltr', label: 'English', short: 'EN' },
});

export const THEMES = Object.freeze(['system', 'light', 'dark']);
export const UNIT_SYSTEMS = Object.freeze(['metric', 'imperial']);
