/**
 * Pure view-model builder: raw API payloads in, one predictable object out.
 * Cached payloads are always re-parsed through this same function.
 */
import { LIMITS } from './config.js';
import { haversine } from './domain/geo.js';
import { dewPoint, dustLevel, uvLevel, aqiLevel } from './domain/levels.js';
import { buildAlerts } from './domain/alerts.js';
import { minutesOfDay, clamp } from './format.js';
import { weatherGroup } from './domain/conditions.js';

export class DataError extends Error {
  constructor(message) {
    super(message);
    this.name = 'DataError';
  }
}

const toNumber = (value) => {
  const number = Number(value);
  return Number.isFinite(number) ? number : null;
};

function findIndexFor(times, iso) {
  let index = 0;
  for (let i = 0; i < times.length; i += 1) {
    if (String(times[i]) <= String(iso)) index = i;
    else break;
  }
  return index;
}

function makeDustMap(air) {
  const map = new Map();
  const times = air?.hourly?.time;
  if (!Array.isArray(times)) return map;
  times.forEach((time, index) => {
    map.set(time, {
      dust: toNumber(air.hourly.dust?.[index]),
      pm10: toNumber(air.hourly.pm10?.[index]),
    });
  });
  return map;
}

export function buildModel(city, bundle, units = 'metric') {
  const forecast = bundle?.forecast;
  if (!forecast || typeof forecast !== 'object') throw new DataError('missing forecast');
  if (!forecast.current || typeof forecast.current !== 'object') throw new DataError('missing current');
  if (!Array.isArray(forecast.hourly?.time) || forecast.hourly.time.length === 0) throw new DataError('missing hourly');
  if (!Array.isArray(forecast.daily?.time) || forecast.daily.time.length === 0) throw new DataError('missing daily');

  const hourIndex = findIndexFor(forecast.hourly.time, forecast.current.time);
  const dustMap = makeDustMap(bundle.air);
  const airCurrent = bundle.air?.current || {};

  const hours = [];
  const maxHours = Math.min(forecast.hourly.time.length, hourIndex + LIMITS.hourlyHours);
  for (let i = hourIndex; i < maxHours; i += 1) {
    const time = forecast.hourly.time[i];
    hours.push({
      time,
      label: String(time).slice(11, 16),
      temp: toNumber(forecast.hourly.temperature_2m?.[i]),
      code: toNumber(forecast.hourly.weather_code?.[i]) ?? 0,
      precipProb: toNumber(forecast.hourly.precipitation_probability?.[i]),
      precip: toNumber(forecast.hourly.precipitation?.[i]),
      wind: toNumber(forecast.hourly.wind_speed_10m?.[i]),
      visibility: toNumber(forecast.hourly.visibility?.[i]),
      isDay: forecast.hourly.is_day?.[i] == null ? true : Number(forecast.hourly.is_day[i]) === 1,
      dust: dustMap.get(time)?.dust ?? null,
    });
  }

  const daily = forecast.daily.time.slice(0, LIMITS.forecastDays).map((date, index) => ({
    date,
    code: toNumber(forecast.daily.weather_code?.[index]) ?? 0,
    max: toNumber(forecast.daily.temperature_2m_max?.[index]),
    min: toNumber(forecast.daily.temperature_2m_min?.[index]),
    sunrise: forecast.daily.sunrise?.[index] || null,
    sunset: forecast.daily.sunset?.[index] || null,
    uvMax: toNumber(forecast.daily.uv_index_max?.[index]),
    precipSum: toNumber(forecast.daily.precipitation_sum?.[index]),
    precipProb: toNumber(forecast.daily.precipitation_probability_max?.[index]),
    windMax: toNumber(forecast.daily.wind_speed_10m_max?.[index]),
  }));

  const currentRaw = forecast.current;
  const humidity = toNumber(currentRaw.relative_humidity_2m);
  const temperature = toNumber(currentRaw.temperature_2m);
  const uv = toNumber(airCurrent.uv_index) ?? daily[0]?.uvMax ?? null;
  const dust = toNumber(airCurrent.dust);
  const pm10 = toNumber(airCurrent.pm10);
  const pm25 = toNumber(airCurrent.pm2_5);
  const aqi = toNumber(airCurrent.us_aqi);
  const visibilityMeters = hours[0]?.visibility ?? null;

  const current = {
    time: currentRaw.time,
    temp: temperature,
    feels: toNumber(currentRaw.apparent_temperature),
    humidity,
    dewPoint: dewPoint(temperature, humidity),
    code: toNumber(currentRaw.weather_code) ?? 0,
    isDay: Number(currentRaw.is_day) === 1,
    precip: toNumber(currentRaw.precipitation),
    rain: toNumber(currentRaw.rain),
    showers: toNumber(currentRaw.showers),
    snowfall: toNumber(currentRaw.snowfall),
    cloud: toNumber(currentRaw.cloud_cover),
    pressure: toNumber(currentRaw.pressure_msl),
    windSpeed: toNumber(currentRaw.wind_speed_10m),
    windDir: toNumber(currentRaw.wind_direction_10m),
    gust: toNumber(currentRaw.wind_gusts_10m),
    visibilityKm: visibilityMeters == null ? null : visibilityMeters / 1000,
    uv,
    uvLevel: uvLevel(uv),
    dust,
    dustLevel: dustLevel(dust),
    pm10,
    pm25,
    aqi,
    aqiLevel: aqiLevel(aqi),
    group: weatherGroup(currentRaw.weather_code),
  };

  const count24 = Math.min(24, hours.length);
  const total24 = hours.slice(0, count24).reduce((sum, hour) => sum + (hour.precip ?? 0), 0);
  const next6mm = hours.slice(0, 6).reduce((sum, hour) => sum + (hour.precip ?? 0), 0);
  const wetHours = hours.slice(0, 12).filter((hour) => (hour.precipProb ?? 0) >= 30 || (hour.precip ?? 0) > 0.1);
  const rain = {
    total24mm: total24,
    next6mm,
    probNow: hours[0]?.precipProb ?? daily[0]?.precipProb ?? null,
    wetHours,
  };

  const today = daily[0];
  const nowMinutes = minutesOfDay(currentRaw.time);
  const riseMinutes = today?.sunrise ? minutesOfDay(today.sunrise) : null;
  const setMinutes = today?.sunset ? minutesOfDay(today.sunset) : null;
  let progress = 0;
  let sunState = 'down';
  if (riseMinutes != null && setMinutes != null && setMinutes > riseMinutes) {
    if (nowMinutes < riseMinutes) {
      progress = 0;
      sunState = 'before';
    } else if (nowMinutes > setMinutes) {
      progress = 1;
      sunState = 'after';
    } else {
      progress = clamp((nowMinutes - riseMinutes) / (setMinutes - riseMinutes), 0, 1);
      sunState = 'up';
    }
  }
  const sun = {
    sunrise: today?.sunrise || null,
    sunset: today?.sunset || null,
    riseMinutes,
    setMinutes,
    nowMinutes,
    progress,
    state: sunState,
    dayLengthMinutes: riseMinutes != null && setMinutes != null ? Math.max(0, setMinutes - riseMinutes) : null,
  };

  const storms = Array.isArray(bundle.storms)
    ? bundle.storms
      .map((storm) => {
        const distanceKm = haversine(city.latitude, city.longitude, storm.latitude, storm.longitude);
        const windKmh = toNumber(storm.windKmh);
        return {
          ...storm,
          windKmh,
          distanceKm,
          level: windKmh == null ? 'info' : windKmh >= 118 ? 'severe' : windKmh >= 63 ? 'warning' : 'info',
        };
      })
      .sort((a, b) => a.distanceKm - b.distanceKm)
      .slice(0, LIMITS.storms)
    : [];

  const dustSeries = hours.map((hour) => hour.dust).filter((value) => value != null);
  const dustSeriesFallback = hours.map((hour) => dustMap.get(hour.time)?.pm10 ?? null).filter((value) => value != null);

  const model = {
    city,
    timezone: forecast.timezone || city.timezone || 'UTC',
    timezoneLabel: forecast.timezone_abbreviation || null,
    utcOffsetSeconds: toNumber(forecast.utc_offset_seconds) ?? 0,
    latitude: toNumber(forecast.latitude) ?? city.latitude,
    longitude: toNumber(forecast.longitude) ?? city.longitude,
    fetchedAt: bundle.fetchedAt,
    current,
    hourly: hours,
    daily,
    rain,
    sun,
    storms,
    stormsStatus: bundle.stormsUnavailable === true ? 'unavailable' : 'ok',
    dustSeries: dustSeries.length > 1 ? dustSeries : dustSeriesFallback,
    stale: Boolean(bundle.stale),
  };

  model.alerts = buildAlerts(model, units);
  return model;
}
