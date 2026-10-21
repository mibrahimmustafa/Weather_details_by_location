import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/localized_text.dart';
import '../../../core/widgets/pressable_scale.dart';
import '../../../data/models/weather_bundle.dart';
import '../../../domain/weather_condition.dart';
import '../../../l10n/app_localizations.dart';
import '../../sheets/info_sheet.dart';
import '../../sheets/sheet_utils.dart';
import '../../widgets/section_header.dart';
import '../../widgets/weather_glyph.dart';

class HourlySection extends StatelessWidget {
  const HourlySection({
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
    final hours = bundle.upcomingHours(count: 24);
    if (hours.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: l10n.hourlyTitle,
          subtitle: l10n.hourlySubtitle,
          trailing: Text(
            '24h',
            style: context.texts.labelMedium?.copyWith(
              color: context.muted,
              letterSpacing: 0.5,
            ),
            textDirection: TextDirection.ltr,
          ),
        ),
        SizedBox(
          height: 152,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: hours.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final point = hours[index];
              return _HourTile(
                point: point,
                isNow: index == 0,
                isDay: bundle.isDaylightAt(point.timeUtc),
                offsetSeconds: bundle.utcOffsetSeconds,
                fmt: fmt,
                l10n: l10n,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HourTile extends StatelessWidget {
  const _HourTile({
    required this.point,
    required this.isNow,
    required this.isDay,
    required this.offsetSeconds,
    required this.fmt,
    required this.l10n,
  });

  final HourlyPoint point;
  final bool isNow;
  final bool isDay;
  final int offsetSeconds;
  final Fmt fmt;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final local = point.timeUtc.add(Duration(seconds: offsetSeconds));
    final accent = context.colors.primary;

    return PressableScale(
      onTap: () => showInfoSheet(
        context,
        title: isNow ? l10n.chartNow : fmt.clock(local),
        icon: Icons.schedule_rounded,
        accent: accent,
        value: fmt.temperature(point.temperatureC),
        description: conditionLabel(
          l10n,
          conditionFromWmoCode(point.weatherCode),
        ),
        details: [
          DetailRow(
            icon: Icons.water_drop_rounded,
            label: l10n.chanceOfRain,
            value: fmt.percent(point.precipitationProbability),
          ),
          DetailRow(
            icon: Icons.grain_rounded,
            label: l10n.precipitation,
            value: fmt.precipitation(point.precipitationMm),
          ),
          DetailRow(
            icon: Icons.air_rounded,
            label: l10n.wind,
            value: fmt.wind(point.windSpeedKmh),
          ),
          DetailRow(
            icon: Icons.visibility_rounded,
            label: l10n.visibility,
            value: fmt.visibility(point.visibilityKm),
          ),
          if (point.dustUgM3 != null)
            DetailRow(
              icon: Icons.grain_rounded,
              label: l10n.dust,
              value: fmt.dust(point.dustUgM3!),
            ),
        ],
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 6),
        decoration: BoxDecoration(
          color: isNow ? accent.withValues(alpha: 0.14) : context.cardColor,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isNow ? accent.withValues(alpha: 0.45) : context.cardBorder,
            width: isNow ? 1.2 : 1,
          ),
          boxShadow: context.softShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isNow ? l10n.chartNow : fmt.clock(local),
              textDirection: TextDirection.ltr,
              style: context.texts.labelSmall?.copyWith(
                color: isNow ? accent : context.muted,
                fontWeight: isNow ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            WeatherGlyph(code: point.weatherCode, isDay: isDay, size: 31),
            Text(
              fmt.temperature(point.temperatureC),
              textDirection: TextDirection.ltr,
              style: context.texts.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.water_drop_rounded,
                  size: 9,
                  color: point.precipitationProbability > 0
                      ? const Color(0xFF49B7D8)
                      : context.muted.withValues(alpha: 0.4),
                ),
                const SizedBox(width: 2),
                Text(
                  fmt.percent(point.precipitationProbability),
                  textDirection: TextDirection.ltr,
                  style: context.texts.labelSmall?.copyWith(
                    fontSize: 9.5,
                    color: point.precipitationProbability > 0
                        ? const Color(0xFF49B7D8)
                        : context.muted.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
