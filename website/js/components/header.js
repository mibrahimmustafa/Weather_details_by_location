/** Sticky header: brand, language pill, search, theme and settings. */
import { icon, logoMark } from './icons.js';
import { qs } from '../dom.js';
import { t } from '../i18n.js';

export function initHeader({ onSearch, onSettings, onTheme, onLocale, onHome }) {
  const logoSlot = qs('#brand-logo');
  if (logoSlot) logoSlot.append(logoMark({ size: 40 }));

  const searchIcon = qs('#icon-search');
  if (searchIcon) searchIcon.append(icon('search', { size: 18 }));
  const settingsIcon = qs('#icon-settings');
  if (settingsIcon) settingsIcon.append(icon('settings', { size: 18 }));
  const themeIcon = qs('#icon-theme');
  if (themeIcon) themeIcon.append(icon('moon', { size: 18 }));

  const searchButton = qs('#btn-search');
  const settingsButton = qs('#btn-settings');
  const themeButton = qs('#btn-theme');
  const brand = qs('#brand');

  searchButton?.addEventListener('click', onSearch);
  settingsButton?.addEventListener('click', onSettings);
  themeButton?.addEventListener('click', onTheme);
  brand?.addEventListener('click', (event) => {
    event.preventDefault();
    onHome?.();
  });

  document.querySelectorAll('[data-lang]').forEach((button) => {
    button.addEventListener('click', () => onLocale(button.dataset.lang));
  });
}

export function syncHeader(state) {
  const searchButton = qs('#btn-search');
  const settingsButton = qs('#btn-settings');
  const themeButton = qs('#btn-theme');
  const brand = qs('#brand');

  if (searchButton) {
    searchButton.setAttribute('aria-label', t('a11y.search'));
    searchButton.setAttribute('data-tooltip', t('header.search'));
  }
  if (settingsButton) {
    settingsButton.setAttribute('aria-label', t('a11y.settings'));
    settingsButton.setAttribute('data-tooltip', t('header.settings'));
  }
  if (themeButton) {
    themeButton.setAttribute('aria-label', t('a11y.theme'));
    themeButton.setAttribute('data-tooltip', t('theme.title'));
    themeButton.setAttribute('aria-pressed', state.resolvedTheme === 'light' ? 'true' : 'false');
    const slot = qs('#icon-theme');
    if (slot) {
      slot.replaceChildren(icon(state.resolvedTheme === 'light' ? 'moon' : 'sun', { size: 18 }));
    }
  }
  if (brand) brand.setAttribute('aria-label', t('a11y.home'));

  document.querySelectorAll('[data-lang]').forEach((button) => {
    const active = button.dataset.lang === state.locale;
    button.classList.toggle('is-active', active);
    button.setAttribute('aria-pressed', active ? 'true' : 'false');
    button.setAttribute('lang', button.dataset.lang);
    button.setAttribute('title', button.dataset.lang === 'ar' ? t('lang.ar') : t('lang.en'));
  });
}
