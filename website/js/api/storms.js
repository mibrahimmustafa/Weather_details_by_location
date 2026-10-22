/**
 * Active tropical systems.
 * Primary: NASA EONET (CORS-friendly). Fallback: GDACS (may be blocked by
 * CORS in some browsers, which is handled quietly by the caller).
 */
import { API } from '../config.js';
import { getJSON, buildUrl } from './http.js';

function toKmh(value, unit) {
  const speed = Number(value);
  if (!Number.isFinite(speed)) return null;
  const normalized = String(unit || '').toLowerCase();
  if (normalized.startsWith('kt') || normalized === 'knots' || normalized === 'kts') return speed * 1.852;
  if (normalized.startsWith('mph')) return speed * 1.609344;
  if (normalized.startsWith('m/s')) return speed * 3.6;
  return speed;
}

function parseEonet(data) {
  const events = Array.isArray(data?.events) ? data.events : [];
  return events
    .map((event) => {
      const geometry = Array.isArray(event?.geometry) ? event.geometry : [];
      const latestPoint = [...geometry].reverse().find(
        (point) => point && point.type === 'Point' && Array.isArray(point.coordinates) && point.coordinates.length >= 2,
      );
      if (!latestPoint) return null;
      const [longitude, latitude] = latestPoint.coordinates.map(Number);
      if (!Number.isFinite(latitude) || !Number.isFinite(longitude)) return null;
      return {
        id: String(event.id || event.title || `${latitude},${longitude}`),
        name: String(event.title || 'Tropical system').trim(),
        latitude,
        longitude,
        windKmh: toKmh(latestPoint.magnitudeValue, latestPoint.magnitudeUnit),
        date: latestPoint.date || '',
        url: event.sources?.[0]?.url || event.link || '',
        source: 'NASA EONET',
      };
    })
    .filter(Boolean);
}

function parseGdacs(data) {
  const features = Array.isArray(data?.features) ? data.features : [];
  return features
    .map((feature) => {
      const props = feature?.properties || {};
      if (props.eventtype && props.eventtype !== 'TC') return null;
      if (props.iscurrent === 'false') return null;
      const coordinates = feature?.geometry?.coordinates;
      if (!Array.isArray(coordinates) || coordinates.length < 2) return null;
      const [longitude, latitude] = coordinates.map(Number);
      if (!Number.isFinite(latitude) || !Number.isFinite(longitude)) return null;
      return {
        id: `gdacs-${props.eventid || props.episodeid || feature.id || latitude}`,
        name: String(props.name || props.eventname || 'Tropical cyclone').trim(),
        latitude,
        longitude,
        windKmh: toKmh(props.severitydata?.severity, props.severitydata?.severityunit),
        date: props.todate || props.fromdate || props.datemodified || '',
        url: props.url?.report || props.url?.details || '',
        source: 'GDACS',
      };
    })
    .filter(Boolean);
}

export async function fetchStorms({ signal } = {}) {
  let primaryError = null;
  try {
    const url = buildUrl(API.eonet, { category: 'severeStorms', status: 'open', days: 60 });
    const data = await getJSON(url, { signal, timeout: 15_000 });
    return parseEonet(data);
  } catch (error) {
    if (error?.name === 'AbortError') throw error;
    primaryError = error;
  }

  try {
    const url = buildUrl(API.gdacs, { eventlist: 'TC', output: 'json' });
    const data = await getJSON(url, { signal, timeout: 12_000, retries: 1 });
    return parseGdacs(data);
  } catch (error) {
    if (error?.name === 'AbortError') throw error;
    throw primaryError || error;
  }
}
