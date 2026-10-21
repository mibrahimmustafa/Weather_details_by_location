import '../../core/utils/json_read.dart';
import '../../domain/geo.dart' as geo;

enum StormAlertLevel { green, orange, red }

/// A tropical cyclone reported by GDACS.
class Storm {
  const Storm({
    required this.id,
    required this.name,
    required this.alertLevel,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    required this.maxWindKmh,
    this.fromUtc,
    this.toUtc,
    this.source = '',
    this.reportUrl,
  });

  final String id;
  final String name;
  final StormAlertLevel alertLevel;
  final String country;
  final double latitude;
  final double longitude;
  final double distanceKm;
  final double maxWindKmh;
  final DateTime? fromUtc;
  final DateTime? toUtc;
  final String source;
  final String? reportUrl;

  /// Parses one GeoJSON feature from the GDACS event list.
  ///
  /// GDACS mixes strings and booleans (`"iscurrent": "true"`), so the parser
  /// accepts both. Returns `null` for features without usable coordinates.
  static Storm? tryParse(
    Map<String, dynamic> feature, {
    required double fromLatitude,
    required double fromLongitude,
  }) {
    final geometry = readMap(feature['geometry']);
    final coordinates = readList(geometry['coordinates']);
    if (coordinates.length < 2) return null;
    final longitude = readDoubleOrNull(coordinates[0]);
    final latitude = readDoubleOrNull(coordinates[1]);
    if (latitude == null || longitude == null) return null;

    final properties = readMap(feature['properties']);
    final eventId = readInt(properties['eventid']);
    final episodeId = readInt(properties['episodeid']);
    final name = readString(
      properties['eventname'],
      readString(properties['name'], 'Tropical cyclone'),
    );
    final severity = readMap(properties['severitydata']);
    final urls = readMap(properties['url']);

    return Storm(
      id: '$eventId-$episodeId',
      name: name,
      alertLevel: _parseAlertLevel(properties['alertlevel']),
      country: readString(properties['country']),
      latitude: latitude,
      longitude: longitude,
      distanceKm: geo.distanceKm(
        fromLatitude,
        fromLongitude,
        latitude,
        longitude,
      ),
      maxWindKmh: readDouble(severity['severity']),
      fromUtc: DateTime.tryParse(readString(properties['fromdate']))?.toUtc(),
      toUtc: DateTime.tryParse(readString(properties['todate']))?.toUtc(),
      source: readString(properties['source']),
      reportUrl: readStringOrNull(urls['report']),
    );
  }

  static bool isCurrent(Map<String, dynamic> feature) {
    final properties = readMap(feature['properties']);
    final value = properties['iscurrent'];
    return value == true || value == 'true';
  }

  static StormAlertLevel _parseAlertLevel(Object? value) {
    switch (readString(value).toLowerCase()) {
      case 'red':
        return StormAlertLevel.red;
      case 'orange':
        return StormAlertLevel.orange;
      default:
        return StormAlertLevel.green;
    }
  }
}
