// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Ajwaa';

  @override
  String get appTagline => 'Weather & time, wherever you are';

  @override
  String appVersionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get language => 'Language';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get settings => 'Settings';

  @override
  String get theme => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get units => 'Units';

  @override
  String get unitsMetric => '°C · km/h';

  @override
  String get unitsImperial => '°F · mph';

  @override
  String get appearance => 'Appearance & language';

  @override
  String get aboutApp => 'About Ajwaa';

  @override
  String get dataSources => 'Data sources';

  @override
  String get privacy => 'Privacy';

  @override
  String get privacyBody =>
      'Your location is used only on your device to fetch the weather. It is never sent to us or stored on a server. Saved cities and the last forecast stay on your device.';

  @override
  String get version => 'Version';

  @override
  String get builtWith => 'Built with Flutter · Free & open data';

  @override
  String get searchCity => 'Search for a city';

  @override
  String get searchHint => 'City name, e.g. Cairo';

  @override
  String get searchNoResults => 'No cities matched your search.';

  @override
  String get searchResults => 'Search results';

  @override
  String get searchPrompt => 'Type at least two letters to search.';

  @override
  String get searchError =>
      'Couldn\'t search right now. Check your connection and try again.';

  @override
  String get popularCities => 'Popular cities';

  @override
  String get savedCities => 'Saved cities';

  @override
  String get currentLocation => 'Current location';

  @override
  String get currentLocationBadge => 'Live location';

  @override
  String get useMyLocation => 'Use my current location';

  @override
  String get locate => 'Locate me';

  @override
  String get locating => 'Finding your location…';

  @override
  String get locationDenied =>
      'Location permission is needed to show your local weather.';

  @override
  String get locationDeniedForever =>
      'Location is blocked. Enable it in your device settings, or pick a city manually.';

  @override
  String get locationServiceDisabled =>
      'Location services are off. Turn them on, or pick a city manually.';

  @override
  String get locationTimeout =>
      'Locating took too long. Try again or pick a city manually.';

  @override
  String get locationFailed => 'We couldn\'t determine your location.';

  @override
  String get noCities => 'No saved cities yet.';

  @override
  String get addCity => 'Add city';

  @override
  String get removeCity => 'Remove city';

  @override
  String cityAdded(String city) {
    return '$city was added to your cities.';
  }

  @override
  String cityRemoved(String city) {
    return '$city was removed.';
  }

  @override
  String get refresh => 'Refresh';

  @override
  String get retry => 'Try again';

  @override
  String get close => 'Close';

  @override
  String get done => 'Done';

  @override
  String get cancel => 'Cancel';

  @override
  String get openLink => 'Open link';

  @override
  String get updated => 'Updated';

  @override
  String get updating => 'Updating…';

  @override
  String updatedAt(String time) {
    return 'Updated $time';
  }

  @override
  String updatedMinutesAgo(int count) {
    return '$count min ago';
  }

  @override
  String get justNow => 'Just now';

  @override
  String get offlineTitle => 'You\'re offline';

  @override
  String get offlineBody => 'Showing the last saved forecast for this city.';

  @override
  String get cachedData => 'Saved data';

  @override
  String get liveData => 'Live';

  @override
  String get feelsLike => 'Feels like';

  @override
  String highLow(String high, String low) {
    return 'H $high · L $low';
  }

  @override
  String get humidity => 'Humidity';

  @override
  String get rain => 'Rain';

  @override
  String get rainChance => 'Chance of rain';

  @override
  String get precipitation => 'Precipitation';

  @override
  String get dust => 'Dust';

  @override
  String get wind => 'Wind';

  @override
  String get windGusts => 'Gusts';

  @override
  String get uvIndex => 'UV index';

  @override
  String get pressure => 'Pressure';

  @override
  String get visibility => 'Visibility';

  @override
  String get cloudCover => 'Cloud cover';

  @override
  String get sunrise => 'Sunrise';

  @override
  String get sunset => 'Sunset';

  @override
  String get airQuality => 'Air quality';

  @override
  String get dewPoint => 'Dew point';

  @override
  String get temperature => 'Temperature';

  @override
  String get details => 'Details';

  @override
  String get weatherDetails => 'Weather details';

  @override
  String get conditionClear => 'Clear';

  @override
  String get conditionMainlyClear => 'Mostly clear';

  @override
  String get conditionPartlyCloudy => 'Partly cloudy';

  @override
  String get conditionCloudy => 'Overcast';

  @override
  String get conditionFog => 'Fog';

  @override
  String get conditionDrizzle => 'Drizzle';

  @override
  String get conditionRain => 'Rain';

  @override
  String get conditionHeavyRain => 'Heavy rain';

  @override
  String get conditionFreezingRain => 'Freezing rain';

  @override
  String get conditionSnow => 'Snow';

  @override
  String get conditionThunderstorm => 'Thunderstorm';

  @override
  String get conditionDust => 'Dust in the air';

  @override
  String get conditionUnknown => 'Mixed conditions';

  @override
  String get now => 'Now';

  @override
  String get localTime => 'Local time';

  @override
  String get timezone => 'Time zone';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get hourlyTitle => 'Next 24 hours';

  @override
  String get hourlySubtitle => 'Temperature, rain chance and wind';

  @override
  String get dailyTitle => '7-day forecast';

  @override
  String get dailySubtitle => 'Highs, lows and rain chance';

  @override
  String get chanceOfRain => 'Chance of rain';

  @override
  String get rainToday => 'Rain today';

  @override
  String get rainNext24h => 'Rain expected in 24 h';

  @override
  String get nextRain => 'Next rain';

  @override
  String get noRainNext24h => 'No rain expected in the next 24 hours.';

  @override
  String rainInHours(int hours) {
    return 'in about $hours h';
  }

  @override
  String get rainNow => 'Rain is falling now';

  @override
  String get rainStopped => 'No rain right now';

  @override
  String get rainChartTitle => 'Rain over the next 12 hours';

  @override
  String get precipAmount => 'Amount';

  @override
  String get humidityHint => 'Share of water vapour in the air at 2 m.';

  @override
  String get windHint => 'Sustained wind at 10 m, with gusts.';

  @override
  String get dustHint => 'Airborne dust concentration near the surface.';

  @override
  String get uvHint =>
      '0–2 low · 3–5 moderate · 6–7 high · 8–10 very high · 11+ extreme.';

  @override
  String get pressureHint =>
      'Sea-level pressure. Falling pressure can mean unsettled weather.';

  @override
  String get visibilityHint => 'Horizontal visibility near the ground.';

  @override
  String get cloudsHint => 'Fraction of the sky covered by clouds.';

  @override
  String get rainHint =>
      'Total liquid precipitation expected in the next 24 hours.';

  @override
  String get rainAndDustTitle => 'Rain & dust';

  @override
  String get rainAndDustSubtitle => 'What the air is doing hour by hour';

  @override
  String get dustTitle => 'Dust & air';

  @override
  String get dustLevel => 'Dust level';

  @override
  String get dustLow => 'Low';

  @override
  String get dustModerate => 'Moderate';

  @override
  String get dustHigh => 'High';

  @override
  String get dustVeryHigh => 'Very high';

  @override
  String get dustAdviceLow => 'Air is clear. A good time to be outside.';

  @override
  String get dustAdviceModerate =>
      'Sensitive people may notice the air. Consider a mask outdoors.';

  @override
  String get dustAdviceHigh =>
      'Limit outdoor activity, keep windows closed and wear a mask.';

  @override
  String get dustAdviceVeryHigh =>
      'Avoid going outside. Seal windows and use an air purifier if you have one.';

  @override
  String get dustTrendTitle => 'Dust over the next 12 hours';

  @override
  String get dustConcentration => 'Dust concentration';

  @override
  String get pm10 => 'PM10';

  @override
  String get pm25 => 'PM2.5';

  @override
  String get alertsTitle => 'Alerts';

  @override
  String get noAlertsTitle => 'All clear';

  @override
  String get noAlertsBody =>
      'No significant weather hazards are expected right now.';

  @override
  String alertsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alerts',
      one: '1 alert',
      zero: 'No alerts',
    );
    return '$_temp0';
  }

  @override
  String get alertHeatTitle => 'Extreme heat';

  @override
  String get alertColdTitle => 'Severe cold';

  @override
  String get alertWindTitle => 'Strong winds';

  @override
  String get alertRainTitle => 'Heavy rain';

  @override
  String get alertDustTitle => 'Dust storm';

  @override
  String get alertUvTitle => 'Very high UV';

  @override
  String get alertThunderTitle => 'Thunderstorms';

  @override
  String get alertStormTitle => 'Cyclone nearby';

  @override
  String alertHeatBody(Object value) {
    return 'Feels like $value. Stay in the shade, drink water and avoid midday sun.';
  }

  @override
  String alertColdBody(Object value) {
    return 'Feels like $value. Cover up and limit time outdoors.';
  }

  @override
  String alertWindBody(Object value) {
    return 'Gusts up to $value. Secure loose objects and take care outdoors.';
  }

  @override
  String alertRainBody(Object value) {
    return '$value of rain is expected soon. Avoid low-lying roads and dry riverbeds.';
  }

  @override
  String alertDustBody(Object value) {
    return 'Dust reaches $value. Close windows and use a mask if you go out.';
  }

  @override
  String alertUvBody(Object value) {
    return 'UV index reaches $value. Use sunscreen, sunglasses and a hat.';
  }

  @override
  String get alertThunderBody =>
      'Thunderstorms are nearby. Stay indoors and avoid open ground.';

  @override
  String alertStormBody(Object distance, Object name) {
    return '$name is about $distance away. Follow official guidance.';
  }

  @override
  String get severityInfo => 'Info';

  @override
  String get severityWarning => 'Warning';

  @override
  String get severitySevere => 'Severe';

  @override
  String get stormsTitle => 'Active cyclones';

  @override
  String get stormsSubtitle => 'Nearest tropical systems, tracked by GDACS';

  @override
  String get stormsEmpty =>
      'No active tropical cyclones are being tracked right now.';

  @override
  String get stormsUnavailable => 'Cyclone data is unavailable right now.';

  @override
  String stormDistance(String distance) {
    return '$distance away';
  }

  @override
  String stormWind(String speed) {
    return 'Winds $speed';
  }

  @override
  String get stormSeverity => 'Severity';

  @override
  String get distance => 'Distance';

  @override
  String get country => 'Country';

  @override
  String get activePeriod => 'Active period';

  @override
  String get viewOnGdacs => 'View on GDACS';

  @override
  String get stormDisclaimer =>
      'Cyclone positions are approximate. Always follow your national meteorological service.';

  @override
  String get aboutTitle => 'About Ajwaa';

  @override
  String get aboutBody =>
      'Ajwaa brings the weather, the rain, the dust and the local time of any city into one calm, glanceable screen — with live location, saved cities, Arabic and English.';

  @override
  String get brandTitle => 'Designed for clarity';

  @override
  String get brandBody =>
      'Warm light, quiet motion and honest data. No accounts, no ads, no tracking.';

  @override
  String get madeBy => 'Made by Mohamed Ibrahim';

  @override
  String get licenses => 'Open-source licenses';

  @override
  String get dataProviderOpenMeteo =>
      'Open-Meteo — weather, air quality & geocoding';

  @override
  String get dataProviderGdacs => 'GDACS — global disaster alerts';

  @override
  String get dataProviderBigDataCloud => 'BigDataCloud — reverse geocoding';

  @override
  String get openSourceNote => 'Free, open data. No API keys required.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorNetwork =>
      'No internet connection. Check your network and try again.';

  @override
  String get errorTimeout => 'The weather service took too long to respond.';

  @override
  String get errorServer =>
      'The weather service is busy right now. Please try again shortly.';

  @override
  String get errorRateLimited =>
      'Too many requests. Please wait a moment and try again.';

  @override
  String get errorMalformed => 'We received unexpected weather data.';

  @override
  String get errorNoCity => 'Choose a city to see its weather.';

  @override
  String get errorLocation =>
      'We couldn\'t get your location. Pick a city instead.';

  @override
  String get errorUnknown => 'An unexpected error occurred.';

  @override
  String get tempUnit => 'Temperature';

  @override
  String get windUnit => 'Wind';

  @override
  String get distanceUnit => 'Distance';

  @override
  String get a11yLanguageToggle => 'Switch language';

  @override
  String get a11yRefresh => 'Refresh weather';

  @override
  String get a11ySettings => 'Open settings';

  @override
  String get a11ySearch => 'Search cities';

  @override
  String get a11yCityPicker => 'Change city';

  @override
  String get selected => 'Selected';

  @override
  String get swipeToRemove => 'Swipe a city to remove it';

  @override
  String get footerNote => 'Forecasts by Open-Meteo · Storm alerts by GDACS';

  @override
  String get pullToRefresh => 'Pull down to refresh';

  @override
  String get loading => 'Loading…';

  @override
  String get showMore => 'Show more';

  @override
  String get showLess => 'Show less';

  @override
  String get next7Days => 'Next 7 days';

  @override
  String get high => 'High';

  @override
  String get low => 'Low';

  @override
  String get gusts => 'gusts';

  @override
  String get direction => 'Direction';

  @override
  String get kmh => 'km/h';

  @override
  String get mph => 'mph';

  @override
  String get celsius => '°C';

  @override
  String get fahrenheit => '°F';

  @override
  String get percent => '%';

  @override
  String weatherSummary(String city, String condition, String temp) {
    return '$city: $condition, $temp';
  }

  @override
  String get cityPickerTitle => 'Choose a city';

  @override
  String get cityPickerSubtitle => 'Weather and time update instantly';

  @override
  String get settingsSaved => 'Preferences saved automatically';

  @override
  String get chartSelected => 'Selected hour';

  @override
  String get chartNow => 'Now';

  @override
  String get rainTotalLabel => 'Total';

  @override
  String get dustPeakLabel => 'Peak';

  @override
  String get stormCategory => 'Category';

  @override
  String get retryHint => 'Check your connection, then try again.';

  @override
  String get welcomeTitle => 'Where are you?';

  @override
  String get welcomeBody =>
      'Allow location access for instant local weather, or pick a city to begin.';

  @override
  String get allowLocation => 'Allow location';

  @override
  String get pickCity => 'Pick a city';

  @override
  String get continueWithout => 'Not now';

  @override
  String get openSettings => 'Open settings';

  @override
  String get unitSystem => 'Measurement system';

  @override
  String get themeDescription => 'Choose how Ajwaa looks.';

  @override
  String get languageDescription =>
      'The whole app switches instantly, including direction.';

  @override
  String get dataNote =>
      'Weather models update hourly. The app refreshes automatically every 10 minutes while open.';

  @override
  String get lastSync => 'Last sync';

  @override
  String get never => 'Never';

  @override
  String get airQualityIndex => 'Air quality index';

  @override
  String get good => 'Good';

  @override
  String get moderate => 'Moderate';

  @override
  String get unhealthySensitive => 'Unhealthy for sensitive groups';

  @override
  String get unhealthy => 'Unhealthy';

  @override
  String get veryUnhealthy => 'Very unhealthy';

  @override
  String get hazardous => 'Hazardous';

  @override
  String get uvLow => 'Low';

  @override
  String get uvModerate => 'Moderate';

  @override
  String get uvHigh => 'High';

  @override
  String get uvVeryHigh => 'Very high';

  @override
  String get uvExtreme => 'Extreme';

  @override
  String get dirN => 'N';

  @override
  String get dirNE => 'NE';

  @override
  String get dirE => 'E';

  @override
  String get dirSE => 'SE';

  @override
  String get dirS => 'S';

  @override
  String get dirSW => 'SW';

  @override
  String get dirW => 'W';

  @override
  String get dirNW => 'NW';

  @override
  String get airNow => 'Air right now';

  @override
  String get feelsLikeShort => 'Feels';

  @override
  String get emptyStateTitle => 'No weather yet';

  @override
  String get emptyStateBody =>
      'Search for a city or allow location access to see the weather.';

  @override
  String get showAllCities => 'All cities';

  @override
  String get manageCities => 'Manage cities';

  @override
  String get refreshSuccess => 'Weather is up to date';

  @override
  String get tapChartHint => 'Tap an hour to inspect it';

  @override
  String detailsFor(Object city) {
    return 'Details for $city';
  }

  @override
  String get a11yWeatherScene => 'Weather illustration';

  @override
  String get closeSheet => 'Close panel';

  @override
  String dataUpdatedShort(Object time) {
    return 'Updated $time';
  }

  @override
  String precipChanceShort(Object value) {
    return '$value%';
  }

  @override
  String get setAsDefault => 'Set as default';

  @override
  String get cityExists => 'City already saved';

  @override
  String get mmUnit => 'mm';

  @override
  String get inUnit => 'in';

  @override
  String get kmUnit => 'km';

  @override
  String get miUnit => 'mi';

  @override
  String get hpaUnit => 'hPa';

  @override
  String get microgramUnit => 'µg/m³';
}
