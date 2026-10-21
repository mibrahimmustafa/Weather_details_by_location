import '../../data/models/city.dart';

/// Curated starter cities. Names are provided in both languages so the picker
/// feels native before the user searches for anything.
class SuggestedCity {
  const SuggestedCity({
    required this.key,
    required this.nameEn,
    required this.nameAr,
    required this.countryEn,
    required this.countryAr,
    required this.countryCode,
    required this.latitude,
    required this.longitude,
    required this.timezone,
    this.adminEn,
    this.adminAr,
  });

  final String key;
  final String nameEn;
  final String nameAr;
  final String countryEn;
  final String countryAr;
  final String countryCode;
  final double latitude;
  final double longitude;
  final String timezone;
  final String? adminEn;
  final String? adminAr;

  City toCity(String languageCode) {
    final isArabic = languageCode == 'ar';
    return City(
      id: 'suggested_$key',
      name: isArabic ? nameAr : nameEn,
      country: isArabic ? countryAr : countryEn,
      admin1: isArabic ? adminAr : adminEn,
      countryCode: countryCode,
      latitude: latitude,
      longitude: longitude,
      timezone: timezone,
    );
  }
}

const List<SuggestedCity> kSuggestedCities = [
  SuggestedCity(
    key: 'cairo',
    nameEn: 'Cairo',
    nameAr: 'القاهرة',
    countryEn: 'Egypt',
    countryAr: 'مصر',
    countryCode: 'EG',
    latitude: 30.0444,
    longitude: 31.2357,
    timezone: 'Africa/Cairo',
    adminEn: 'Cairo Governorate',
    adminAr: 'محافظة القاهرة',
  ),
  SuggestedCity(
    key: 'riyadh',
    nameEn: 'Riyadh',
    nameAr: 'الرياض',
    countryEn: 'Saudi Arabia',
    countryAr: 'السعودية',
    countryCode: 'SA',
    latitude: 24.7136,
    longitude: 46.6753,
    timezone: 'Asia/Riyadh',
  ),
  SuggestedCity(
    key: 'dubai',
    nameEn: 'Dubai',
    nameAr: 'دبي',
    countryEn: 'United Arab Emirates',
    countryAr: 'الإمارات',
    countryCode: 'AE',
    latitude: 25.2048,
    longitude: 55.2708,
    timezone: 'Asia/Dubai',
  ),
  SuggestedCity(
    key: 'london',
    nameEn: 'London',
    nameAr: 'لندن',
    countryEn: 'United Kingdom',
    countryAr: 'المملكة المتحدة',
    countryCode: 'GB',
    latitude: 51.5074,
    longitude: -0.1278,
    timezone: 'Europe/London',
  ),
  SuggestedCity(
    key: 'istanbul',
    nameEn: 'Istanbul',
    nameAr: 'إسطنبول',
    countryEn: 'Türkiye',
    countryAr: 'تركيا',
    countryCode: 'TR',
    latitude: 41.0082,
    longitude: 28.9784,
    timezone: 'Europe/Istanbul',
  ),
  SuggestedCity(
    key: 'newyork',
    nameEn: 'New York',
    nameAr: 'نيويورك',
    countryEn: 'United States',
    countryAr: 'الولايات المتحدة',
    countryCode: 'US',
    latitude: 40.7128,
    longitude: -74.006,
    timezone: 'America/New_York',
    adminEn: 'New York',
    adminAr: 'نيويورك',
  ),
  SuggestedCity(
    key: 'tokyo',
    nameEn: 'Tokyo',
    nameAr: 'طوكيو',
    countryEn: 'Japan',
    countryAr: 'اليابان',
    countryCode: 'JP',
    latitude: 35.6762,
    longitude: 139.6503,
    timezone: 'Asia/Tokyo',
  ),
  SuggestedCity(
    key: 'paris',
    nameEn: 'Paris',
    nameAr: 'باريس',
    countryEn: 'France',
    countryAr: 'فرنسا',
    countryCode: 'FR',
    latitude: 48.8566,
    longitude: 2.3522,
    timezone: 'Europe/Paris',
  ),
];

City defaultCityFor(String languageCode) =>
    kSuggestedCities.first.toCity(languageCode);

List<City> suggestedCitiesFor(String languageCode) =>
    kSuggestedCities.map((city) => city.toCity(languageCode)).toList();
