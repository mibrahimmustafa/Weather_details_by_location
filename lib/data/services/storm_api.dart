import '../../core/constants/app_info.dart';
import '../../core/errors/app_failure.dart';
import '../../core/network/api_client.dart';

/// Active tropical cyclones.
///
/// Primary source: NASA EONET — global, key-less and CORS-enabled, so the web
/// build works too. Fallback: GDACS, which adds official alert levels.
/// Both are free public services.
class StormApi {
  StormApi(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> fetchRaw({int lookBackDays = 45}) async {
    try {
      final payload = await _client.getJson(
        Uri.parse(ApiEndpoints.eonetStorms),
      );
      return {'source': 'eonet', 'payload': payload};
    } on AppFailure {
      final now = DateTime.now().toUtc();
      final from = now.subtract(Duration(days: lookBackDays));
      final uri = Uri.parse(ApiEndpoints.activeStorms).replace(
        queryParameters: {
          'eventlist': 'TC',
          'fromDate': _date(from),
          'toDate': _date(now.add(const Duration(days: 1))),
        },
      );
      final payload = await _client.getJson(uri);
      return {'source': 'gdacs', 'payload': payload};
    }
  }

  static String _date(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}
