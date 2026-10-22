/** Seven detail cards; each one opens an explanation sheet. */
import { el } from '../dom.js';
import { icon } from './icons.js';
import { sectionShell } from './section.js';
import { t } from '../i18n.js';
import {
  num, formatTemp, formatWind, compassLabel, tempValue, distanceValue, distanceUnit,
} from '../format.js';

export function detailsSection({ model, units, onOpenInfo }) {
  const c = model.current;
  const items = [
    {
      key: 'humidity',
      icon: 'droplet',
      tone: 'teal',
      value: c.humidity == null ? t('misc.na') : `${num(c.humidity)}%`,
      sub: t('detail.humiditySub', { value: formatTemp(c.dewPoint, units) }),
      infoBody: 'info.humidity.body',
    },
    {
      key: 'wind',
      icon: 'wind',
      tone: 'sky',
      value: formatWind(c.windSpeed, units),
      sub: t('detail.windSub', {
        dir: compassLabel(c.windDir),
        gust: formatWind(c.gust, units),
      }),
      infoBody: 'info.wind.body',
    },
    {
      key: 'rainChance',
      icon: 'droplet',
      tone: 'rain',
      value: model.rain.probNow == null ? t('misc.na') : `${num(model.rain.probNow)}%`,
      sub: t('detail.rainChanceSub'),
      infoBody: 'info.rain.body',
    },
    {
      key: 'uv',
      icon: 'sun',
      tone: 'gold',
      value: num(c.uv, 1),
      sub: c.uvLevel ? t(`uv.${c.uvLevel}`) : t('misc.na'),
      infoBody: 'info.uv.body',
      level: c.uvLevel,
    },
    {
      key: 'pressure',
      icon: 'gauge',
      tone: 'navy',
      value: c.pressure == null ? t('misc.na') : `${num(c.pressure)}`,
      unit: 'hPa',
      sub: t('detail.pressureSub'),
      infoBody: 'info.pressure.body',
    },
    {
      key: 'visibility',
      icon: 'eye',
      tone: 'mint',
      value: c.visibilityKm == null ? t('misc.na') : `${num(distanceValue(c.visibilityKm, units), 1)}`,
      unit: distanceUnit(units),
      sub: t('detail.visibilitySub'),
      infoBody: 'info.visibility.body',
    },
    {
      key: 'cloud',
      icon: 'cloud',
      tone: 'slate',
      value: c.cloud == null ? t('misc.na') : `${num(c.cloud)}%`,
      sub: t('detail.cloudSub'),
      infoBody: 'info.cloud.body',
    },
  ];

  const cards = items.map((item) => {
    const label = t(`detail.${item.key}`);
    const button = el('button', {
      class: 'detail',
      type: 'button',
      'aria-label': `${label}: ${item.value}${item.unit ? ` ${item.unit}` : ''}. ${item.sub}. ${t('detail.tap')}`,
      onclick: () => onOpenInfo({
        icon: item.icon,
        tone: item.tone,
        title: label,
        body: t(item.infoBody),
        rows: [
          { label, value: `${item.value}${item.unit ? ` ${item.unit}` : ''}` },
          { label: t('detail.more'), value: item.sub },
        ],
      }),
    },
    el('span', { class: `detail__icon detail__icon--${item.tone}` }, icon(item.icon, { size: 19 })),
    el('span', { class: 'detail__label', text: label }),
    el('span', { class: 'detail__value' },
      el('span', { text: item.value }),
      item.unit ? el('span', { class: 'detail__unit', text: item.unit }) : null,
    ),
    el('span', { class: 'detail__sub', text: item.sub }),
    el('span', { class: 'detail__arrow', 'aria-hidden': 'true' }, icon('chevron', { size: 14 })),
    );
    return button;
  });

  return sectionShell({
    id: 'details',
    title: t('section.details'),
    iconName: 'layers',
    meta: t('section.detailsHint'),
    className: 'section--details',
    body: el('div', { class: 'details-grid' }, cards),
  });
}
