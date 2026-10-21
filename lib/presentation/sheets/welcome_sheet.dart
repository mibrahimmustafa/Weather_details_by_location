import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/localized_text.dart';
import '../../l10n/app_localizations.dart';
import '../../state/location_controller.dart';
import '../../state/providers.dart';
import '../../state/settings_controller.dart';
import '../widgets/ajwaa_logo.dart';
import 'sheet_utils.dart';

Future<void> showWelcomeSheet(
  BuildContext context, {
  required VoidCallback onPickCity,
}) {
  return showAjwaaSheet<void>(context, WelcomeSheet(onPickCity: onPickCity));
}

class WelcomeSheet extends ConsumerStatefulWidget {
  const WelcomeSheet({super.key, required this.onPickCity});

  final VoidCallback onPickCity;

  @override
  ConsumerState<WelcomeSheet> createState() => _WelcomeSheetState();
}

class _WelcomeSheetState extends ConsumerState<WelcomeSheet> {
  String? _error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locating = ref.watch(locationProvider).isLocating;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.md,
        AppSpacing.xxl,
        AppSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AjwaaMark(size: 76),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.welcomeTitle,
            textAlign: TextAlign.center,
            style: context.texts.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.welcomeBody,
            textAlign: TextAlign.center,
            style: context.texts.bodyMedium?.copyWith(
              color: context.muted,
              height: 1.6,
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.colors.errorContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: context.colors.error.withValues(alpha: 0.25),
                ),
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
                      _error!,
                      style: context.texts.bodySmall?.copyWith(height: 1.45),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xxl),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: locating ? null : _allow,
              icon: locating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location_rounded, size: 18),
              label: Text(locating ? l10n.locating : l10n.allowLocation),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: locating ? null : _pick,
              icon: const Icon(Icons.location_city_rounded, size: 18),
              label: Text(l10n.pickCity),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => ref.read(locationServiceProvider).openSettings(),
              child: Text(l10n.openSettings),
            ),
          ],
          const SizedBox(height: AppSpacing.xs),
          TextButton(
            onPressed: locating ? null : _skip,
            child: Text(l10n.continueWithout),
          ),
        ],
      ),
    );
  }

  Future<void> _allow() async {
    setState(() => _error = null);
    try {
      await ref.read(locationProvider.notifier).locate();
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      final city = ref.read(locationProvider).city;
      final name = city == null || city.name.isEmpty
          ? l10n.currentLocation
          : city.name;
      final messenger = ScaffoldMessenger.of(context);
      _finish();
      messenger.showSnackBar(SnackBar(content: Text(l10n.cityAdded(name))));
    } on Object catch (error) {
      if (!mounted) return;
      setState(
        () => _error = failureMessage(AppLocalizations.of(context), error),
      );
    }
  }

  void _pick() {
    _finish();
    widget.onPickCity();
  }

  void _skip() => _finish();

  void _finish() {
    ref.read(settingsProvider.notifier).markWelcomeSeen();
    if (mounted) Navigator.of(context).maybePop();
  }
}
