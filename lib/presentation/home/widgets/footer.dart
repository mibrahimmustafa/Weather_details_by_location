import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_info.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/pressable_scale.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/ajwaa_logo.dart';

class HomeFooter extends StatelessWidget {
  const HomeFooter({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.colors.outlineVariant.withValues(alpha: 0),
                context.colors.outlineVariant.withValues(alpha: 0.8),
                context.colors.outlineVariant.withValues(alpha: 0),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AjwaaMark(size: 22),
            const SizedBox(width: AppSpacing.sm),
            Text(
              l10n.appName,
              style: context.texts.titleSmall?.copyWith(
                color: context.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          l10n.footerNote,
          textAlign: TextAlign.center,
          style: context.texts.bodySmall?.copyWith(color: context.muted),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpacing.md,
          runSpacing: 6,
          children: [
            _SourceLink(
              label: 'Open-Meteo',
              url: AppInfo.openMeteoUrl,
              l10n: l10n,
            ),
            _SourceLink(
              label: 'NASA EONET',
              url: 'https://eonet.gsfc.nasa.gov',
              l10n: l10n,
            ),
            _SourceLink(label: 'GDACS', url: AppInfo.gdacsUrl, l10n: l10n),
            _SourceLink(
              label: 'BigDataCloud',
              url: AppInfo.bigDataCloudUrl,
              l10n: l10n,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          '${l10n.madeBy} · ${l10n.appVersionLabel(AppInfo.version)}',
          textAlign: TextAlign.center,
          style: context.texts.labelSmall?.copyWith(
            color: context.muted.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.openSourceNote,
          textAlign: TextAlign.center,
          style: context.texts.labelSmall?.copyWith(
            color: context.muted.withValues(alpha: 0.65),
            fontSize: 9.5,
          ),
        ),
      ],
    );
  }
}

class _SourceLink extends StatelessWidget {
  const _SourceLink({
    required this.label,
    required this.url,
    required this.l10n,
  });

  final String label;
  final String url;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () => _open(context),
      semanticLabel: '${l10n.openLink}: $label',
      scale: 0.96,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: context.colors.outlineVariant.withValues(alpha: 0.75),
          ),
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
            const SizedBox(width: 3),
            Icon(
              Icons.open_in_new_rounded,
              size: 9,
              color: context.muted.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorUnknown)));
    }
  }
}
