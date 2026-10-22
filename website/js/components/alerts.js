/** Actionable alerts derived from the rules engine. */
import { el } from '../dom.js';
import { icon } from './icons.js';
import { sectionShell } from './section.js';
import { t, tp } from '../i18n.js';

const ICONS = {
  heat: 'thermometer',
  cold: 'thermometer',
  wind: 'wind',
  rain: 'droplet',
  dust: 'wind',
  uv: 'sun',
  thunder: 'alert',
  cyclone: 'cyclone',
};

export function alertsSection({ model, onOpenAlert }) {
  if (!model.alerts || model.alerts.length === 0) return null;

  const cards = model.alerts.map((alert) => {
    const title = t(alert.titleKey, alert.params);
    const body = t(alert.bodyKey, alert.params);
    const button = el('button', {
      class: `alert alert--${alert.severity}`,
      type: 'button',
      onclick: () => onOpenAlert(alert),
      'aria-label': `${title}. ${body}`,
    },
    el('span', { class: 'alert__icon' }, icon(ICONS[alert.type] || 'alert', { size: 20 })),
    el('span', { class: 'alert__body' },
      el('span', { class: 'alert__title', text: title }),
      el('span', { class: 'alert__text', text: body }),
    ),
    el('span', { class: `severity severity--${alert.severity}`, text: t(`severity.${alert.severity}`) }),
    icon('chevron', { size: 16, className: 'alert__chevron' }),
    );
    return button;
  });

  return sectionShell({
    id: 'alerts',
    title: t('alerts.title'),
    iconName: 'alert',
    meta: t('alerts.subtitle'),
    action: el('span', { class: 'count-badge', text: tp('alerts.count', model.alerts.length) }),
    className: 'section--alerts',
    body: el('div', { class: 'alerts' }, cards),
  });
}
