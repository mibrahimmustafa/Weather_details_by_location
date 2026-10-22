/**
 * Formatting helpers — numbers stay Western in both languages, dates and
 * weekdays follow the active locale. All inputs are metric; conversion happens
 * at the edge, right before display.
 */
import { getIntlLocale, t, tp } from './i18n.js';
import { LOCALES } from './config.js';

const numberFormats = new Map();
function nf(digits = 0, minDigits = 0) {
  const key = `${digits}:${minDigits}`;
  if (!numberFormats.has(key)) {
    numberFormats.set(key, new Intl.NumberFormat('en-US', {
      maximumFractionDigits: digits,
      minimumFractionDigits: minDigits,
      useGrouping: true,
    }));
  }
  return numberFormats.get(key);
}

export function num(value, digits = 0) {
  if (value == null || Number.isNaN(Number(value))) return t('misc.na');
  return nf(digits).format(Number(value));
}

export function fixed(value, digits = 0) {
  if (value == null || Number.isNaN(Number(value))) return t('misc.na');
  return Number(value).toFixed(digits);
}

/* ---------------------------------- units --------------------------------- */

export const toF = (c) => (c * 9) / 5 + 32;
export const toMph = (kmh) => kmh * 0.621371;
export const toInches = (mm) => mm * 0.0393701;
export const toMiles = (km) => km * 0.621371;

export function tempValue(celsius, units = 'metric') {
  if (celsius == null || Number.isNaN(Number(celsius))) return null;
  return units === 'imperial' ? toF(Number(celsius)) : Number(celsius);
}

export function tempUnit(units = 'metric') {
  return units === 'imperial' ? '°F' : '°C';
}

export function windValue(kmh, units = 'metric') {
  if (kmh == null || Number.isNaN(Number(kmh))) return null;
  return units === 'imperial' ? toMph(Number(kmh)) : Number(kmh);
}

export function windUnit(units = 'metric') {
  return units === 'imperial' ? 'mph' : 'km/h';
}

export function precipValue(mm, units = 'metric') {
  if (mm == null || Number.isNaN(Number(mm))) return null;
  return units === 'imperial' ? toInches(Number(mm)) : Number(mm);
}

export function precipUnit(units = 'metric') {
  return units === 'imperial' ? 'in' : 'mm';
}

export function distanceValue(km, units = 'metric') {
  if (km == null || Number.isNaN(Number(km))) return null;
  return units === 'imperial' ? toMiles(Number(km)) : Number(km);
}

export function distanceUnit(units = 'metric') {
  return t(units === 'imperial' ? 'misc.mi' : 'misc.km');
}

export function formatTemp(celsius, units = 'metric', digits = 0) {
  const value = tempValue(celsius, units);
  return value == null ? t('misc.na') : `${num(value, digits)}°`;
}

export function formatWind(kmh, units = 'metric', digits = 0) {
  const value = windValue(kmh, units);
  return value == null ? t('misc.na') : `${num(value, digits)} ${windUnit(units)}`;
}

export function formatDistance(km, units = 'metric', digits = 0) {
  const value = distanceValue(km, units);
  return value == null ? t('misc.na') : `${num(value, digits)} ${distanceUnit(units)}`;
}

export function formatPrecip(mm, units = 'metric', digits = 1) {
  const value = precipValue(mm, units);
  return value == null ? t('misc.na') : `${num(value, digits)} ${precipUnit(units)}`;
}

/* ---------------------------------- dates --------------------------------- */

const dateFormats = new Map();
function dtf(options) {
  const locale = getIntlLocale();
  const key = `${locale}:${JSON.stringify(options)}`;
  if (!dateFormats.has(key)) dateFormats.set(key, new Intl.DateTimeFormat(locale, options));
  return dateFormats.get(key);
}

export function formatClock(date = new Date(), timeZone) {
  const options = {
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
    hourCycle: 'h23',
  };
  if (timeZone) options.timeZone = timeZone;
  try {
    return dtf(options).format(date);
  } catch {
    delete options.timeZone;
    return dtf(options).format(date);
  }
}

export function formatDateLine(date = new Date(), timeZone, locale = undefined) {
  const options = { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' };
  if (timeZone) options.timeZone = timeZone;

  const make = () => {
    const intlLocale = locale
      ? (LOCALES[locale]?.intl || getIntlLocale())
      : getIntlLocale();
    return new Intl.DateTimeFormat(intlLocale, options);
  };

  let formatter;
  try {
    formatter = make();
  } catch {
    delete options.timeZone;
    formatter = make();
  }

  try {
    return formatter.format(date);
  } catch {
    return new Intl.DateTimeFormat(getIntlLocale(), {
      weekday: 'long', day: 'numeric', month: 'long', year: 'numeric',
    }).format(date);
  }
}

/** "14:00" for a naive local ISO string such as 2026-10-21T14:00. */
export function formatHourLabel(iso) {
  if (typeof iso !== 'string' || iso.length < 16) return t('misc.na');
  return iso.slice(11, 16);
}

/** Minutes since local midnight for a naive local ISO string. */
export function minutesOfDay(iso) {
  if (typeof iso !== 'string' || iso.length < 16) return 0;
  const h = Number(iso.slice(11, 13));
  const m = Number(iso.slice(14, 16));
  if (Number.isNaN(h) || Number.isNaN(m)) return 0;
  return h * 60 + m;
}

export function parseNaiveDate(iso) {
  if (typeof iso !== 'string') return new Date(NaN);
  return new Date(`${iso.slice(0, 19)}Z`);
}

export function dateKey(date = new Date()) {
  const pad = (n) => String(n).padStart(2, '0');
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}`;
}

/** Weekday label for a YYYY-MM-DD date, independent of the browser time zone. */
export function weekdayLabel(dateStr, { short = false } = {}) {
  const date = new Date(`${dateStr}T12:00:00Z`);
  const options = { weekday: short ? 'short' : 'long', timeZone: 'UTC' };
  return dtf(options).format(date);
}

export function dayMonthLabel(dateStr, { month = 'long' } = {}) {
  const date = new Date(`${dateStr}T12:00:00Z`);
  return dtf({ day: 'numeric', month, timeZone: 'UTC' }).format(date);
}

export function daysBetween(dateStr, referenceStr) {
  const a = Date.parse(`${dateStr}T12:00:00Z`);
  const b = Date.parse(`${referenceStr}T12:00:00Z`);
  if (Number.isNaN(a) || Number.isNaN(b)) return 0;
  return Math.round((a - b) / 86_400_000);
}

export function dayLabel(dateStr, todayStr) {
  const diff = daysBetween(dateStr, todayStr);
  if (diff === 0) return t('daily.today');
  if (diff === 1) return t('daily.tomorrow');
  return weekdayLabel(dateStr);
}

/** GMT+3 / GMT-4:30 from an offset in seconds (open-meteo provides this). */
export function timezoneOffsetLabel(offsetSeconds) {
  if (offsetSeconds == null || Number.isNaN(Number(offsetSeconds))) return 'GMT';
  const totalMinutes = Math.round(Number(offsetSeconds) / 60);
  const sign = totalMinutes < 0 ? '−' : '+';
  const abs = Math.abs(totalMinutes);
  const h = Math.floor(abs / 60);
  const m = abs % 60;
  return `GMT${sign}${h}${m ? `:${String(m).padStart(2, '0')}` : ''}`;
}

/* -------------------------------- relative -------------------------------- */

export function relativeUpdate(fetchedAt, now = Date.now()) {
  const diff = Math.max(0, now - fetchedAt);
  const minutes = Math.floor(diff / 60_000);
  if (minutes < 1) return t('hero.updatedJustNow');
  if (minutes < 60) return tp('hero.updatedMin', minutes, { n: minutes });
  const hours = Math.floor(minutes / 60);
  return tp('hero.updatedHour', hours, { n: hours });
}

export function formatDurationMinutes(totalMinutes) {
  const minutes = Math.max(0, Math.round(totalMinutes));
  const h = Math.floor(minutes / 60);
  const m = minutes % 60;
  return t('sun.hoursMinutes', { h: num(h), m: num(m) });
}

export function compassShort(degrees) {
  if (degrees == null || Number.isNaN(Number(degrees))) return '';
  const dirs = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
  const index = Math.round(((Number(degrees) % 360) / 45)) % 8;
  return dirs[index];
}

export function compassLabel(degrees, { short = false } = {}) {
  const key = compassShort(degrees);
  return key ? t(`dir.${key}${short ? '_short' : ''}`) : t('misc.na');
}

export function clamp(value, min, max) {
  return Math.min(max, Math.max(min, value));
}
