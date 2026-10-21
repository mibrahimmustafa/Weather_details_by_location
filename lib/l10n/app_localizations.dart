import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Ajwaa'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Weather & time, wherever you are'**
  String get appTagline;

  /// No description provided for @appVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String appVersionLabel(String version);

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get units;

  /// No description provided for @unitsMetric.
  ///
  /// In en, this message translates to:
  /// **'°C · km/h'**
  String get unitsMetric;

  /// No description provided for @unitsImperial.
  ///
  /// In en, this message translates to:
  /// **'°F · mph'**
  String get unitsImperial;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance & language'**
  String get appearance;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About Ajwaa'**
  String get aboutApp;

  /// No description provided for @dataSources.
  ///
  /// In en, this message translates to:
  /// **'Data sources'**
  String get dataSources;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @privacyBody.
  ///
  /// In en, this message translates to:
  /// **'Your location is used only on your device to fetch the weather. It is never sent to us or stored on a server. Saved cities and the last forecast stay on your device.'**
  String get privacyBody;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @builtWith.
  ///
  /// In en, this message translates to:
  /// **'Built with Flutter · Free & open data'**
  String get builtWith;

  /// No description provided for @searchCity.
  ///
  /// In en, this message translates to:
  /// **'Search for a city'**
  String get searchCity;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'City name, e.g. Cairo'**
  String get searchHint;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No cities matched your search.'**
  String get searchNoResults;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'Search results'**
  String get searchResults;

  /// No description provided for @searchPrompt.
  ///
  /// In en, this message translates to:
  /// **'Type at least two letters to search.'**
  String get searchPrompt;

  /// No description provided for @searchError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t search right now. Check your connection and try again.'**
  String get searchError;

  /// No description provided for @popularCities.
  ///
  /// In en, this message translates to:
  /// **'Popular cities'**
  String get popularCities;

  /// No description provided for @savedCities.
  ///
  /// In en, this message translates to:
  /// **'Saved cities'**
  String get savedCities;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current location'**
  String get currentLocation;

  /// No description provided for @currentLocationBadge.
  ///
  /// In en, this message translates to:
  /// **'Live location'**
  String get currentLocationBadge;

  /// No description provided for @useMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my current location'**
  String get useMyLocation;

  /// No description provided for @locate.
  ///
  /// In en, this message translates to:
  /// **'Locate me'**
  String get locate;

  /// No description provided for @locating.
  ///
  /// In en, this message translates to:
  /// **'Finding your location…'**
  String get locating;

  /// No description provided for @locationDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission is needed to show your local weather.'**
  String get locationDenied;

  /// No description provided for @locationDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location is blocked. Enable it in your device settings, or pick a city manually.'**
  String get locationDeniedForever;

  /// No description provided for @locationServiceDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are off. Turn them on, or pick a city manually.'**
  String get locationServiceDisabled;

  /// No description provided for @locationTimeout.
  ///
  /// In en, this message translates to:
  /// **'Locating took too long. Try again or pick a city manually.'**
  String get locationTimeout;

  /// No description provided for @locationFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t determine your location.'**
  String get locationFailed;

  /// No description provided for @noCities.
  ///
  /// In en, this message translates to:
  /// **'No saved cities yet.'**
  String get noCities;

  /// No description provided for @addCity.
  ///
  /// In en, this message translates to:
  /// **'Add city'**
  String get addCity;

  /// No description provided for @removeCity.
  ///
  /// In en, this message translates to:
  /// **'Remove city'**
  String get removeCity;

  /// No description provided for @cityAdded.
  ///
  /// In en, this message translates to:
  /// **'{city} was added to your cities.'**
  String cityAdded(String city);

  /// No description provided for @cityRemoved.
  ///
  /// In en, this message translates to:
  /// **'{city} was removed.'**
  String cityRemoved(String city);

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @openLink.
  ///
  /// In en, this message translates to:
  /// **'Open link'**
  String get openLink;

  /// No description provided for @updated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get updated;

  /// No description provided for @updating.
  ///
  /// In en, this message translates to:
  /// **'Updating…'**
  String get updating;

  /// No description provided for @updatedAt.
  ///
  /// In en, this message translates to:
  /// **'Updated {time}'**
  String updatedAt(String time);

  /// No description provided for @updatedMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String updatedMinutesAgo(int count);

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @offlineTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline'**
  String get offlineTitle;

  /// No description provided for @offlineBody.
  ///
  /// In en, this message translates to:
  /// **'Showing the last saved forecast for this city.'**
  String get offlineBody;

  /// No description provided for @cachedData.
  ///
  /// In en, this message translates to:
  /// **'Saved data'**
  String get cachedData;

  /// No description provided for @liveData.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get liveData;

  /// No description provided for @feelsLike.
  ///
  /// In en, this message translates to:
  /// **'Feels like'**
  String get feelsLike;

  /// No description provided for @highLow.
  ///
  /// In en, this message translates to:
  /// **'H {high} · L {low}'**
  String highLow(String high, String low);

  /// No description provided for @humidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get humidity;

  /// No description provided for @rain.
  ///
  /// In en, this message translates to:
  /// **'Rain'**
  String get rain;

  /// No description provided for @rainChance.
  ///
  /// In en, this message translates to:
  /// **'Chance of rain'**
  String get rainChance;

  /// No description provided for @precipitation.
  ///
  /// In en, this message translates to:
  /// **'Precipitation'**
  String get precipitation;

  /// No description provided for @dust.
  ///
  /// In en, this message translates to:
  /// **'Dust'**
  String get dust;

  /// No description provided for @wind.
  ///
  /// In en, this message translates to:
  /// **'Wind'**
  String get wind;

  /// No description provided for @windGusts.
  ///
  /// In en, this message translates to:
  /// **'Gusts'**
  String get windGusts;

  /// No description provided for @uvIndex.
  ///
  /// In en, this message translates to:
  /// **'UV index'**
  String get uvIndex;

  /// No description provided for @pressure.
  ///
  /// In en, this message translates to:
  /// **'Pressure'**
  String get pressure;

  /// No description provided for @visibility.
  ///
  /// In en, this message translates to:
  /// **'Visibility'**
  String get visibility;

  /// No description provided for @cloudCover.
  ///
  /// In en, this message translates to:
  /// **'Cloud cover'**
  String get cloudCover;

  /// No description provided for @sunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get sunrise;

  /// No description provided for @sunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get sunset;

  /// No description provided for @airQuality.
  ///
  /// In en, this message translates to:
  /// **'Air quality'**
  String get airQuality;

  /// No description provided for @dewPoint.
  ///
  /// In en, this message translates to:
  /// **'Dew point'**
  String get dewPoint;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @weatherDetails.
  ///
  /// In en, this message translates to:
  /// **'Weather details'**
  String get weatherDetails;

  /// No description provided for @conditionClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get conditionClear;

  /// No description provided for @conditionMainlyClear.
  ///
  /// In en, this message translates to:
  /// **'Mostly clear'**
  String get conditionMainlyClear;

  /// No description provided for @conditionPartlyCloudy.
  ///
  /// In en, this message translates to:
  /// **'Partly cloudy'**
  String get conditionPartlyCloudy;

  /// No description provided for @conditionCloudy.
  ///
  /// In en, this message translates to:
  /// **'Overcast'**
  String get conditionCloudy;

  /// No description provided for @conditionFog.
  ///
  /// In en, this message translates to:
  /// **'Fog'**
  String get conditionFog;

  /// No description provided for @conditionDrizzle.
  ///
  /// In en, this message translates to:
  /// **'Drizzle'**
  String get conditionDrizzle;

  /// No description provided for @conditionRain.
  ///
  /// In en, this message translates to:
  /// **'Rain'**
  String get conditionRain;

  /// No description provided for @conditionHeavyRain.
  ///
  /// In en, this message translates to:
  /// **'Heavy rain'**
  String get conditionHeavyRain;

  /// No description provided for @conditionFreezingRain.
  ///
  /// In en, this message translates to:
  /// **'Freezing rain'**
  String get conditionFreezingRain;

  /// No description provided for @conditionSnow.
  ///
  /// In en, this message translates to:
  /// **'Snow'**
  String get conditionSnow;

  /// No description provided for @conditionThunderstorm.
  ///
  /// In en, this message translates to:
  /// **'Thunderstorm'**
  String get conditionThunderstorm;

  /// No description provided for @conditionDust.
  ///
  /// In en, this message translates to:
  /// **'Dust in the air'**
  String get conditionDust;

  /// No description provided for @conditionUnknown.
  ///
  /// In en, this message translates to:
  /// **'Mixed conditions'**
  String get conditionUnknown;

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get now;

  /// No description provided for @localTime.
  ///
  /// In en, this message translates to:
  /// **'Local time'**
  String get localTime;

  /// No description provided for @timezone.
  ///
  /// In en, this message translates to:
  /// **'Time zone'**
  String get timezone;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @hourlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Next 24 hours'**
  String get hourlyTitle;

  /// No description provided for @hourlySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Temperature, rain chance and wind'**
  String get hourlySubtitle;

  /// No description provided for @dailyTitle.
  ///
  /// In en, this message translates to:
  /// **'7-day forecast'**
  String get dailyTitle;

  /// No description provided for @dailySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Highs, lows and rain chance'**
  String get dailySubtitle;

  /// No description provided for @chanceOfRain.
  ///
  /// In en, this message translates to:
  /// **'Chance of rain'**
  String get chanceOfRain;

  /// No description provided for @rainToday.
  ///
  /// In en, this message translates to:
  /// **'Rain today'**
  String get rainToday;

  /// No description provided for @rainNext24h.
  ///
  /// In en, this message translates to:
  /// **'Rain expected in 24 h'**
  String get rainNext24h;

  /// No description provided for @nextRain.
  ///
  /// In en, this message translates to:
  /// **'Next rain'**
  String get nextRain;

  /// No description provided for @noRainNext24h.
  ///
  /// In en, this message translates to:
  /// **'No rain expected in the next 24 hours.'**
  String get noRainNext24h;

  /// No description provided for @rainInHours.
  ///
  /// In en, this message translates to:
  /// **'in about {hours} h'**
  String rainInHours(int hours);

  /// No description provided for @rainNow.
  ///
  /// In en, this message translates to:
  /// **'Rain is falling now'**
  String get rainNow;

  /// No description provided for @rainStopped.
  ///
  /// In en, this message translates to:
  /// **'No rain right now'**
  String get rainStopped;

  /// No description provided for @rainChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Rain over the next 12 hours'**
  String get rainChartTitle;

  /// No description provided for @precipAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get precipAmount;

  /// No description provided for @humidityHint.
  ///
  /// In en, this message translates to:
  /// **'Share of water vapour in the air at 2 m.'**
  String get humidityHint;

  /// No description provided for @windHint.
  ///
  /// In en, this message translates to:
  /// **'Sustained wind at 10 m, with gusts.'**
  String get windHint;

  /// No description provided for @dustHint.
  ///
  /// In en, this message translates to:
  /// **'Airborne dust concentration near the surface.'**
  String get dustHint;

  /// No description provided for @uvHint.
  ///
  /// In en, this message translates to:
  /// **'0–2 low · 3–5 moderate · 6–7 high · 8–10 very high · 11+ extreme.'**
  String get uvHint;

  /// No description provided for @pressureHint.
  ///
  /// In en, this message translates to:
  /// **'Sea-level pressure. Falling pressure can mean unsettled weather.'**
  String get pressureHint;

  /// No description provided for @visibilityHint.
  ///
  /// In en, this message translates to:
  /// **'Horizontal visibility near the ground.'**
  String get visibilityHint;

  /// No description provided for @cloudsHint.
  ///
  /// In en, this message translates to:
  /// **'Fraction of the sky covered by clouds.'**
  String get cloudsHint;

  /// No description provided for @rainHint.
  ///
  /// In en, this message translates to:
  /// **'Total liquid precipitation expected in the next 24 hours.'**
  String get rainHint;

  /// No description provided for @rainAndDustTitle.
  ///
  /// In en, this message translates to:
  /// **'Rain & dust'**
  String get rainAndDustTitle;

  /// No description provided for @rainAndDustSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What the air is doing hour by hour'**
  String get rainAndDustSubtitle;

  /// No description provided for @dustTitle.
  ///
  /// In en, this message translates to:
  /// **'Dust & air'**
  String get dustTitle;

  /// No description provided for @dustLevel.
  ///
  /// In en, this message translates to:
  /// **'Dust level'**
  String get dustLevel;

  /// No description provided for @dustLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get dustLow;

  /// No description provided for @dustModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get dustModerate;

  /// No description provided for @dustHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get dustHigh;

  /// No description provided for @dustVeryHigh.
  ///
  /// In en, this message translates to:
  /// **'Very high'**
  String get dustVeryHigh;

  /// No description provided for @dustAdviceLow.
  ///
  /// In en, this message translates to:
  /// **'Air is clear. A good time to be outside.'**
  String get dustAdviceLow;

  /// No description provided for @dustAdviceModerate.
  ///
  /// In en, this message translates to:
  /// **'Sensitive people may notice the air. Consider a mask outdoors.'**
  String get dustAdviceModerate;

  /// No description provided for @dustAdviceHigh.
  ///
  /// In en, this message translates to:
  /// **'Limit outdoor activity, keep windows closed and wear a mask.'**
  String get dustAdviceHigh;

  /// No description provided for @dustAdviceVeryHigh.
  ///
  /// In en, this message translates to:
  /// **'Avoid going outside. Seal windows and use an air purifier if you have one.'**
  String get dustAdviceVeryHigh;

  /// No description provided for @dustTrendTitle.
  ///
  /// In en, this message translates to:
  /// **'Dust over the next 12 hours'**
  String get dustTrendTitle;

  /// No description provided for @dustConcentration.
  ///
  /// In en, this message translates to:
  /// **'Dust concentration'**
  String get dustConcentration;

  /// No description provided for @pm10.
  ///
  /// In en, this message translates to:
  /// **'PM10'**
  String get pm10;

  /// No description provided for @pm25.
  ///
  /// In en, this message translates to:
  /// **'PM2.5'**
  String get pm25;

  /// No description provided for @alertsTitle.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alertsTitle;

  /// No description provided for @noAlertsTitle.
  ///
  /// In en, this message translates to:
  /// **'All clear'**
  String get noAlertsTitle;

  /// No description provided for @noAlertsBody.
  ///
  /// In en, this message translates to:
  /// **'No significant weather hazards are expected right now.'**
  String get noAlertsBody;

  /// No description provided for @alertsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No alerts} =1{1 alert} other{{count} alerts}}'**
  String alertsCount(int count);

  /// No description provided for @alertHeatTitle.
  ///
  /// In en, this message translates to:
  /// **'Extreme heat'**
  String get alertHeatTitle;

  /// No description provided for @alertColdTitle.
  ///
  /// In en, this message translates to:
  /// **'Severe cold'**
  String get alertColdTitle;

  /// No description provided for @alertWindTitle.
  ///
  /// In en, this message translates to:
  /// **'Strong winds'**
  String get alertWindTitle;

  /// No description provided for @alertRainTitle.
  ///
  /// In en, this message translates to:
  /// **'Heavy rain'**
  String get alertRainTitle;

  /// No description provided for @alertDustTitle.
  ///
  /// In en, this message translates to:
  /// **'Dust storm'**
  String get alertDustTitle;

  /// No description provided for @alertUvTitle.
  ///
  /// In en, this message translates to:
  /// **'Very high UV'**
  String get alertUvTitle;

  /// No description provided for @alertThunderTitle.
  ///
  /// In en, this message translates to:
  /// **'Thunderstorms'**
  String get alertThunderTitle;

  /// No description provided for @alertStormTitle.
  ///
  /// In en, this message translates to:
  /// **'Cyclone nearby'**
  String get alertStormTitle;

  /// No description provided for @alertHeatBody.
  ///
  /// In en, this message translates to:
  /// **'Feels like {value}. Stay in the shade, drink water and avoid midday sun.'**
  String alertHeatBody(Object value);

  /// No description provided for @alertColdBody.
  ///
  /// In en, this message translates to:
  /// **'Feels like {value}. Cover up and limit time outdoors.'**
  String alertColdBody(Object value);

  /// No description provided for @alertWindBody.
  ///
  /// In en, this message translates to:
  /// **'Gusts up to {value}. Secure loose objects and take care outdoors.'**
  String alertWindBody(Object value);

  /// No description provided for @alertRainBody.
  ///
  /// In en, this message translates to:
  /// **'{value} of rain is expected soon. Avoid low-lying roads and dry riverbeds.'**
  String alertRainBody(Object value);

  /// No description provided for @alertDustBody.
  ///
  /// In en, this message translates to:
  /// **'Dust reaches {value}. Close windows and use a mask if you go out.'**
  String alertDustBody(Object value);

  /// No description provided for @alertUvBody.
  ///
  /// In en, this message translates to:
  /// **'UV index reaches {value}. Use sunscreen, sunglasses and a hat.'**
  String alertUvBody(Object value);

  /// No description provided for @alertThunderBody.
  ///
  /// In en, this message translates to:
  /// **'Thunderstorms are nearby. Stay indoors and avoid open ground.'**
  String get alertThunderBody;

  /// No description provided for @alertStormBody.
  ///
  /// In en, this message translates to:
  /// **'{name} is about {distance} away. Follow official guidance.'**
  String alertStormBody(Object distance, Object name);

  /// No description provided for @severityInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get severityInfo;

  /// No description provided for @severityWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get severityWarning;

  /// No description provided for @severitySevere.
  ///
  /// In en, this message translates to:
  /// **'Severe'**
  String get severitySevere;

  /// No description provided for @stormsTitle.
  ///
  /// In en, this message translates to:
  /// **'Active cyclones'**
  String get stormsTitle;

  /// No description provided for @stormsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Nearest tropical systems, tracked by GDACS'**
  String get stormsSubtitle;

  /// No description provided for @stormsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No active tropical cyclones are being tracked right now.'**
  String get stormsEmpty;

  /// No description provided for @stormsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Cyclone data is unavailable right now.'**
  String get stormsUnavailable;

  /// No description provided for @stormDistance.
  ///
  /// In en, this message translates to:
  /// **'{distance} away'**
  String stormDistance(String distance);

  /// No description provided for @stormWind.
  ///
  /// In en, this message translates to:
  /// **'Winds {speed}'**
  String stormWind(String speed);

  /// No description provided for @stormSeverity.
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get stormSeverity;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @activePeriod.
  ///
  /// In en, this message translates to:
  /// **'Active period'**
  String get activePeriod;

  /// No description provided for @viewOnGdacs.
  ///
  /// In en, this message translates to:
  /// **'View on GDACS'**
  String get viewOnGdacs;

  /// No description provided for @stormDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Cyclone positions are approximate. Always follow your national meteorological service.'**
  String get stormDisclaimer;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About Ajwaa'**
  String get aboutTitle;

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'Ajwaa brings the weather, the rain, the dust and the local time of any city into one calm, glanceable screen — with live location, saved cities, Arabic and English.'**
  String get aboutBody;

  /// No description provided for @brandTitle.
  ///
  /// In en, this message translates to:
  /// **'Designed for clarity'**
  String get brandTitle;

  /// No description provided for @brandBody.
  ///
  /// In en, this message translates to:
  /// **'Warm light, quiet motion and honest data. No accounts, no ads, no tracking.'**
  String get brandBody;

  /// No description provided for @madeBy.
  ///
  /// In en, this message translates to:
  /// **'Made by Mohamed Ibrahim'**
  String get madeBy;

  /// No description provided for @licenses.
  ///
  /// In en, this message translates to:
  /// **'Open-source licenses'**
  String get licenses;

  /// No description provided for @dataProviderOpenMeteo.
  ///
  /// In en, this message translates to:
  /// **'Open-Meteo — weather, air quality & geocoding'**
  String get dataProviderOpenMeteo;

  /// No description provided for @dataProviderGdacs.
  ///
  /// In en, this message translates to:
  /// **'GDACS — global disaster alerts'**
  String get dataProviderGdacs;

  /// No description provided for @dataProviderBigDataCloud.
  ///
  /// In en, this message translates to:
  /// **'BigDataCloud — reverse geocoding'**
  String get dataProviderBigDataCloud;

  /// No description provided for @openSourceNote.
  ///
  /// In en, this message translates to:
  /// **'Free, open data. No API keys required.'**
  String get openSourceNote;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Check your network and try again.'**
  String get errorNetwork;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'The weather service took too long to respond.'**
  String get errorTimeout;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'The weather service is busy right now. Please try again shortly.'**
  String get errorServer;

  /// No description provided for @errorRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please wait a moment and try again.'**
  String get errorRateLimited;

  /// No description provided for @errorMalformed.
  ///
  /// In en, this message translates to:
  /// **'We received unexpected weather data.'**
  String get errorMalformed;

  /// No description provided for @errorNoCity.
  ///
  /// In en, this message translates to:
  /// **'Choose a city to see its weather.'**
  String get errorNoCity;

  /// No description provided for @errorLocation.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t get your location. Pick a city instead.'**
  String get errorLocation;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get errorUnknown;

  /// No description provided for @tempUnit.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get tempUnit;

  /// No description provided for @windUnit.
  ///
  /// In en, this message translates to:
  /// **'Wind'**
  String get windUnit;

  /// No description provided for @distanceUnit.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distanceUnit;

  /// No description provided for @a11yLanguageToggle.
  ///
  /// In en, this message translates to:
  /// **'Switch language'**
  String get a11yLanguageToggle;

  /// No description provided for @a11yRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh weather'**
  String get a11yRefresh;

  /// No description provided for @a11ySettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get a11ySettings;

  /// No description provided for @a11ySearch.
  ///
  /// In en, this message translates to:
  /// **'Search cities'**
  String get a11ySearch;

  /// No description provided for @a11yCityPicker.
  ///
  /// In en, this message translates to:
  /// **'Change city'**
  String get a11yCityPicker;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @swipeToRemove.
  ///
  /// In en, this message translates to:
  /// **'Swipe a city to remove it'**
  String get swipeToRemove;

  /// No description provided for @footerNote.
  ///
  /// In en, this message translates to:
  /// **'Forecasts by Open-Meteo · Storm alerts by GDACS'**
  String get footerNote;

  /// No description provided for @pullToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Pull down to refresh'**
  String get pullToRefresh;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get showMore;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;

  /// No description provided for @next7Days.
  ///
  /// In en, this message translates to:
  /// **'Next 7 days'**
  String get next7Days;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @gusts.
  ///
  /// In en, this message translates to:
  /// **'gusts'**
  String get gusts;

  /// No description provided for @direction.
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get direction;

  /// No description provided for @kmh.
  ///
  /// In en, this message translates to:
  /// **'km/h'**
  String get kmh;

  /// No description provided for @mph.
  ///
  /// In en, this message translates to:
  /// **'mph'**
  String get mph;

  /// No description provided for @celsius.
  ///
  /// In en, this message translates to:
  /// **'°C'**
  String get celsius;

  /// No description provided for @fahrenheit.
  ///
  /// In en, this message translates to:
  /// **'°F'**
  String get fahrenheit;

  /// No description provided for @percent.
  ///
  /// In en, this message translates to:
  /// **'%'**
  String get percent;

  /// No description provided for @weatherSummary.
  ///
  /// In en, this message translates to:
  /// **'{city}: {condition}, {temp}'**
  String weatherSummary(String city, String condition, String temp);

  /// No description provided for @cityPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a city'**
  String get cityPickerTitle;

  /// No description provided for @cityPickerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Weather and time update instantly'**
  String get cityPickerSubtitle;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Preferences saved automatically'**
  String get settingsSaved;

  /// No description provided for @chartSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected hour'**
  String get chartSelected;

  /// No description provided for @chartNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get chartNow;

  /// No description provided for @rainTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get rainTotalLabel;

  /// No description provided for @dustPeakLabel.
  ///
  /// In en, this message translates to:
  /// **'Peak'**
  String get dustPeakLabel;

  /// No description provided for @stormCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get stormCategory;

  /// No description provided for @retryHint.
  ///
  /// In en, this message translates to:
  /// **'Check your connection, then try again.'**
  String get retryHint;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Where are you?'**
  String get welcomeTitle;

  /// No description provided for @welcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Allow location access for instant local weather, or pick a city to begin.'**
  String get welcomeBody;

  /// No description provided for @allowLocation.
  ///
  /// In en, this message translates to:
  /// **'Allow location'**
  String get allowLocation;

  /// No description provided for @pickCity.
  ///
  /// In en, this message translates to:
  /// **'Pick a city'**
  String get pickCity;

  /// No description provided for @continueWithout.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get continueWithout;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @unitSystem.
  ///
  /// In en, this message translates to:
  /// **'Measurement system'**
  String get unitSystem;

  /// No description provided for @themeDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose how Ajwaa looks.'**
  String get themeDescription;

  /// No description provided for @languageDescription.
  ///
  /// In en, this message translates to:
  /// **'The whole app switches instantly, including direction.'**
  String get languageDescription;

  /// No description provided for @dataNote.
  ///
  /// In en, this message translates to:
  /// **'Weather models update hourly. The app refreshes automatically every 10 minutes while open.'**
  String get dataNote;

  /// No description provided for @lastSync.
  ///
  /// In en, this message translates to:
  /// **'Last sync'**
  String get lastSync;

  /// No description provided for @never.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get never;

  /// No description provided for @airQualityIndex.
  ///
  /// In en, this message translates to:
  /// **'Air quality index'**
  String get airQualityIndex;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @moderate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get moderate;

  /// No description provided for @unhealthySensitive.
  ///
  /// In en, this message translates to:
  /// **'Unhealthy for sensitive groups'**
  String get unhealthySensitive;

  /// No description provided for @unhealthy.
  ///
  /// In en, this message translates to:
  /// **'Unhealthy'**
  String get unhealthy;

  /// No description provided for @veryUnhealthy.
  ///
  /// In en, this message translates to:
  /// **'Very unhealthy'**
  String get veryUnhealthy;

  /// No description provided for @hazardous.
  ///
  /// In en, this message translates to:
  /// **'Hazardous'**
  String get hazardous;

  /// No description provided for @uvLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get uvLow;

  /// No description provided for @uvModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get uvModerate;

  /// No description provided for @uvHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get uvHigh;

  /// No description provided for @uvVeryHigh.
  ///
  /// In en, this message translates to:
  /// **'Very high'**
  String get uvVeryHigh;

  /// No description provided for @uvExtreme.
  ///
  /// In en, this message translates to:
  /// **'Extreme'**
  String get uvExtreme;

  /// No description provided for @dirN.
  ///
  /// In en, this message translates to:
  /// **'N'**
  String get dirN;

  /// No description provided for @dirNE.
  ///
  /// In en, this message translates to:
  /// **'NE'**
  String get dirNE;

  /// No description provided for @dirE.
  ///
  /// In en, this message translates to:
  /// **'E'**
  String get dirE;

  /// No description provided for @dirSE.
  ///
  /// In en, this message translates to:
  /// **'SE'**
  String get dirSE;

  /// No description provided for @dirS.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get dirS;

  /// No description provided for @dirSW.
  ///
  /// In en, this message translates to:
  /// **'SW'**
  String get dirSW;

  /// No description provided for @dirW.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get dirW;

  /// No description provided for @dirNW.
  ///
  /// In en, this message translates to:
  /// **'NW'**
  String get dirNW;

  /// No description provided for @airNow.
  ///
  /// In en, this message translates to:
  /// **'Air right now'**
  String get airNow;

  /// No description provided for @feelsLikeShort.
  ///
  /// In en, this message translates to:
  /// **'Feels'**
  String get feelsLikeShort;

  /// No description provided for @emptyStateTitle.
  ///
  /// In en, this message translates to:
  /// **'No weather yet'**
  String get emptyStateTitle;

  /// No description provided for @emptyStateBody.
  ///
  /// In en, this message translates to:
  /// **'Search for a city or allow location access to see the weather.'**
  String get emptyStateBody;

  /// No description provided for @showAllCities.
  ///
  /// In en, this message translates to:
  /// **'All cities'**
  String get showAllCities;

  /// No description provided for @manageCities.
  ///
  /// In en, this message translates to:
  /// **'Manage cities'**
  String get manageCities;

  /// No description provided for @refreshSuccess.
  ///
  /// In en, this message translates to:
  /// **'Weather is up to date'**
  String get refreshSuccess;

  /// No description provided for @tapChartHint.
  ///
  /// In en, this message translates to:
  /// **'Tap an hour to inspect it'**
  String get tapChartHint;

  /// No description provided for @detailsFor.
  ///
  /// In en, this message translates to:
  /// **'Details for {city}'**
  String detailsFor(Object city);

  /// No description provided for @a11yWeatherScene.
  ///
  /// In en, this message translates to:
  /// **'Weather illustration'**
  String get a11yWeatherScene;

  /// No description provided for @closeSheet.
  ///
  /// In en, this message translates to:
  /// **'Close panel'**
  String get closeSheet;

  /// No description provided for @dataUpdatedShort.
  ///
  /// In en, this message translates to:
  /// **'Updated {time}'**
  String dataUpdatedShort(Object time);

  /// No description provided for @precipChanceShort.
  ///
  /// In en, this message translates to:
  /// **'{value}%'**
  String precipChanceShort(Object value);

  /// No description provided for @setAsDefault.
  ///
  /// In en, this message translates to:
  /// **'Set as default'**
  String get setAsDefault;

  /// No description provided for @cityExists.
  ///
  /// In en, this message translates to:
  /// **'City already saved'**
  String get cityExists;

  /// No description provided for @mmUnit.
  ///
  /// In en, this message translates to:
  /// **'mm'**
  String get mmUnit;

  /// No description provided for @inUnit.
  ///
  /// In en, this message translates to:
  /// **'in'**
  String get inUnit;

  /// No description provided for @kmUnit.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get kmUnit;

  /// No description provided for @miUnit.
  ///
  /// In en, this message translates to:
  /// **'mi'**
  String get miUnit;

  /// No description provided for @hpaUnit.
  ///
  /// In en, this message translates to:
  /// **'hPa'**
  String get hpaUnit;

  /// No description provided for @microgramUnit.
  ///
  /// In en, this message translates to:
  /// **'µg/m³'**
  String get microgramUnit;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
