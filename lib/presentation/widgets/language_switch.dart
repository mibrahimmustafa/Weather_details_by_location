import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/pressable_scale.dart';
import '../../l10n/app_localizations.dart';
import '../../state/settings_controller.dart';

/// Compact AR | EN switch. Direction-aware, with animated selection.
class LanguageSwitch extends ConsumerWidget {
  const LanguageSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isArabic = ref.watch(settingsProvider).isArabic;

    return Semantics(
      button: true,
      label: l10n.a11yLanguageToggle,
      child: Tooltip(
        message: l10n.a11yLanguageToggle,
        child: Container(
          height: 36,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: context.cardBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Option(
                label: 'ع',
                selected: isArabic,
                onTap: () =>
                    ref.read(settingsProvider.notifier).setLocale('ar'),
              ),
              _Option(
                label: 'EN',
                selected: !isArabic,
                onTap: () =>
                    ref.read(settingsProvider.notifier).setLocale('en'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      scale: 0.94,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        width: 36,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontFamily: 'PlexArabic',
            fontSize: 12.5,
            height: 1,
            fontWeight: FontWeight.w700,
            color: selected
                ? Theme.of(context).colorScheme.onPrimary
                : context.muted,
          ),
          child: Text(label, textDirection: TextDirection.ltr),
        ),
      ),
    );
  }
}
