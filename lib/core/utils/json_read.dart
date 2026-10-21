/// Small, defensive readers for loosely-typed JSON.
///
/// Weather APIs occasionally return `null` inside numeric arrays, so every
/// accessor here is null-safe instead of relying on hard casts.
double readDouble(Object? value, [double fallback = 0]) =>
    value is num ? value.toDouble() : fallback;

double? readDoubleOrNull(Object? value) =>
    value is num ? value.toDouble() : null;

int readInt(Object? value, [int fallback = 0]) =>
    value is num ? value.toInt() : fallback;

int? readIntOrNull(Object? value) => value is num ? value.toInt() : null;

String readString(Object? value, [String fallback = '']) =>
    value is String ? value : fallback;

String? readStringOrNull(Object? value) =>
    value is String && value.trim().isNotEmpty ? value : null;

List<Object?> readList(Object? value) =>
    value is List ? value : const <Object?>[];

Map<String, dynamic> readMap(Object? value) =>
    value is Map<String, dynamic> ? value : const <String, dynamic>{};

DateTime? readUnixSeconds(Object? value) {
  if (value is! num) return null;
  return DateTime.fromMillisecondsSinceEpoch(value.toInt() * 1000, isUtc: true);
}

T? firstWhereOrNull<T>(Iterable<T> items, bool Function(T) test) {
  for (final item in items) {
    if (test(item)) return item;
  }
  return null;
}
