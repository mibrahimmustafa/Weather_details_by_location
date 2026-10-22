/**
 * Ajwaa service worker — keeps the app shell available when the connection drops.
 *
 * Strategy:
 *  - Navigation: network-first, falling back to the cached shell. A reload while
 *    offline still boots the app, which then shows the last cached city and the
 *    "showing saved data" banner.
 *  - Same-origin assets: cache-first with a background refresh, so updates land
 *    on the next visit without blocking the current one.
 *  - Cross-origin requests (the weather APIs) are never intercepted; the app
 *    owns its own validated payload cache in localStorage.
 *
 * Bump CACHE_VERSION whenever files in PRECACHE change.
 */

const CACHE_VERSION = 'ajwaa-shell-v1';
const SHELL = ['./', './index.html'];
const PRECACHE = [
  ...SHELL,
  './assets/icons/favicon.svg',
  './assets/fonts/ibm-plex-sans-arabic-arabic-300-normal.woff2',
  './assets/fonts/ibm-plex-sans-arabic-arabic-400-normal.woff2',
  './assets/fonts/ibm-plex-sans-arabic-arabic-500-normal.woff2',
  './assets/fonts/ibm-plex-sans-arabic-arabic-600-normal.woff2',
  './assets/fonts/ibm-plex-sans-arabic-arabic-700-normal.woff2',
  './assets/fonts/ibm-plex-sans-arabic-latin-300-normal.woff2',
  './assets/fonts/ibm-plex-sans-arabic-latin-400-normal.woff2',
  './assets/fonts/ibm-plex-sans-arabic-latin-500-normal.woff2',
  './assets/fonts/ibm-plex-sans-arabic-latin-600-normal.woff2',
  './assets/fonts/ibm-plex-sans-arabic-latin-700-normal.woff2',
  './css/tokens.css',
  './css/base.css',
  './css/layout.css',
  './css/atmosphere.css',
  './css/components.css',
  './css/sheets.css',
  './css/motion.css',
  './js/main.js',
  './js/charts.js',
  './js/city.js',
  './js/config.js',
  './js/dom.js',
  './js/format.js',
  './js/i18n.js',
  './js/model.js',
  './js/service.js',
  './js/storage.js',
  './js/store.js',
  './js/api/airquality.js',
  './js/api/forecast.js',
  './js/api/geocoding.js',
  './js/api/http.js',
  './js/api/storms.js',
  './js/components/alerts.js',
  './js/components/cityPicker.js',
  './js/components/daily.js',
  './js/components/details.js',
  './js/components/errorView.js',
  './js/components/footer.js',
  './js/components/header.js',
  './js/components/hero.js',
  './js/components/hourly.js',
  './js/components/icons.js',
  './js/components/infoSheet.js',
  './js/components/rainDust.js',
  './js/components/scene.js',
  './js/components/section.js',
  './js/components/settingsSheet.js',
  './js/components/sheets.js',
  './js/components/skeleton.js',
  './js/components/storms.js',
  './js/components/sunPath.js',
  './js/components/toast.js',
  './js/components/welcome.js',
  './js/domain/alerts.js',
  './js/domain/conditions.js',
  './js/domain/geo.js',
  './js/domain/levels.js',
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_VERSION)
      .then((cache) => cache.addAll(PRECACHE))
      .then(() => self.skipWaiting()),
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(
        keys.filter((key) => key.startsWith('ajwaa-shell-') && key !== CACHE_VERSION)
          .map((key) => caches.delete(key)),
      ))
      .then(() => self.clients.claim()),
  );
});

self.addEventListener('fetch', (event) => {
  const request = event.request;
  if (request.method !== 'GET') return;

  const url = new URL(request.url);
  if (url.origin !== self.location.origin) return;

  if (request.mode === 'navigate') {
    event.respondWith(networkFirstShell(request));
    return;
  }

  event.respondWith(staleWhileRevalidate(request));
});

async function networkFirstShell(request) {
  const cache = await caches.open(CACHE_VERSION);
  try {
    const response = await fetch(request);
    if (response && response.ok) {
      cache.put(new URL('./index.html', self.location.href), response.clone());
    }
    return response;
  } catch (error) {
    const cached = await cache.match('./index.html') || await cache.match('./');
    if (cached) return cached;
    throw error;
  }
}

async function staleWhileRevalidate(request) {
  const cache = await caches.open(CACHE_VERSION);
  const cached = await cache.match(request);
  const network = fetch(request)
    .then((response) => {
      if (response && response.ok) cache.put(request, response.clone());
      return response;
    })
    .catch(() => null);

  if (cached) return cached;
  const response = await network;
  if (response) return response;
  return new Response('', { status: 504, statusText: 'Offline' });
}
