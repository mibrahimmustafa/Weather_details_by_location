import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/surface_card.dart';
import '../../../l10n/app_localizations.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.l10n,
    required this.message,
    required this.onRetry,
    required this.onPickCity,
    this.busy = false,
  });

  final AppLocalizations l10n;
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onPickCity;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SurfaceCard(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: context.colors.error.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cloud_off_rounded,
                  size: 32,
                  color: context.colors.error,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                message,
                textAlign: TextAlign.center,
                style: context.texts.titleMedium?.copyWith(height: 1.45),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.retryHint,
                textAlign: TextAlign.center,
                style: context.texts.bodySmall?.copyWith(color: context.muted),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: busy ? null : onRetry,
                  icon: busy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(l10n.retry),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: busy ? null : onPickCity,
                  icon: const Icon(Icons.location_city_rounded, size: 18),
                  label: Text(l10n.pickCity),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
