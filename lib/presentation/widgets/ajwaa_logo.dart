import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// The Ajwaa mark: a sun that doubles as a clock, with a cloud drifting across
/// it. Drawn with vectors so it stays crisp at every size and can be exported.
class AjwaaMark extends StatelessWidget {
  const AjwaaMark({super.key, this.size = 32, this.monochrome = false});

  final double size;
  final bool monochrome;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Ajwaa',
      image: true,
      child: CustomPaint(
        size: Size.square(size),
        painter: _AjwaaMarkPainter(monochrome: monochrome),
      ),
    );
  }
}

class AjwaaAppIcon extends StatelessWidget {
  const AjwaaAppIcon({super.key, this.size = 1024});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF16345C), Color(0xFF0B1B33), Color(0xFF072C33)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -size * 0.18,
            top: -size * 0.22,
            child: Container(
              width: size * 0.8,
              height: size * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.teal.withValues(alpha: 0.28),
                    AppColors.teal.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Center(child: AjwaaMark(size: size * 0.72)),
        ],
      ),
    );
  }
}

class _AjwaaMarkPainter extends CustomPainter {
  _AjwaaMarkPainter({this.monochrome = false});

  final bool monochrome;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width;
    Offset p(double x, double y) => Offset(x * scale, y * scale);
    final sunCenter = p(0.60, 0.38);

    if (monochrome) {
      canvas.saveLayer(Offset.zero & size, Paint());
    } else {
      final glow = Paint()
        ..shader =
            RadialGradient(
              colors: [
                AppColors.gold.withValues(alpha: 0.38),
                AppColors.gold.withValues(alpha: 0),
              ],
            ).createShader(
              Rect.fromCircle(center: sunCenter, radius: scale * 0.38),
            );
      canvas.drawCircle(sunCenter, scale * 0.38, glow);
    }

    final sunRadius = scale * 0.205;
    final sunPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.25, -0.25),
        colors: [Color(0xFFFFE7A8), Color(0xFFFFC04D), Color(0xFFF59A2E)],
        stops: [0, 0.55, 1],
      ).createShader(Rect.fromCircle(center: sunCenter, radius: sunRadius));
    canvas.drawCircle(
      sunCenter,
      sunRadius,
      monochrome ? (Paint()..color = Colors.white) : sunPaint,
    );

    // Sun rays.
    final rayPaint = Paint()
      ..color = monochrome
          ? Colors.white
          : AppColors.gold.withValues(alpha: 0.95)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = scale * 0.024;
    for (var i = 0; i < 8; i++) {
      final angle = (math.pi / 4) * i + math.pi / 12;
      final start =
          sunCenter +
          Offset(math.cos(angle), math.sin(angle)) * (sunRadius + scale * 0.05);
      final end =
          sunCenter +
          Offset(math.cos(angle), math.sin(angle)) *
              (sunRadius + scale * 0.095);
      canvas.drawLine(start, end, rayPaint);
    }

    // Clock hands inside the sun.
    final handPaint = Paint()
      ..color = monochrome ? Colors.white : AppColors.navy800
      ..strokeCap = StrokeCap.round
      ..strokeWidth = scale * 0.026;
    final hourEnd =
        sunCenter + Offset(math.cos(-1.9), math.sin(-1.9)) * (sunRadius * 0.48);
    final minuteEnd =
        sunCenter + Offset(math.cos(0.45), math.sin(0.45)) * (sunRadius * 0.72);
    canvas.drawLine(sunCenter, hourEnd, handPaint);
    canvas.drawLine(sunCenter, minuteEnd, handPaint);
    canvas.drawCircle(
      sunCenter,
      scale * 0.022,
      Paint()..color = monochrome ? Colors.white : AppColors.navy800,
    );

    // Cloud: three overlapping lobes and a rounded base.
    final cloudPath = Path()
      ..addOval(Rect.fromCircle(center: p(0.35, 0.615), radius: scale * 0.115))
      ..addOval(Rect.fromCircle(center: p(0.50, 0.56), radius: scale * 0.155))
      ..addOval(Rect.fromCircle(center: p(0.655, 0.61), radius: scale * 0.105))
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(scale * 0.23, scale * 0.60, scale * 0.76, scale * 0.71),
          Radius.circular(scale * 0.075),
        ),
      );
    final cloudPaint = Paint()
      ..shader =
          const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFD8ECFF)],
          ).createShader(
            Rect.fromLTRB(scale * 0.2, scale * 0.42, scale * 0.8, scale * 0.75),
          );
    canvas.drawPath(
      cloudPath,
      monochrome ? (Paint()..color = Colors.white) : cloudPaint,
    );

    if (monochrome) {
      // Punch the clock hands back out so the mask keeps its character.
      final clear = Paint()..blendMode = BlendMode.clear;
      canvas.drawLine(
        sunCenter,
        hourEnd,
        clear
          ..strokeWidth = scale * 0.034
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawLine(sunCenter, minuteEnd, clear);
      canvas.restore();
    }

    // Two drops under the cloud.
    final dropPaint = Paint()
      ..color = monochrome
          ? Colors.white
          : AppColors.teal.withValues(alpha: 0.95);
    for (final x in [0.43, 0.56]) {
      final path = Path()
        ..moveTo(scale * x, scale * 0.76)
        ..quadraticBezierTo(
          scale * (x - 0.045),
          scale * 0.84,
          scale * x,
          scale * 0.86,
        )
        ..quadraticBezierTo(
          scale * (x + 0.045),
          scale * 0.84,
          scale * x,
          scale * 0.76,
        );
      canvas.drawPath(path, dropPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _AjwaaMarkPainter oldDelegate) =>
      oldDelegate.monochrome != monochrome;
}
