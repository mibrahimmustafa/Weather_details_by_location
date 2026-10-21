import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/surface_card.dart';
import '../../data/models/weather_bundle.dart';
import '../../l10n/app_localizations.dart';

/// Daylight arc with the sun's current position.
class SunPath extends StatelessWidget {
  const SunPath({
    super.key,
    required this.bundle,
    required this.fmt,
    required this.l10n,
  });

  final WeatherBundle bundle;
  final Fmt fmt;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final today = bundle.today;
    if (today == null || today.sunriseUtc == null || today.sunsetUtc == null) {
      return const SizedBox.shrink();
    }
    final sunrise = today.sunriseUtc!;
    final sunset = today.sunsetUtc!;
    final now = DateTime.now().toUtc();
    final total = sunset.difference(sunrise).inSeconds;
    final progress = total <= 0
        ? 0.0
        : (now.difference(sunrise).inSeconds / total).clamp(0.0, 1.0);
    final isDay = now.isAfter(sunrise) && now.isBefore(sunset);

    return SurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(
                  Icons.wb_twilight_rounded,
                  size: 18,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '${l10n.sunrise} · ${l10n.sunset}',
                style: context.texts.titleSmall,
              ),
              const Spacer(),
              Text(
                fmt.clockFromUtc(now, bundle.utcOffsetSeconds),
                style: context.texts.labelMedium?.copyWith(
                  color: context.muted,
                ),
                textDirection: TextDirection.ltr,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 76,
            child: CustomPaint(
              painter: _SunArcPainter(
                progress: progress,
                isDay: isDay,
                isRtl: Directionality.of(context) == TextDirection.rtl,
                trackColor: context.colors.outlineVariant,
                glowColor: isDay ? AppColors.gold : AppColors.lilac,
              ),
              size: Size.infinite,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _TimeLabel(
                icon: Icons.arrow_upward_rounded,
                label: l10n.sunrise,
                value: fmt.clockFromUtc(sunrise, bundle.utcOffsetSeconds),
              ),
              _TimeLabel(
                icon: Icons.arrow_downward_rounded,
                label: l10n.sunset,
                value: fmt.clockFromUtc(sunset, bundle.utcOffsetSeconds),
                alignEnd: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeLabel extends StatelessWidget {
  const _TimeLabel({
    required this.icon,
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: context.muted),
            const SizedBox(width: 4),
            Text(
              label,
              style: context.texts.labelSmall?.copyWith(color: context.muted),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: context.texts.labelLarge,
          textDirection: TextDirection.ltr,
        ),
      ],
    );
  }
}

class _SunArcPainter extends CustomPainter {
  _SunArcPainter({
    required this.progress,
    required this.isDay,
    required this.isRtl,
    required this.trackColor,
    required this.glowColor,
  });

  final double progress;
  final bool isDay;
  final bool isRtl;
  final Color trackColor;
  final Color glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final horizon = size.height * 0.86;
    final radius = math.min(size.width * 0.44, size.height * 1.35);
    final center = Offset(size.width / 2, horizon);
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawArc(
      rect,
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = trackColor.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Dashed horizon.
    final dash = Paint()
      ..color = trackColor.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, horizon), Offset(x + 4, horizon), dash);
      x += 9;
    }

    final visualProgress = isRtl ? 1 - progress : progress;
    final angle = math.pi + math.pi * visualProgress;
    final sun = center + Offset(math.cos(angle), math.sin(angle)) * radius;

    canvas.drawCircle(
      sun,
      16,
      Paint()
        ..shader = RadialGradient(
          colors: [
            glowColor.withValues(alpha: 0.35),
            glowColor.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: sun, radius: 16)),
    );
    canvas.drawCircle(
      sun,
      5,
      Paint()
        ..shader = RadialGradient(
          colors: isDay
              ? const [Color(0xFFFFF3C4), AppColors.gold]
              : const [Color(0xFFE6DEFF), AppColors.lilac],
        ).createShader(Rect.fromCircle(center: sun, radius: 5)),
    );
  }

  @override
  bool shouldRepaint(covariant _SunArcPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.isDay != isDay ||
      oldDelegate.isRtl != isRtl ||
      oldDelegate.trackColor != trackColor;
}
