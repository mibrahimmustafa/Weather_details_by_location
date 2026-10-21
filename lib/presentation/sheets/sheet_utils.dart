import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Opens a centered, width-constrained modal sheet on all form factors.
Future<T?> showAjwaaSheet<T>(
  BuildContext context,
  Widget child, {
  double? heightFactor,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) {
      final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
      final content = Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: child,
      );
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: heightFactor == null
            ? content
            : FractionallySizedBox(heightFactor: heightFactor, child: content),
      );
    },
  );
}

class SheetHeader extends StatelessWidget {
  const SheetHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onClose,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.texts.headlineSmall),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: context.texts.bodySmall?.copyWith(
                      color: context.muted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onClose ?? () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.close_rounded),
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          ),
        ],
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  const DetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 18, color: context.muted),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: context.texts.bodyMedium?.copyWith(color: context.muted),
            ),
          ),
          Text(
            value,
            style: context.texts.labelLarge,
            textDirection: TextDirection.ltr,
          ),
        ],
      ),
    );
  }
}
