/** Settings: appearance, units, language, privacy, sources, about. */
import { el } from '../dom.js';
import { icon, logoMark } from './icons.js';
import { t } from '../i18n.js';
import { APP } from '../config.js';
import { openSheet, segmented, settingsBlock } from './sheets.js';

const SOURCES = [
  { name: 'Open-Meteo', note: 'Forecast · Air quality · Geocoding', url: 'https://open-meteo.com/' },
  { name: 'NASA EONET', note: 'Active tropical systems', url: 'https://eonet.gsfc.nasa.gov/' },
  { name: 'GDACS', note: 'Disaster alerts fallback', url: 'https://www.gdacs.org/' },
  { name: 'BigDataCloud', note: 'Reverse geocoding', url: 'https://www.bigdatacloud.com/' },
];

export function openSettings({ settings, onChange, onReset }) {
  const content = el('div', { class: 'settings' });

  content.append(
    settingsBlock(t('sheet.settings.appearance'), segmented([
      { value: 'system', label: t('theme.system'), icon: 'layers' },
      { value: 'light', label: t('theme.light'), icon: 'sun' },
      { value: 'dark', label: t('theme.dark'), icon: 'moon' },
    ], settings.themeMode, (value) => onChange({ themeMode: value }), t('theme.title')), { iconName: 'sun' }),

    settingsBlock(t('sheet.settings.units'), segmented([
      { value: 'metric', label: t('units.metric'), hint: t('units.metricHint') },
      { value: 'imperial', label: t('units.imperial'), hint: t('units.imperialHint') },
    ], settings.unitSystem, (value) => onChange({ unitSystem: value }), t('units.title'))),

    settingsBlock(t('sheet.settings.language'), segmented([
      { value: 'ar', label: t('lang.ar') },
      { value: 'en', label: t('lang.en') },
    ], settings.localeCode, (value) => onChange({ localeCode: value }), t('lang.title')), {
      note: t('lang.hint'),
      iconName: 'globe',
    }),

    settingsBlock(t('sheet.settings.privacy'), el('p', { class: 'settings-text', text: t('sheet.settings.privacyBody') }), {
      iconName: 'eye',
    }),

    settingsBlock(t('sheet.settings.sources'), el('div', { class: 'sources' },
      SOURCES.map((source) => el('a', {
        class: 'source-row',
        href: source.url,
        target: '_blank',
        rel: 'noopener noreferrer',
      },
      el('span', { class: 'source-row__main' },
        el('strong', { text: source.name }),
        el('span', { text: source.note }),
      ),
      icon('external', { size: 15 }),
      )),
    ), { note: t('sheet.settings.sourcesBody'), iconName: 'globe' }),

    settingsBlock(t('sheet.settings.dataNote'), el('p', { class: 'settings-text', text: t('sheet.settings.dataNoteBody') }), {
      iconName: 'info',
    }),

    settingsBlock(t('sheet.settings.about'), el('div', { class: 'about' },
      el('span', { class: 'about__logo' }, logoMark({ size: 46 })),
      el('div', { class: 'about__text' },
        el('strong', { class: 'about__name', text: `${t('app.name')} · Ajwaa` }),
        el('span', { text: `${t('sheet.settings.version')} ${APP.version}` }),
        el('span', { text: `${t('sheet.settings.author')} · ${APP.author}` }),
        el('span', { class: 'about__built', text: t('sheet.settings.built') }),
      ),
    ), { iconName: 'sparkle' }),

    settingsBlock(t('sheet.settings.licenses'), el('p', { class: 'settings-text', text: t('sheet.settings.licensesBody') }), {
      iconName: 'info',
    }),
  );

  const reset = el('button', {
    class: 'btn btn--ghost btn--danger',
    type: 'button',
    onclick: () => {
      onReset();
    },
  }, icon('refresh', { size: 16 }), el('span', { text: t('sheet.settings.reset') }));

  const sheet = openSheet({
    title: t('sheet.settings.title'),
    subtitle: t('sheet.settings.subtitle'),
    content,
    className: 'sheet--settings',
    footer: el('div', { class: 'settings__footer' },
      reset,
      el('span', { class: 'settings__version', text: `${t('app.name')} · v${APP.version}` }),
    ),
  });
  return sheet;
}
