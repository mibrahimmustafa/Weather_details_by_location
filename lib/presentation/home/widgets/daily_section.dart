import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/localized_text.dart';
import '../../../core/widgets/pressable_scale.dart';
import '../../../core/widgets/surface_card.dart';
import '../../../data/models/weather_bundle.dart';
import '../../../domain/weather_condition.dart';
import '../../../l10n/app_localizations.dart';
import '../../sheets/info_sheet.dart';
import '../../sheets/sheet_utils.dart';
import '../../widgets/section_header.dart';
import '../../widgets/weather_glyph.dart';

/// Seven-day outlook with weekly temperature range bars.
class DailySection extends StatelessWidget {
  const DailySection({
    super.key,
    required this.bundle,
    required this.fmt,
    required this.l10n,
  });

  final WeatherBundle bundle;
  final Fmt fmt;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final days = bundle.daily.take(7).toList(growable: false);
    if (days.isEmpty) return const SizedBox.shrink();

    var weekMin = days.first.temperatureMinC;
    var weekMax = days.first.temperatureMaxC;
    for (final day in days.skip(1)) {
      weekMin = math.min(weekMin, day.temperatureMinC);
      weekMax = math.max(weekMax, day.temperatureMaxC);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: l10n.dailyTitle,
          subtitle: l10n.dailySubtitle,
          trailing: Text(
            l10n.next7Days,
            style: context.texts.labelSmall?.copyWith(color: context.muted),
          ),
        ),
        SurfaceCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            children: [
              for (var i = 0; i < days.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    color: context.colors.outlineVariant.withValues(
                      alpha: 0.55,
                    ),
                  ),
                _DayRow(
                  day: days[i],
                  isToday: i == 0,
                  weekMin: weekMin,
                  weekMax: weekMax,
                  offsetSeconds: bundle.utcOffsetSeconds,
                  fmt: fmt,
                  l10n: l10n,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.day,
    required this.isToday,
    required this.weekMin,
    required this.weekMax,
    required this.offsetSeconds,
    required this.fmt,
    required this.l10n,
  });

  final DailyPoint day;
  final bool isToday;
  final double weekMin;
  final double weekMax;
  final int offsetSeconds;
  final Fmt fmt;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final local = day.dateUtc.add(Duration(seconds: offsetSeconds));
    final condition = conditionFromWmoCode(day.weatherCode);
    final dayLabel = fmt.dayLabel(day, offsetSeconds: offsetSeconds);

    return PressableScale(
      onTap: () => _open(context, condition, local),
      scale: 0.99,
      semanticLabel:
          '$dayLabel, ${conditionLabel(l10n, condition)}, '
          '${fmt.temperature(day.temperatureMaxC)} / ${fmt.temperature(day.temperatureMinC)}',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          color: isToday
              ? context.colors.primary.withValues(alpha: 0.07)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 78,
              child: Text(
                dayLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.texts.labelLarge?.copyWith(
                  color: isToday ? context.colors.primary : null,
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ),
            WeatherGlyph(code: day.weatherCode, isDay: true, size: 28),
            const SizedBox(width: AppSpacing.sm),
            SizedBox(
              width: 38,
              child: Row(
                children: [
                  Icon(
                    Icons.water_drop_rounded,
                    size: 9,
                    color: day.precipitationProbabilityMax > 0
                        ? const Color(0xFF49B7D8)
                        : context.muted.withValues(alpha: 0.35),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    fmt.percent(day.precipitationProbabilityMax),
                    style: context.texts.labelSmall?.copyWith(
                      fontSize: 9.5,
                      color: day.precipitationProbabilityMax > 0
                          ? const Color(0xFF3F9FC0)
                          : context.muted.withValues(alpha: 0.5),
                    ),
                    textDirection: TextDirection.ltr,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: _TempBar(
                  low: day.temperatureMinC,
                  high: day.temperatureMaxC,
                  weekMin: weekMin,
                  weekMax: weekMax,
                ),
              ),
            ),
            SizedBox(
              width: 72,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerEnd,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      fmt.temperature(day.temperatureMaxC),
                      style: context.texts.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      fmt.temperature(day.temperatureMinC),
                      style: context.texts.labelMedium?.copyWith(
                        color: context.muted,
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context, WeatherCondition condition, DateTime local) {
    showInfoSheet(
      context,
      title: fmt.weekday(local),
      icon: Icons.calendar_today_rounded,
      accent: context.colors.primary,
      value: l10n.highLow(
        fmt.temperature(day.temperatureMaxC),
        fmt.temperature(day.temperatureMinC),
      ),
      description: conditionLabel(l10n, condition),
      details: [
        DetailRow(
          icon: Icons.water_drop_rounded,
          label: l10n.chanceOfRain,
          value: fmt.percent(day.precipitationProbabilityMax),
        ),
        DetailRow(
          icon: Icons.umbrella_rounded,
          label: l10n.rainTotalLabel,
          value: fmt.precipitation(day.precipitationSumMm),
        ),
        DetailRow(
          icon: Icons.air_rounded,
          label: l10n.wind,
          value: fmt.wind(day.windSpeedMaxKmh),
        ),
        DetailRow(
          icon: Icons.wb_sunny_rounded,
          label: l10n.uvIndex,
          value: fmt.uv(day.uvIndexMax),
        ),
        if (day.sunriseUtc != null)
          DetailRow(
            icon: Icons.wb_twilight_rounded,
            label: l10n.sunrise,
            value: fmt.clockFromUtc(day.sunriseUtc!, offsetSeconds),
          ),
        if (day.sunsetUtc != null)
          DetailRow(
            icon: Icons.nightlight_round,
            label: l10n.sunset,
            value: fmt.clockFromUtc(day.sunsetUtc!, offsetSeconds),
          ),
      ],
      footnote: l10n.dailySubtitle,
    );
  }
}

class _TempBar extends StatelessWidget {
  const _TempBar({
    required this.low,
    required this.high,
    required this.weekMin,
    required this.weekMax,
  });

  final double low;
  final double high;
  final double weekMin;
  final double weekMax;

  @override
  Widget build(BuildContext context) {
    final span = math.max(1.0, weekMax - weekMin);
    final start = ((low - weekMin) / span).clamp(0.0, 1.0);
    final end = ((high - weekMin) / span).clamp(start + 0.06, 1.0);

    return SizedBox(
      height: 8,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final left = start * width;
          final barWidth = math.max(14.0, (end - start) * width);
          return Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.colors.outlineVariant.withValues(
                      alpha: context.isDark ? 0.35 : 0.55,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),
              Positioned(
                left: left.clamp(0, math.max(0, width - barWidth)),
                top: 0,
                bottom: 0,
                width: barWidth,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF5AB8E8),
                        Color(0xFFF2C15E),
                        Color(0xFFF08A5D),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
