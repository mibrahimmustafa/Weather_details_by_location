/** Rain and dust: the two signature readings of Ajwaa. */
import { el } from '../dom.js';
import { icon } from './icons.js';
import { sectionShell } from './section.js';
import { t } from '../i18n.js';
import { areaChart } from '../charts.js';
import { num, precipValue, precipUnit, formatPrecip } from '../format.js';

export function rainDustSection({ model, units }) {
  const dustCard = buildDustCard(model);
  const rainCard = buildRainCard(model, units);
  return sectionShell({
    id: 'rain-dust',
    title: t('section.rainDust'),
    iconName: 'droplet',
    className: 'section--split',
    body: el('div', { class: 'split' }, dustCard, rainCard),
  });
}

function buildDustCard(model) {
  const { current, dustSeries } = model;
  const hasDust = Number.isFinite(Number(current.dust));
  const level = current.dustLevel;
  const levelLabel = level ? t(`dust.${level}`) : t('misc.na');

  const header = el('div', { class: 'card__head' },
    el('div', { class: 'card__title-wrap' },
      el('span', { class: 'card__icon card__icon--dust' }, icon('wind', { size: 18 })),
      el('div', {},
        el('h3', { class: 'card__title', text: t('dust.title') }),
        el('p', { class: 'card__eyebrow', text: t('dust.value') }),
      ),
    ),
    el('span', { class: `level level--dust-${level || 'none'}`, text: levelLabel }),
  );

  const reading = el('div', { class: 'metric' },
    el('span', { class: 'metric__value', text: hasDust ? num(current.dust) : t('misc.na') }),
    el('span', { class: 'metric__unit', text: t('misc.ugm3') }),
  );

  const advice = el('p', {
    class: 'card__advice',
    text: hasDust && level ? t(`dust.advice.${level}`) : t('dust.noData'),
  });

  const chart = el('div', { class: 'chart-block' },
    el('div', { class: 'chart-block__head' },
      el('span', { text: t('dust.chart') }),
      el('span', { class: 'chart-block__badge', text: t('dust.level') }),
    ),
    areaChart(dustSeries, { label: t('dust.chart'), height: 104 }),
  );

  const chips = el('div', { class: 'chips' },
    current.aqi != null ? el('span', { class: `chip chip--aqi level--aqi-${current.aqiLevel}` },
      el('span', { class: 'chip__label', text: t('dust.aqi') }),
      el('strong', { text: num(current.aqi) }),
      el('span', { class: 'chip__sub', text: t(`aqi.${current.aqiLevel}`) }),
    ) : null,
    current.pm25 != null ? el('span', { class: 'chip' },
      el('span', { class: 'chip__label', text: t('dust.pm25') }),
      el('strong', { text: num(current.pm25, 1) }),
      el('span', { class: 'chip__sub', text: t('misc.ugm3') }),
    ) : null,
    current.pm10 != null ? el('span', { class: 'chip' },
      el('span', { class: 'chip__label', text: t('dust.pm10') }),
      el('strong', { text: num(current.pm10, 1) }),
      el('span', { class: 'chip__sub', text: t('misc.ugm3') }),
    ) : null,
  );

  return el('article', { class: 'card dust-card' }, header, reading,
    el('p', { class: 'card__label', text: t('dust.health') }), advice, chart, chips);
}

function buildRainCard(model, units) {
  const { rain, current } = model;
  const total = precipValue(rain.total24mm, units);
  const probability = rain.probNow;

  const header = el('div', { class: 'card__head' },
    el('div', { class: 'card__title-wrap' },
      el('span', { class: 'card__icon card__icon--rain' }, icon('droplet', { size: 18 })),
      el('div', {},
        el('h3', { class: 'card__title', text: t('rain.title') }),
        el('p', { class: 'card__eyebrow', text: t('rain.total') }),
      ),
    ),
    el('span', { class: 'level level--rain', text: `${num(probability ?? 0)}%` }),
  );

  const reading = el('div', { class: 'metric' },
    el('span', { class: 'metric__value', text: num(total, total < 10 ? 1 : 0) }),
    el('span', { class: 'metric__unit', text: precipUnit(units) }),
  );

  const probabilityBlock = el('div', { class: 'prob' },
    el('div', { class: 'prob__head' },
      el('span', { text: t('rain.probNow') }),
      el('strong', { text: probability == null ? t('misc.na') : `${num(probability)}%` }),
    ),
    el('div', { class: 'prob__track', role: 'img', 'aria-label': `${t('rain.probNow')} ${num(probability ?? 0)}%` },
      el('span', { class: 'prob__fill', style: { width: `${Math.max(2, Math.min(100, Number(probability) || 0))}%` } }),
    ),
  );

  const bars = el('div', { class: 'rain-strip', role: 'img', 'aria-label': t('rain.next') });
  model.hourly.slice(0, 12).forEach((hour) => {
    const chance = Number(hour.precipProb) || 0;
    const bar = el('span', { class: `rain-bar${chance >= 30 ? ' is-wet' : ''}` },
      el('span', {
        class: 'rain-bar__fill',
        style: { height: `${Math.max(8, chance)}%`, width: '100%' },
      }),
    );
    bar.setAttribute('title', `${hour.label} · ${chance}%`);
    bar.append(el('span', { class: 'rain-bar__time', text: hour.label.slice(0, 2) }));
    bars.append(bar);
  });

  const wet = rain.wetHours?.[0];
  const wetLine = el('p', { class: 'card__hint' },
    wet
      ? `${t('rain.nextWet')}: ${wet.label} · ${num(wet.precipProb ?? 0)}%`
      : t('rain.none'),
  );

  const currentLine = Number(current.precip) > 0
    ? el('p', { class: 'card__advice', text: t('rain.expected', { value: formatPrecip(current.precip, units, 1) }) })
    : null;

  return el('article', { class: 'card rain-card' }, header, reading, currentLine || adviceSpacer(),
    probabilityBlock,
    el('div', { class: 'card__label-row' },
      el('span', { class: 'card__label', text: t('rain.next') }),
      el('span', { class: 'card__label-muted', text: t('section.hourlyHint') }),
    ),
    bars, wetLine);
}

function adviceSpacer() {
  return el('p', { class: 'card__advice card__advice--muted', text: t('rain.scroll') });
}
