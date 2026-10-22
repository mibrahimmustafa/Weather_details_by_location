/**
 * Hand-drawn SVG charts: no chart library, no canvas dependency, crisp on
 * every pixel density and readable by screen readers.
 */
import { el, svgFromString } from './dom.js';

let gradientCounter = 0;

function smoothPath(points) {
  if (points.length === 0) return '';
  if (points.length === 1) return `M${points[0].x},${points[0].y}`;
  let path = `M${points[0].x.toFixed(2)},${points[0].y.toFixed(2)}`;
  for (let i = 1; i < points.length; i += 1) {
    const prev = points[i - 1];
    const current = points[i];
    const midX = (prev.x + current.x) / 2;
    path += ` C${midX.toFixed(2)},${prev.y.toFixed(2)} ${midX.toFixed(2)},${current.y.toFixed(2)} ${current.x.toFixed(2)},${current.y.toFixed(2)}`;
  }
  return path;
}

/**
 * Dust / PM area chart.
 * @param {number[]} values
 * @param {{label?: string, height?: number}} options
 */
export function areaChart(values, { label = '', height = 110 } = {}) {
  const clean = values.filter((value) => Number.isFinite(Number(value))).map(Number);
  if (clean.length < 2) {
    return el('div', { class: 'chart-empty', text: '—' });
  }
  gradientCounter += 1;
  const id = `grad-${gradientCounter}`;
  const width = 360;
  const padding = 8;
  const bottom = height - padding;
  const max = Math.max(...clean);
  const min = Math.min(...clean);
  const span = max - min || 1;
  const points = clean.map((value, index) => ({
    x: padding + (index / (clean.length - 1)) * (width - padding * 2),
    y: bottom - ((value - min) / span) * (height - padding * 2 - 8),
  }));
  const line = smoothPath(points);
  const area = `${line} L${points[points.length - 1].x.toFixed(2)},${bottom} L${points[0].x.toFixed(2)},${bottom} Z`;
  const last = points[points.length - 1];

  const svg = svgFromString(`
    <svg class="chart chart--area" viewBox="0 0 ${width} ${height}" width="100%" height="${height}"
      preserveAspectRatio="none" role="img" aria-label="${escapeAttribute(label)}">
      <defs>
        <linearGradient id="${id}" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0" stop-color="var(--chart-line)" stop-opacity="0.45"/>
          <stop offset="1" stop-color="var(--chart-line)" stop-opacity="0"/>
        </linearGradient>
      </defs>
      <g class="chart__grid" aria-hidden="true">
        <line x1="0" y1="${height * 0.25}" x2="${width}" y2="${height * 0.25}"/>
        <line x1="0" y1="${height * 0.5}" x2="${width}" y2="${height * 0.5}"/>
        <line x1="0" y1="${height * 0.75}" x2="${width}" y2="${height * 0.75}"/>
      </g>
      <path d="${area}" fill="url(#${id})"/>
      <path d="${line}" class="chart__line" fill="none" vector-effect="non-scaling-stroke"/>
      <circle cx="${last.x.toFixed(2)}" cy="${last.y.toFixed(2)}" r="3.2" class="chart__dot"/>
    </svg>
  `);
  return svg;
}

/** Weekly temperature range bar, normalized across the whole week. */
export function rangeBar(min, max, weekMin, weekMax) {
  const lo = Number.isFinite(Number(min)) ? Number(min) : 0;
  const hi = Number.isFinite(Number(max)) ? Number(max) : lo;
  const span = Math.max(1, Number(weekMax) - Number(weekMin));
  const left = ((lo - Number(weekMin)) / span) * 100;
  const width = Math.max(5, ((hi - lo) / span) * 100);
  return el('div', {
    class: 'range',
    role: 'img',
    'aria-label': `${round(lo)}° – ${round(hi)}°`,
  }, el('span', {
    class: 'range__fill',
    style: {
      insetInlineStart: `${clamp(left, 0, 95)}%`,
      width: `${clamp(width, 5, 100 - clamp(left, 0, 95))}%`,
    },
  }));
}

/** Sun path arc with a glowing marker at the current position. */
export function sunArc(progress, state = 'up') {
  const p = clamp(Number(progress) || 0, 0, 1);
  const cx = 80;
  const cy = 88;
  const r = 64;
  const angle = Math.PI * (1 - p);
  const x = cx + r * Math.cos(angle);
  const y = cy - r * Math.sin(angle);
  const svg = svgFromString(`
    <svg class="sunarc${state === 'up' ? '' : ' is-down'}" viewBox="0 0 160 104" width="100%" role="img" aria-hidden="true" focusable="false">
      <line class="sunarc__horizon" x1="6" y1="88" x2="154" y2="88"/>
      <path class="sunarc__track" d="M16 88 A64 64 0 0 1 144 88" pathLength="100"/>
      <path class="sunarc__progress" d="M16 88 A64 64 0 0 1 144 88" pathLength="100"
        stroke-dasharray="${(p * 100).toFixed(2)} 100"/>
      <circle class="sunarc__halo" cx="${x.toFixed(2)}" cy="${y.toFixed(2)}" r="11"/>
      <circle class="sunarc__sun" cx="${x.toFixed(2)}" cy="${y.toFixed(2)}" r="5"/>
      <g class="sunarc__ticks">
        <line x1="16" y1="88" x2="16" y2="94"/><line x1="144" y1="88" x2="144" y2="94"/>
      </g>
    </svg>
  `);
  return svg;
}

function clamp(value, min, max) {
  return Math.min(max, Math.max(min, value));
}

function round(value) {
  return Math.round(Number(value) || 0);
}

function escapeAttribute(value) {
  return String(value).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}
