/**
 * Animated weather scene used as the hero background.
 * Pure DOM + CSS: clouds drift, rain falls, stars twinkle, sun pulses.
 */
import { el } from '../dom.js';

const random = (min, max) => min + Math.random() * (max - min);

function cloud(x, y, scale, duration, delay, opacity) {
  const node = el('div', { class: 'scene__cloud' });
  node.style.setProperty('--x', `${x}%`);
  node.style.setProperty('--y', `${y}%`);
  node.style.setProperty('--s', String(scale));
  node.style.setProperty('--dur', `${duration}s`);
  node.style.setProperty('--delay', `${delay}s`);
  node.style.setProperty('--o', String(opacity));
  node.append(el('span', { class: 'puff puff--a' }), el('span', { class: 'puff puff--b' }), el('span', { class: 'puff puff--c' }));
  return node;
}

export function weatherScene(family = 'clear', isNight = false) {
  const scene = el('div', {
    class: `scene scene--${family}${isNight ? ' is-night' : ''}`,
    'aria-hidden': 'true',
  });

  scene.append(el('div', { class: 'scene__glow' }));

  if (isNight) {
    const stars = el('div', { class: 'scene__stars' });
    for (let i = 0; i < 28; i += 1) {
      const star = el('span', { class: 'scene__star' });
      star.style.setProperty('--x', `${random(2, 98).toFixed(2)}%`);
      star.style.setProperty('--y', `${random(2, 72).toFixed(2)}%`);
      star.style.setProperty('--size', `${random(1, 2.4).toFixed(2)}px`);
      star.style.setProperty('--delay', `${random(0, 4).toFixed(2)}s`);
      star.style.setProperty('--dur', `${random(2.6, 6).toFixed(2)}s`);
      stars.append(star);
    }
    scene.append(stars);
  }

  scene.append(el('div', { class: 'scene__orb' }));

  const config = {
    clear: { count: 1, y: [12, 26], opacity: 0.55, scale: [0.9, 1.15] },
    cloudy: { count: 4, y: [18, 54], opacity: 0.8, scale: [1, 1.5] },
    rain: { count: 4, y: [10, 42], opacity: 0.85, scale: [1, 1.55] },
    storm: { count: 4, y: [8, 40], opacity: 0.9, scale: [1.05, 1.6] },
    snow: { count: 3, y: [12, 40], opacity: 0.8, scale: [0.95, 1.35] },
    fog: { count: 2, y: [30, 50], opacity: 0.55, scale: [1.1, 1.5] },
    night: { count: 1, y: [18, 30], opacity: 0.35, scale: [0.85, 1.05] },
  }[family] || { count: 2, y: [20, 40], opacity: 0.7, scale: [1, 1.3] };

  const clouds = el('div', { class: 'scene__clouds' });
  for (let i = 0; i < config.count; i += 1) {
    clouds.append(cloud(
      random(-12, 72),
      random(config.y[0], config.y[1]),
      random(config.scale[0], config.scale[1]),
      random(48, 95),
      random(-40, 0),
      config.opacity,
    ));
  }
  scene.append(clouds);

  if (family === 'rain' || family === 'storm') {
    const rain = el('div', { class: 'scene__rain' });
    for (let i = 0; i < 22; i += 1) {
      const drop = el('span', { class: 'scene__drop' });
      drop.style.setProperty('--x', `${random(0, 100).toFixed(2)}%`);
      drop.style.setProperty('--delay', `${random(0, 2).toFixed(2)}s`);
      drop.style.setProperty('--dur', `${random(0.65, 1.5).toFixed(2)}s`);
      drop.style.setProperty('--h', `${random(10, 24).toFixed(1)}px`);
      drop.style.setProperty('--o', random(0.25, 0.7).toFixed(2));
      rain.append(drop);
    }
    scene.append(rain);
  }

  if (family === 'snow') {
    const snow = el('div', { class: 'scene__snow' });
    for (let i = 0; i < 24; i += 1) {
      const flake = el('span', { class: 'scene__flake' });
      flake.style.setProperty('--x', `${random(0, 100).toFixed(2)}%`);
      flake.style.setProperty('--delay', `${random(0, 4).toFixed(2)}s`);
      flake.style.setProperty('--dur', `${random(4, 9).toFixed(2)}s`);
      flake.style.setProperty('--size', `${random(2, 5).toFixed(1)}px`);
      flake.style.setProperty('--drift', `${random(-30, 30).toFixed(0)}px`);
      snow.append(flake);
    }
    scene.append(snow);
  }

  if (family === 'fog') {
    scene.append(el('div', { class: 'scene__fog scene__fog--a' }), el('div', { class: 'scene__fog scene__fog--b' }));
  }

  if (family === 'storm') scene.append(el('div', { class: 'scene__flash' }));

  return scene;
}
