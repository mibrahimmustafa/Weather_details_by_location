/** Layout-preserving shimmer skeleton for the first load. */
import { el } from '../dom.js';
import { t } from '../i18n.js';

export function skeletonView() {
  const bone = (className = '') => el('span', { class: `bone ${className}`.trim(), 'aria-hidden': 'true' });
  return el('div', { class: 'skeleton', 'aria-busy': 'true' },
    el('span', { class: 'visually-hidden', text: t('loader.preparing') }),
    el('div', { class: 'skeleton__hero card' },
      bone('bone--chip'),
      el('div', { class: 'skeleton__hero-row' },
        el('div', { class: 'skeleton__stack' }, bone('bone--temp'), bone('bone--line'), bone('bone--line bone--short')),
        bone('bone--glyph'),
      ),
      el('div', { class: 'skeleton__clock' }, bone('bone--chip'), bone('bone--clock')),
    ),
    el('div', { class: 'skeleton__row' }, bone('bone--pill'), bone('bone--pill'), bone('bone--pill')),
    el('div', { class: 'skeleton__grid' },
      el('div', { class: 'skeleton__card card' }, bone('bone--line'), bone('bone--big'), bone('bone--line')),
      el('div', { class: 'skeleton__card card' }, bone('bone--line'), bone('bone--big'), bone('bone--line')),
    ),
    el('div', { class: 'skeleton__grid skeleton__grid--three' },
      el('div', { class: 'skeleton__card card' }, bone('bone--line'), bone('bone--line')),
      el('div', { class: 'skeleton__card card' }, bone('bone--line'), bone('bone--line')),
      el('div', { class: 'skeleton__card card' }, bone('bone--line'), bone('bone--line')),
    ),
  );
}
