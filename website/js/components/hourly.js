/** Next 24 hours, horizontally scrollable with a highlighted "now" cell. */
import { el } from '../dom.js';
import { icon, weatherGlyph } from './icons.js';
import { sectionShell } from './section.js';
import { t } from '../i18n.js';
import { conditionKey } from '../domain/conditions.js';
import { num, formatTemp, formatWind } from '../format.js';

export function hourlySection({ model, units }) {
  const strip = el('div', {
    class: 'hourly',
    role: 'list',
    tabindex: '0',
    'aria-label': t('section.hourly'),
  });

  model.hourly.forEach((hour, index) => {
    const isNow = index === 0;
    const probability = hour.precipProb == null ? t('misc.na') : `${num(hour.precipProb)}%`;
    const cell = el('div', {
      class: `hour${isNow ? ' is-now' : ''}`,
      role: 'listitem',
      'aria-label': `${isNow ? t('hourly.now') : hour.label} — ${t(conditionKey(hour.code))} — ${formatTemp(hour.temp, units)} — ${t('hourly.rain')} ${probability} — ${t('hourly.wind')} ${formatWind(hour.wind, units)}`,
    },
    el('span', { class: 'hour__time', text: isNow ? t('hourly.now') : hour.label }),
    el('span', { class: 'hour__glyph' }, weatherGlyph(hour.code, hour.isDay, { size: 44 })),
    el('span', { class: 'hour__temp', text: formatTemp(hour.temp, units) }),
    el('span', { class: 'hour__meta' },
      el('span', { class: `hour__rain${(hour.precipProb ?? 0) >= 30 ? ' is-wet' : ''}` },
        icon('droplet', { size: 12 }), el('span', { text: probability })),
      el('span', { class: 'hour__wind' }, icon('wind', { size: 12 }), el('span', { text: formatWind(hour.wind, units, 0) })),
    ),
    );
    strip.append(cell);
  });

  return sectionShell({
    id: 'hourly',
    title: t('section.hourly'),
    iconName: 'clock',
    hint: t('section.hourlyHint'),
    className: 'section--hourly',
    body: el('div', { class: 'scroll-x' },
      strip,
      el('div', { class: 'scroll-x__fade scroll-x__fade--start', 'aria-hidden': 'true' }),
      el('div', { class: 'scroll-x__fade scroll-x__fade--end', 'aria-hidden': 'true' }),
    ),
  });
}
