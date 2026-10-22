/** WMO weather code → semantic group. Single source used by glyphs and copy. */
const GROUP_BY_CODE = new Map([
  [0, 'clear'],
  [1, 'mainlyClear'],
  [2, 'partlyCloudy'],
  [3, 'overcast'],
  [45, 'fog'],
  [48, 'fog'],
  [51, 'drizzle'],
  [53, 'drizzle'],
  [55, 'drizzle'],
  [56, 'freezingDrizzle'],
  [57, 'freezingDrizzle'],
  [61, 'rain'],
  [63, 'rain'],
  [65, 'rain'],
  [66, 'freezingRain'],
  [67, 'freezingRain'],
  [71, 'snow'],
  [73, 'snow'],
  [75, 'snow'],
  [77, 'snow'],
  [80, 'showers'],
  [81, 'showers'],
  [82, 'showers'],
  [85, 'snowShowers'],
  [86, 'snowShowers'],
  [95, 'thunder'],
  [96, 'thunder'],
  [99, 'thunder'],
]);

export function weatherGroup(code) {
  return GROUP_BY_CODE.get(Number(code)) || 'unknown';
}

export function conditionKey(code) {
  const numeric = Number(code);
  return GROUP_BY_CODE.has(numeric) ? `cond.${numeric}` : 'cond.0';
}

/** Glyph family: merges drizzle/freezing into rain, keeps snow and thunder. */
export function glyphFamily(code) {
  const group = weatherGroup(code);
  switch (group) {
    case 'clear':
    case 'mainlyClear':
      return 'clear';
    case 'partlyCloudy':
      return 'partly';
    case 'overcast':
      return 'cloudy';
    case 'fog':
      return 'fog';
    case 'drizzle':
    case 'freezingDrizzle':
    case 'rain':
    case 'freezingRain':
    case 'showers':
      return 'rain';
    case 'snow':
    case 'snowShowers':
      return 'snow';
    case 'thunder':
      return 'thunder';
    default:
      return 'partly';
  }
}

export function isThunder(code) {
  return Number(code) >= 95;
}

export function isWet(code) {
  return Number(code) >= 51;
}

export function isSnow(code) {
  return [71, 73, 75, 77, 85, 86].includes(Number(code));
}

/** Scene family used by the animated hero background. */
export function sceneFamily(code, isDay = true) {
  const family = glyphFamily(code);
  if (family === 'clear' || family === 'partly') return isDay ? 'clear' : 'night';
  if (family === 'cloudy') return 'cloudy';
  if (family === 'fog') return 'fog';
  if (family === 'rain') return 'rain';
  if (family === 'snow') return 'snow';
  if (family === 'thunder') return 'storm';
  return 'cloudy';
}
