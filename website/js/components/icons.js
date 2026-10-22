/**
 * Inline SVG icons, brand mark and weather glyphs.
 * No icon font, no CDN, no external files — everything is drawn here.
 */
import { svgFromString } from '../dom.js';

const PATHS = {
  search: '<circle cx="11" cy="11" r="7"/><path d="m16.5 16.5 4.5 4.5"/>',
  settings: '<circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.7 1.7 0 0 0 .3 1.9l.1.1a2 2 0 1 1-2.8 2.8l-.1-.1a1.7 1.7 0 0 0-1.9-.3 1.7 1.7 0 0 0-1 1.5V21a2 2 0 1 1-4 0v-.1a1.7 1.7 0 0 0-1.1-1.5 1.7 1.7 0 0 0-1.9.3l-.1.1a2 2 0 1 1-2.8-2.8l.1-.1a1.7 1.7 0 0 0 .3-1.9 1.7 1.7 0 0 0-1.5-1H3a2 2 0 1 1 0-4h.1a1.7 1.7 0 0 0 1.5-1.1 1.7 1.7 0 0 0-.3-1.9l-.1-.1a2 2 0 1 1 2.8-2.8l.1.1a1.7 1.7 0 0 0 1.9.3H9a1.7 1.7 0 0 0 1-1.5V3a2 2 0 1 1 4 0v.1a1.7 1.7 0 0 0 1 1.5 1.7 1.7 0 0 0 1.9-.3l.1-.1a2 2 0 1 1 2.8 2.8l-.1.1a1.7 1.7 0 0 0-.3 1.9V9a1.7 1.7 0 0 0 1.5 1H21a2 2 0 1 1 0 4h-.1a1.7 1.7 0 0 0-1.5 1z"/>',
  refresh: '<path d="M20.5 11a8.5 8.5 0 1 0-.8 4.4"/><path d="M20.5 4.5V11h-6.5"/>',
  location: '<path d="M20 10.2c0 5.8-8 11.8-8 11.8s-8-6-8-11.8a8 8 0 1 1 16 0z"/><circle cx="12" cy="10" r="3"/>',
  chevron: '<path d="m9 18 6-6-6-6"/>',
  close: '<path d="M6 6l12 12M18 6 6 18"/>',
  sun: '<circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4"/>',
  moon: '<path d="M21 12.8A9 9 0 1 1 11.2 3a7 7 0 0 0 9.8 9.8z"/>',
  trash: '<path d="M3 6h18M8 6V4h8v2M6 6l1 14h10l1-14M10 10v6M14 10v6"/>',
  external: '<path d="M14 3h7v7M21 3l-9 9"/><path d="M19 14v5a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V7a2 2 0 0 1 2-2h5"/>',
  info: '<circle cx="12" cy="12" r="9"/><path d="M12 11v5M12 8h.01"/>',
  alert: '<path d="M10.3 3.9 1.8 18a2 2 0 0 0 1.7 3h17a2 2 0 0 0 1.7-3L13.7 3.9a2 2 0 0 0-3.4 0z"/><path d="M12 9v4M12 17h.01"/>',
  wind: '<path d="M3 8h11a3 3 0 1 0-3-3M3 12h15a3 3 0 1 1-3 3M3 16h8a2.5 2.5 0 1 1-2.5 2.5"/>',
  droplet: '<path d="M12 2.7 6.3 8.4a8 8 0 1 0 11.4 0L12 2.7z"/>',
  eye: '<path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12z"/><circle cx="12" cy="12" r="3"/>',
  cloud: '<path d="M17.5 19H6.7A4.7 4.7 0 0 1 6 9.7a6.3 6.3 0 0 1 12.1 1.1 4.1 4.1 0 0 1-.6 8.2z"/>',
  gauge: '<path d="M4.9 19a9 9 0 1 1 14.2 0"/><path d="M12 13l4-4"/><circle cx="12" cy="13" r="1"/>',
  cyclone: '<path d="M12 12c0-3 2.5-5 5.5-4.5C21 8.2 22 12 20 15c-2.4 3.6-7 4.5-10.5 2.5C5.5 15.3 4 11 6 7.5c1.7-3 5.5-4 8.5-2.5"/><circle cx="12" cy="12" r="1.4"/>',
  compass: '<circle cx="12" cy="12" r="9"/><path d="m15.5 8.5-2 5-5 2 2-5 5-2z"/>',
  globe: '<circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3c2.5 2.5 4 5.7 4 9s-1.5 6.5-4 9c-2.5-2.5-4-5.7-4-9s1.5-6.5 4-9z"/>',
  check: '<path d="m4 12.5 5 5L20 6.5"/>',
  arrowDown: '<path d="M12 4v16M6 14l6 6 6-6"/>',
  sparkle: '<path d="M12 3l1.8 5.2L19 10l-5.2 1.8L12 17l-1.8-5.2L5 10l5.2-1.8L12 3z"/>',
  thermometer: '<path d="M14 14.8V5a2 2 0 1 0-4 0v9.8a4 4 0 1 0 4 0z"/>',
  clock: '<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>',
  layers: '<path d="m12 3 9 5-9 5-9-5 9-5z"/><path d="m3 13 9 5 9-5M3 17l9 5 9-5"/>',
  plus: '<path d="M12 5v14M5 12h14"/>',
};

const DIRECTIONAL = new Set(['chevron']);

export function icon(name, { size = 20, className = '', strokeWidth = 1.8 } = {}) {
  const path = PATHS[name] || PATHS.info;
  const directional = DIRECTIONAL.has(name) ? ' icon--directional' : '';
  return svgFromString(`
    <svg class="icon${directional}${className ? ` ${className}` : ''}" width="${size}" height="${size}" viewBox="0 0 24 24"
      fill="none" stroke="currentColor" stroke-width="${strokeWidth}" stroke-linecap="round" stroke-linejoin="round"
      aria-hidden="true" focusable="false">${path}</svg>
  `);
}

export const iconNames = Object.freeze(Object.keys(PATHS));

/* ---------------------------------- logo ---------------------------------- */

let logoCounter = 0;

export function logoMark({ size = 44, mono = false, className = '' } = {}) {
  logoCounter += 1;
  const uid = `ajwaa-logo-${logoCounter}`;
  const sun = mono ? 'currentColor' : `url(#${uid}-sun)`;
  const cloud = mono ? 'currentColor' : `url(#${uid}-cloud)`;
  const drop = mono ? 'currentColor' : `url(#${uid}-drop)`;
  return svgFromString(`
    <svg class="logo-mark${mono ? ' logo-mark--mono' : ''}${className ? ` ${className}` : ''}"
      width="${size}" height="${size}" viewBox="0 0 64 64" role="img" aria-label="Ajwaa">
      <defs>
        <linearGradient id="${uid}-sun" x1="14" y1="8" x2="50" y2="42" gradientUnits="userSpaceOnUse">
          <stop offset="0" stop-color="#FFD08A"/><stop offset="0.55" stop-color="#F2A65A"/><stop offset="1" stop-color="#F08A5D"/>
        </linearGradient>
        <linearGradient id="${uid}-cloud" x1="16" y1="32" x2="48" y2="50" gradientUnits="userSpaceOnUse">
          <stop offset="0" stop-color="#FFFFFF"/><stop offset="1" stop-color="#D9EEF5"/>
        </linearGradient>
        <linearGradient id="${uid}-drop" x1="26" y1="48" x2="38" y2="60" gradientUnits="userSpaceOnUse">
          <stop offset="0" stop-color="#5AB8E8"/><stop offset="1" stop-color="#2E8B7A"/>
        </linearGradient>
      </defs>
      <circle cx="32" cy="25" r="15.5" fill="${sun}" opacity="${mono ? 0.95 : 1}"/>
      <circle cx="32" cy="25" r="11.4" fill="none" stroke="#0B1B33" stroke-opacity="0.18" stroke-width="1.1"/>
      <g stroke="#0B1B33" stroke-width="3" stroke-linecap="round" opacity="0.82">
        <path d="M32 25V15.6"/><path d="M32 25l7.4 4.6"/>
      </g>
      <g fill="#0B1B33" opacity="0.55">
        <circle cx="32" cy="9.6" r="1.25"/><circle cx="47.4" cy="25" r="1.25"/>
        <circle cx="32" cy="40.4" r="1.25"/><circle cx="16.6" cy="25" r="1.25"/>
      </g>
      <path d="M18.5 47.5h26.2a8.3 8.3 0 0 0 1.2-16.5 12.4 12.4 0 0 0-23.5-2.9 9.1 9.1 0 0 0-3.9 19.4Z"
        fill="${cloud}" opacity="${mono ? 0.75 : 1}"/>
      <g fill="${drop}" opacity="${mono ? 0.9 : 1}">
        <path d="M25.6 49.4c-1.6 2.3-2.4 3.8-2.4 5a2.4 2.4 0 0 0 4.8 0c0-1.2-.8-2.7-2.4-5z"/>
        <path d="M36.9 50.6c-1.5 2.2-2.3 3.6-2.3 4.8a2.3 2.3 0 0 0 4.6 0c0-1.2-.8-2.6-2.3-4.8z"/>
      </g>
    </svg>
  `);
}

export function faviconMarkup() {
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
    <defs>
      <linearGradient id="bg" x1="0" y1="0" x2="64" y2="64"><stop stop-color="#16345C"/><stop offset="1" stop-color="#072C33"/></linearGradient>
      <linearGradient id="sun" x1="14" y1="8" x2="50" y2="42"><stop stop-color="#FFD08A"/><stop offset="1" stop-color="#F08A5D"/></linearGradient>
    </defs>
    <rect width="64" height="64" rx="15" fill="url(#bg)"/>
    <circle cx="32" cy="25" r="14" fill="url(#sun)"/>
    <g stroke="#0B1B33" stroke-width="3" stroke-linecap="round" opacity=".8"><path d="M32 25V16"/><path d="M32 25l7 4.4"/></g>
    <path d="M18.5 47.5h26.2a8.3 8.3 0 0 0 1.2-16.5 12.4 12.4 0 0 0-23.5-2.9 9.1 9.1 0 0 0-3.9 19.4Z" fill="#F6FBFE"/>
    <path d="M25.6 49.4c-1.6 2.3-2.4 3.8-2.4 5a2.4 2.4 0 0 0 4.8 0c0-1.2-.8-2.7-2.4-5z" fill="#49B7D8"/>
    <path d="M36.9 50.6c-1.5 2.2-2.3 3.6-2.3 4.8a2.3 2.3 0 0 0 4.6 0c0-1.2-.8-2.6-2.3-4.8z" fill="#2E8B7A"/>
  </svg>`;
}

/* ------------------------------ weather glyph ----------------------------- */

const CLOUD_PATH = 'M19.5 47.5h26a8.6 8.6 0 0 0 1.3-17.1 12.8 12.8 0 0 0-24.2-2.9 9.4 9.4 0 0 0-3.1 20Z';
const CLOUD_SMALL = 'M26 43h18.5a6.2 6.2 0 0 0 .9-12.3 9.2 9.2 0 0 0-17.4-2.1A6.8 6.8 0 0 0 26 43Z';

function rays(cx, cy, inner, outer, count = 8, offset = 0) {
  const lines = [];
  for (let i = 0; i < count; i += 1) {
    const angle = offset + (i * Math.PI * 2) / count;
    const x1 = cx + Math.cos(angle) * inner;
    const y1 = cy + Math.sin(angle) * inner;
    const x2 = cx + Math.cos(angle) * outer;
    const y2 = cy + Math.sin(angle) * outer;
    lines.push(`<line x1="${x1.toFixed(2)}" y1="${y1.toFixed(2)}" x2="${x2.toFixed(2)}" y2="${y2.toFixed(2)}"/>`);
  }
  return `<g class="wg-rays" stroke-linecap="round" stroke-width="2.4">${lines.join('')}</g>`;
}

function drops(xs, y = 50, length = 7) {
  return `<g class="wg-drops" stroke-linecap="round" stroke-width="2.6">${xs.map((x, index) => (
    `<line class="wg-drop" style="animation-delay:${index * 0.22}s" x1="${x}" y1="${y}" x2="${x - 1.4}" y2="${y + length}"/>`
  )).join('')}</g>`;
}

export function weatherGlyph(code, isDay = true, { size = 64, className = '' } = {}) {
  const numeric = Number(code);
  const family = (() => {
    if ([0, 1].includes(numeric)) return 'clear';
    if (numeric === 2) return 'partly';
    if (numeric === 3) return 'cloudy';
    if ([45, 48].includes(numeric)) return 'fog';
    if ([51, 53, 55, 56, 57].includes(numeric)) return 'drizzle';
    if ([61, 63, 65, 66, 67, 80, 81, 82].includes(numeric)) return 'rain';
    if ([71, 73, 75, 77, 85, 86].includes(numeric)) return 'snow';
    if ([95, 96, 99].includes(numeric)) return 'thunder';
    return 'partly';
  })();

  const night = !isDay;
  let body = '';

  if (family === 'clear' && night) {
    body = `
      <circle class="wg-glow" cx="34" cy="30" r="20" opacity="0.16"/>
      <path class="wg-moon" d="M44 14a17 17 0 1 0 8.5 25A14 14 0 0 1 44 14Z"/>
      <g class="wg-stars">
        <circle cx="16" cy="18" r="1.5"/><circle cx="24" cy="36" r="1"/><circle cx="13" cy="40" r="1.2"/>
      </g>`;
  } else if (family === 'clear') {
    body = `<circle class="wg-glow" cx="32" cy="32" r="22" opacity="0.22"/>${rays(32, 32, 17, 23)}<circle class="wg-sun" cx="32" cy="32" r="12"/>`;
  } else if (family === 'partly') {
    body = `
      ${night
    ? '<path class="wg-moon wg-moon--small" d="M43 12a12 12 0 1 0 6 17.5A10 10 0 0 1 43 12Z"/>'
    : `${rays(42, 22, 11, 15)}<circle class="wg-sun wg-sun--small" cx="42" cy="22" r="8"/>`}
      <path class="wg-cloud" d="${CLOUD_PATH}"/>`;
  } else if (family === 'cloudy') {
    body = `<path class="wg-cloud wg-cloud--back" d="${CLOUD_SMALL}" transform="translate(11 0)" opacity=".55"/><path class="wg-cloud" d="${CLOUD_PATH}"/>`;
  } else if (family === 'fog') {
    body = `<path class="wg-cloud" d="${CLOUD_PATH}"/>
      <g class="wg-fog" stroke-linecap="round" stroke-width="2.4">
        <line x1="18" y1="52" x2="46" y2="52"/><line x1="23" y1="57" x2="41" y2="57"/>
      </g>`;
  } else if (family === 'drizzle') {
    body = `<path class="wg-cloud" d="${CLOUD_PATH}"/>${drops([25, 33, 41], 50, 6)}`;
  } else if (family === 'rain') {
    body = `<path class="wg-cloud" d="${CLOUD_PATH}"/>${drops([24, 32, 40], 49, 9)}`;
  } else if (family === 'snow') {
    body = `<path class="wg-cloud" d="${CLOUD_PATH}"/>
      <g class="wg-flakes" stroke-linecap="round" stroke-width="2">
        <g class="wg-flake" transform="translate(24 54)"><path d="M-4 0h8M0 -4v8M-2.8 -2.8l5.6 5.6M2.8 -2.8l-5.6 5.6"/></g>
        <g class="wg-flake" transform="translate(33 58)" style="animation-delay:.5s"><path d="M-4 0h8M0 -4v8M-2.8 -2.8l5.6 5.6M2.8 -2.8l-5.6 5.6"/></g>
        <g class="wg-flake" transform="translate(42 54)" style="animation-delay:1s"><path d="M-4 0h8M0 -4v8M-2.8 -2.8l5.6 5.6M2.8 -2.8l-5.6 5.6"/></g>
      </g>`;
  } else if (family === 'thunder') {
    body = `<path class="wg-cloud" d="${CLOUD_PATH}"/>
      <path class="wg-bolt" d="M34 40 24 55h7l-3 9 12-15h-7l5-9Z"/>
      ${drops([22, 44], 52, 7)}`;
  }

  return svgFromString(`
    <svg class="wglyph wglyph--${family}${night ? ' is-night' : ''}${className ? ` ${className}` : ''}"
      width="${size}" height="${size}" viewBox="0 0 64 64" aria-hidden="true" focusable="false">${body}</svg>
  `);
}
