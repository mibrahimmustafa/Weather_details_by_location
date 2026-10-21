import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/weather_bundle.dart';
import '../../l10n/app_localizations.dart';

/// Interactive 12-hour precipitation bars: tap or drag to inspect an hour.
class RainChart extends StatefulWidget {
  const RainChart({
    super.key,
    required this.points,
    required this.offsetSeconds,
    required this.fmt,
    required this.l10n,
  });

  final List<HourlyPoint> points;
  final int offsetSeconds;
  final Fmt fmt;
  final AppLocalizations l10n;

  @override
  State<RainChart> createState() => _RainChartState();
}

class _RainChartState extends State<RainChart> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.points.isEmpty) {
      return Text(
        widget.l10n.errorMalformed,
        style: context.texts.bodySmall?.copyWith(color: context.muted),
      );
    }
    final index = _selected.clamp(0, widget.points.length - 1);
    final point = widget.points[index];
    final local = point.timeUtc.add(Duration(seconds: widget.offsetSeconds));
    final chance = point.precipitationProbability;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ChartBubble(
          label: index == 0 ? widget.l10n.chartNow : widget.fmt.clock(local),
          value: widget.fmt.precipitation(point.precipitationMm),
          trailing: widget.fmt.percent(chance),
          color: const Color(0xFF5CC8E8),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 92,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) =>
                    _select(details.localPosition.dx, width),
                onHorizontalDragUpdate: (details) =>
                    _select(details.localPosition.dx, width),
                child: CustomPaint(
                  size: Size(width, 92),
                  painter: _RainPainter(
                    points: widget.points,
                    selected: index,
                    gridColor: context.colors.outlineVariant,
                    barColor: const Color(0xFF58C4E6),
                    accent: const Color(0xFF46D5C0),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final point in _labelPoints())
              Text(
                widget.fmt.clock(
                  point.timeUtc.add(Duration(seconds: widget.offsetSeconds)),
                ),
                style: context.texts.labelSmall?.copyWith(
                  color: context.muted,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
                textDirection: TextDirection.ltr,
              ),
          ],
        ),
      ],
    );
  }

  List<HourlyPoint> _labelPoints() {
    final points = widget.points;
    if (points.length <= 4) return points;
    final step = (points.length - 1) / 3;
    return [for (var i = 0; i < 4; i++) points[(i * step).round()]];
  }

  void _select(double dx, double width) {
    final count = widget.points.length;
    if (count == 0 || width <= 0) return;
    final index = (dx / width * count).floor().clamp(0, count - 1);
    if (index == _selected) return;
    setState(() => _selected = index);
  }
}

class _RainPainter extends CustomPainter {
  _RainPainter({
    required this.points,
    required this.selected,
    required this.gridColor,
    required this.barColor,
    required this.accent,
  });

  final List<HourlyPoint> points;
  final int selected;
  final Color gridColor;
  final Color barColor;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.45)
      ..strokeWidth = 1;
    for (var i = 1; i <= 2; i++) {
      final y = size.height * i / 3;
      _dashedLine(canvas, Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final maxValue = points
        .map((point) => point.precipitationMm)
        .fold<double>(0.2, (a, b) => math.max(a, b));
    final slot = size.width / points.length;
    final barWidth = math.min(slot * 0.52, 18.0);
    final bottom = size.height - 2;

    for (var i = 0; i < points.length; i++) {
      final value = points[i].precipitationMm;
      final height = (value / maxValue).clamp(0.02, 1.0) * (size.height - 8);
      final left = slot * i + (slot - barWidth) / 2;
      final isSelected = i == selected;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, bottom - height, barWidth, height),
        const Radius.circular(7),
      );
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isSelected
              ? [accent, barColor]
              : [
                  barColor.withValues(alpha: 0.55),
                  barColor.withValues(alpha: 0.18),
                ],
        ).createShader(rect.outerRect);
      canvas.drawRRect(rect, paint);
    }
  }

  void _dashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dash = 4.0;
    const gap = 6.0;
    var x = start.dx;
    while (x < end.dx) {
      canvas.drawLine(Offset(x, start.dy), Offset(x + dash, start.dy), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _RainPainter oldDelegate) =>
      oldDelegate.selected != selected ||
      oldDelegate.points != points ||
      oldDelegate.gridColor != gridColor;
}

/// Interactive 12-hour dust trend.
class DustChart extends StatefulWidget {
  const DustChart({
    super.key,
    required this.points,
    required this.offsetSeconds,
    required this.fmt,
    required this.l10n,
  });

  final List<({DateTime time, double value})> points;
  final int offsetSeconds;
  final Fmt fmt;
  final AppLocalizations l10n;

  @override
  State<DustChart> createState() => _DustChartState();
}

class _DustChartState extends State<DustChart> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.points.isEmpty) {
      return Text(
        widget.l10n.dustHint,
        style: context.texts.bodySmall?.copyWith(color: context.muted),
      );
    }
    final index = _selected.clamp(0, widget.points.length - 1);
    final point = widget.points[index];
    final local = point.time.add(Duration(seconds: widget.offsetSeconds));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ChartBubble(
          label: index == 0 ? widget.l10n.chartNow : widget.fmt.clock(local),
          value: widget.fmt.dust(point.value),
          color: const Color(0xFFC98B45),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 92,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) =>
                    _select(details.localPosition.dx, width),
                onHorizontalDragUpdate: (details) =>
                    _select(details.localPosition.dx, width),
                child: CustomPaint(
                  size: Size(width, 92),
                  painter: _DustPainter(
                    points: widget.points,
                    selected: index,
                    gridColor: context.colors.outlineVariant,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final point in _labels())
              Text(
                widget.fmt.clock(
                  point.time.add(Duration(seconds: widget.offsetSeconds)),
                ),
                style: context.texts.labelSmall?.copyWith(
                  color: context.muted,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
                textDirection: TextDirection.ltr,
              ),
          ],
        ),
      ],
    );
  }

  List<({DateTime time, double value})> _labels() {
    final points = widget.points;
    if (points.length <= 4) return points;
    final step = (points.length - 1) / 3;
    return [for (var i = 0; i < 4; i++) points[(i * step).round()]];
  }

  void _select(double dx, double width) {
    final count = widget.points.length;
    if (count == 0 || width <= 0) return;
    final index = (dx / width * count).floor().clamp(0, count - 1);
    if (index == _selected) return;
    setState(() => _selected = index);
  }
}

class _DustPainter extends CustomPainter {
  _DustPainter({
    required this.points,
    required this.selected,
    required this.gridColor,
  });

  final List<({DateTime time, double value})> points;
  final int selected;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final maxValue =
        points
            .map((point) => point.value)
            .fold<double>(10, (a, b) => math.max(a, b)) *
        1.2;
    final dx = size.width / math.max(1, points.length - 1);

    for (var i = 1; i <= 2; i++) {
      final y = size.height * i / 3;
      final paint = Paint()
        ..color = gridColor.withValues(alpha: 0.4)
        ..strokeWidth = 1;
      var x = 0.0;
      while (x < size.width) {
        canvas.drawLine(Offset(x, y), Offset(x + 4, y), paint);
        x += 10;
      }
    }

    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x = dx * i;
      final y =
          size.height - (points[i].value / maxValue) * (size.height - 10) - 4;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final prevX = dx * (i - 1);
        final prevY =
            size.height -
            (points[i - 1].value / maxValue) * (size.height - 10) -
            4;
        final controlX = (prevX + x) / 2;
        path.cubicTo(controlX, prevY, controlX, y, x, y);
      }
    }

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFD69B52).withValues(alpha: 0.35),
            const Color(0xFFD69B52).withValues(alpha: 0.02),
          ],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFC98B45)
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    final selectedX = dx * selected;
    final selectedY =
        size.height -
        (points[selected].value / maxValue) * (size.height - 10) -
        4;
    canvas.drawLine(
      Offset(selectedX, 0),
      Offset(selectedX, size.height),
      Paint()
        ..color = const Color(0xFFC98B45).withValues(alpha: 0.35)
        ..strokeWidth = 1,
    );
    canvas.drawCircle(
      Offset(selectedX, selectedY),
      4.5,
      Paint()..color = const Color(0xFFC98B45),
    );
    canvas.drawCircle(
      Offset(selectedX, selectedY),
      8,
      Paint()..color = const Color(0xFFC98B45).withValues(alpha: 0.2),
    );
  }

  @override
  bool shouldRepaint(covariant _DustPainter oldDelegate) =>
      oldDelegate.selected != selected ||
      oldDelegate.points != points ||
      oldDelegate.gridColor != gridColor;
}

class _ChartBubble extends StatelessWidget {
  const _ChartBubble({
    required this.label,
    required this.value,
    required this.color,
    this.trailing,
  });

  final String label;
  final String value;
  final Color color;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: context.texts.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            value,
            style: context.texts.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 6),
            Text(
              '· $trailing',
              style: context.texts.labelSmall?.copyWith(color: context.muted),
            ),
          ],
        ],
      ),
    );
  }
}
