/**
 * Minimal observable store: one state object, one subscribe function.
 * Components never mutate state directly; they call actions in main.js.
 */
const state = {
  status: 'booting',
  locale: 'ar',
  units: 'metric',
  theme: 'system',
  resolvedTheme: 'dark',
  cities: [],
  selectedId: null,
  settings: null,
  bundle: null,
  model: null,
  loading: false,
  stale: false,
  errorKind: null,
  geoStatus: 'idle',
  settingsOpen: false,
  sheet: null,
  updatedAt: 0,
};

const listeners = new Set();

export function getState() {
  return state;
}

export function setState(patch) {
  Object.assign(state, patch);
  listeners.forEach((listener) => {
    try {
      listener(state);
    } catch (error) {
      console.error('[ajwaa] store listener failed', error);
    }
  });
}

export function subscribe(listener) {
  listeners.add(listener);
  return () => listeners.delete(listener);
}

export function selectedCity() {
  if (!state.selectedId) return null;
  return state.cities.find((city) => city.id === state.selectedId) || null;
}
