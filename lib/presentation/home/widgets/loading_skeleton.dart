import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shimmer.dart';
import '../../../l10n/app_localizations.dart';

/// First-load placeholder that mirrors the real layout.
class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: l10n.loading,
      container: true,
      child: Shimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 290,
              decoration: BoxDecoration(
                color: context.isDark
                    ? Colors.white.withValues(alpha: 0.07)
                    : const Color(0xFFDCEBF9),
                borderRadius: BorderRadius.circular(AppRadius.xxl),
              ),
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonBox(width: 150, height: 30, radius: 15),
                  const Spacer(),
                  const SkeletonBox(width: 150, height: 64, radius: 20),
                  const SizedBox(height: AppSpacing.sm),
                  const SkeletonBox(width: 110, height: 18, radius: 9),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: const [
                      Expanded(child: SkeletonBox(height: 14, radius: 7)),
                      SizedBox(width: AppSpacing.xl),
                      Expanded(child: SkeletonBox(height: 14, radius: 7)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            const SkeletonBox(width: 130, height: 22, radius: 10),
            const SizedBox(height: AppSpacing.md),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: context.isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: context.cardBorder),
              ),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonBox(width: 38, height: 38, radius: 12),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 120, height: 16, radius: 8),
                        SizedBox(height: AppSpacing.sm),
                        SkeletonBox(height: 12, radius: 6),
                        SizedBox(height: 6),
                        SkeletonBox(width: 180, height: 12, radius: 6),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            const SkeletonBox(width: 170, height: 22, radius: 10),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                for (var i = 0; i < 3; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Container(
                      height: 132,
                      decoration: BoxDecoration(
                        color: context.isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: context.cardBorder),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
