/** Friendly, translated error screen with one clear recovery action. */
import { el } from '../dom.js';
import { icon } from './icons.js';
import { t } from '../i18n.js';

const KNOWN = new Set(['network', 'timeout', 'server', 'data', 'unknown', 'offline']);

export function errorView({ kind = 'unknown', onRetry }) {
  const safeKind = KNOWN.has(kind) ? kind : 'unknown';
  return el('div', { class: 'error-view card', role: 'alert' },
    el('span', { class: 'error-view__icon' }, icon('cloud', { size: 34 })),
    el('h2', { class: 'error-view__title', text: t('errors.title') }),
    el('p', { class: 'error-view__message', text: t(`errors.${safeKind}`) }),
    el('p', { class: 'error-view__hint', text: t('errors.hint') }),
    el('button', {
      class: 'btn btn--primary',
      type: 'button',
      onclick: onRetry,
    }, icon('refresh', { size: 16 }), el('span', { text: t('errors.retry') })),
  );
}

export function offlineBanner({ onRetry }) {
  return el('div', { class: 'offline-banner', role: 'status' },
    el('span', { class: 'offline-banner__icon' }, icon('alert', { size: 17 })),
    el('div', { class: 'offline-banner__text' },
      el('strong', { text: t('hero.staleTitle') }),
      el('span', { text: t('hero.staleBody') }),
    ),
    el('button', {
      class: 'offline-banner__action',
      type: 'button',
      onclick: onRetry,
      text: t('hero.retry'),
    }),
  );
}
