/**
 * Network orchestration for one city. Forecast is required; air quality and
 * storms are optional and degrade individually.
 */
import { fetchForecast } from './api/forecast.js';
import { fetchAirQuality } from './api/airquality.js';
import { fetchStorms } from './api/storms.js';

export async function fetchBundle(city, { signal } = {}) {
  const [forecastResult, airResult, stormsResult] = await Promise.allSettled([
    fetchForecast(city, { signal }),
    fetchAirQuality(city, { signal }),
    fetchStorms({ signal }),
  ]);

  if (forecastResult.status === 'rejected') throw forecastResult.reason;

  return {
    fetchedAt: Date.now(),
    latitude: city.latitude,
    longitude: city.longitude,
    forecast: forecastResult.value,
    air: airResult.status === 'fulfilled' ? airResult.value : null,
    storms: stormsResult.status === 'fulfilled' ? stormsResult.value : null,
    stormsUnavailable: stormsResult.status === 'rejected',
  };
}
