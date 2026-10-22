/** First-run welcome sheet. The decision is remembered and never asked again. */
import { el } from '../dom.js';
import { icon, logoMark } from './icons.js';
import { t } from '../i18n.js';
import { openSheet } from './sheets.js';

export function openWelcome({ onAllow, onChoose, onLater }) {
  const content = el('div', { class: 'welcome' },
    el('span', { class: 'welcome__logo' }, logoMark({ size: 86 })),
    el('h2', { class: 'welcome__title', text: t('welcome.title') }),
    el('p', { class: 'welcome__body', text: t('welcome.body') }),
    el('div', { class: 'welcome__actions' },
      el('button', {
        class: 'btn btn--primary btn--wide',
        type: 'button',
        onclick: () => {
          close();
          onAllow?.();
        },
      }, icon('location', { size: 17 }), el('span', { text: t('welcome.allow') })),
      el('button', {
        class: 'btn btn--soft btn--wide',
        type: 'button',
        onclick: () => {
          close();
          onChoose?.();
        },
      }, icon('search', { size: 16 }), el('span', { text: t('welcome.choose') })),
      el('button', {
        class: 'text-btn welcome__later',
        type: 'button',
        onclick: () => {
          close();
          onLater?.();
        },
        text: t('welcome.later'),
      }),
    ),
    el('p', { class: 'welcome__privacy' },
      icon('eye', { size: 14 }),
      el('span', { text: t('welcome.privacy') }),
    ),
  );

  const sheet = openSheet({
    title: t('welcome.sheetTitle'),
    content,
    className: 'sheet--welcome',
    initialFocus: content.querySelector('.btn--primary'),
    onClose: () => onLater?.(),
  });

  function close() {
    sheet.close();
  }

  return sheet;
}
