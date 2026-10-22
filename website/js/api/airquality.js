/** Open-Meteo air quality & dust (no key, CORS enabled). */
import { API } from '../config.js';
import { getJSON, buildUrl } from './http.js';

export async function fetchAirQuality({ latitude, longitude }, { signal } = {}) {
  const url = buildUrl(API.airQuality, {
    latitude,
    longitude,
    timezone: 'auto',
    current: 'dust,pm10,pm2_5,us_aqi,european_aqi,uv_index',
    hourly: 'dust,pm10,pm2_5',
    forecast_days: 2,
  });
  return getJSON(url, { signal });
}
