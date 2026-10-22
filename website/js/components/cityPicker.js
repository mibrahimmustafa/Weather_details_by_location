/** City picker sheet: geolocation, saved cities (swipe to delete), popular, search. */
import { el, clear } from '../dom.js';
import { icon } from './icons.js';
import { t } from '../i18n.js';
import { cityName, countryName, cityContext } from '../city.js';
import { POPULAR_CITIES } from '../config.js';
import { searchCities } from '../api/geocoding.js';
import { openSheet } from './sheets.js';

export function openCityPicker({
  cities,
  selectedId,
  locale,
  onPick,
  onLocate,
  onDelete,
}) {
  let list = [...cities];
  let searchTimer = null;
  let searchController = null;
  let sheet = null;

  const input = el('input', {
    class: 'search-field__input',
    type: 'search',
    id: 'city-search-input',
    placeholder: t('sheet.city.search'),
    autocomplete: 'off',
    spellcheck: 'false',
    'aria-label': t('sheet.city.search'),
  });

  const clearButton = el('button', {
    class: 'search-field__clear',
    type: 'button',
    hidden: true,
    'aria-label': t('a11y.clearSearch'),
    onclick: () => {
      input.value = '';
      clearButton.hidden = true;
      resultsWrap.hidden = true;
      savedBlock.hidden = false;
      popularBlock.hidden = false;
      input.focus();
    },
  }, icon('close', { size: 15 }));

  const searchField = el('div', { class: 'search-field' },
    icon('search', { size: 18 }),
    input,
    clearButton,
  );

  const locateButton = el('button', {
    class: 'locate-btn',
    type: 'button',
    onclick: async () => {
      if (locateButton.disabled) return;
      setLocating(true);
      const city = await onLocate();
      setLocating(false);
      if (city) sheet?.close();
    },
  },
  el('span', { class: 'locate-btn__icon' }, icon('location', { size: 18 })),
  el('span', { class: 'locate-btn__text' },
    el('strong', { text: t('sheet.city.current') }),
    el('span', { text: t('sheet.city.currentHint') }),
  ),
  el('span', { class: 'locate-btn__arrow' }, icon('chevron', { size: 16 })),
  );

  function setLocating(locating) {
    locateButton.disabled = locating;
    locateButton.classList.toggle('is-loading', locating);
    const strong = locateButton.querySelector('.locate-btn__text strong');
    if (strong) strong.textContent = locating ? t('sheet.city.locating') : t('sheet.city.current');
  }

  const savedWrap = el('div', { class: 'city-list' });
  const savedBlock = el('section', { class: 'picker-block' },
    el('div', { class: 'picker-block__head' },
      el('h3', { text: t('sheet.city.saved') }),
      el('span', { class: 'picker-block__hint', text: t('sheet.city.swipe') }),
    ),
    savedWrap,
  );

  function isSaved(city) {
    return list.some((saved) => saved.id === city.id
      || (Math.abs(saved.latitude - city.latitude) < 0.02 && Math.abs(saved.longitude - city.longitude) < 0.02));
  }

  function renderSaved() {
    clear(savedWrap);
    if (list.length === 0) {
      savedWrap.append(el('p', { class: 'picker-empty', text: t('sheet.city.empty') }));
      return;
    }
    list.forEach((city) => {
      savedWrap.append(savedRow(city));
    });
  }

  function savedRow(city) {
    const selected = city.id === selectedId;
    const name = cityName(city, locale);
    const row = el('div', { class: 'city-row' });
    const main = el('button', {
      class: `city-row__main${selected ? ' is-selected' : ''}`,
      type: 'button',
      'aria-label': t('a11y.selectCity', { city: name }),
      onclick: (event) => {
        if (row.dataset.dragged === '1') {
          event.preventDefault();
          row.dataset.dragged = '0';
          return;
        }
        onPick(city);
        sheet?.close();
      },
    },
    el('span', { class: 'city-row__code', text: city.countryCode || '—' }),
    el('span', { class: 'city-row__text' },
      el('span', { class: 'city-row__name', text: name }),
      el('span', { class: 'city-row__meta', text: cityContext(city, locale) || countryName(city, locale) }),
    ),
    selected ? el('span', { class: 'city-row__check' }, icon('check', { size: 15 })) : null,
    );

    const del = el('button', {
      class: 'city-row__delete',
      type: 'button',
      'aria-label': t('a11y.removeCity', { city: name }),
      title: t('sheet.city.remove'),
      onclick: () => {
        const updated = onDelete(city);
        if (Array.isArray(updated)) list = updated;
        renderSaved();
      },
    }, icon('trash', { size: 16 }));

    // Swipe left to delete (pointer/touch only; the delete button stays for keyboards).
    let startX = null;
    let dx = 0;
    main.addEventListener('pointerdown', (event) => {
      if (event.pointerType === 'mouse') return;
      startX = event.clientX;
      dx = 0;
      row.dataset.dragged = '0';
    });
    main.addEventListener('pointermove', (event) => {
      if (startX == null) return;
      dx = event.clientX - startX;
      if (dx < 0) {
        row.style.transform = `translateX(${Math.max(dx, -120)}px)`;
        if (dx < -8) row.dataset.dragged = '1';
      }
    });
    const finishSwipe = () => {
      if (startX == null) return;
      row.style.transform = '';
      if (dx < -84) {
        const updated = onDelete(city);
        if (Array.isArray(updated)) list = updated;
        renderSaved();
      }
      setTimeout(() => {
        row.dataset.dragged = '0';
        startX = null;
        dx = 0;
      }, 40);
    };
    main.addEventListener('pointerup', finishSwipe);
    main.addEventListener('pointercancel', finishSwipe);

    row.append(main, del);
    return row;
  }

  renderSaved();

  const popularBlock = el('section', { class: 'picker-block' },
    el('h3', { text: t('sheet.city.popular') }),
    el('div', { class: 'chips chips--wrap' },
      POPULAR_CITIES.map((city) => el('button', {
        class: 'chip chip--button',
        type: 'button',
        onclick: () => {
          onPick(city);
          sheet?.close();
        },
      }, icon('plus', { size: 12 }), el('span', { text: cityName(city, locale) }))),
    ),
  );

  const resultsHead = el('h3', { class: 'picker-results__title', text: t('sheet.city.results') });
  const results = el('div', { class: 'city-list', 'aria-live': 'polite' });
  const resultsWrap = el('section', { class: 'picker-block picker-block--results', hidden: true },
    resultsHead, results);

  function renderResults(items, message = '') {
    clear(results);
    if (message) {
      results.append(el('p', { class: 'picker-empty', text: message }));
      return;
    }
    if (items.length === 0) {
      results.append(el('div', { class: 'picker-empty' },
        el('strong', { text: t('sheet.city.noResults') }),
        el('span', { text: t('sheet.city.noResultsHint') }),
      ));
      return;
    }
    items.forEach((city) => {
      results.append(el('button', {
        class: 'city-result',
        type: 'button',
        onclick: () => {
          onPick(city);
          sheet?.close();
        },
      },
      el('span', { class: 'city-row__code', text: city.countryCode || '—' }),
      el('span', { class: 'city-result__text' },
        el('span', { class: 'city-result__name', text: cityName(city, locale) }),
        el('span', { class: 'city-result__meta', text: cityContext(city, locale) }),
      ),
      isSaved(city)
        ? el('span', { class: 'city-row__check' }, icon('check', { size: 15 }))
        : el('span', { class: 'city-result__add' }, icon('plus', { size: 15 })),
      ));
    });
  }

  input.addEventListener('input', () => {
    const query = input.value.trim();
    clearButton.hidden = query.length === 0;
    clearTimeout(searchTimer);
    searchController?.abort();

    if (query.length < 2) {
      resultsWrap.hidden = true;
      savedBlock.hidden = false;
      popularBlock.hidden = false;
      return;
    }

    savedBlock.hidden = true;
    popularBlock.hidden = true;
    resultsWrap.hidden = false;
    resultsHead.textContent = t('sheet.city.results');
    renderResults([], t('sheet.city.searching'));

    searchTimer = setTimeout(async () => {
      const controller = new AbortController();
      searchController = controller;
      try {
        const found = await searchCities(query, locale, { signal: controller.signal });
        if (input.value.trim() !== query) return;
        renderResults(found);
      } catch (error) {
        if (error?.kind === 'abort') return;
        if (input.value.trim() !== query) return;
        renderResults([], t('errors.network'));
      }
    }, 380);
  });

  input.addEventListener('keydown', (event) => {
    if (event.key === 'Enter') {
      const first = results.querySelector('.city-result');
      if (first) first.click();
    }
  });

  input.addEventListener('search', () => {
    if (!input.value) clearButton.click();
  });

  const content = el('div', { class: 'city-picker' },
    searchField,
    locateButton,
    savedBlock,
    popularBlock,
    resultsWrap,
  );

  sheet = openSheet({
    title: t('sheet.city.title'),
    subtitle: t('sheet.city.subtitle'),
    content,
    className: 'sheet--cities',
    initialFocus: input,
    onClose: () => {
      clearTimeout(searchTimer);
      searchController?.abort();
    },
  });

  // Keep the search field from auto-zooming on iOS while still allowing focus.
  input.setAttribute('enterkeyhint', 'search');
  return sheet;
}
