import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_info.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/units.dart';
import '../../l10n/app_localizations.dart';
import '../../state/settings_controller.dart';
import '../widgets/ajwaa_logo.dart';
import 'info_sheet.dart';
import 'sheet_utils.dart';

Future<void> showSettingsSheet(BuildContext context) {
  return showAjwaaSheet<void>(
    context,
    const SettingsSheet(),
    heightFactor: 0.92,
  );
}

class SettingsSheet extends ConsumerWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);

    return SizedBox.expand(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxl,
          0,
          AppSpacing.xxl,
          AppSpacing.xxxl,
        ),
        children: [
          SheetHeader(title: l10n.settings, subtitle: l10n.settingsSaved),
          _Section(
            icon: Icons.palette_outlined,
            title: l10n.theme,
            caption: l10n.themeDescription,
            child: SegmentedButton<ThemeMode>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text(l10n.themeSystem),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text(l10n.themeLight),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text(l10n.themeDark),
                ),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (selection) =>
                  controller.setThemeMode(selection.first),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _Section(
            icon: Icons.straighten_rounded,
            title: l10n.unitSystem,
            caption: l10n.units,
            child: SegmentedButton<UnitSystem>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: UnitSystem.metric,
                  label: Text(l10n.unitsMetric),
                ),
                ButtonSegment(
                  value: UnitSystem.imperial,
                  label: Text(l10n.unitsImperial),
                ),
              ],
              selected: {settings.unitSystem},
              onSelectionChanged: (selection) =>
                  controller.setUnitSystem(selection.first),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _Section(
            icon: Icons.translate_rounded,
            title: l10n.language,
            caption: l10n.languageDescription,
            child: SegmentedButton<String>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: 'ar', label: Text(l10n.arabic)),
                ButtonSegment(value: 'en', label: Text(l10n.english)),
              ],
              selected: {settings.localeCode},
              onSelectionChanged: (selection) =>
                  controller.setLocale(selection.first),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          _SettingsTile(
            icon: Icons.lock_outline_rounded,
            title: l10n.privacy,
            onTap: () => showInfoSheet(
              context,
              title: l10n.privacy,
              icon: Icons.lock_outline_rounded,
              accent: context.colors.primary,
              description: l10n.privacyBody,
            ),
          ),
          _SettingsTile(
            icon: Icons.cloud_outlined,
            title: l10n.dataSources,
            subtitle: l10n.openSourceNote,
            onTap: () => showDataSourceSheet(context),
          ),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            title: l10n.aboutTitle,
            subtitle: l10n.appVersionLabel(AppInfo.version),
            onTap: () => showAboutSheet(context),
          ),
          _SettingsTile(
            icon: Icons.description_outlined,
            title: l10n.licenses,
            onTap: () => showLicensePage(
              context: context,
              applicationName: l10n.appName,
              applicationVersion: AppInfo.version,
              applicationLegalese: l10n.madeBy,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.dataNote,
            style: context.texts.bodySmall?.copyWith(
              color: context.muted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.caption,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String caption;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 17, color: context.colors.primary),
            const SizedBox(width: AppSpacing.sm),
            Text(title, style: context.texts.titleSmall),
          ],
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 25),
          child: Text(
            caption,
            style: context.texts.bodySmall?.copyWith(
              color: context.muted,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(width: double.infinity, child: child),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: context.colors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(icon, size: 19, color: context.colors.primary),
      ),
      title: Text(title, style: context.texts.titleSmall),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.texts.bodySmall?.copyWith(color: context.muted),
            ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: context.muted,
      ),
    );
  }
}

Future<void> showDataSourceSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context);
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
          SheetHeader(title: l10n.dataSources, subtitle: l10n.openSourceNote),
          _ProviderTile(
            icon: Icons.wb_sunny_outlined,
            title: l10n.dataProviderOpenMeteo,
            url: AppInfo.openMeteoUrl,
            l10n: l10n,
          ),
          _ProviderTile(
            icon: Icons.cyclone_rounded,
            title: 'NASA EONET — ${l10n.stormsTitle}',
            url: 'https://eonet.gsfc.nasa.gov',
            l10n: l10n,
          ),
          _ProviderTile(
            icon: Icons.warning_amber_rounded,
            title: l10n.dataProviderGdacs,
            url: AppInfo.gdacsUrl,
            l10n: l10n,
          ),
          _ProviderTile(
            icon: Icons.place_outlined,
            title: l10n.dataProviderBigDataCloud,
            url: AppInfo.bigDataCloudUrl,
            l10n: l10n,
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  size: 17,
                  color: context.colors.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    l10n.openSourceNote,
                    style: context.texts.bodySmall?.copyWith(height: 1.45),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _ProviderTile extends StatelessWidget {
  const _ProviderTile({
    required this.icon,
    required this.title,
    required this.url,
    required this.l10n,
  });

  final IconData icon;
  final String title;
  final String url;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => _open(context),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      leading: Icon(icon, size: 20, color: context.muted),
      title: Text(title, style: context.texts.bodyMedium),
      trailing: Icon(Icons.open_in_new_rounded, size: 16, color: context.muted),
    );
  }

  Future<void> _open(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorUnknown)));
    }
  }
}

Future<void> showAboutSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context);
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
        children: [
          SheetHeader(title: l10n.aboutTitle),
          const AjwaaMark(size: 68),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.appName, style: context.texts.headlineMedium),
          const SizedBox(height: 4),
          Text(
            l10n.appTagline,
            textAlign: TextAlign.center,
            style: context.texts.bodySmall?.copyWith(color: context.muted),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.aboutBody,
            textAlign: TextAlign.center,
            style: context.texts.bodyMedium?.copyWith(height: 1.6),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.colors.primary.withValues(alpha: 0.12),
                  context.colors.primary.withValues(alpha: 0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: context.colors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Text(
                  l10n.brandTitle,
                  style: context.texts.titleSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.brandBody,
                  textAlign: TextAlign.center,
                  style: context.texts.bodySmall?.copyWith(
                    color: context.muted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            '${l10n.madeBy} · ${l10n.appVersionLabel(AppInfo.version)}',
            textAlign: TextAlign.center,
            style: context.texts.labelMedium?.copyWith(color: context.muted),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.builtWith,
            textAlign: TextAlign.center,
            style: context.texts.labelSmall?.copyWith(
              color: context.muted.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => showLicensePage(
                context: context,
                applicationName: l10n.appName,
                applicationVersion: AppInfo.version,
                applicationLegalese: l10n.madeBy,
              ),
              icon: const Icon(Icons.description_outlined, size: 18),
              label: Text(l10n.licenses),
            ),
          ),
        ],
      ),
    ),
  );
}
