/** Seven-day outlook with normalized range bars. */
import { el } from '../dom.js';
import { icon, weatherGlyph } from './icons.js';
import { sectionShell } from './section.js';
import { t } from '../i18n.js';
import { rangeBar } from '../charts.js';
import { num, formatTemp, dayLabel, dayMonthLabel } from '../format.js';

export function dailySection({ model, units, onOpenDay }) {
  const days = model.daily;
  const todayStr = days[0]?.date;
  const weekMin = Math.min(...days.map((day) => Number(day.min ?? 0)));
  const weekMax = Math.max(...days.map((day) => Number(day.max ?? 0)));

  const rows = days.map((day) => {
    const label = dayLabel(day.date, todayStr);
    const isToday = day.date === todayStr;
    const row = el('button', {
      class: `day${isToday ? ' is-today' : ''}`,
      type: 'button',
      onclick: () => onOpenDay(day),
      'aria-label': `${label} — ${t('daily.max')} ${formatTemp(day.max, units)} · ${t('daily.min')} ${formatTemp(day.min, units)} · ${t('daily.rain')} ${num(day.precipProb ?? 0)}%`,
    },
    el('span', { class: 'day__label' },
      el('span', { class: 'day__name', text: label }),
      el('span', { class: 'day__date', text: dayMonthLabel(day.date, { month: 'short' }) }),
    ),
    el('span', { class: 'day__glyph', 'aria-hidden': 'true' }, weatherGlyph(day.code, true, { size: 40 })),
    el('span', { class: 'day__prob' }, icon('droplet', { size: 12 }), el('span', { text: `${num(day.precipProb ?? 0)}%` })),
    el('span', { class: 'day__range' }, rangeBar(day.min, day.max, weekMin, weekMax)),
    el('span', { class: 'day__temps' },
      el('strong', { class: 'day__max', text: formatTemp(day.max, units) }),
      el('span', { class: 'day__min', text: formatTemp(day.min, units) }),
    ),
    );
    return row;
  });

  return sectionShell({
    id: 'daily',
    title: t('section.daily'),
    iconName: 'layers',
    meta: t('daily.subtitle'),
    className: 'section--daily',
    body: el('div', { class: 'days' }, rows),
  });
}
