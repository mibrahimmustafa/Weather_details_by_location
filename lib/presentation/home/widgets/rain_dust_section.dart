import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/localized_text.dart';
import '../../../core/widgets/surface_card.dart';
import '../../../data/models/weather_bundle.dart';
import '../../../domain/environment_levels.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/charts.dart';
import '../../widgets/section_header.dart';

class RainDustSection extends StatelessWidget {
  const RainDustSection({
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
    final rainCard = _RainCard(bundle: bundle, fmt: fmt, l10n: l10n);
    final dustCard = _DustCard(bundle: bundle, fmt: fmt, l10n: l10n);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: l10n.rainAndDustTitle,
          subtitle: l10n.rainAndDustSubtitle,
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 720) {
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: rainCard),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: dustCard),
                  ],
                ),
              );
            }
            return Column(
              children: [
                rainCard,
                const SizedBox(height: AppSpacing.md),
                dustCard,
              ],
            );
          },
        ),
      ],
    );
  }
}

class _RainCard extends StatelessWidget {
  const _RainCard({
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
    final chance = hours.fold<int>(
      0,
      (value, point) => math.max(value, point.precipitationProbability),
    );
    final total = bundle.precipitationNext(hours: 24);
    final rainIndex = bundle.hoursUntilRain(withinHours: 24);
    final chartPoints = bundle.upcomingHours(count: 12);

    final String nextRain;
    if (bundle.current.precipitationMm >= 0.15) {
      nextRain = l10n.rainNow;
    } else if (rainIndex == null) {
      nextRain = l10n.noRainNext24h;
    } else if (rainIndex == 0) {
      nextRain = l10n.rainInHours(1);
    } else {
      nextRain = '${l10n.nextRain} · ${l10n.rainInHours(rainIndex)}';
    }

    return SurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconBadge(
                icon: Icons.water_drop_rounded,
                color: const Color(0xFF3FA9D6),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(l10n.rain, style: context.texts.titleMedium),
              ),
              _MetricPill(
                icon: Icons.umbrella_rounded,
                text: fmt.percent(chance),
                color: const Color(0xFF3FA9D6),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            fmt.precipitation(total),
            style: context.texts.headlineMedium?.copyWith(
              fontSize: 26,
              fontWeight: FontWeight.w600,
            ),
            textDirection: TextDirection.ltr,
          ),
          const SizedBox(height: 1),
          Text(
            l10n.rainNext24h,
            style: context.texts.bodySmall?.copyWith(color: context.muted),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.schedule_rounded,
                size: 13,
                color: AppColors.sky,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  nextRain,
                  style: context.texts.labelSmall?.copyWith(
                    color: context.isDark
                        ? const Color(0xFF8FD8F2)
                        : const Color(0xFF1F7EA3),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          RainChart(
            points: chartPoints,
            offsetSeconds: bundle.utcOffsetSeconds,
            fmt: fmt,
            l10n: l10n,
          ),
          const SizedBox(height: 4),
          _TapHint(text: l10n.tapChartHint),
        ],
      ),
    );
  }
}

class _DustCard extends StatelessWidget {
  const _DustCard({
    required this.bundle,
    required this.fmt,
    required this.l10n,
  });

  final WeatherBundle bundle;
  final Fmt fmt;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final air = bundle.air;
    final dust = air.dust ?? air.pm10;
    final aqi = air.usAqi ?? air.europeanAqi;

    if (dust == null) {
      return SurfaceCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _IconBadge(
                  icon: Icons.grain_rounded,
                  color: const Color(0xFFC98B45),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(l10n.dustTitle, style: context.texts.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.dustHint,
              style: context.texts.bodySmall?.copyWith(color: context.muted),
            ),
          ],
        ),
      );
    }

    final level = dustLevelFor(dust);
    final color = _dustColor(level);
    final points = <({DateTime time, double value})>[];
    for (final hour in bundle.upcomingHours(count: 12)) {
      final value = hour.dustUgM3 ?? hour.pm10;
      if (value != null) points.add((time: hour.timeUtc, value: value));
    }

    return SurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconBadge(icon: Icons.grain_rounded, color: color),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(l10n.dustTitle, style: context.texts.titleMedium),
              ),
              _MetricPill(text: dustLevelLabel(l10n, level), color: color),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  fmt.dust(dust),
                  style: context.texts.headlineMedium?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                  textDirection: TextDirection.ltr,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  l10n.dustConcentration,
                  style: context.texts.labelSmall?.copyWith(
                    color: context.muted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            dustAdvice(l10n, level),
            style: context.texts.bodySmall?.copyWith(
              color: context.muted,
              height: 1.5,
            ),
          ),
          if (points.length >= 2) ...[
            const SizedBox(height: AppSpacing.lg),
            DustChart(
              points: points,
              offsetSeconds: bundle.utcOffsetSeconds,
              fmt: fmt,
              l10n: l10n,
            ),
            const SizedBox(height: 4),
            _TapHint(text: l10n.tapChartHint),
          ],
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              if (air.pm10 != null)
                _MiniChip(label: l10n.pm10, value: fmt.pm(air.pm10!)),
              if (air.pm25 != null)
                _MiniChip(label: l10n.pm25, value: fmt.pm(air.pm25!)),
              if (aqi != null)
                _MiniChip(
                  label: l10n.airQualityIndex,
                  value: '$aqi',
                  color: _aqiColor(aqiLevelFor(aqi)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static Color _dustColor(DustLevel level) {
    return switch (level) {
      DustLevel.low => AppColors.teal,
      DustLevel.moderate => AppColors.amber,
      DustLevel.high => const Color(0xFFD98345),
      DustLevel.veryHigh => AppColors.coral,
    };
  }

  static Color _aqiColor(AqiLevel level) {
    return switch (level) {
      AqiLevel.good => AppColors.teal,
      AqiLevel.moderate => AppColors.amber,
      AqiLevel.unhealthySensitive => const Color(0xFFD98345),
      AqiLevel.unhealthy => AppColors.coral,
      AqiLevel.veryUnhealthy => const Color(0xFFB5548B),
      AqiLevel.hazardous => const Color(0xFF8E4B6B),
    };
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({this.icon, required this.text, required this.color});

  final IconData? icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            textDirection: text.contains('°') ? TextDirection.ltr : null,
            style: context.texts.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: context.isDark
            ? Colors.white.withValues(alpha: 0.05)
            : const Color(0xFFF1F6FC),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: context.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: context.texts.labelSmall?.copyWith(
              color: context.muted,
              fontSize: 9.5,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            value,
            textDirection: TextDirection.ltr,
            style: context.texts.labelSmall?.copyWith(
              color: color ?? context.colors.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _TapHint extends StatelessWidget {
  const _TapHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.touch_app_rounded,
          size: 11,
          color: context.muted.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: context.texts.labelSmall?.copyWith(
            color: context.muted.withValues(alpha: 0.7),
            fontSize: 9.5,
          ),
        ),
      ],
    );
  }
}
