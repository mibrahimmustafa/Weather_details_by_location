/**
 * Bootstrap and controller. Owns the loading lifecycle, city switching,
 * settings, geolocation, pull-to-refresh and the live clock, then delegates
 * every pixel of UI to the components in js/components.
 */
import { CACHE, DEFAULT_CITY, LIMITS } from './config.js';
import { applyTranslations, getDir, setLocale, t } from './i18n.js';
import { getState, setState, subscribe } from './store.js';
import * as storage from './storage.js';
import { buildModel, DataError } from './model.js';
import { fetchBundle } from './service.js';
import { ApiError } from './api/http.js';
import { reverseGeocode } from './api/geocoding.js';
import { haversine } from './domain/geo.js';
import { cityName } from './city.js';
import { formatClock, formatDateLine, relativeUpdate, clamp } from './format.js';
import { el, clear } from './dom.js';
import { logoMark } from './components/icons.js';
import { initHeader, syncHeader } from './components/header.js';
import { renderFooter } from './components/footer.js';
import { heroCard } from './components/hero.js';
import { alertsSection } from './components/alerts.js';
import { hourlySection } from './components/hourly.js';
import { rainDustSection } from './components/rainDust.js';
import { detailsSection } from './components/details.js';
import { sunSection } from './components/sunPath.js';
import { stormsSection } from './components/storms.js';
import { dailySection } from './components/daily.js';
import { skeletonView } from './components/skeleton.js';
import { errorView, offlineBanner } from './components/errorView.js';
import { showToast } from './components/toast.js';
import { closeSheet, isSheetOpen } from './components/sheets.js';
import { openCityPicker } from './components/cityPicker.js';
import { openSettings as openSettingsSheet } from './components/settingsSheet.js';
import { openWelcome } from './components/welcome.js';
import { openInfo, openDay, openAlert } from './components/infoSheet.js';

const contentRoot = document.getElementById('app-content');
const bannerRoot = document.getElementById('app-banner');
const footerRoot = document.getElementById('site-footer');
const ptr = document.getElementById('ptr');

let loadToken = 0;
let loadController = null;
let lastLocale = null;
let lastTheme = null;
let welcomeShown = false;

/* -------------------------------------------------------------------------- */
/*                                   boot                                     */
/* -------------------------------------------------------------------------- */

function resolveTheme(mode) {
  if (mode === 'light' || mode === 'dark') return mode;
  return window.matchMedia?.('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
}

function applyTheme(theme) {
  document.documentElement.dataset.theme = theme;
  const meta = document.querySelector('meta[name="theme-color"]');
  if (meta) meta.setAttribute('content', theme === 'dark' ? '#0B1B33' : '#F3F7FB');
}

function applyLocaleDom(state) {
  const html = document.documentElement;
  html.lang = state.locale;
  html.dir = getDir(state.locale);
  html.dataset.locale = state.locale;
  document.title = `${t('app.name')} — ${t('app.tagline')}`;
  const description = document.querySelector('meta[name="description"]');
  if (description) description.setAttribute('content', t('app.description'));
  const ogTitle = document.querySelector('meta[property="og:title"]');
  if (ogTitle) ogTitle.setAttribute('content', `${t('app.name')} — ${t('app.tagline')}`);
  const ogDescription = document.querySelector('meta[property="og:description"]');
  if (ogDescription) ogDescription.setAttribute('content', t('app.description'));
  applyTranslations(document);
}

function onStateChange(state) {
  if (state.locale !== lastLocale) {
    lastLocale = state.locale;
    applyLocaleDom(state);
    renderFooter(footerRoot, { onOpenSettings: openSettingsSheetAction, onTop: scrollTop });
  }
  if (state.resolvedTheme !== lastTheme) {
    lastTheme = state.resolvedTheme;
    applyTheme(state.resolvedTheme);
  }
  syncHeader(state);
  render(state);
}

function setupLoader() {
  const slot = document.getElementById('boot-logo');
  if (slot) slot.append(logoMark({ size: 78 }));
}

function hideLoader(delay = 500) {
  window.setTimeout(() => {
    const boot = document.getElementById('boot-loader');
    document.body.classList.add('is-ready');
    if (!boot) return;
    boot.classList.add('is-hiding');
    window.setTimeout(() => boot.remove(), 620);
  }, delay);
}

function scrollTop() {
  window.scrollTo({ top: 0, behavior: 'smooth' });
}

function init() {
  const settings = storage.readSettings();
  setLocale(settings.localeCode);

  let { cities, selectedId } = storage.readCities();
  cities = storage.ensureDefaultCity(cities);
  if (!selectedId || !cities.some((city) => city.id === selectedId)) selectedId = cities[0].id;
  storage.writeCities(cities, selectedId);

  setState({
    settings,
    locale: settings.localeCode,
    units: settings.unitSystem,
    theme: settings.themeMode,
    resolvedTheme: resolveTheme(settings.themeMode),
    cities,
    selectedId,
    status: 'loading',
  });

  setupLoader();
  initHeader({
    onSearch: openCities,
    onSettings: openSettingsSheetAction,
    onTheme: toggleTheme,
    onLocale: setLanguage,
    onHome: () => window.scrollTo({ top: 0, behavior: 'smooth' }),
  });
  initPullToRefresh();
  initLifecycle();

  applyTheme(getState().resolvedTheme);
  applyLocaleDom(getState());
  renderFooter(footerRoot, { onOpenSettings: openSettingsSheetAction, onTop: scrollTop });
  syncHeader(getState());
  render(getState());
  subscribe(onStateChange);

  hideLoader(600);
  selectCity(selectedId);

  window.setTimeout(maybeWelcome, 1300);
  startClock();
  registerServiceWorker();
}

/**
 * The worker caches the shell so an offline reload can still boot the app and
 * show the last saved forecast. Registration is deliberately late and silent:
 * it must never delay or break the first paint.
 */
function registerServiceWorker() {
  if (!('serviceWorker' in navigator) || !/^https?:$/.test(window.location.protocol)) return;
  navigator.serviceWorker.register('sw.js').catch(() => {
    /* Offline shell is an enhancement; ignore blocked or unsupported setups. */
  });
}

/* -------------------------------------------------------------------------- */
/*                                 rendering                                  */
/* -------------------------------------------------------------------------- */

function render(state) {
  if (!contentRoot) return;
  renderBanner(state);
  renderContent(state);
}

function renderBanner(state) {
  if (!bannerRoot) return;
  clear(bannerRoot);
  if (state.stale && state.model) {
    bannerRoot.append(offlineBanner({ onRetry: () => refresh() }));
  }
}

function renderContent(state) {
  clear(contentRoot);
  contentRoot.setAttribute('aria-busy', !state.model && state.status === 'loading' ? 'true' : 'false');

  if (!state.model) {
    if (state.status === 'error') {
      contentRoot.append(errorView({ kind: state.errorKind || 'unknown', onRetry: () => refresh() }));
    } else {
      contentRoot.append(skeletonView());
    }
    return;
  }

  const model = state.model;
  const units = state.units;
  const nodes = [
    heroCard({
      model,
      units,
      loading: state.loading,
      onOpenCities: openCities,
      onRefresh: () => refresh(),
    }),
    alertsSection({ model, onOpenAlert: (alert) => openAlert({ alert }) }),
    hourlySection({ model, units }),
    rainDustSection({ model, units }),
    detailsSection({ model, units, onOpenInfo: (payload) => openInfo(payload) }),
    sunSection({ model }),
    stormsSection({ model, units, onRetry: () => refresh() }),
    dailySection({ model, units, onOpenDay: (day) => openDay({ model, day, units }) }),
  ].filter(Boolean);

  nodes.forEach((node, index) => {
    node.classList.add('reveal');
    node.style.setProperty('--i', String(index));
    contentRoot.append(node);
  });
}

/* -------------------------------------------------------------------------- */
/*                                   cities                                   */
/* -------------------------------------------------------------------------- */

async function selectCity(cityId, { force = false, silent = false } = {}) {
  const state = getState();
  const city = state.cities.find((item) => item.id === cityId);
  if (!city) return;

  const token = ++loadToken;
  if (loadController) loadController.abort();
  const controller = new AbortController();
  loadController = controller;

  const switching = state.selectedId !== cityId || !state.model || state.model.city?.id !== cityId;
  const cached = storage.readCache(cityId);
  const fresh = !force && storage.isCacheFresh(cached, city, Date.now());

  storage.writeCities(state.cities, cityId);

  if (switching) {
    setState({
      selectedId: cityId,
      model: null,
      bundle: null,
      status: 'loading',
      loading: true,
      stale: false,
      errorKind: null,
    });
  } else {
    setState({ selectedId: cityId, loading: !fresh, errorKind: null });
  }

  if (cached && (fresh || switching)) {
    try {
      const cachedModel = buildModel(city, { ...cached, stale: !fresh }, getState().units);
      if (token !== loadToken) return;
      updateCityTimezone(city.id, cachedModel.timezone);
      setState({
        model: cachedModel,
        bundle: { ...cached, stale: !fresh },
        status: 'ready',
        stale: !fresh,
        loading: !fresh,
      });
    } catch {
      /* A corrupted cache is ignored; the network path below will fill in. */
    }
  }

  if (fresh) {
    setState({ loading: false, stale: false });
    return;
  }

  try {
    const bundle = await fetchBundle(city, { signal: controller.signal });
    if (token !== loadToken) return;
    storage.writeCache(city.id, bundle);
    const model = buildModel(city, bundle, getState().units);
    updateCityTimezone(city.id, model.timezone);
    setState({
      model,
      bundle,
      status: 'ready',
      stale: false,
      loading: false,
      errorKind: null,
      updatedAt: bundle.fetchedAt,
    });
    if (!silent && !switching) showToast(t('toast.refreshed'));
  } catch (error) {
    if (token !== loadToken) return;
    if (error?.kind === 'abort' || controller.signal.aborted) return;
    const kind = mapError(error);
    if (getState().model) {
      setState({ loading: false, stale: true, errorKind: kind });
      if (!silent) showToast(t('toast.offline'), { tone: 'error' });
    } else {
      setState({ status: 'error', loading: false, stale: false, errorKind: kind, model: null });
    }
  } finally {
    if (token === loadToken) loadController = null;
  }
}

function updateCityTimezone(cityId, timezone) {
  if (!timezone) return;
  const state = getState();
  const city = state.cities.find((item) => item.id === cityId);
  if (!city || city.timezone === timezone) return;
  const cities = state.cities.map((item) => (item.id === cityId ? { ...item, timezone } : item));
  storage.writeCities(cities, state.selectedId);
  setState({ cities });
}

function addCity(rawCity) {
  const state = getState();
  const city = storage.sanitizeCity(rawCity);
  if (!city) return null;

  const existing = state.cities.find((saved) => saved.id === city.id
    || haversine(saved.latitude, saved.longitude, city.latitude, city.longitude) < 2);
  if (existing) {
    if (existing.id !== state.selectedId) selectCity(existing.id);
    showToast(t('sheet.city.exists', { city: cityName(existing) }));
    return existing;
  }

  let cities = [...state.cities, city];
  if (cities.length > LIMITS.savedCities) {
    const removable = cities.find((item) => item.id !== state.selectedId) || cities[0];
    cities = cities.filter((item) => item.id !== removable.id);
    storage.safeRemove(storage.cacheKey(removable.id));
  }

  storage.writeCities(cities, city.id);
  setState({ cities, selectedId: city.id });
  selectCity(city.id);
  showToast(t('sheet.city.added', { city: cityName(city) }));
  return city;
}

function removeCity(city) {
  const state = getState();
  const remaining = state.cities.filter((item) => item.id !== city.id);
  const nextCities = remaining.length > 0 ? remaining : [{ ...DEFAULT_CITY }];
  const wasSelected = state.selectedId === city.id;
  const nextSelected = wasSelected ? nextCities[0].id : state.selectedId;

  storage.safeRemove(storage.cacheKey(city.id));
  storage.writeCities(nextCities, nextSelected);
  setState({
    cities: nextCities,
    selectedId: nextSelected,
    ...(wasSelected ? { model: null, bundle: null, status: 'loading' } : {}),
  });
  showToast(t('toast.removed', { city: cityName(city) }));

  if (wasSelected) selectCity(nextSelected);
  return nextCities;
}

function openCities() {
  if (isSheetOpen()) closeSheet({ immediate: true, silent: true });
  const state = getState();
  openCityPicker({
    cities: state.cities,
    selectedId: state.selectedId,
    locale: state.locale,
    onPick: (city) => addCity(city),
    onLocate: () => requestLocation(),
    onDelete: (city) => removeCity(city),
  });
}

/* -------------------------------------------------------------------------- */
/*                                geolocation                                 */
/* -------------------------------------------------------------------------- */

function requestLocation() {
  return new Promise((resolve) => {
    if (!navigator.geolocation) {
      showToast(t('sheet.city.geoUnsupported'), { tone: 'error' });
      resolve(null);
      return;
    }

    setState({ geoStatus: 'locating' });
    navigator.geolocation.getCurrentPosition(async (position) => {
      const latitude = Number(position.coords.latitude.toFixed(4));
      const longitude = Number(position.coords.longitude.toFixed(4));
      const info = await reverseGeocode(latitude, longitude, getState().locale);
      const name = info?.name || t('sheet.city.myLocation');
      const state = getState();
      const nearby = state.cities.find((city) => city.source === 'geo'
        && haversine(city.latitude, city.longitude, latitude, longitude) < 5);

      if (nearby) {
        const updated = {
          ...nearby,
          latitude,
          longitude,
          ...(info?.name ? { name: info.name } : {}),
          ...(info?.country ? { country: info.country, countryEn: info.country } : {}),
          ...(info?.countryCode ? { countryCode: info.countryCode } : {}),
          ...(info?.admin1 ? { admin1: info.admin1 } : {}),
        };
        const cities = state.cities.map((city) => (city.id === nearby.id ? updated : city));
        storage.writeCities(cities, updated.id);
        setState({ cities, selectedId: updated.id, geoStatus: 'granted' });
        selectCity(updated.id, { force: true });
        resolve(updated);
        return;
      }

      const city = {
        id: `geo-${latitude.toFixed(2)}-${longitude.toFixed(2)}`,
        name,
        nameEn: name,
        country: info?.country || '',
        countryEn: info?.country || '',
        countryCode: info?.countryCode || '',
        admin1: info?.admin1 || '',
        latitude,
        longitude,
        timezone: Intl.DateTimeFormat().resolvedOptions().timeZone || 'UTC',
        source: 'geo',
      };
      setState({ geoStatus: 'granted' });
      const saved = addCity(city);
      if (!info?.name) showToast(t('sheet.city.geoNoCity'));
      resolve(saved);
    }, (error) => {
      setState({ geoStatus: error.code === 1 ? 'denied' : 'error' });
      showToast(error.code === 1 ? t('sheet.city.geoDenied') : t('sheet.city.geoFailed'), { tone: 'error' });
      resolve(null);
    }, { enableHighAccuracy: false, timeout: 14_000, maximumAge: 5 * 60 * 1000 });
  });
}

/* -------------------------------------------------------------------------- */
/*                                 settings                                   */
/* -------------------------------------------------------------------------- */

function changeSettings(patch) {
  const state = getState();
  const next = { ...(state.settings || storage.defaultSettings()), ...patch };
  const localeChanged = Boolean(patch.localeCode && patch.localeCode !== state.locale);

  if (localeChanged) {
    setLocale(next.localeCode);
    closeSheet({ immediate: true, silent: true });
  }
  storage.writeSettings(next);

  let model = state.model;
  const unitsChanged = Boolean(patch.unitSystem && patch.unitSystem !== state.units);
  if ((unitsChanged || localeChanged) && state.bundle && state.model) {
    try {
      model = buildModel(state.model.city, state.bundle, next.unitSystem);
    } catch {
      /* keep the current model if the cached payload is not parseable */
    }
  }

  setState({
    settings: next,
    locale: next.localeCode,
    units: next.unitSystem,
    theme: next.themeMode,
    resolvedTheme: resolveTheme(next.themeMode),
    model,
  });
}

function toggleTheme() {
  const state = getState();
  changeSettings({ themeMode: state.resolvedTheme === 'dark' ? 'light' : 'dark' });
}

function setLanguage(locale) {
  if (locale === getState().locale) return;
  changeSettings({ localeCode: locale === 'en' ? 'en' : 'ar' });
}

function openSettingsSheetAction() {
  if (isSheetOpen()) closeSheet({ immediate: true, silent: true });
  openSettingsSheet({
    settings: getState().settings,
    onChange: changeSettings,
    onReset: resetPreferences,
  });
}

function resetPreferences() {
  storage.resetPreferences();
  const defaults = storage.defaultSettings();
  setLocale(defaults.localeCode);
  storage.writeSettings(defaults);
  closeSheet({ immediate: true, silent: true });

  let model = getState().model;
  if (getState().bundle) {
    try {
      model = buildModel(getState().model.city, getState().bundle, defaults.unitSystem);
    } catch {
      model = null;
    }
  }

  setState({
    settings: defaults,
    locale: defaults.localeCode,
    units: defaults.unitSystem,
    theme: defaults.themeMode,
    resolvedTheme: resolveTheme(defaults.themeMode),
    model,
  });
  showToast(t('sheet.settings.resetDone'));
  if (getState().selectedId) selectCity(getState().selectedId, { force: true, silent: true });
}

function markWelcomeSeen() {
  const state = getState();
  const settings = { ...(state.settings || storage.defaultSettings()), hasSeenWelcome: true };
  storage.writeSettings(settings);
  storage.writeOnboardingSeen();
  setState({ settings });
}

function maybeWelcome() {
  if (welcomeShown) return;
  const state = getState();
  if (!state.settings) return;
  if (state.settings.hasSeenWelcome || storage.readOnboardingSeen()) return;
  welcomeShown = true;
  openWelcome({
    onAllow: () => {
      markWelcomeSeen();
      requestLocation();
    },
    onChoose: () => {
      markWelcomeSeen();
      openCities();
    },
    onLater: markWelcomeSeen,
  });
}

/* -------------------------------------------------------------------------- */
/*                                  refresh                                   */
/* -------------------------------------------------------------------------- */

function refresh({ silent = false } = {}) {
  const state = getState();
  if (!state.selectedId) return;
  selectCity(state.selectedId, { force: true, silent });
}

function mapError(error) {
  if (error instanceof DataError) return 'data';
  if (error instanceof ApiError) {
    if (error.kind === 'timeout') return 'timeout';
    if (error.kind === 'network') return 'network';
    if (error.kind === 'server' || error.kind === 'http') return 'server';
    if (error.kind === 'data') return 'data';
  }
  return 'unknown';
}

/* -------------------------------------------------------------------------- */
/*                                   clock                                    */
/* -------------------------------------------------------------------------- */

function updateSunPosition() {
  const state = getState();
  const model = state.model;
  const svg = document.querySelector('.sunarc');
  if (!svg || !model || model.sun.riseMinutes == null || model.sun.setMinutes == null) return;
  const { riseMinutes, setMinutes } = model.sun;
  if (setMinutes <= riseMinutes) return;

  const shifted = new Date(Date.now() + (model.utcOffsetSeconds || 0) * 1000);
  const minutes = shifted.getUTCHours() * 60 + shifted.getUTCMinutes();
  const progress = clamp((minutes - riseMinutes) / (setMinutes - riseMinutes), 0, 1);
  const angle = Math.PI * (1 - progress);
  const x = 80 + 64 * Math.cos(angle);
  const y = 88 - 64 * Math.sin(angle);

  const path = svg.querySelector('.sunarc__progress');
  if (path) path.setAttribute('stroke-dasharray', `${(progress * 100).toFixed(2)} 100`);
  svg.querySelectorAll('.sunarc__sun, .sunarc__halo').forEach((circle) => {
    circle.setAttribute('cx', x.toFixed(2));
    circle.setAttribute('cy', y.toFixed(2));
  });

  const label = document.getElementById('sun-now-label');
  if (label) {
    const span = label.lastElementChild;
    const text = `${t('sun.now')} · ${formatClock(new Date(), model.timezone).slice(0, 5)}`;
    if (span && span.textContent !== text) span.textContent = text;
  }
}

function updateClock() {
  const state = getState();
  if (!state.model) return;
  const now = new Date();
  const clock = document.getElementById('live-clock');
  if (clock) {
    const text = formatClock(now, state.model.timezone);
    if (clock.textContent !== text) clock.textContent = text;
    clock.setAttribute('datetime', now.toISOString());
  }
  const date = document.getElementById('hero-date');
  if (date) {
    const text = formatDateLine(now, state.model.timezone);
    if (date.textContent !== text) date.textContent = text;
  }
  const updated = document.getElementById('hero-updated');
  if (updated) {
    const text = relativeUpdate(state.model.fetchedAt);
    if (updated.textContent !== text) updated.textContent = text;
  }
  updateSunPosition();
}

function startClock() {
  updateClock();
  window.setInterval(updateClock, 1000);
}

/* -------------------------------------------------------------------------- */
/*                             lifecycle & gestures                           */
/* -------------------------------------------------------------------------- */

function initLifecycle() {
  const media = window.matchMedia?.('(prefers-color-scheme: dark)');
  media?.addEventListener?.('change', () => {
    if (getState().settings?.themeMode === 'system') {
      setState({ resolvedTheme: resolveTheme('system') });
    }
  });

  window.setInterval(() => {
    const state = getState();
    if (document.visibilityState !== 'visible') return;
    if (!state.model || state.loading || isSheetOpen()) return;
    if (Date.now() - state.model.fetchedAt > CACHE.autoRefreshMs) {
      selectCity(state.selectedId, { force: true, silent: true });
    }
  }, 60_000);

  document.addEventListener('visibilitychange', () => {
    if (document.visibilityState !== 'visible') return;
    const state = getState();
    if (state.model && Date.now() - state.model.fetchedAt > CACHE.autoRefreshMs && !state.loading) {
      selectCity(state.selectedId, { force: true, silent: true });
    }
  });

  window.addEventListener('online', () => {
    const state = getState();
    if (state.stale || (state.model && Date.now() - state.model.fetchedAt > CACHE.ttlMs)) {
      refresh({ silent: true });
    }
  });

  window.addEventListener('offline', () => {
    if (getState().model) showToast(t('toast.offline'), { tone: 'error' });
  });

  window.addEventListener('keydown', (event) => {
    if (event.key === '/' && !isSheetOpen()) {
      const target = document.activeElement;
      const typing = target && /^(INPUT|TEXTAREA|SELECT)$/.test(target.tagName);
      if (!typing) {
        event.preventDefault();
        openCities();
      }
    }
  });
}

function initPullToRefresh() {
  if (!ptr) return;
  let startY = null;
  let distance = 0;
  let active = false;

  document.addEventListener('touchstart', (event) => {
    if (event.touches.length !== 1 || window.scrollY > 0 || isSheetOpen()) return;
    startY = event.touches[0].clientY;
    distance = 0;
    active = false;
  }, { passive: true });

  document.addEventListener('touchmove', (event) => {
    if (startY == null) return;
    const delta = event.touches[0].clientY - startY;
    if (delta <= 0) return;
    distance = Math.min(96, delta * 0.5);
    active = distance > 8;
    ptr.classList.toggle('is-visible', active);
    ptr.style.setProperty('--pull', `${distance}px`);
    ptr.style.setProperty('--ptr-angle', `${Math.round(distance * 2.4)}deg`);
    if (event.cancelable && delta > 8) event.preventDefault();
  }, { passive: false });

  const finish = () => {
    if (startY == null) return;
    const shouldRefresh = active && distance > 58;
    ptr.classList.remove('is-visible');
    ptr.style.setProperty('--pull', '0px');
    ptr.style.setProperty('--ptr-angle', '0deg');
    startY = null;
    distance = 0;
    active = false;
    if (shouldRefresh && !getState().loading) refresh();
  };

  document.addEventListener('touchend', finish, { passive: true });
  document.addEventListener('touchcancel', finish, { passive: true });
}

/* -------------------------------------------------------------------------- */

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', init, { once: true });
} else {
  init();
}
