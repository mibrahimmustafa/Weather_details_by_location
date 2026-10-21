import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'sheet_utils.dart';

/// A compact bottom sheet used for alerts, metric explanations and hour details.
Future<void> showInfoSheet(
  BuildContext context, {
  required String title,
  required IconData icon,
  required Color accent,
  String? value,
  String? description,
  String? footnote,
  List<Widget> details = const [],
}) {
  final l10n = MaterialLocalizations.of(context);
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
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: accent, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Text(title, style: context.texts.headlineSmall)),
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.close_rounded),
                tooltip: l10n.closeButtonTooltip,
              ),
            ],
          ),
          if (value != null) ...[
            const SizedBox(height: AppSpacing.xl),
            Text(
              value,
              style: context.texts.displaySmall?.copyWith(
                color: accent,
                fontWeight: FontWeight.w600,
              ),
              textDirection: TextDirection.ltr,
            ),
          ],
          if (description != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              description,
              style: context.texts.bodyLarge?.copyWith(height: 1.6),
            ),
          ],
          if (details.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            SurfaceDetails(children: details),
          ],
          if (footnote != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 15,
                  color: context.muted,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    footnote,
                    style: context.texts.bodySmall?.copyWith(
                      color: context.muted,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    ),
  );
}

class SurfaceDetails extends StatelessWidget {
  const SurfaceDetails({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: context.isDark
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFFF3F7FC),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
