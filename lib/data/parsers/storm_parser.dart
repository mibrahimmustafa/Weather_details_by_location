import '../../core/utils/json_read.dart';
import '../../domain/geo.dart';
import '../models/storm.dart';

/// Parses either NASA EONET or GDACS payloads into active, distance-sorted
/// storms. The input is the wrapper produced by `StormApi`:
/// `{source: 'eonet'|'gdacs', payload: {...}}`.
class StormParser {
  static List<Storm> parse(
    Map<String, dynamic> wrapper, {
    required double latitude,
    required double longitude,
  }) {
    final source = readString(wrapper['source']);
    final payload = readMap(wrapper['payload']);
    final storms = source == 'eonet'
        ? _parseEonet(payload, latitude, longitude)
        : _parseGdacs(payload, latitude, longitude);
    storms.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return storms;
  }

  static List<Storm> _parseEonet(
    Map<String, dynamic> json,
    double latitude,
    double longitude,
  ) {
    final result = <Storm>[];
    for (final raw in readList(json['events'])) {
      final event = readMap(raw);
      final geometries = readList(event['geometry']);
      if (geometries.isEmpty) continue;

      final points = <({DateTime date, double lat, double lon, double wind})>[];
      for (final rawGeometry in geometries) {
        final geometry = readMap(rawGeometry);
        final coordinates = readList(geometry['coordinates']);
        if (coordinates.length < 2) continue;
        final lon = readDoubleOrNull(coordinates[0]);
        final lat = readDoubleOrNull(coordinates[1]);
        final date = DateTime.tryParse(readString(geometry['date']))?.toUtc();
        if (lon == null || lat == null || date == null) continue;
        final magnitude = readDouble(geometry['magnitudeValue']);
        final unit = readString(geometry['magnitudeUnit']).toLowerCase();
        final windKmh = unit.contains('kt') || unit.contains('knot')
            ? magnitude * 1.852
            : unit.contains('mph')
            ? magnitude * 1.60934
            : magnitude;
        points.add((date: date, lat: lat, lon: lon, wind: windKmh));
      }
      if (points.isEmpty) continue;
      points.sort((a, b) => a.date.compareTo(b.date));
      final latest = points.last;
      final first = points.first;
      final sources = readList(event['sources']);
      final source = sources.isEmpty
          ? const <String, dynamic>{}
          : readMap(sources.first);

      result.add(
        Storm(
          id: 'eonet_${readString(event['id'])}',
          name: readString(event['title'], 'Tropical cyclone'),
          alertLevel: _levelFromWind(latest.wind),
          country: '',
          latitude: latest.lat,
          longitude: latest.lon,
          distanceKm: distanceKm(latitude, longitude, latest.lat, latest.lon),
          maxWindKmh: latest.wind,
          fromUtc: first.date,
          toUtc: latest.date,
          source: readString(source['id'], 'EONET'),
          reportUrl: readStringOrNull(source['url']),
        ),
      );
    }
    return result;
  }

  static List<Storm> _parseGdacs(
    Map<String, dynamic> json,
    double latitude,
    double longitude,
  ) {
    final storms = <Storm>[];
    for (final raw in readList(json['features'])) {
      final feature = readMap(raw);
      if (!Storm.isCurrent(feature)) continue;
      final storm = Storm.tryParse(
        feature,
        fromLatitude: latitude,
        fromLongitude: longitude,
      );
      if (storm != null) storms.add(storm);
    }
    return storms;
  }

  static StormAlertLevel _levelFromWind(double kmh) {
    if (kmh >= 118) return StormAlertLevel.red;
    if (kmh >= 63) return StormAlertLevel.orange;
    return StormAlertLevel.green;
  }
}
