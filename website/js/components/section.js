import { el } from '../dom.js';
import { icon } from './icons.js';

/**
 * Shared section shell: eyebrow icon, title, optional meta, hint and action.
 */
export function sectionShell({
  id = '',
  title,
  iconName = 'sparkle',
  meta = null,
  hint = null,
  action = null,
  className = '',
  body,
} = {}) {
  const head = el('div', { class: 'section__head' },
    el('div', { class: 'section__title-wrap' },
      el('span', { class: 'section__icon' }, icon(iconName, { size: 17 })),
      el('div', { class: 'section__titles' },
        el('h2', { class: 'section__title', id: id ? `${id}-title` : null, text: title }),
        meta ? el('p', { class: 'section__meta', text: meta }) : null,
      ),
    ),
    hint ? el('span', { class: 'section__hint', text: hint }) : null,
    action || null,
  );

  return el('section', { class: `section ${className}`.trim(), id: id || null, 'aria-labelledby': id ? `${id}-title` : null },
    head,
    body,
  );
}

export function chip(text, { className = '', iconName = null } = {}) {
  const node = el('span', { class: `chip ${className}`.trim() });
  if (iconName) node.append(icon(iconName, { size: 14 }));
  if (text) node.append(el('span', { text }));
  return node;
}

export function emptyState({ iconName = 'info', title, body, action = null, className = '' }) {
  return el('div', { class: `empty-state ${className}`.trim() },
    el('span', { class: 'empty-state__icon' }, icon(iconName, { size: 26 })),
    el('h3', { class: 'empty-state__title', text: title }),
    body ? el('p', { class: 'empty-state__body', text: body }) : null,
    action,
  );
}
