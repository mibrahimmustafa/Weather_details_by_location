// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'أجواء';

  @override
  String get appTagline => 'الطقس والوقت، أينما كنت';

  @override
  String appVersionLabel(String version) {
    return 'الإصدار $version';
  }

  @override
  String get language => 'اللغة';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get settings => 'الإعدادات';

  @override
  String get theme => 'المظهر';

  @override
  String get themeSystem => 'النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get units => 'الوحدات';

  @override
  String get unitsMetric => '°C · كم/س';

  @override
  String get unitsImperial => '°F · ميل/س';

  @override
  String get appearance => 'المظهر واللغة';

  @override
  String get aboutApp => 'عن أجواء';

  @override
  String get dataSources => 'مصادر البيانات';

  @override
  String get privacy => 'الخصوصية';

  @override
  String get privacyBody =>
      'يُستخدم موقعك على جهازك فقط لجلب حالة الطقس، ولا يُرسل إلينا أو يُخزَّن على أي خادم. المدن المحفوظة وآخر توقعات تبقى على جهازك.';

  @override
  String get version => 'الإصدار';

  @override
  String get builtWith => 'صُنع بـ Flutter · بيانات مجانية ومفتوحة';

  @override
  String get searchCity => 'ابحث عن مدينة';

  @override
  String get searchHint => 'اسم المدينة، مثل: القاهرة';

  @override
  String get searchNoResults => 'لا توجد مدن مطابقة لبحثك.';

  @override
  String get searchResults => 'نتائج البحث';

  @override
  String get searchPrompt => 'اكتب حرفين على الأقل للبحث.';

  @override
  String get searchError => 'تعذر البحث الآن. تحقق من اتصالك وحاول مجددًا.';

  @override
  String get popularCities => 'مدن شائعة';

  @override
  String get savedCities => 'مدنك المحفوظة';

  @override
  String get currentLocation => 'موقعي الحالي';

  @override
  String get currentLocationBadge => 'موقع مباشر';

  @override
  String get useMyLocation => 'استخدم موقعي الحالي';

  @override
  String get locate => 'حدد موقعي';

  @override
  String get locating => 'جارٍ تحديد موقعك…';

  @override
  String get locationDenied => 'نحتاج إذن الموقع لعرض طقس منطقتك.';

  @override
  String get locationDeniedForever =>
      'الموقع محظور. فعّله من إعدادات الجهاز، أو اختر مدينة يدويًا.';

  @override
  String get locationServiceDisabled =>
      'خدمة الموقع متوقفة. فعّلها أو اختر مدينة يدويًا.';

  @override
  String get locationTimeout =>
      'استغرق تحديد الموقع وقتًا طويلًا. حاول مجددًا أو اختر مدينة.';

  @override
  String get locationFailed => 'لم نتمكن من تحديد موقعك.';

  @override
  String get noCities => 'لا توجد مدن محفوظة بعد.';

  @override
  String get addCity => 'إضافة مدينة';

  @override
  String get removeCity => 'حذف المدينة';

  @override
  String cityAdded(String city) {
    return 'أُضيفت $city إلى مدنك.';
  }

  @override
  String cityRemoved(String city) {
    return 'تم حذف $city.';
  }

  @override
  String get refresh => 'تحديث';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get close => 'إغلاق';

  @override
  String get done => 'تم';

  @override
  String get cancel => 'إلغاء';

  @override
  String get openLink => 'فتح الرابط';

  @override
  String get updated => 'آخر تحديث';

  @override
  String get updating => 'جارٍ التحديث…';

  @override
  String updatedAt(String time) {
    return 'آخر تحديث $time';
  }

  @override
  String updatedMinutesAgo(int count) {
    return 'منذ $count دقيقة';
  }

  @override
  String get justNow => 'الآن';

  @override
  String get offlineTitle => 'لا يوجد اتصال';

  @override
  String get offlineBody => 'نعرض آخر توقعات محفوظة لهذه المدينة.';

  @override
  String get cachedData => 'بيانات محفوظة';

  @override
  String get liveData => 'مباشر';

  @override
  String get feelsLike => 'يُشعر كأنه';

  @override
  String highLow(String high, String low) {
    return 'العظمى $high · الصغرى $low';
  }

  @override
  String get humidity => 'الرطوبة';

  @override
  String get rain => 'الأمطار';

  @override
  String get rainChance => 'احتمال الأمطار';

  @override
  String get precipitation => 'الهطول';

  @override
  String get dust => 'الغبار';

  @override
  String get wind => 'الرياح';

  @override
  String get windGusts => 'هبات الرياح';

  @override
  String get uvIndex => 'مؤشر الأشعة';

  @override
  String get pressure => 'الضغط الجوي';

  @override
  String get visibility => 'مدى الرؤية';

  @override
  String get cloudCover => 'الغطاء السحابي';

  @override
  String get sunrise => 'الشروق';

  @override
  String get sunset => 'الغروب';

  @override
  String get airQuality => 'جودة الهواء';

  @override
  String get dewPoint => 'نقطة الندى';

  @override
  String get temperature => 'درجة الحرارة';

  @override
  String get details => 'التفاصيل';

  @override
  String get weatherDetails => 'تفاصيل الطقس';

  @override
  String get conditionClear => 'صحو';

  @override
  String get conditionMainlyClear => 'صحو غالبًا';

  @override
  String get conditionPartlyCloudy => 'غائم جزئيًا';

  @override
  String get conditionCloudy => 'غائم';

  @override
  String get conditionFog => 'ضباب';

  @override
  String get conditionDrizzle => 'رذاذ';

  @override
  String get conditionRain => 'أمطار';

  @override
  String get conditionHeavyRain => 'أمطار غزيرة';

  @override
  String get conditionFreezingRain => 'أمطار متجمدة';

  @override
  String get conditionSnow => 'ثلوج';

  @override
  String get conditionThunderstorm => 'عواصف رعدية';

  @override
  String get conditionDust => 'غبار في الجو';

  @override
  String get conditionUnknown => 'أجواء متقلبة';

  @override
  String get now => 'الآن';

  @override
  String get localTime => 'التوقيت المحلي';

  @override
  String get timezone => 'المنطقة الزمنية';

  @override
  String get today => 'اليوم';

  @override
  String get tomorrow => 'غدًا';

  @override
  String get hourlyTitle => 'الساعات الـ24 القادمة';

  @override
  String get hourlySubtitle => 'الحرارة واحتمال الأمطار والرياح';

  @override
  String get dailyTitle => 'توقعات 7 أيام';

  @override
  String get dailySubtitle => 'العظمى والصغرى واحتمال الأمطار';

  @override
  String get chanceOfRain => 'احتمال الأمطار';

  @override
  String get rainToday => 'أمطار اليوم';

  @override
  String get rainNext24h => 'أمطار خلال 24 ساعة';

  @override
  String get nextRain => 'أقرب أمطار';

  @override
  String get noRainNext24h => 'لا تُتوقع أمطار خلال الساعات الـ24 القادمة.';

  @override
  String rainInHours(int hours) {
    return 'خلال $hours ساعة تقريبًا';
  }

  @override
  String get rainNow => 'الأمطار تهطل الآن';

  @override
  String get rainStopped => 'لا أمطار الآن';

  @override
  String get rainChartTitle => 'الأمطار خلال 12 ساعة';

  @override
  String get precipAmount => 'الكمية';

  @override
  String get humidityHint => 'نسبة بخار الماء في الهواء على ارتفاع مترين.';

  @override
  String get windHint => 'رياح مستمرة على ارتفاع 10 أمتار، مع الهبات.';

  @override
  String get dustHint => 'تركيز الغبار العالق قرب سطح الأرض.';

  @override
  String get uvHint =>
      '0–2 منخفض · 3–5 متوسط · 6–7 مرتفع · 8–10 مرتفع جدًا · 11+ بالغ.';

  @override
  String get pressureHint =>
      'الضغط عند سطح البحر. انخفاضه قد يعني أجواء متقلبة.';

  @override
  String get visibilityHint => 'مدى الرؤية الأفقية قرب الأرض.';

  @override
  String get cloudsHint => 'نسبة السماء المغطاة بالسحب.';

  @override
  String get rainHint => 'إجمالي الهطول السائل المتوقع خلال 24 ساعة.';

  @override
  String get rainAndDustTitle => 'الأمطار والغبار';

  @override
  String get rainAndDustSubtitle => 'حالة الهواء ساعة بساعة';

  @override
  String get dustTitle => 'الغبار والهواء';

  @override
  String get dustLevel => 'مستوى الغبار';

  @override
  String get dustLow => 'منخفض';

  @override
  String get dustModerate => 'متوسط';

  @override
  String get dustHigh => 'مرتفع';

  @override
  String get dustVeryHigh => 'مرتفع جدًا';

  @override
  String get dustAdviceLow => 'الهواء صافٍ، ووقت مناسب للخروج.';

  @override
  String get dustAdviceModerate =>
      'قد يلاحظ أصحاب الحساسية تغيرًا في الهواء. فكّر في ارتداء كمامة بالخارج.';

  @override
  String get dustAdviceHigh =>
      'قلل النشاط خارج المنزل، وأغلق النوافذ، وارتدِ كمامة.';

  @override
  String get dustAdviceVeryHigh =>
      'تجنب الخروج. أحكم إغلاق النوافذ واستخدم منقي الهواء إن توفر.';

  @override
  String get dustTrendTitle => 'الغبار خلال 12 ساعة';

  @override
  String get dustConcentration => 'تركيز الغبار';

  @override
  String get pm10 => 'PM10';

  @override
  String get pm25 => 'PM2.5';

  @override
  String get alertsTitle => 'التنبيهات';

  @override
  String get noAlertsTitle => 'الأجواء مستقرة';

  @override
  String get noAlertsBody => 'لا تُتوقع مخاطر جوية مهمة في الوقت الحالي.';

  @override
  String alertsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تنبيه',
      many: '$count تنبيهًا',
      few: '$count تنبيهات',
      two: 'تنبيهان',
      one: 'تنبيه واحد',
      zero: 'لا تنبيهات',
    );
    return '$_temp0';
  }

  @override
  String get alertHeatTitle => 'حرارة شديدة';

  @override
  String get alertColdTitle => 'برد قارس';

  @override
  String get alertWindTitle => 'رياح قوية';

  @override
  String get alertRainTitle => 'أمطار غزيرة';

  @override
  String get alertDustTitle => 'عاصفة غبار';

  @override
  String get alertUvTitle => 'أشعة فوق بنفسجية عالية';

  @override
  String get alertThunderTitle => 'عواصف رعدية';

  @override
  String get alertStormTitle => 'إعصار قريب';

  @override
  String alertHeatBody(Object value) {
    return 'الإحساس الحراري $value. ابقَ في الظل، واشرب الماء، وتجنب شمس الظهيرة.';
  }

  @override
  String alertColdBody(Object value) {
    return 'الإحساس الحراري $value. ارتدِ ملابس دافئة وقلل البقاء خارج المنزل.';
  }

  @override
  String alertWindBody(Object value) {
    return 'هبات تصل إلى $value. ثبّت الأشياء المتطايرة وخذ حذرك بالخارج.';
  }

  @override
  String alertRainBody(Object value) {
    return 'يُتوقع هطول $value قريبًا. تجنب الطرق المنخفضة ومجاري السيول.';
  }

  @override
  String alertDustBody(Object value) {
    return 'تركيز الغبار يصل إلى $value. أغلق النوافذ وارتدِ كمامة عند الخروج.';
  }

  @override
  String alertUvBody(Object value) {
    return 'مؤشر الأشعة يصل إلى $value. استخدم واقي الشمس والنظارة والقبعة.';
  }

  @override
  String get alertThunderBody =>
      'عواصف رعدية قريبة. ابقَ في الداخل وتجنب الأماكن المفتوحة.';

  @override
  String alertStormBody(Object distance, Object name) {
    return '$name يبعد نحو $distance. اتبع إرشادات الجهات الرسمية.';
  }

  @override
  String get severityInfo => 'معلومة';

  @override
  String get severityWarning => 'تحذير';

  @override
  String get severitySevere => 'خطر';

  @override
  String get stormsTitle => 'الأعاصير النشطة';

  @override
  String get stormsSubtitle => 'أقرب الأنظمة المدارية، بحسب GDACS';

  @override
  String get stormsEmpty => 'لا تُرصد أعاصير مدارية نشطة الآن.';

  @override
  String get stormsUnavailable => 'بيانات الأعاصير غير متوفرة حاليًا.';

  @override
  String stormDistance(String distance) {
    return 'يبعد $distance';
  }

  @override
  String stormWind(String speed) {
    return 'رياح $speed';
  }

  @override
  String get stormSeverity => 'الشدة';

  @override
  String get distance => 'المسافة';

  @override
  String get country => 'الدولة';

  @override
  String get activePeriod => 'فترة النشاط';

  @override
  String get viewOnGdacs => 'عرض على GDACS';

  @override
  String get stormDisclaimer =>
      'مواقع الأعاصير تقديرية. اتبع دائمًا هيئة الأرصاد الوطنية.';

  @override
  String get aboutTitle => 'عن أجواء';

  @override
  String get aboutBody =>
      'أجواء يجمع الطقس والأمطار والغبار والتوقيت المحلي لأي مدينة في شاشة واحدة هادئة وسهلة القراءة — مع الموقع المباشر والمدن المحفوظة والعربية والإنجليزية.';

  @override
  String get brandTitle => 'مصمّم للوضوح';

  @override
  String get brandBody =>
      'ضوء دافئ، حركة هادئة، وبيانات صادقة. بلا حسابات، بلا إعلانات، بلا تتبع.';

  @override
  String get madeBy => 'صنعه محمد إبراهيم';

  @override
  String get licenses => 'تراخيص المصادر المفتوحة';

  @override
  String get dataProviderOpenMeteo => 'Open-Meteo — الطقس وجودة الهواء والمدن';

  @override
  String get dataProviderGdacs => 'GDACS — تنبيهات الكوارث العالمية';

  @override
  String get dataProviderBigDataCloud => 'BigDataCloud — تحديد اسم الموقع';

  @override
  String get openSourceNote => 'بيانات مجانية ومفتوحة، بلا مفاتيح API.';

  @override
  String get errorGeneric => 'حدث خطأ ما. حاول مرة أخرى.';

  @override
  String get errorNetwork =>
      'لا يوجد اتصال بالإنترنت. تحقق من الشبكة وحاول مجددًا.';

  @override
  String get errorTimeout => 'تأخرت خدمة الطقس في الرد.';

  @override
  String get errorServer => 'خدمة الطقس مشغولة الآن. حاول بعد قليل.';

  @override
  String get errorRateLimited => 'طلبات كثيرة جدًا. انتظر لحظات ثم حاول.';

  @override
  String get errorMalformed => 'وصلتنا بيانات طقس غير متوقعة.';

  @override
  String get errorNoCity => 'اختر مدينة لعرض حالة طقسها.';

  @override
  String get errorLocation =>
      'لم نتمكن من معرفة موقعك. اختر مدينة بدلًا من ذلك.';

  @override
  String get errorUnknown => 'حدث خطأ غير متوقع.';

  @override
  String get tempUnit => 'الحرارة';

  @override
  String get windUnit => 'الرياح';

  @override
  String get distanceUnit => 'المسافة';

  @override
  String get a11yLanguageToggle => 'تغيير اللغة';

  @override
  String get a11yRefresh => 'تحديث الطقس';

  @override
  String get a11ySettings => 'فتح الإعدادات';

  @override
  String get a11ySearch => 'البحث عن مدن';

  @override
  String get a11yCityPicker => 'تغيير المدينة';

  @override
  String get selected => 'محددة';

  @override
  String get swipeToRemove => 'اسحب المدينة لحذفها';

  @override
  String get footerNote => 'التوقعات من Open-Meteo · تنبيهات الأعاصير من GDACS';

  @override
  String get pullToRefresh => 'اسحب للأسفل للتحديث';

  @override
  String get loading => 'جارٍ التحميل…';

  @override
  String get showMore => 'المزيد';

  @override
  String get showLess => 'أقل';

  @override
  String get next7Days => 'الأيام السبعة القادمة';

  @override
  String get high => 'العظمى';

  @override
  String get low => 'الصغرى';

  @override
  String get gusts => 'هبات';

  @override
  String get direction => 'الاتجاه';

  @override
  String get kmh => 'كم/س';

  @override
  String get mph => 'ميل/س';

  @override
  String get celsius => '°C';

  @override
  String get fahrenheit => '°F';

  @override
  String get percent => '%';

  @override
  String weatherSummary(String city, String condition, String temp) {
    return '$city: $condition، $temp';
  }

  @override
  String get cityPickerTitle => 'اختر مدينة';

  @override
  String get cityPickerSubtitle => 'الطقس والوقت يتحدثان فورًا';

  @override
  String get settingsSaved => 'تُحفظ تفضيلاتك تلقائيًا';

  @override
  String get chartSelected => 'الساعة المحددة';

  @override
  String get chartNow => 'الآن';

  @override
  String get rainTotalLabel => 'الإجمالي';

  @override
  String get dustPeakLabel => 'الذروة';

  @override
  String get stormCategory => 'التصنيف';

  @override
  String get retryHint => 'تحقق من اتصالك ثم حاول مرة أخرى.';

  @override
  String get welcomeTitle => 'أين أنت؟';

  @override
  String get welcomeBody =>
      'اسمح بالوصول إلى موقعك لعرض طقسك فورًا، أو اختر مدينة للبدء.';

  @override
  String get allowLocation => 'السماح بالموقع';

  @override
  String get pickCity => 'اختر مدينة';

  @override
  String get continueWithout => 'ليس الآن';

  @override
  String get openSettings => 'فتح الإعدادات';

  @override
  String get unitSystem => 'نظام القياس';

  @override
  String get themeDescription => 'اختر شكل أجواء.';

  @override
  String get languageDescription =>
      'يتغير التطبيق كاملًا فورًا، بما في ذلك اتجاه النص.';

  @override
  String get dataNote =>
      'تُحدَّث نماذج الطقس كل ساعة. ويُحدَّث التطبيق تلقائيًا كل 10 دقائق أثناء فتحه.';

  @override
  String get lastSync => 'آخر مزامنة';

  @override
  String get never => 'أبدًا';

  @override
  String get airQualityIndex => 'مؤشر جودة الهواء';

  @override
  String get good => 'جيد';

  @override
  String get moderate => 'متوسط';

  @override
  String get unhealthySensitive => 'غير صحي للفئات الحساسة';

  @override
  String get unhealthy => 'غير صحي';

  @override
  String get veryUnhealthy => 'غير صحي جدًا';

  @override
  String get hazardous => 'خطير';

  @override
  String get uvLow => 'منخفض';

  @override
  String get uvModerate => 'متوسط';

  @override
  String get uvHigh => 'مرتفع';

  @override
  String get uvVeryHigh => 'مرتفع جدًا';

  @override
  String get uvExtreme => 'بالغ';

  @override
  String get dirN => 'شمال';

  @override
  String get dirNE => 'شمال شرق';

  @override
  String get dirE => 'شرق';

  @override
  String get dirSE => 'جنوب شرق';

  @override
  String get dirS => 'جنوب';

  @override
  String get dirSW => 'جنوب غرب';

  @override
  String get dirW => 'غرب';

  @override
  String get dirNW => 'شمال غرب';

  @override
  String get airNow => 'الهواء الآن';

  @override
  String get feelsLikeShort => 'الإحساس';

  @override
  String get emptyStateTitle => 'لا توجد بيانات بعد';

  @override
  String get emptyStateBody =>
      'ابحث عن مدينة أو اسمح بالوصول إلى موقعك لعرض الطقس.';

  @override
  String get showAllCities => 'كل المدن';

  @override
  String get manageCities => 'إدارة المدن';

  @override
  String get refreshSuccess => 'الطقس محدَّث';

  @override
  String get tapChartHint => 'اضغط على ساعة لاستعراض قيمتها';

  @override
  String detailsFor(Object city) {
    return 'تفاصيل $city';
  }

  @override
  String get a11yWeatherScene => 'رسم توضيحي للطقس';

  @override
  String get closeSheet => 'إغلاق اللوحة';

  @override
  String dataUpdatedShort(Object time) {
    return 'محدَّث $time';
  }

  @override
  String precipChanceShort(Object value) {
    return '$value%';
  }

  @override
  String get setAsDefault => 'تعيين كافتراضي';

  @override
  String get cityExists => 'المدينة محفوظة بالفعل';

  @override
  String get mmUnit => 'ملم';

  @override
  String get inUnit => 'بوصة';

  @override
  String get kmUnit => 'كم';

  @override
  String get miUnit => 'ميل';

  @override
  String get hpaUnit => 'هكتوباسكال';

  @override
  String get microgramUnit => 'ميكروغرام/م³';
}
