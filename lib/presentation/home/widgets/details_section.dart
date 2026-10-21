import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/localized_text.dart';
import '../../../core/widgets/surface_card.dart';
import '../../../data/models/weather_bundle.dart';
import '../../../domain/environment_levels.dart';
import '../../../domain/units.dart';
import '../../../l10n/app_localizations.dart';
import '../../sheets/info_sheet.dart';
import '../../sheets/sheet_utils.dart';
import '../../widgets/section_header.dart';
import '../../widgets/sun_path.dart';

class DetailsSection extends StatelessWidget {
  const DetailsSection({
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
    final current = bundle.current;
    final air = bundle.air;
    final uv = air.uvIndex ?? current.uvIndex;
    final next24 = bundle.upcomingHours(count: 24);
    final rainChance = next24.isEmpty
        ? 0
        : next24
              .map((point) => point.precipitationProbability)
              .reduce((a, b) => a > b ? a : b);
    final rainTotal = bundle.precipitationNext(hours: 24);
    final condition = conditionLabel(l10n, bundle.condition);

    final metrics = <_Metric>[
      _Metric(
        icon: Icons.water_drop_rounded,
        color: const Color(0xFF4CA8D8),
        label: l10n.humidity,
        value: fmt.percent(current.relativeHumidity),
        sub: '${l10n.dewPoint} ${fmt.temperature(current.dewPointC)}',
        hint: l10n.humidityHint,
        details: [
          DetailRow(
            icon: Icons.water_drop_outlined,
            label: l10n.humidity,
            value: fmt.percent(current.relativeHumidity),
          ),
          DetailRow(
            icon: Icons.thermostat_rounded,
            label: l10n.dewPoint,
            value: fmt.temperature(current.dewPointC),
          ),
        ],
      ),
      _Metric(
        icon: Icons.air_rounded,
        color: AppColors.teal,
        label: l10n.wind,
        value: fmt.wind(current.windSpeedKmh),
        sub:
            '${fmt.direction(current.windDirectionDeg)} · ${l10n.windGusts} ${fmt.wind(current.windGustKmh)}',
        hint: l10n.windHint,
        details: [
          DetailRow(
            icon: Icons.explore_rounded,
            label: l10n.direction,
            value:
                '${fmt.direction(current.windDirectionDeg)} · ${current.windDirectionDeg.round()}°',
          ),
          DetailRow(
            icon: Icons.air_rounded,
            label: l10n.wind,
            value: fmt.wind(current.windSpeedKmh),
          ),
          DetailRow(
            icon: Icons.storm_rounded,
            label: l10n.windGusts,
            value: fmt.wind(current.windGustKmh),
          ),
        ],
      ),
      _Metric(
        icon: Icons.umbrella_rounded,
        color: const Color(0xFF3FA9D6),
        label: l10n.rainChance,
        value: fmt.percent(rainChance),
        sub: '${l10n.rainTotalLabel} ${fmt.precipitation(rainTotal)}',
        hint: l10n.rainHint,
        details: [
          DetailRow(
            icon: Icons.umbrella_rounded,
            label: l10n.chanceOfRain,
            value: fmt.percent(rainChance),
          ),
          DetailRow(
            icon: Icons.water_drop_rounded,
            label: l10n.rainNext24h,
            value: fmt.precipitation(rainTotal),
          ),
        ],
      ),
      _Metric(
        icon: Icons.wb_sunny_rounded,
        color: AppColors.gold,
        label: l10n.uvIndex,
        value: fmt.uv(uv),
        sub: uvLevelLabel(l10n, uvLevelFor(uv)),
        hint: l10n.uvHint,
        details: [
          DetailRow(
            icon: Icons.wb_sunny_rounded,
            label: l10n.uvIndex,
            value: fmt.uv(uv),
          ),
          DetailRow(
            icon: Icons.info_outline_rounded,
            label: l10n.details,
            value: uvLevelLabel(l10n, uvLevelFor(uv)),
          ),
        ],
      ),
      _Metric(
        icon: Icons.speed_rounded,
        color: const Color(0xFF9C8CFF),
        label: l10n.pressure,
        value: fmt.number(current.pressureHpa),
        sub: l10n.hpaUnit,
        hint: l10n.pressureHint,
        details: [
          DetailRow(
            icon: Icons.speed_rounded,
            label: l10n.pressure,
            value: fmt.pressure(current.pressureHpa),
          ),
        ],
      ),
      _Metric(
        icon: Icons.visibility_rounded,
        color: const Color(0xFF7A9AB8),
        label: l10n.visibility,
        value: fmt.number(
          Units.distance(current.visibilityKm, fmt.units),
          decimals: current.visibilityKm < 10 ? 1 : 0,
        ),
        sub: fmt.units == UnitSystem.metric ? l10n.kmUnit : l10n.miUnit,
        hint: l10n.visibilityHint,
        details: [
          DetailRow(
            icon: Icons.visibility_rounded,
            label: l10n.visibility,
            value: fmt.visibility(current.visibilityKm),
          ),
        ],
      ),
      _Metric(
        icon: Icons.cloud_rounded,
        color: const Color(0xFF8CA0B4),
        label: l10n.cloudCover,
        value: fmt.percent(current.cloudCover),
        sub: condition,
        hint: l10n.cloudsHint,
        details: [
          DetailRow(
            icon: Icons.cloud_rounded,
            label: l10n.cloudCover,
            value: fmt.percent(current.cloudCover),
          ),
          DetailRow(
            icon: Icons.thermostat_rounded,
            label: l10n.feelsLike,
            value: fmt.temperature(current.feelsLikeC),
          ),
        ],
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: l10n.weatherDetails,
          subtitle: l10n.detailsFor(
            bundle.city.isCurrentLocation && bundle.city.name.isEmpty
                ? l10n.currentLocation
                : bundle.city.name,
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 640 ? 3 : 2;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: metrics.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                mainAxisExtent: 132,
              ),
              itemBuilder: (context, index) {
                final metric = metrics[index];
                return SurfaceCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  onTap: () => showInfoSheet(
                    context,
                    title: metric.label,
                    icon: metric.icon,
                    accent: metric.color,
                    value: metric.value,
                    description: metric.hint,
                    details: metric.details,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: metric.color.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Icon(
                              metric.icon,
                              size: 17,
                              color: metric.color,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              metric.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.texts.labelMedium?.copyWith(
                                color: context.muted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        metric.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.ltr,
                        style: context.texts.titleLarge?.copyWith(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        metric.sub,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.texts.labelSmall?.copyWith(
                          color: context.muted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: AppSpacing.md),
        SunPath(bundle: bundle, fmt: fmt, l10n: l10n),
      ],
    );
  }
}

class _Metric {
  const _Metric({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.sub,
    required this.hint,
    required this.details,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String sub;
  final String hint;
  final List<Widget> details;
}
