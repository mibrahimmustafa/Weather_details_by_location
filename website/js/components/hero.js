/** Hero card: city, current reading, animated scene and the live local clock. */
import { el } from '../dom.js';
import { icon } from './icons.js';
import { weatherGlyph } from './icons.js';
import { weatherScene } from './scene.js';
import { t } from '../i18n.js';
import { cityName, countryName } from '../city.js';
import { sceneFamily, conditionKey } from '../domain/conditions.js';
import {
  num, tempValue, tempUnit, formatTemp, formatClock, formatDateLine,
  relativeUpdate, timezoneOffsetLabel, weekdayLabel,
} from '../format.js';

export function heroCard({ model, units, loading, onOpenCities, onRefresh }) {
  const current = model.current;
  const today = model.daily[0] || {};
  const scene = weatherScene(sceneFamily(current.code, current.isDay), !current.isDay);
  const cityLabel = cityName(model.city);
  const country = countryName(model.city);
  const tzLabel = model.timezoneLabel || timezoneOffsetLabel(model.utcOffsetSeconds);

  const chip = el('button', {
    class: 'city-chip',
    type: 'button',
    onclick: onOpenCities,
    'aria-label': t('a11y.selectCity', { city: cityLabel }),
  },
  el('span', { class: 'city-chip__pin' }, icon('location', { size: 16 })),
  el('span', { class: 'city-chip__body' },
    el('span', { class: 'city-chip__name', text: cityLabel }),
    country ? el('span', { class: 'city-chip__country', text: country }) : null,
  ),
  icon('chevron', { size: 15, className: 'city-chip__chevron' }),
  );

  const live = el('span', { class: 'live-badge' },
    el('span', { class: 'live-badge__dot', 'aria-hidden': 'true' }),
    el('span', { text: t('hero.live') }),
  );

  const temperature = el('div', { class: 'hero__temp' },
    el('span', { class: 'hero__temp-value', text: num(tempValue(current.temp, units), 0) }),
    el('span', { class: 'hero__temp-unit', dir: 'ltr', text: tempUnit(units) }),
  );

  const reading = el('div', { class: 'hero__reading' },
    temperature,
    el('p', { class: 'hero__condition', text: t(conditionKey(current.code)) }),
    el('p', { class: 'hero__feels', text: t('hero.feelsLike', { temp: formatTemp(current.feels, units) }) }),
    el('p', { class: 'hero__range', text: t('hero.range', {
      high: formatTemp(today.max, units),
      low: formatTemp(today.min, units),
    }) }),
  );

  const clock = el('div', { class: 'hero__clock-block' },
    el('div', { class: 'hero__clock-head' },
      el('span', { class: 'hero__clock-label' }, icon('clock', { size: 14 }), el('span', { text: t('hero.localTime') })),
      el('span', { class: 'tz-chip', text: tzLabel }),
    ),
    el('time', {
      class: 'hero__clock',
      id: 'live-clock',
      role: 'timer',
      'aria-live': 'off',
      datetime: new Date().toISOString(),
      text: formatClock(new Date(), model.timezone),
    }),
    el('p', {
      class: 'hero__date',
      id: 'hero-date',
      text: formatDateLine(new Date(), model.timezone),
    }),
    el('span', { class: 'visually-hidden', text: today.date ? weekdayLabel(today.date) : '' }),
  );

  const refreshButton = el('button', {
    class: `refresh-btn${loading ? ' is-loading' : ''}`,
    id: 'refresh-btn',
    type: 'button',
    onclick: onRefresh,
    'aria-label': t('a11y.refresh'),
    'aria-busy': loading ? 'true' : 'false',
  },
  icon('refresh', { size: 17 }),
  el('span', { text: t('hero.refresh') }),
  );

  const footer = el('div', { class: 'hero__foot' },
    el('div', { class: 'hero__updated' },
      el('span', { class: 'hero__updated-dot', 'aria-hidden': 'true' }),
      el('span', { id: 'hero-updated', text: relativeUpdate(model.fetchedAt) }),
    ),
    refreshButton,
  );

  const card = el('section', { class: 'hero card', 'aria-labelledby': 'hero-city-name' },
    scene,
    el('div', { class: 'hero__veil', 'aria-hidden': 'true' }),
    el('div', { class: 'hero__content' },
      el('div', { class: 'hero__top' }, chip, live),
      el('div', { class: 'hero__body' },
        reading,
        el('div', { class: 'hero__glyph', 'aria-hidden': 'true' }, weatherGlyph(current.code, current.isDay, { size: 112 })),
      ),
      clock,
      footer,
    ),
  );
  const nameNode = chip.querySelector('.city-chip__name');
  if (nameNode) nameNode.id = 'hero-city-name';
  return card;
}
