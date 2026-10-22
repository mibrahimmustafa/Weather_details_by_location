/** Footer: brand, attribution, provider links, privacy and version. */
import { el, append, clear } from '../dom.js';
import { icon, logoMark } from './icons.js';
import { t } from '../i18n.js';
import { APP } from '../config.js';

const PROVIDERS = [
  { name: 'Open-Meteo', url: 'https://open-meteo.com/' },
  { name: 'NASA EONET', url: 'https://eonet.gsfc.nasa.gov/' },
  { name: 'GDACS', url: 'https://www.gdacs.org/' },
  { name: 'BigDataCloud', url: 'https://www.bigdatacloud.com/' },
];

export function renderFooter(root, { onOpenSettings, onTop } = {}) {
  clear(root);
  const providers = el('ul', { class: 'footer__providers' });
  PROVIDERS.forEach((provider) => {
    const link = el('a', {
      class: 'footer__provider',
      href: provider.url,
      target: '_blank',
      rel: 'noopener noreferrer',
    }, el('span', { text: provider.name }), icon('external', { size: 13 }));
    link.setAttribute('aria-label', `${provider.name} — ${t('a11y.openSource')}`);
    providers.append(el('li', {}, link));
  });

  append(root,
    el('div', { class: 'footer__top' },
      el('div', { class: 'footer__brand' },
        el('span', { class: 'footer__logo' }, logoMark({ size: 34 })),
        el('div', {},
          el('p', { class: 'footer__name', text: t('app.name') }),
          el('p', { class: 'footer__tagline', text: t('app.tagline') }),
        ),
      ),
      el('button', {
        class: 'icon-btn footer__top-btn',
        type: 'button',
        onclick: onTop,
        'aria-label': t('footer.top'),
      }, icon('arrowDown', { size: 18, className: 'icon--up' })),
    ),
    el('div', { class: 'footer__grid' },
      el('div', { class: 'footer__col' },
        el('h3', { class: 'footer__heading', text: t('footer.sources') }),
        providers,
        el('p', { class: 'footer__note', text: t('footer.attribution') }),
      ),
      el('div', { class: 'footer__col' },
        el('h3', { class: 'footer__heading', text: t('sheet.settings.about') }),
        el('p', { class: 'footer__line' }, el('span', { text: t('sheet.settings.version') }), el('b', { text: APP.version })),
        el('p', { class: 'footer__line' }, el('span', { text: t('sheet.settings.author') }), el('b', { text: APP.author })),
        el('div', { class: 'footer__links' },
          el('button', { class: 'text-btn', type: 'button', text: t('footer.privacy'), onclick: onOpenSettings }),
          el('button', { class: 'text-btn', type: 'button', text: t('footer.licenses'), onclick: onOpenSettings }),
        ),
      ),
    ),
    el('div', { class: 'footer__bottom' },
      el('p', { class: 'footer__made', text: t('footer.madeBy') }),
      el('span', { class: 'footer__dot', 'aria-hidden': 'true' }),
      el('p', { class: 'footer__made', text: `${t('sheet.settings.version')} ${APP.version}` }),
      el('span', { class: 'footer__dot', 'aria-hidden': 'true' }),
      el('p', { class: 'footer__made footer__made--muted', text: t('footer.openData') }),
    ),
  );
}
