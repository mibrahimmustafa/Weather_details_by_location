import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/localized_text.dart';
import '../../../core/widgets/pressable_scale.dart';
import '../../../data/models/weather_bundle.dart';
import '../../../domain/units.dart';
import '../../../l10n/app_localizations.dart';
import '../../theme/weather_palette.dart';
import '../../widgets/live_clock.dart';
import '../../widgets/weather_glyph.dart';
import '../../widgets/weather_scene.dart';

/// The signature card: current conditions, the city clock and a living sky.
class HeroCard extends StatelessWidget {
  const HeroCard({
    super.key,
    required this.bundle,
    required this.fmt,
    required this.l10n,
    required this.onPickCity,
    required this.onRefresh,
    required this.onToggleUnits,
    required this.refreshing,
    required this.units,
  });

  final WeatherBundle bundle;
  final Fmt fmt;
  final AppLocalizations l10n;
  final VoidCallback onPickCity;
  final VoidCallback onRefresh;
  final VoidCallback onToggleUnits;
  final bool refreshing;
  final UnitSystem units;

  @override
  Widget build(BuildContext context) {
    final palette = WeatherPalette.of(
      bundle.condition,
      isDay: bundle.current.isDay,
    );
    final cityName = bundle.city.isCurrentLocation && bundle.city.name.isEmpty
        ? l10n.currentLocation
        : bundle.city.name;
    final localNow = DateTime.now().toUtc().add(
      Duration(seconds: bundle.utcOffsetSeconds),
    );
    final today = bundle.today;
    final temp = fmt.temperature(bundle.current.temperatureC);

    return Semantics(
      container: true,
      label: l10n.weatherSummary(
        cityName,
        conditionLabel(l10n, bundle.condition),
        fmt.temperature(bundle.current.temperatureC),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: palette.linearGradient,
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          boxShadow: [
            BoxShadow(
              color: palette.gradient.last.withValues(alpha: 0.35),
              blurRadius: 42,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: WeatherScene(
                condition: bundle.condition,
                isDay: bundle.current.isDay,
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: AlignmentDirectional.topStart,
                      end: AlignmentDirectional.bottomEnd,
                      colors: [
                        Colors.black.withValues(alpha: 0.30),
                        Colors.black.withValues(alpha: 0.04),
                        Colors.black.withValues(alpha: 0.28),
                      ],
                      stops: const [0, 0.5, 1],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.xl,
                AppSpacing.xxl,
                AppSpacing.xl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: _CityChip(
                          bundle: bundle,
                          l10n: l10n,
                          name: cityName,
                          onTap: onPickCity,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _StatusChip(
                        label: bundle.isFromCache
                            ? l10n.cachedData
                            : l10n.liveData,
                        color: bundle.isFromCache
                            ? AppColors.gold
                            : AppColors.tealSoft,
                      ),
                    ],
                  ),
                  const SizedBox(height: 38),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 450),
                                  switchInCurve: Curves.easeOutCubic,
                                  transitionBuilder: (child, animation) =>
                                      FadeTransition(
                                        opacity: animation,
                                        child: ScaleTransition(
                                          scale: Tween<double>(
                                            begin: 0.94,
                                            end: 1,
                                          ).animate(animation),
                                          child: child,
                                        ),
                                      ),
                                  child: Text(
                                    temp,
                                    key: ValueKey(temp),
                                    textDirection: TextDirection.ltr,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayLarge
                                        ?.copyWith(
                                          fontSize: 82,
                                          height: 0.95,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: -3,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.18,
                                              ),
                                              blurRadius: 18,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: _UnitChip(
                                    units: units,
                                    onTap: onToggleUnits,
                                    tooltip: l10n.unitSystem,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              conditionLabel(l10n, bundle.condition),
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 21,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: AppSpacing.md,
                              runSpacing: 4,
                              children: [
                                _HeroMeta(
                                  text:
                                      '${l10n.feelsLike} ${fmt.temperature(bundle.current.feelsLikeC)}',
                                ),
                                if (today != null)
                                  _HeroMeta(
                                    text: l10n.highLow(
                                      fmt.temperature(today.temperatureMaxC),
                                      fmt.temperature(today.temperatureMinC),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 2),
                        child: WeatherGlyph(
                          code: bundle.current.weatherCode,
                          isDay: bundle.current.isDay,
                          size: 78,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Container(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule_rounded,
                                  size: 14,
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  l10n.localTime,
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: Colors.white.withValues(
                                          alpha: 0.72,
                                        ),
                                        letterSpacing: 0.4,
                                      ),
                                ),
                                const SizedBox(width: 7),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.pill,
                                    ),
                                  ),
                                  child: Text(
                                    fmt.gmtOffset(bundle.utcOffsetSeconds),
                                    textDirection: TextDirection.ltr,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: Colors.white.withValues(
                                            alpha: 0.85,
                                          ),
                                          fontSize: 10,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            LiveClock(
                              offsetSeconds: bundle.utcOffsetSeconds,
                              style: Theme.of(context).textTheme.headlineLarge
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.8,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              fmt.fullDate(localNow),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.82),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _RefreshButton(
                            refreshing: refreshing,
                            onTap: onRefresh,
                            label: l10n.refresh,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          SizedBox(
                            width: 116,
                            child: Text(
                              refreshing
                                  ? l10n.updating
                                  : fmt.relativeUpdated(bundle.fetchedAt),
                              textAlign: TextAlign.end,
                              maxLines: 2,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.72),
                                    height: 1.3,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CityChip extends StatelessWidget {
  const _CityChip({
    required this.bundle,
    required this.l10n,
    required this.name,
    required this.onTap,
  });

  final WeatherBundle bundle;
  final AppLocalizations l10n;
  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      semanticLabel: l10n.a11yCityPicker,
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(10, 8, 10, 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.place_rounded, size: 15, color: Colors.white),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (bundle.city.isCurrentLocation) ...[
              const SizedBox(width: 5),
              Icon(
                Icons.my_location_rounded,
                size: 12,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ],
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.7), blurRadius: 6),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMeta extends StatelessWidget {
  const _HeroMeta({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Colors.white.withValues(alpha: 0.86),
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _UnitChip extends StatelessWidget {
  const _UnitChip({
    required this.units,
    required this.onTap,
    required this.tooltip,
  });

  final UnitSystem units;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: PressableScale(
        onTap: onTap,
        scale: 0.92,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: Text(
              units == UnitSystem.metric ? '°C' : '°F',
              key: ValueKey(units),
              textDirection: TextDirection.ltr,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RefreshButton extends StatefulWidget {
  const _RefreshButton({
    required this.refreshing,
    required this.onTap,
    required this.label,
  });

  final bool refreshing;
  final VoidCallback onTap;
  final String label;

  @override
  State<_RefreshButton> createState() => _RefreshButtonState();
}

class _RefreshButtonState extends State<_RefreshButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    if (widget.refreshing) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant _RefreshButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refreshing && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.refreshing && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.label,
      child: PressableScale(
        onTap: widget.refreshing ? null : widget.onTap,
        semanticLabel: widget.label,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
          ),
          child: RotationTransition(
            turns: _controller,
            child: const Icon(
              Icons.refresh_rounded,
              size: 20,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
