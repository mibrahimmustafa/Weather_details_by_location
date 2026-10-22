/**
 * Rules engine. Turns the current snapshot into actionable, severity-ordered
 * alerts. Copy lives in i18n; this module only decides *what* matters.
 */
import { num, tempValue, formatDistance, windValue, windUnit, precipValue, precipUnit } from '../format.js';
import { t } from '../i18n.js';

const TYPE_ORDER = ['heat', 'cold', 'wind', 'rain', 'dust', 'uv', 'thunder', 'cyclone'];

function tempWithUnit(celsius, units) {
  if (celsius == null || Number.isNaN(Number(celsius))) return '—';
  return `${num(tempValue(celsius, units), 0)}°${units === 'imperial' ? 'F' : 'C'}`;
}

function make(type, severity, params = {}) {
  return {
    id: `${type}-${severity}`,
    type,
    severity,
    icon: type,
    titleKey: `alert.${type}.${severity}`,
    bodyKey: `alert.${type}.advice${severity === 'severe' ? 'Severe' : 'Warning'}`,
    params,
  };
}

export function buildAlerts(model, units = 'metric') {
  const alerts = [];
  if (!model || !model.current) return alerts;
  const c = model.current;

  if (Number.isFinite(Number(c.feels))) {
    const feels = Number(c.feels);
    if (feels >= 43) alerts.push(make('heat', 'severe', { value: tempWithUnit(feels, units) }));
    else if (feels >= 38) alerts.push(make('heat', 'warning', { value: tempWithUnit(feels, units) }));
    if (feels <= -10) alerts.push(make('cold', 'severe', { value: tempWithUnit(feels, units) }));
    else if (feels <= 0) alerts.push(make('cold', 'warning', { value: tempWithUnit(feels, units) }));
  }

  const maxWind = Math.max(Number(c.windSpeed) || 0, Number(c.gust) || 0);
  const windText = `${num(windValue(maxWind, units))} ${windUnit(units)}`;
  if (maxWind >= 70) alerts.push(make('wind', 'severe', { value: windText }));
  else if (maxWind >= 40) alerts.push(make('wind', 'warning', { value: windText }));

  const rainNow = Number(c.precip) || 0;
  const next6 = Number(model.rain?.next6mm) || 0;
  const rainValue = `${num(precipValue(next6, units), next6 >= 10 ? 0 : 1)} ${precipUnit(units)}`;
  if (rainNow >= 8 || next6 >= 25) alerts.push(make('rain', 'severe', { value: rainValue }));
  else if (rainNow >= 2.5 || next6 >= 10) alerts.push(make('rain', 'warning', { value: rainValue }));

  const dustValue = c.dust ?? c.pm10;
  if (Number.isFinite(Number(dustValue))) {
    const dust = Number(dustValue);
    const pm10 = Number(c.pm10) || 0;
    if (dust >= 150 || pm10 >= 300) alerts.push(make('dust', 'severe', { value: `${num(dust)} ${t('misc.ugm3')}` }));
    else if (dust >= 50 || pm10 >= 150) alerts.push(make('dust', 'warning', { value: `${num(dust)} ${t('misc.ugm3')}` }));
  }

  if (Number.isFinite(Number(c.uv))) {
    const uv = Number(c.uv);
    if (uv >= 11) alerts.push(make('uv', 'severe', { value: num(uv, 1) }));
    else if (uv >= 8) alerts.push(make('uv', 'warning', { value: num(uv, 1) }));
  }

  if (Number(c.code) >= 96) alerts.push(make('thunder', 'severe'));
  else if (Number(c.code) >= 95) alerts.push(make('thunder', 'warning'));

  const nearest = Array.isArray(model.storms) ? model.storms[0] : null;
  if (nearest && Number.isFinite(Number(nearest.distanceKm))) {
    const distance = formatDistance(nearest.distanceKm, units, 0);
    if (nearest.distanceKm <= 500) {
      alerts.push(make('cyclone', 'severe', { name: nearest.name, distance }));
    } else if (nearest.distanceKm <= 1000) {
      alerts.push(make('cyclone', 'warning', { name: nearest.name, distance }));
    }
  }

  const sevRank = { severe: 2, warning: 1, info: 0 };
  return alerts
    .sort((a, b) => (sevRank[b.severity] - sevRank[a.severity]) || (TYPE_ORDER.indexOf(a.type) - TYPE_ORDER.indexOf(b.type)))
    .map((alert, index) => ({ ...alert, order: index }));
}
