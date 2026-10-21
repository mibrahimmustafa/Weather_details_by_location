import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/suggested_cities.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/localized_text.dart';
import '../../core/widgets/pressable_scale.dart';
import '../../data/models/city.dart';
import '../../l10n/app_localizations.dart';
import '../../state/cities_controller.dart';
import '../../state/location_controller.dart';
import '../../state/providers.dart';
import '../../state/settings_controller.dart';
import 'sheet_utils.dart';

Future<void> showCityPickerSheet(BuildContext context) {
  return showAjwaaSheet<void>(
    context,
    const CityPickerSheet(),
    heightFactor: 0.92,
  );
}

class CityPickerSheet extends ConsumerStatefulWidget {
  const CityPickerSheet({super.key});

  @override
  ConsumerState<CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends ConsumerState<CityPickerSheet> {
  final TextEditingController _text = TextEditingController();
  Timer? _debounce;
  String _query = '';
  List<City> _results = const [];
  bool _searching = false;
  String? _searchError;
  String? _locationError;
  int _request = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final saved = ref.watch(citiesProvider);
    final locating = ref.watch(locationProvider).isLocating;

    return SizedBox.expand(
      child: Column(
        children: [
          SheetHeader(
            title: l10n.cityPickerTitle,
            subtitle: l10n.cityPickerSubtitle,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: TextField(
              controller: _text,
              textInputAction: TextInputAction.search,
              autocorrect: false,
              onChanged: _onChanged,
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        onPressed: _clear,
                        icon: const Icon(Icons.close_rounded, size: 18),
                        tooltip: l10n.cancel,
                      ),
              ),
            ),
          ),
          if (_locationError != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.sm,
                AppSpacing.xxl,
                0,
              ),
              child: _InlineError(
                message: _locationError!,
                l10n: l10n,
                onOpenSettings: () =>
                    ref.read(locationServiceProvider).openSettings(),
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.sm,
                AppSpacing.xxl,
                AppSpacing.xxl,
              ),
              children: [
                _LocationTile(
                  l10n: l10n,
                  busy: locating,
                  onTap: locating ? null : _useLocation,
                ),
                const SizedBox(height: AppSpacing.xl),
                if (_query.trim().length >= 2)
                  ..._searchResults(l10n, saved)
                else
                  ..._browse(l10n, saved),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    final query = value.trim();
    setState(() {
      _query = value;
      _searchError = null;
      if (query.length < 2) {
        _results = const [];
        _searching = false;
      } else {
        _searching = true;
      }
    });
    if (query.length < 2) return;
    _debounce = Timer(const Duration(milliseconds: 380), () => _search(query));
  }

  void _clear() {
    _debounce?.cancel();
    _request++;
    _text.clear();
    setState(() {
      _query = '';
      _results = const [];
      _searching = false;
      _searchError = null;
    });
  }

  Future<void> _search(String query) async {
    final request = ++_request;
    final language = ref.read(settingsProvider).localeCode;
    try {
      final results = await ref
          .read(geocodingApiProvider)
          .search(query, language: language);
      if (!mounted || request != _request) return;
      setState(() {
        _results = results;
        _searching = false;
        _searchError = null;
      });
    } on Object catch (error) {
      if (!mounted || request != _request) return;
      setState(() {
        _searching = false;
        _searchError = failureMessage(AppLocalizations.of(context), error);
      });
    }
  }

  Future<void> _useLocation() async {
    setState(() => _locationError = null);
    try {
      await ref.read(locationProvider.notifier).locate();
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      final city = ref.read(locationProvider).city;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).maybePop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n.cityAdded(
              city == null || city.name.isEmpty
                  ? l10n.currentLocation
                  : city.name,
            ),
          ),
        ),
      );
    } on Object catch (error) {
      if (!mounted) return;
      setState(
        () => _locationError = failureMessage(
          AppLocalizations.of(context),
          error,
        ),
      );
    }
  }

  List<Widget> _searchResults(AppLocalizations l10n, CitiesState saved) {
    if (_searching) {
      return [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: LinearProgressIndicator(minHeight: 2.5),
        ),
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          child: Text(
            l10n.searchPrompt,
            style: context.texts.bodySmall?.copyWith(color: context.muted),
          ),
        ),
      ];
    }
    if (_searchError != null) {
      return [_InlineError(message: _searchError!, l10n: l10n)];
    }
    if (_results.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
          child: Column(
            children: [
              Icon(
                Icons.travel_explore_rounded,
                size: 40,
                color: context.muted.withValues(alpha: 0.6),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.searchNoResults,
                textAlign: TextAlign.center,
                style: context.texts.bodyMedium?.copyWith(color: context.muted),
              ),
            ],
          ),
        ),
      ];
    }

    return [
      Text(
        l10n.searchResults,
        style: context.texts.labelMedium?.copyWith(color: context.muted),
      ),
      const SizedBox(height: AppSpacing.sm),
      for (final city in _results)
        _CityTile(
          city: city,
          l10n: l10n,
          selected: saved.selected?.id == city.id,
          saved: saved.cities.any(
            (item) =>
                item.id == city.id ||
                (item.name == city.name && item.country == city.country),
          ),
          onTap: () => _select(city),
        ),
    ];
  }

  List<Widget> _browse(AppLocalizations l10n, CitiesState saved) {
    final language = ref.watch(settingsProvider).localeCode;
    final suggested = suggestedCitiesFor(language)
        .where(
          (city) => !saved.cities.any(
            (item) =>
                item.id == city.id ||
                (item.name == city.name && item.country == city.country),
          ),
        )
        .toList(growable: false);

    return [
      Row(
        children: [
          Text(
            l10n.savedCities,
            style: context.texts.labelMedium?.copyWith(color: context.muted),
          ),
          const Spacer(),
          if (saved.cities.length > 1)
            Text(
              l10n.swipeToRemove,
              style: context.texts.labelSmall?.copyWith(
                color: context.muted.withValues(alpha: 0.7),
                fontSize: 9.5,
              ),
            ),
        ],
      ),
      const SizedBox(height: AppSpacing.sm),
      for (final city in saved.cities)
        Dismissible(
          key: ValueKey('saved-${city.id}'),
          direction: saved.canRemove
              ? DismissDirection.endToStart
              : DismissDirection.none,
          confirmDismiss: (_) => _confirmRemove(city, l10n),
          onDismissed: (_) => _remove(city, l10n),
          background: Container(
            alignment: AlignmentDirectional.centerEnd,
            padding: const EdgeInsetsDirectional.only(end: AppSpacing.xl),
            decoration: BoxDecoration(
              color: context.colors.error.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.white,
            ),
          ),
          child: _CityTile(
            city: city,
            l10n: l10n,
            selected: saved.selected?.id == city.id,
            saved: true,
            onTap: () => _select(city),
            onRemove: saved.canRemove
                ? () => _removeWithConfirm(city, l10n)
                : null,
          ),
        ),
      if (suggested.isNotEmpty) ...[
        const SizedBox(height: AppSpacing.xl),
        Text(
          l10n.popularCities,
          style: context.texts.labelMedium?.copyWith(color: context.muted),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final city in suggested)
              _PopularChip(city: city, onTap: () => _select(city)),
          ],
        ),
      ],
    ];
  }

  void _select(City city) {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final alreadySelected = ref.read(citiesProvider).selected?.id == city.id;
    final added = ref.read(citiesProvider.notifier).add(city);
    final name = city.name.isEmpty ? l10n.currentLocation : city.name;
    Navigator.of(context).maybePop();
    if (alreadySelected) return;
    messenger.showSnackBar(
      SnackBar(content: Text(added ? l10n.cityAdded(name) : l10n.cityExists)),
    );
  }

  Future<void> _removeWithConfirm(City city, AppLocalizations l10n) async {
    final confirmed = await _confirmRemove(city, l10n);
    if (confirmed && mounted) _remove(city, l10n);
  }

  Future<bool> _confirmRemove(City city, AppLocalizations l10n) async {
    if (!ref.read(citiesProvider).canRemove) return false;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.removeCity),
        content: Text(city.name.isEmpty ? l10n.currentLocation : city.name),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.removeCity),
          ),
        ],
      ),
    );
    return result == true;
  }

  void _remove(City city, AppLocalizations l10n) {
    final messenger = ScaffoldMessenger.of(context);
    final removed = ref.read(citiesProvider.notifier).remove(city.id);
    if (!removed) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          l10n.cityRemoved(
            city.name.isEmpty ? l10n.currentLocation : city.name,
          ),
        ),
      ),
    );
  }
}

class _LocationTile extends StatelessWidget {
  const _LocationTile({
    required this.l10n,
    required this.busy,
    required this.onTap,
  });

  final AppLocalizations l10n;
  final bool busy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      semanticLabel: l10n.useMyLocation,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              context.colors.primary.withValues(alpha: 0.14),
              context.colors.primary.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: context.colors.primary.withValues(alpha: 0.28),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: busy
                  ? Padding(
                      padding: const EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: context.colors.primary,
                      ),
                    )
                  : Icon(
                      Icons.my_location_rounded,
                      size: 21,
                      color: context.colors.primary,
                    ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    busy ? l10n.locating : l10n.useMyLocation,
                    style: context.texts.titleSmall?.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.currentLocationBadge,
                    style: context.texts.labelSmall?.copyWith(
                      color: context.muted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: context.colors.primary.withValues(alpha: 0.8),
            ),
          ],
        ),
      ),
    );
  }
}

class _CityTile extends StatelessWidget {
  const _CityTile({
    required this.city,
    required this.l10n,
    required this.selected,
    required this.saved,
    required this.onTap,
    this.onRemove,
  });

  final City city;
  final AppLocalizations l10n;
  final bool selected;
  final bool saved;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final name = city.name.isEmpty && city.isCurrentLocation
        ? l10n.currentLocation
        : city.name;
    final subtitle = [
      city.admin1,
      city.country,
    ].whereType<String>().where((part) => part.isNotEmpty).toSet().join(' · ');

    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 2,
        ),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: selected
                ? context.colors.primary.withValues(alpha: 0.16)
                : context.colors.surfaceContainerHighest.withValues(alpha: 0.7),
            shape: BoxShape.circle,
          ),
          child: Icon(
            city.isCurrentLocation
                ? Icons.my_location_rounded
                : Icons.location_city_rounded,
            size: 19,
            color: selected ? context.colors.primary : context.muted,
          ),
        ),
        title: Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.texts.titleSmall?.copyWith(
            color: selected ? context.colors.primary : null,
          ),
        ),
        subtitle: subtitle.isEmpty
            ? null
            : Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.texts.bodySmall?.copyWith(color: context.muted),
              ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected)
              Icon(
                Icons.check_circle_rounded,
                size: 20,
                color: context.colors.primary,
              )
            else if (!saved)
              Icon(
                Icons.add_circle_outline_rounded,
                size: 20,
                color: context.muted,
              ),
            if (onRemove != null)
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline_rounded, size: 19),
                tooltip: l10n.removeCity,
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
      ),
    );
  }
}

class _PopularChip extends StatelessWidget {
  const _PopularChip({required this.city, required this.onTap});

  final City city;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      scale: 0.96,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: context.cardBorder),
          boxShadow: context.softShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.place_rounded, size: 13, color: context.muted),
            const SizedBox(width: 5),
            Text(
              city.name,
              style: context.texts.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (city.country.isNotEmpty) ...[
              const SizedBox(width: 5),
              Text(
                city.country,
                style: context.texts.labelSmall?.copyWith(
                  color: context.muted,
                  fontSize: 9.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({
    required this.message,
    required this.l10n,
    this.onOpenSettings,
  });

  final String message;
  final AppLocalizations l10n;
  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.errorContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.colors.error.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 18,
            color: context.colors.error,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: context.texts.bodySmall?.copyWith(height: 1.45),
            ),
          ),
          if (onOpenSettings != null)
            TextButton(
              onPressed: onOpenSettings,
              child: Text(l10n.openSettings),
            ),
        ],
      ),
    );
  }
}
