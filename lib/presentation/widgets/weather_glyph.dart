import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/weather_condition.dart';

/// Compact, theme-aware weather glyph for lists and chips.
class WeatherGlyph extends StatelessWidget {
  const WeatherGlyph({
    super.key,
    required this.code,
    required this.isDay,
    this.size = 30,
  });

  final int code;
  final bool isDay;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return CustomPaint(
      size: Size.square(size),
      painter: _GlyphPainter(
        condition: conditionFromWmoCode(code),
        isDay: isDay,
        cloudColor: isDark ? Colors.white : const Color(0xFF93A9C0),
        cloudShade: isDark ? const Color(0xFFD7E8FA) : const Color(0xFFB9CCDE),
        sunColor: AppColors.gold,
        rainColor: isDark ? const Color(0xFF7FD4E8) : const Color(0xFF2E8FB5),
        snowColor: isDark ? Colors.white : const Color(0xFF7FB4D6),
        dustColor: const Color(0xFFC98B45),
      ),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  const _GlyphPainter({
    required this.condition,
    required this.isDay,
    required this.cloudColor,
    required this.cloudShade,
    required this.sunColor,
    required this.rainColor,
    required this.snowColor,
    required this.dustColor,
  });

  final WeatherCondition condition;
  final bool isDay;
  final Color cloudColor;
  final Color cloudShade;
  final Color sunColor;
  final Color rainColor;
  final Color snowColor;
  final Color dustColor;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final center = Offset(s / 2, s / 2);

    switch (condition) {
      case WeatherCondition.clear:
        if (isDay) {
          _sun(canvas, center, s * 0.27);
        } else {
          _moon(canvas, center, s * 0.26);
        }
        break;
      case WeatherCondition.mainlyClear:
        if (isDay) {
          _sun(canvas, center + Offset(s * 0.11, -s * 0.11), s * 0.21);
        } else {
          _moon(canvas, center + Offset(s * 0.11, -s * 0.11), s * 0.21);
        }
        _cloud(canvas, center + Offset(-s * 0.07, s * 0.14), s * 0.34);
        break;
      case WeatherCondition.partlyCloudy:
        if (isDay) {
          _sun(canvas, center + Offset(s * 0.16, -s * 0.15), s * 0.19);
        } else {
          _moon(canvas, center + Offset(s * 0.16, -s * 0.15), s * 0.19);
        }
        _cloud(canvas, center + Offset(-s * 0.05, s * 0.12), s * 0.4);
        break;
      case WeatherCondition.cloudy:
        _cloud(canvas, center + Offset(-s * 0.12, s * 0.05), s * 0.32);
        _cloud(canvas, center + Offset(s * 0.12, s * 0.14), s * 0.28);
        break;
      case WeatherCondition.fog:
        _cloud(canvas, center + Offset(0, -s * 0.06), s * 0.38);
        for (var i = 0; i < 3; i++) {
          final y = center.dy + s * (0.13 + i * 0.09);
          canvas.drawLine(
            Offset(s * (0.2 + i * 0.04), y),
            Offset(s * (0.8 - i * 0.04), y),
            Paint()
              ..color = cloudShade.withValues(alpha: 0.85)
              ..strokeWidth = s * 0.055
              ..strokeCap = StrokeCap.round,
          );
        }
        break;
      case WeatherCondition.drizzle:
        _cloud(canvas, center + Offset(0, -s * 0.1), s * 0.4);
        _drops(canvas, s, count: 2, startY: 0.68, short: true);
        break;
      case WeatherCondition.rain:
        _cloud(canvas, center + Offset(0, -s * 0.1), s * 0.4);
        _drops(canvas, s, count: 3, startY: 0.66);
        break;
      case WeatherCondition.heavyRain:
        _cloud(canvas, center + Offset(0, -s * 0.12), s * 0.42);
        _drops(canvas, s, count: 4, startY: 0.64, long: true);
        break;
      case WeatherCondition.freezingRain:
        _cloud(canvas, center + Offset(0, -s * 0.1), s * 0.4);
        _drops(canvas, s, count: 2, startY: 0.66);
        _snowflake(canvas, Offset(s * 0.72, s * 0.78), s * 0.055);
        break;
      case WeatherCondition.snow:
        _cloud(canvas, center + Offset(0, -s * 0.1), s * 0.4);
        _snowflake(canvas, Offset(s * 0.35, s * 0.74), s * 0.06);
        _snowflake(canvas, Offset(s * 0.55, s * 0.82), s * 0.045);
        _snowflake(canvas, Offset(s * 0.7, s * 0.72), s * 0.038);
        break;
      case WeatherCondition.thunderstorm:
        _cloud(canvas, center + Offset(0, -s * 0.12), s * 0.42);
        _bolt(canvas, s);
        break;
      case WeatherCondition.dust:
        _sun(canvas, center + Offset(0, -s * 0.08), s * 0.2);
        for (var i = 0; i < 3; i++) {
          final y = s * (0.56 + i * 0.13);
          final path = Path()
            ..moveTo(s * 0.16, y)
            ..quadraticBezierTo(s * 0.4, y - s * 0.09, s * 0.62, y)
            ..quadraticBezierTo(s * 0.76, y + s * 0.05, s * 0.86, y - s * 0.02);
          canvas.drawPath(
            path,
            Paint()
              ..color = dustColor.withValues(alpha: 0.75)
              ..style = PaintingStyle.stroke
              ..strokeWidth = s * 0.045
              ..strokeCap = StrokeCap.round,
          );
        }
        break;
      case WeatherCondition.unknown:
        _cloud(canvas, center, s * 0.4);
        break;
    }
  }

  void _sun(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(
      center,
      radius * 1.9,
      Paint()
        ..shader = RadialGradient(
          colors: [
            sunColor.withValues(alpha: 0.3),
            sunColor.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 1.9)),
    );
    final paint = Paint()
      ..color = sunColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = radius * 0.22;
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      canvas.drawLine(
        center + Offset(math.cos(angle), math.sin(angle)) * (radius * 1.3),
        center + Offset(math.cos(angle), math.sin(angle)) * (radius * 1.62),
        paint,
      );
    }
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: [const Color(0xFFFFEEB8), sunColor, const Color(0xFFF0A23A)],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  void _moon(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFFF3E9C8));
    final crater = Paint()..color = const Color(0xFFD9CFA8);
    canvas.drawCircle(
      center + Offset(-radius * 0.3, radius * 0.2),
      radius * 0.18,
      crater,
    );
    canvas.drawCircle(
      center + Offset(radius * 0.25, -radius * 0.2),
      radius * 0.12,
      crater,
    );
  }

  void _cloud(Canvas canvas, Offset center, double scale) {
    final path = Path()
      ..addOval(
        Rect.fromCircle(
          center: center + Offset(-scale * 0.22, scale * 0.03),
          radius: scale * 0.2,
        ),
      )
      ..addOval(
        Rect.fromCircle(
          center: center + Offset(0, -scale * 0.12),
          radius: scale * 0.27,
        ),
      )
      ..addOval(
        Rect.fromCircle(
          center: center + Offset(scale * 0.24, scale * 0.04),
          radius: scale * 0.19,
        ),
      )
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center + Offset(0, scale * 0.12),
            width: scale * 0.82,
            height: scale * 0.3,
          ),
          Radius.circular(scale * 0.15),
        ),
      );
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [cloudColor, cloudShade],
        ).createShader(Rect.fromCircle(center: center, radius: scale)),
    );
  }

  void _drops(
    Canvas canvas,
    double s, {
    required int count,
    required double startY,
    bool short = false,
    bool long = false,
  }) {
    final paint = Paint()
      ..color = rainColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = s * 0.05;
    final length =
        s *
        (short
            ? 0.09
            : long
            ? 0.2
            : 0.14);
    for (var i = 0; i < count; i++) {
      final x = s * (0.34 + i * (0.32 / math.max(1, count - 1)));
      final y = s * startY;
      canvas.drawLine(
        Offset(x, y),
        Offset(x - length * 0.4, y + length),
        paint,
      );
    }
  }

  void _snowflake(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = snowColor
      ..strokeWidth = radius * 0.32
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final angle = i * math.pi / 3;
      canvas.drawLine(
        center - Offset(math.cos(angle), math.sin(angle)) * radius,
        center + Offset(math.cos(angle), math.sin(angle)) * radius,
        paint,
      );
    }
  }

  void _bolt(Canvas canvas, double s) {
    final path = Path()
      ..moveTo(s * 0.54, s * 0.58)
      ..lineTo(s * 0.43, s * 0.79)
      ..lineTo(s * 0.53, s * 0.79)
      ..lineTo(s * 0.46, s * 0.95)
      ..lineTo(s * 0.64, s * 0.72)
      ..lineTo(s * 0.54, s * 0.72)
      ..lineTo(s * 0.6, s * 0.58)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFE082), Color(0xFFFFB300)],
        ).createShader(Rect.fromLTWH(s * 0.4, s * 0.55, s * 0.3, s * 0.4)),
    );
  }

  @override
  bool shouldRepaint(covariant _GlyphPainter oldDelegate) =>
      oldDelegate.condition != condition ||
      oldDelegate.isDay != isDay ||
      oldDelegate.cloudColor != cloudColor;
}
