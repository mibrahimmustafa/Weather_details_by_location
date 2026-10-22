/** Explanation, day-detail and alert-detail sheets. */
import { el } from '../dom.js';
import { icon, weatherGlyph } from './icons.js';
import { t } from '../i18n.js';
import { openSheet } from './sheets.js';
import { conditionKey } from '../domain/conditions.js';
import {
  num, formatTemp, formatWind, formatPrecip, formatHourLabel, dayLabel,
  dayMonthLabel, weekdayLabel,
} from '../format.js';

export function openInfo({ title, body, iconName = 'info', tone = 'teal', rows = [] }) {
  const content = el('div', { class: 'info-sheet' },
    el('span', { class: `info-sheet__icon detail__icon--${tone}` }, icon(iconName, { size: 26 })),
    el('p', { class: 'info-sheet__body', text: body }),
    rows.length ? el('dl', { class: 'info-list' }, rows.map((row) => el('div', { class: 'info-list__row' },
      el('dt', { text: row.label }),
      el('dd', { text: row.value }),
    ))) : null,
  );
  return openSheet({ title, content, className: 'sheet--info' });
}

export function openDay({ model, day, units }) {
  const today = model.daily[0]?.date;
  const label = dayLabel(day.date, today);
  const rows = [
    { label: t('daily.max'), value: formatTemp(day.max, units) },
    { label: t('daily.min'), value: formatTemp(day.min, units) },
    { label: t('daily.prob'), value: day.precipProb == null ? t('misc.na') : `${num(day.precipProb)}%` },
    { label: t('daily.precip'), value: formatPrecip(day.precipSum, units, 1) },
    { label: t('daily.wind'), value: formatWind(day.windMax, units) },
    { label: t('daily.uv'), value: num(day.uvMax, 1) },
    { label: t('daily.sunrise'), value: day.sunrise ? formatHourLabel(day.sunrise) : t('misc.na') },
    { label: t('daily.sunset'), value: day.sunset ? formatHourLabel(day.sunset) : t('misc.na') },
  ];

  const content = el('div', { class: 'day-sheet' },
    el('div', { class: 'day-sheet__hero' },
      el('span', { class: 'day-sheet__glyph' }, weatherGlyph(day.code, true, { size: 84 })),
      el('div', { class: 'day-sheet__reading' },
        el('strong', { class: 'day-sheet__temp', text: formatTemp(day.max, units) }),
        el('span', { class: 'day-sheet__min', text: `${t('daily.min')} ${formatTemp(day.min, units)}` }),
        el('span', { class: 'day-sheet__condition', text: t(conditionKey(day.code)) }),
      ),
    ),
    el('dl', { class: 'info-list' }, rows.map((row) => el('div', { class: 'info-list__row' },
      el('dt', { text: row.label }),
      el('dd', { text: row.value }),
    ))),
  );

  return openSheet({
    title: label,
    subtitle: `${weekdayLabel(day.date)} · ${dayMonthLabel(day.date)}`,
    content,
    className: 'sheet--day',
  });
}

export function openAlert({ alert }) {
  const title = t(alert.titleKey, alert.params);
  const advice = t(alert.bodyKey, alert.params);
  const content = el('div', { class: `alert-sheet alert-sheet--${alert.severity}` },
    el('div', { class: 'alert-sheet__head' },
      el('span', { class: `alert-sheet__icon alert-sheet__icon--${alert.severity}` }, icon(alertIcon(alert.type), { size: 28 })),
      el('span', { class: `severity severity--${alert.severity}`, text: t(`severity.${alert.severity}`) }),
    ),
    el('h3', { class: 'alert-sheet__title', text: title }),
    el('h4', { class: 'alert-sheet__advice-title', text: t('alerts.advice') }),
    el('p', { class: 'alert-sheet__advice', text: advice }),
  );

  return openSheet({
    title: t('alerts.title'),
    content,
    className: 'sheet--alert',
  });
}

function alertIcon(type) {
  const map = {
    heat: 'thermometer',
    cold: 'thermometer',
    wind: 'wind',
    rain: 'droplet',
    dust: 'wind',
    uv: 'sun',
    thunder: 'alert',
    cyclone: 'cyclone',
  };
  return map[type] || 'alert';
}
