import { getLocale } from './i18n.js';

export function cityName(city, locale = getLocale()) {
  if (!city) return '';
  if (locale === 'en') return city.nameEn || city.name || '';
  return city.name || city.nameEn || '';
}

export function countryName(city, locale = getLocale()) {
  if (!city) return '';
  if (locale === 'en') return city.countryEn || city.country || '';
  return city.country || city.countryEn || '';
}

export function cityContext(city, locale = getLocale()) {
  return [countryName(city, locale), city?.admin1].filter(Boolean).join(' · ');
}

export function shortCityName(city, locale = getLocale()) {
  const name = cityName(city, locale);
  return name.length > 22 ? `${name.slice(0, 21)}…` : name;
}
