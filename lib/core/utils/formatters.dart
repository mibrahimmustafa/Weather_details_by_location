import 'package:intl/intl.dart';

import '../../data/models/weather_bundle.dart';
import '../../domain/units.dart';
import '../../l10n/app_localizations.dart';

/// Locale-aware presentation of metric values.
///
/// Numbers always use Western digits (clearer in a data-dense weather UI),
/// while month and weekday names follow the active language.
class Fmt {
  Fmt({required this.l10n, required this.units, required this.locale});

  final AppLocalizations l10n;
  final UnitSystem units;
  final String locale;

  static final NumberFormat _integer = NumberFormat('#,##0', 'en');
  static final NumberFormat _oneDecimal = NumberFormat('#,##0.0', 'en');
  static final NumberFormat _twoDecimals = NumberFormat('#,##0.00', 'en');

  bool get _imperial => units == UnitSystem.imperial;

  String number(double value, {int decimals = 0}) {
    if (!value.isFinite) return '–';
    return switch (decimals) {
      0 => _integer.format(value),
      1 => _oneDecimal.format(value),
      _ => _twoDecimals.format(value),
    };
  }

  String temperature(double celsius, {int decimals = 0}) =>
      '${number(Units.temperature(celsius, units), decimals: decimals)}°';

  String temperatureWithUnit(double celsius) =>
      '${temperature(celsius)}${l10n.celsius == '°C' ? 'C' : ''}';

  String wind(double kmh) =>
      '${number(Units.wind(kmh, units))} ${_imperial ? l10n.mph : l10n.kmh}';

  String precipitation(double mm) {
    if (_imperial) {
      return '${number(Units.precipitation(mm, units), decimals: mm == 0 ? 0 : 2)} ${l10n.inUnit}';
    }
    return '${number(mm, decimals: mm == 0 ? 0 : 1)} ${l10n.mmUnit}';
  }

  String precipitationValue(double mm) {
    if (_imperial) {
      return number(Units.precipitation(mm, units), decimals: 2);
    }
    return number(mm, decimals: 1);
  }

  String visibility(double km) {
    final value = Units.distance(km, units);
    return '${number(value, decimals: value < 10 ? 1 : 0)} ${_imperial ? l10n.miUnit : l10n.kmUnit}';
  }

  String distance(double km) {
    final value = Units.distance(km, units);
    return '${number(value)} ${_imperial ? l10n.miUnit : l10n.kmUnit}';
  }

  String pressure(double hpa) => '${number(hpa)} ${l10n.hpaUnit}';

  String dust(double microgramsPerCubicMetre) =>
      '${number(microgramsPerCubicMetre)} ${l10n.microgramUnit}';

  String pm(double microgramsPerCubicMetre) =>
      number(microgramsPerCubicMetre, decimals: 1);

  String uv(double index) => number(index, decimals: 1);

  String percent(num value) => '${number(value.toDouble())}${l10n.percent}';

  /// Formats a "city-local" DateTime (already offset-shifted) as 24-hour time.
  String clock(DateTime cityLocal, {bool seconds = false}) {
    final hh = cityLocal.hour.toString().padLeft(2, '0');
    final mm = cityLocal.minute.toString().padLeft(2, '0');
    if (!seconds) return '$hh:$mm';
    final ss = cityLocal.second.toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }

  String clockFromUtc(
    DateTime utc,
    int offsetSeconds, {
    bool seconds = false,
  }) => clock(utc.add(Duration(seconds: offsetSeconds)), seconds: seconds);

  String weekday(DateTime cityLocal) =>
      DateFormat('EEEE', locale).format(cityLocal);

  String weekdayShort(DateTime cityLocal) =>
      DateFormat('EEE', locale).format(cityLocal);

  String month(DateTime cityLocal) =>
      DateFormat('MMMM', locale).format(cityLocal);

  String fullDate(DateTime cityLocal) =>
      '${weekday(cityLocal)} · ${cityLocal.day} ${month(cityLocal)}';

  String shortDate(DateTime cityLocal) =>
      '${cityLocal.day} ${month(cityLocal)}';

  String dayLabel(DailyPoint day, {required int offsetSeconds}) {
    final local = day.dateUtc.add(Duration(seconds: offsetSeconds));
    final now = DateTime.now().toUtc().add(Duration(seconds: offsetSeconds));
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(local.year, local.month, local.day);
    final difference = target.difference(today).inDays;
    if (difference == 0) return l10n.today;
    if (difference == 1) return l10n.tomorrow;
    return weekdayShort(local);
  }

  String relativeUpdated(DateTime fetchedAtUtc) {
    final diff = DateTime.now().toUtc().difference(fetchedAtUtc);
    if (diff.inSeconds < 60) return l10n.justNow;
    if (diff.inMinutes < 60) return l10n.updatedMinutesAgo(diff.inMinutes);
    final local = fetchedAtUtc.toLocal();
    return l10n.updatedAt(DateFormat('HH:mm', 'en').format(local));
  }

  String direction(double degrees) {
    final index = (((degrees % 360) + 22.5) ~/ 45) % 8;
    return switch (index) {
      0 => l10n.dirN,
      1 => l10n.dirNE,
      2 => l10n.dirE,
      3 => l10n.dirSE,
      4 => l10n.dirS,
      5 => l10n.dirSW,
      6 => l10n.dirW,
      _ => l10n.dirNW,
    };
  }

  String gmtOffset(int seconds) {
    final sign = seconds < 0 ? '-' : '+';
    final absolute = seconds.abs();
    final hours = absolute ~/ 3600;
    final minutes = (absolute % 3600) ~/ 60;
    final hh = hours.toString().padLeft(2, '0');
    if (minutes == 0) return 'GMT$sign$hh';
    final mm = minutes.toString().padLeft(2, '0');
    return 'GMT$sign$hh:$mm';
  }
}
