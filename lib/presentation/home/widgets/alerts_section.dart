import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/localized_text.dart';
import '../../../core/widgets/surface_card.dart';
import '../../../domain/alerts.dart';
import '../../../l10n/app_localizations.dart';
import '../../sheets/info_sheet.dart';
import '../../widgets/section_header.dart';

class AlertsSection extends StatelessWidget {
  const AlertsSection({
    super.key,
    required this.alerts,
    required this.fmt,
    required this.l10n,
  });

  final List<WeatherAlert> alerts;
  final Fmt fmt;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: l10n.alertsTitle,
          subtitle: l10n.alertsCount(alerts.length),
          trailing: alerts.isEmpty ? null : _CountBadge(count: alerts.length),
        ),
        if (alerts.isEmpty)
          SurfaceCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            color: AppColors.teal.withValues(
              alpha: context.isDark ? 0.08 : 0.10,
            ),
            borderColor: AppColors.teal.withValues(alpha: 0.25),
            child: Row(
              children: [
                const Icon(
                  Icons.verified_rounded,
                  color: AppColors.teal,
                  size: 22,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.noAlertsTitle, style: context.texts.titleSmall),
                      const SizedBox(height: 2),
                      Text(
                        l10n.noAlertsBody,
                        style: context.texts.bodySmall?.copyWith(
                          color: context.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 136,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: alerts.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
              itemBuilder: (context, index) {
                final alert = alerts[index];
                return SizedBox(
                  width: 300,
                  child: _AlertCard(alert: alert, fmt: fmt, l10n: l10n),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({
    required this.alert,
    required this.fmt,
    required this.l10n,
  });

  final WeatherAlert alert;
  final Fmt fmt;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final color = _severityColor(alert.severity);
    final value = _formatValue(alert);
    final title = alertTitle(l10n, alert.kind);
    final body = alertBody(l10n, alert.kind, value, name: alert.stormName);

    return SurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      onTap: () => showInfoSheet(
        context,
        title: title,
        icon: _iconFor(alert.kind),
        accent: color,
        value: value.isEmpty ? null : value,
        description: body,
        footnote: _severityLabel(l10n, alert.severity),
      ),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withValues(alpha: context.isDark ? 0.14 : 0.10),
          context.cardColor,
        ],
      ),
      borderColor: color.withValues(alpha: 0.28),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(_iconFor(alert.kind), color: color, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.texts.titleSmall,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        _severityLabel(l10n, alert.severity),
                        style: context.texts.labelSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w700,
                          fontSize: 9.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  body,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: context.texts.bodySmall?.copyWith(
                    color: context.muted,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatValue(WeatherAlert alert) {
    return switch (alert.kind) {
      AlertKind.heat || AlertKind.cold =>
        alert.value == null ? '' : fmt.temperature(alert.value!),
      AlertKind.wind => alert.value == null ? '' : fmt.wind(alert.value!),
      AlertKind.rain =>
        alert.value == null ? '' : fmt.precipitation(alert.value!),
      AlertKind.dust => alert.value == null ? '' : fmt.dust(alert.value!),
      AlertKind.uv => alert.value == null ? '' : fmt.uv(alert.value!),
      AlertKind.storm =>
        alert.distanceKm == null ? '' : fmt.distance(alert.distanceKm!),
      AlertKind.thunder => '',
    };
  }

  static IconData _iconFor(AlertKind kind) {
    return switch (kind) {
      AlertKind.heat => Icons.device_thermostat_rounded,
      AlertKind.cold => Icons.ac_unit_rounded,
      AlertKind.wind => Icons.air_rounded,
      AlertKind.rain => Icons.water_drop_rounded,
      AlertKind.dust => Icons.grain_rounded,
      AlertKind.uv => Icons.wb_sunny_rounded,
      AlertKind.thunder => Icons.thunderstorm_rounded,
      AlertKind.storm => Icons.cyclone_rounded,
    };
  }

  static Color _severityColor(AlertSeverity severity) {
    return switch (severity) {
      AlertSeverity.info => AppColors.teal,
      AlertSeverity.warning => AppColors.amber,
      AlertSeverity.severe => AppColors.coral,
    };
  }

  static String _severityLabel(AppLocalizations l10n, AlertSeverity severity) {
    return switch (severity) {
      AlertSeverity.info => l10n.severityInfo,
      AlertSeverity.warning => l10n.severityWarning,
      AlertSeverity.severe => l10n.severitySevere,
    };
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: context.colors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        '$count',
        style: context.texts.labelMedium?.copyWith(
          color: context.colors.primary,
          fontWeight: FontWeight.w700,
        ),
        textDirection: TextDirection.ltr,
      ),
    );
  }
}
