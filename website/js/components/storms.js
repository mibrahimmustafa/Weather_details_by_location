/** Active tropical systems, sorted by distance from the selected city. */
import { el } from '../dom.js';
import { icon } from './icons.js';
import { sectionShell, emptyState } from './section.js';
import { t } from '../i18n.js';
import { cityName } from '../city.js';
import { num, formatDistance, formatWind } from '../format.js';

export function stormsSection({ model, units, onRetry }) {
  let body;
  if (model.stormsStatus === 'unavailable') {
    body = emptyState({
      iconName: 'cyclone',
      title: t('storms.unavailable'),
      body: t('storms.unavailableBody'),
      action: el('button', {
        class: 'btn btn--ghost',
        type: 'button',
        onclick: onRetry,
        text: t('storms.retry'),
      }),
    });
  } else if (!model.storms.length) {
    body = emptyState({
      iconName: 'cyclone',
      title: t('storms.empty'),
      body: t('storms.emptyBody'),
    });
  } else {
    body = el('div', { class: 'storms' }, model.storms.map((storm) => stormRow(storm, units)));
  }

  return sectionShell({
    id: 'storms',
    title: t('section.storms'),
    iconName: 'cyclone',
    meta: t('storms.subtitle', { city: cityName(model.city) }),
    className: 'section--storms',
    body,
  });
}

function stormRow(storm, units) {
  const levelLabel = t(`storms.level.${storm.level}`);
  const wind = storm.windKmh == null ? t('storms.unknownWind') : formatWind(storm.windKmh, units);
  const row = el('article', { class: 'storm' },
    el('span', { class: `storm__icon storm__icon--${storm.level}` }, icon('cyclone', { size: 22 })),
    el('div', { class: 'storm__main' },
      el('h3', { class: 'storm__name', text: storm.name }),
      el('p', { class: 'storm__meta' },
        el('span', {}, icon('location', { size: 12 }), el('span', { text: formatDistance(storm.distanceKm, units) })),
        el('span', { class: 'storm__sep', 'aria-hidden': 'true' }),
        el('span', {}, icon('wind', { size: 12 }), el('span', { text: wind })),
        storm.source ? el('span', { class: 'storm__source', text: storm.source }) : null,
      ),
    ),
    el('span', { class: `severity severity--${storm.level}`, text: levelLabel }),
    storm.url ? el('a', {
      class: 'icon-btn storm__link',
      href: storm.url,
      target: '_blank',
      rel: 'noopener noreferrer',
      'aria-label': `${t('a11y.openSource')} — ${storm.name}`,
    }, icon('external', { size: 16 })) : null,
  );
  return row;
}
