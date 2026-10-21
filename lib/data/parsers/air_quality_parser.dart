import '../../core/utils/json_read.dart';
import '../models/weather_bundle.dart';

/// Parses air-quality payloads into current values plus hourly dust series.
class AirQualityParser {
  static AirSnapshot parse(Map<String, dynamic> json) {
    final currentMap = readMap(json['current']);
    final hourlyMap = readMap(json['hourly']);

    final current = AirQuality(
      pm10: readDoubleOrNull(currentMap['pm10']),
      pm25: readDoubleOrNull(currentMap['pm2_5']),
      dust: readDoubleOrNull(currentMap['dust']),
      usAqi: readIntOrNull(currentMap['us_aqi']),
      europeanAqi: readIntOrNull(currentMap['european_aqi']),
      uvIndex: readDoubleOrNull(currentMap['uv_index']),
    );

    return AirSnapshot(
      current: current,
      hourlyDust: _series(hourlyMap['time'], hourlyMap['dust']),
      hourlyPm10: _series(hourlyMap['time'], hourlyMap['pm10']),
    );
  }

  static Map<int, double> _series(Object? times, Object? values) {
    final timeList = readList(times);
    final valueList = readList(values);
    final result = <int, double>{};
    for (var i = 0; i < timeList.length && i < valueList.length; i++) {
      final time = readUnixSeconds(timeList[i]);
      final value = readDoubleOrNull(valueList[i]);
      if (time == null || value == null) continue;
      result[time.millisecondsSinceEpoch ~/ 1000] = value;
    }
    return result;
  }
}
