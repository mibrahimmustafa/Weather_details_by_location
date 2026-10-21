import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/localized_text.dart';
import '../../core/widgets/reveal.dart';
import '../../core/widgets/surface_card.dart';
import '../../data/models/weather_bundle.dart';
import '../../domain/alerts.dart';
import '../../domain/units.dart';
import '../../l10n/app_localizations.dart';
import '../../state/settings_controller.dart';
import '../../state/weather_controller.dart';
import '../sheets/city_picker_sheet.dart';
import '../sheets/settings_sheet.dart';
import '../sheets/welcome_sheet.dart';
import '../theme/weather_palette.dart';
import '../widgets/ajwaa_logo.dart';
import '../widgets/language_switch.dart';
import 'widgets/alerts_section.dart';
import 'widgets/daily_section.dart';
import 'widgets/details_section.dart';
import 'widgets/error_view.dart';
import 'widgets/footer.dart';
import 'widgets/hero_card.dart';
import 'widgets/hourly_section.dart';
import 'widgets/loading_skeleton.dart';
import 'widgets/rain_dust_section.dart';
import 'widgets/storms_section.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  static const Duration _autoRefreshEvery = Duration(minutes: 10);

  Timer? _autoRefreshTimer;
  bool _refreshing = false;
  bool _welcomeScheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _autoRefreshTimer = Timer.periodic(
      _autoRefreshEvery,
      (_) => _autoRefresh(),
    );
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _autoRefresh();
  }

  Future<void> _autoRefresh() async {
    if (!mounted) return;
    if (!ref.read(weatherProvider).hasValue) return;
    try {
      await ref.read(weatherProvider.notifier).refresh();
    } on Object {
      // Background refresh failures stay silent; the cache remains visible.
    }
  }

  Future<void> _refresh({bool feedback = true}) async {
    if (_refreshing) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _refreshing = true);
    try {
      await ref.read(weatherProvider.notifier).refresh();
      if (!mounted) return;
      if (feedback) _snack(l10n.refreshSuccess);
    } on Object catch (error) {
      if (!mounted) return;
      _snack(failureMessage(l10n, error));
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openCityPicker() async {
    if (!mounted) return;
    await showCityPickerSheet(context);
  }

  Future<void> _openSettings() async {
    if (!mounted) return;
    await showSettingsSheet(context);
  }

  void _maybeShowWelcome() {
    if (_welcomeScheduled) return;
    if (ref.read(settingsProvider).hasSeenWelcome) return;
    _welcomeScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showWelcomeSheet(context, onPickCity: () => unawaited(_openCityPicker()));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final weather = ref.watch(weatherProvider);
    final bundle = weather.asData?.value;
    final fmt = Fmt(
      l10n: l10n,
      units: settings.unitSystem,
      locale: settings.localeCode,
    );
    final palette = bundle == null
        ? null
        : WeatherPalette.of(bundle.condition, isDay: bundle.current.isDay);

    _maybeShowWelcome();

    final children = <Widget>[
      _Header(
        l10n: l10n,
        onSearch: () => unawaited(_openCityPicker()),
        onSettings: () => unawaited(_openSettings()),
      ),
      if (bundle != null) ...[
        HeroCard(
          bundle: bundle,
          fmt: fmt,
          l10n: l10n,
          onPickCity: () => unawaited(_openCityPicker()),
          onRefresh: _refresh,
          onToggleUnits: () => ref
              .read(settingsProvider.notifier)
              .setUnitSystem(
                settings.unitSystem == UnitSystem.metric
                    ? UnitSystem.imperial
                    : UnitSystem.metric,
              ),
          refreshing: _refreshing,
          units: settings.unitSystem,
        ),
        if (bundle.isFromCache)
          _OfflineBanner(bundle: bundle, fmt: fmt, l10n: l10n),
        AlertsSection(alerts: buildWeatherAlerts(bundle), fmt: fmt, l10n: l10n),
        HourlySection(bundle: bundle, fmt: fmt, l10n: l10n),
        RainDustSection(bundle: bundle, fmt: fmt, l10n: l10n),
        DetailsSection(bundle: bundle, fmt: fmt, l10n: l10n),
        StormsSection(bundle: bundle, fmt: fmt, l10n: l10n),
        DailySection(bundle: bundle, fmt: fmt, l10n: l10n),
      ] else if (weather.hasError)
        ErrorView(
          l10n: l10n,
          message: failureMessage(l10n, weather.error),
          onRetry: () => ref.invalidate(weatherProvider),
          onPickCity: () => unawaited(_openCityPicker()),
        )
      else
        LoadingSkeleton(l10n: l10n),
      HomeFooter(l10n: l10n),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(child: _Atmosphere(palette: palette)),
          SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: RefreshIndicator(
                  onRefresh: () => _refresh(feedback: false),
                  color: context.colors.primary,
                  backgroundColor: context.colors.surface,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.sm,
                      AppSpacing.xl,
                      AppSpacing.huge,
                    ),
                    itemCount: children.length,
                    itemBuilder: (context, index) => Padding(
                      padding: EdgeInsets.only(
                        bottom: index == children.length - 1
                            ? 0
                            : AppSpacing.xxxl,
                      ),
                      child: Reveal(index: index, child: children[index]),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.l10n,
    required this.onSearch,
    required this.onSettings,
  });

  final AppLocalizations l10n;
  final VoidCallback onSearch;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final showTagline = constraints.maxWidth > 430;
        return Row(
          children: [
            const AjwaaMark(size: 34),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.appName,
                    style: context.texts.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (showTagline)
                    Text(
                      l10n.appTagline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.texts.bodySmall?.copyWith(
                        color: context.muted,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const LanguageSwitch(),
            const SizedBox(width: AppSpacing.sm),
            _HeaderAction(
              icon: Icons.search_rounded,
              tooltip: l10n.a11ySearch,
              onTap: onSearch,
            ),
            const SizedBox(width: AppSpacing.xs),
            _HeaderAction(
              icon: Icons.tune_rounded,
              tooltip: l10n.a11ySettings,
              onTap: onSettings,
            ),
          ],
        );
      },
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        style: IconButton.styleFrom(
          backgroundColor: context.cardColor,
          side: BorderSide(color: context.cardBorder),
          minimumSize: const Size(42, 42),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({
    required this.bundle,
    required this.fmt,
    required this.l10n,
  });

  final WeatherBundle bundle;
  final Fmt fmt;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      color: AppColors.gold.withValues(alpha: context.isDark ? 0.12 : 0.16),
      borderColor: AppColors.gold.withValues(alpha: 0.35),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, size: 20, color: AppColors.amber),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.offlineTitle, style: context.texts.titleSmall),
                const SizedBox(height: 2),
                Text(
                  l10n.offlineBody,
                  style: context.texts.bodySmall?.copyWith(
                    color: context.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            fmt.relativeUpdated(bundle.fetchedAt),
            style: context.texts.labelSmall?.copyWith(color: context.muted),
          ),
        ],
      ),
    );
  }
}

class _Atmosphere extends StatelessWidget {
  const _Atmosphere({this.palette});

  final WeatherPalette? palette;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final glow = palette?.glow ?? AppColors.teal;
    final accent = palette?.accent ?? AppColors.sky;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: isDark
                  ? const [
                      AppColors.navy950,
                      AppColors.navy900,
                      Color(0xFF07222A),
                    ]
                  : const [
                      Color(0xFFF4F9FF),
                      Color(0xFFE9F3FB),
                      Color(0xFFE8F7F2),
                    ],
            ),
          ),
        ),
        PositionedDirectional(
          top: -140,
          end: -100,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            width: 380,
            height: 380,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  glow.withValues(alpha: isDark ? 0.24 : 0.20),
                  glow.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
        PositionedDirectional(
          bottom: -80,
          start: -100,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  accent.withValues(alpha: isDark ? 0.16 : 0.14),
                  accent.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
