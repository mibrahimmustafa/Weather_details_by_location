/**
 * Accessible sheet system: bottom sheets on phones, centered modals on desktop.
 * Handles Esc, backdrop click, focus trap/restore, scroll lock and drag-to-dismiss.
 */
import { el } from '../dom.js';
import { icon } from './icons.js';
import { t } from '../i18n.js';
import { trapFocus } from '../dom.js';

let active = null;

export function isSheetOpen() {
  return Boolean(active);
}

export function openSheet({
  title,
  subtitle = '',
  content,
  className = '',
  footer = null,
  onClose = null,
  initialFocus = null,
} = {}) {
  if (active) closeSheet({ immediate: true, silent: true });

  const titleId = `sheet-title-${Date.now().toString(36)}`;
  const layer = el('div', { class: 'sheet-layer' });
  const backdrop = el('div', { class: 'sheet__backdrop' });

  const closeButton = el('button', {
    class: 'icon-btn sheet__close',
    type: 'button',
    'aria-label': t('a11y.close'),
    onclick: () => closeSheet(),
  }, icon('close', { size: 18 }));

  const head = el('header', { class: 'sheet__head' },
    el('div', { class: 'sheet__grab', 'aria-hidden': 'true' }),
    el('div', { class: 'sheet__heading' },
      el('h2', { class: 'sheet__title', id: titleId, text: title }),
      subtitle ? el('p', { class: 'sheet__subtitle', text: subtitle }) : null,
    ),
    closeButton,
  );

  const body = el('div', { class: 'sheet__body' }, content);
  const panel = el('section', {
    class: `sheet ${className}`.trim(),
    role: 'dialog',
    'aria-modal': 'true',
    'aria-labelledby': titleId,
    tabindex: '-1',
  }, head, body, footer ? el('footer', { class: 'sheet__footer' }, footer) : null);

  layer.append(backdrop, panel);
  document.getElementById('sheets-root').append(layer);
  document.body.classList.add('is-locked');

  backdrop.addEventListener('click', () => closeSheet());

  // Drag to dismiss — only from the header/handle, only downwards.
  let startY = null;
  let delta = 0;
  let pointerId = null;
  head.addEventListener('pointerdown', (event) => {
    if (event.target.closest('button')) return;
    startY = event.clientY;
    delta = 0;
    pointerId = event.pointerId;
    panel.classList.add('is-dragging');
    try {
      panel.setPointerCapture(pointerId);
    } catch {
      /* not all engines support capture on the panel */
    }
  });
  panel.addEventListener('pointermove', (event) => {
    if (startY == null || event.pointerId !== pointerId) return;
    delta = Math.max(0, event.clientY - startY);
    panel.style.transform = `translateY(${delta}px)`;
  });
  const endDrag = () => {
    if (startY == null) return;
    panel.classList.remove('is-dragging');
    panel.style.transform = '';
    if (delta > 110) closeSheet();
    startY = null;
    delta = 0;
    pointerId = null;
  };
  panel.addEventListener('pointerup', endDrag);
  panel.addEventListener('pointercancel', endDrag);
  panel.addEventListener('pointerleave', endDrag);

  requestAnimationFrame(() => layer.classList.add('is-open'));

  const releaseTrap = trapFocus(panel, initialFocus);

  const onKeyDown = (event) => {
    if (event.key === 'Escape') {
      event.preventDefault();
      closeSheet();
    }
  };
  document.addEventListener('keydown', onKeyDown);

  active = { layer, panel, releaseTrap, onKeyDown, onClose };

  return {
    panel,
    body,
    close: () => closeSheet(),
  };
}

export function closeSheet({ immediate = false, silent = false } = {}) {
  if (!active) return;
  const current = active;
  active = null;

  document.removeEventListener('keydown', current.onKeyDown);
  current.releaseTrap();
  current.layer.classList.remove('is-open');
  current.layer.classList.add('is-closing');

  const finish = () => {
    current.layer.remove();
    if (!document.querySelector('.sheet-layer')) document.body.classList.remove('is-locked');
    if (!silent && typeof current.onClose === 'function') current.onClose();
  };

  if (immediate) finish();
  else setTimeout(finish, 240);
}

/* ------------------------------ shared bits ------------------------------- */

export function segmented(options, value, onChange, ariaLabel) {
  const group = el('div', { class: 'segmented', role: 'group', 'aria-label': ariaLabel });
  const buttons = options.map((option) => {
    const button = el('button', {
      class: `segmented__item${option.value === value ? ' is-active' : ''}`,
      type: 'button',
      'aria-pressed': option.value === value ? 'true' : 'false',
      onclick: () => {
        buttons.forEach((item) => {
          const activeOption = item.dataset.value === option.value;
          item.classList.toggle('is-active', activeOption);
          item.setAttribute('aria-pressed', activeOption ? 'true' : 'false');
        });
        onChange(option.value);
      },
    },
    option.icon ? icon(option.icon, { size: 15 }) : null,
    el('span', { class: 'segmented__label', text: option.label }),
    option.hint ? el('span', { class: 'segmented__hint', text: option.hint }) : null,
    );
    button.dataset.value = option.value;
    return button;
  });
  group.append(...buttons);
  return group;
}

export function settingsBlock(title, content, { note = null, iconName = null } = {}) {
  return el('section', { class: 'settings-block' },
    el('h3', { class: 'settings-block__title' },
      iconName ? icon(iconName, { size: 15 }) : null,
      el('span', { text: title }),
    ),
    content,
    note ? el('p', { class: 'settings-block__note', text: note }) : null,
  );
}
