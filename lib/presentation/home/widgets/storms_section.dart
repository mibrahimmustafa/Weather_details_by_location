import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/surface_card.dart';
import '../../../data/models/storm.dart';
import '../../../data/models/weather_bundle.dart';
import '../../../l10n/app_localizations.dart';
import '../../sheets/info_sheet.dart';
import '../../sheets/sheet_utils.dart';
import '../../widgets/section_header.dart';

/// Active tropical cyclones, closest first.
class StormsSection extends StatelessWidget {
  const StormsSection({
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
    final storms = [...bundle.storms]
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: l10n.stormsTitle,
          subtitle: l10n.stormsSubtitle,
          trailing: Icon(
            Icons.cyclone_rounded,
            size: 20,
            color: context.muted.withValues(alpha: 0.7),
          ),
        ),
        if (!bundle.stormsAvailable)
          _Notice(
            icon: Icons.cloud_off_rounded,
            text: l10n.stormsUnavailable,
            color: context.muted,
          )
        else if (storms.isEmpty)
          _Notice(
            icon: Icons.verified_rounded,
            text: l10n.stormsEmpty,
            color: AppColors.teal,
          )
        else
          Column(
            children: [
              for (var i = 0; i < storms.length && i < 4; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.sm),
                _StormCard(
                  storm: storms[i],
                  fmt: fmt,
                  l10n: l10n,
                  offsetSeconds: bundle.utcOffsetSeconds,
                ),
              ],
            ],
          ),
      ],
    );
  }
}

class _StormCard extends StatelessWidget {
  const _StormCard({
    required this.storm,
    required this.fmt,
    required this.l10n,
    required this.offsetSeconds,
  });

  final Storm storm;
  final Fmt fmt;
  final AppLocalizations l10n;
  final int offsetSeconds;

  @override
  Widget build(BuildContext context) {
    final color = stormColor(storm.alertLevel);
    final level = stormLevelLabel(l10n, storm.alertLevel);

    return SurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      onTap: () => showStormSheet(
        context,
        storm: storm,
        fmt: fmt,
        l10n: l10n,
        offsetSeconds: offsetSeconds,
      ),
      semanticLabel:
          '${storm.name} · ${l10n.stormDistance(fmt.distance(storm.distanceKm))}',
      borderColor: color.withValues(alpha: 0.26),
      gradient: LinearGradient(
        begin: AlignmentDirectional.topStart,
        end: AlignmentDirectional.bottomEnd,
        colors: [
          color.withValues(alpha: context.isDark ? 0.13 : 0.09),
          context.cardColor,
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.cyclone_rounded, color: color, size: 25),
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
                        storm.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.texts.titleSmall,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        level,
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
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: 3,
                  children: [
                    _Meta(
                      icon: Icons.near_me_rounded,
                      text: l10n.stormDistance(fmt.distance(storm.distanceKm)),
                    ),
                    _Meta(
                      icon: Icons.air_rounded,
                      text: l10n.stormWind(fmt.wind(storm.maxWindKmh)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: context.muted.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: context.muted),
        const SizedBox(width: 3),
        Text(
          text,
          style: context.texts.labelSmall?.copyWith(color: context.muted),
        ),
      ],
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.text, required this.color});

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: context.texts.bodySmall?.copyWith(color: context.muted),
            ),
          ),
        ],
      ),
    );
  }
}

Color stormColor(StormAlertLevel level) {
  return switch (level) {
    StormAlertLevel.green => AppColors.teal,
    StormAlertLevel.orange => AppColors.amber,
    StormAlertLevel.red => AppColors.coral,
  };
}

String stormLevelLabel(AppLocalizations l10n, StormAlertLevel level) {
  return switch (level) {
    StormAlertLevel.green => l10n.severityInfo,
    StormAlertLevel.orange => l10n.severityWarning,
    StormAlertLevel.red => l10n.severitySevere,
  };
}

Future<void> showStormSheet(
  BuildContext context, {
  required Storm storm,
  required Fmt fmt,
  required AppLocalizations l10n,
  required int offsetSeconds,
}) {
  final color = stormColor(storm.alertLevel);
  final range = _range(storm, fmt, offsetSeconds);

  return showAjwaaSheet<void>(
    context,
    SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.sm,
        AppSpacing.xxl,
        AppSpacing.xxxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SheetHeader(title: storm.name, subtitle: l10n.stormsTitle),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.cyclone_rounded, color: color, size: 28),
              ),
              const SizedBox(width: AppSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  stormLevelLabel(l10n, storm.alertLevel),
                  style: context.texts.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                l10n.stormDistance(fmt.distance(storm.distanceKm)),
                style: context.texts.labelLarge,
                textDirection: TextDirection.ltr,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          SurfaceDetails(
            children: [
              DetailRow(
                icon: Icons.air_rounded,
                label: l10n.wind,
                value: fmt.wind(storm.maxWindKmh),
              ),
              DetailRow(
                icon: Icons.near_me_rounded,
                label: l10n.distance,
                value: fmt.distance(storm.distanceKm),
              ),
              if (storm.country.isNotEmpty)
                DetailRow(
                  icon: Icons.public_rounded,
                  label: l10n.country,
                  value: storm.country,
                ),
              if (range != null)
                DetailRow(
                  icon: Icons.date_range_rounded,
                  label: l10n.activePeriod,
                  value: range,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: 15, color: context.muted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.stormDisclaimer,
                  style: context.texts.bodySmall?.copyWith(
                    color: context.muted,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          if (storm.reportUrl != null) ...[
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _openReport(context, storm.reportUrl!),
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: Text(l10n.viewOnGdacs),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

String? _range(Storm storm, Fmt fmt, int offsetSeconds) {
  final from = storm.fromUtc;
  final to = storm.toUtc;
  if (from == null && to == null) return null;
  final start = from == null
      ? ''
      : fmt.shortDate(from.add(Duration(seconds: offsetSeconds)));
  final end = to == null
      ? ''
      : fmt.shortDate(to.add(Duration(seconds: offsetSeconds)));
  if (start.isEmpty) return end;
  if (end.isEmpty || start == end) return start;
  return '$start – $end';
}

Future<void> _openReport(BuildContext context, String url) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = AppLocalizations.of(context);
  final uri = Uri.tryParse(url);
  if (uri == null) return;
  try {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) throw StateError('Could not open $url');
  } on Object {
    messenger.showSnackBar(SnackBar(content: Text(l10n.errorUnknown)));
  }
}
