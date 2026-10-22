/** Sun path: arc from sunrise to sunset with a live marker. */
import { el } from '../dom.js';
import { icon } from './icons.js';
import { sectionShell } from './section.js';
import { t } from '../i18n.js';
import { sunArc } from '../charts.js';
import { formatHourLabel, formatDurationMinutes } from '../format.js';

export function sunSection({ model }) {
  const sun = model.sun;
  const stateLabel = sun.state === 'before' ? t('sun.before') : sun.state === 'after' ? t('sun.after') : null;

  const card = el('article', { class: 'card sun-card' },
    el('div', { class: 'sun-card__stage' },
      sunArc(sun.progress, sun.state),
      el('span', { class: 'sun-card__now', id: 'sun-now-label' },
        el('span', { class: 'sun-card__now-dot', 'aria-hidden': 'true' }),
        el('span', { text: `${t('sun.now')} · ${String(model.current.time).slice(11, 16)}` }),
      ),
    ),
    el('div', { class: 'sun-card__legend' },
      legend('sunrise', sun.sunrise ? formatHourLabel(sun.sunrise) : '—', 'gold'),
      legend('sun.length', sun.dayLengthMinutes != null ? formatDurationMinutes(sun.dayLengthMinutes) : '—', 'teal'),
      legend('sunset', sun.sunset ? formatHourLabel(sun.sunset) : '—', 'coral'),
    ),
    stateLabel ? el('p', { class: 'sun-card__state', text: stateLabel }) : null,
  );

  return sectionShell({
    id: 'sun',
    title: t('section.sun'),
    iconName: 'sun',
    className: 'section--sun',
    body: card,
  });
}

function legend(key, value, tone) {
  return el('div', { class: `sun-legend sun-legend--${tone}` },
    el('span', { class: 'sun-legend__dot', 'aria-hidden': 'true' }),
    el('span', { class: 'sun-legend__label', text: t(key) }),
    el('strong', { class: 'sun-legend__value', text: value }),
  );
}
