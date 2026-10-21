/// A city the user can see weather for.
///
/// [isCurrentLocation] cities are refreshed by GPS; regular cities come from
/// Open-Meteo geocoding search.
class City {
  const City({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.country = '',
    this.admin1,
    this.countryCode,
    this.timezone,
    this.isCurrentLocation = false,
  });

  static const String currentLocationId = 'current-location';

  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String country;
  final String? admin1;
  final String? countryCode;
  final String? timezone;
  final bool isCurrentLocation;

  City copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    String? country,
    String? admin1,
    String? countryCode,
    String? timezone,
    bool? isCurrentLocation,
  }) {
    return City(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      country: country ?? this.country,
      admin1: admin1 ?? this.admin1,
      countryCode: countryCode ?? this.countryCode,
      timezone: timezone ?? this.timezone,
      isCurrentLocation: isCurrentLocation ?? this.isCurrentLocation,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'latitude': latitude,
    'longitude': longitude,
    'country': country,
    'admin1': admin1,
    'countryCode': countryCode,
    'timezone': timezone,
    'isCurrentLocation': isCurrentLocation,
  };

  factory City.fromJson(Map<String, dynamic> json) => City(
    id: json['id'] as String,
    name: (json['name'] as String?) ?? '',
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    country: (json['country'] as String?) ?? '',
    admin1: json['admin1'] as String?,
    countryCode: json['countryCode'] as String?,
    timezone: json['timezone'] as String?,
    isCurrentLocation: json['isCurrentLocation'] == true,
  );

  @override
  bool operator ==(Object other) => other is City && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'City($id, $name)';
}
