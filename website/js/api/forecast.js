/** Open-Meteo forecast (no key, CORS enabled). */
import { API } from '../config.js';
import { getJSON, buildUrl, ApiError } from './http.js';

const CURRENT = [
  'temperature_2m',
  'relative_humidity_2m',
  'apparent_temperature',
  'is_day',
  'precipitation',
  'rain',
  'showers',
  'snowfall',
  'weather_code',
  'cloud_cover',
  'pressure_msl',
  'wind_speed_10m',
  'wind_direction_10m',
  'wind_gusts_10m',
].join(',');

const HOURLY = [
  'temperature_2m',
  'precipitation_probability',
  'precipitation',
  'weather_code',
  'wind_speed_10m',
  'visibility',
  'is_day',
].join(',');

const DAILY = [
  'weather_code',
  'temperature_2m_max',
  'temperature_2m_min',
  'sunrise',
  'sunset',
  'uv_index_max',
  'precipitation_sum',
  'precipitation_probability_max',
  'wind_speed_10m_max',
].join(',');

export async function fetchForecast({ latitude, longitude }, { signal } = {}) {
  const url = buildUrl(API.forecast, {
    latitude,
    longitude,
    timezone: 'auto',
    current: CURRENT,
    hourly: HOURLY,
    daily: DAILY,
    forecast_days: 7,
    temperature_unit: 'celsius',
    wind_speed_unit: 'kmh',
    precipitation_unit: 'mm',
  });
  const data = await getJSON(url, { signal });
  if (!data || !data.current || !Array.isArray(data.hourly?.time) || !Array.isArray(data.daily?.time)) {
    throw new ApiError('data', 'Forecast payload is missing required fields', { url });
  }
  return data;
}
