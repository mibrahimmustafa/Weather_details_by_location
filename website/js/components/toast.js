/** Toast / snackbar, one at a time, announced politely. */
import { el, clear } from '../dom.js';
import { icon } from './icons.js';

let hideTimer = null;

export function showToast(message, { tone = 'info', duration = 3400 } = {}) {
  const root = document.getElementById('toast-root');
  if (!root) return;
  clear(root);
  clearTimeout(hideTimer);

  const node = el('div', { class: `toast toast--${tone}`, role: 'status', 'aria-live': 'polite' },
    el('span', { class: 'toast__icon' }, icon(tone === 'error' ? 'alert' : 'check', { size: 16 })),
    el('span', { class: 'toast__text', text: message }),
  );
  root.append(node);
  requestAnimationFrame(() => node.classList.add('is-visible'));

  hideTimer = setTimeout(() => {
    node.classList.remove('is-visible');
    setTimeout(() => node.remove(), 240);
  }, duration);
}
