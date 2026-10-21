import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/weather_condition.dart';

/// Slowly moving atmospheric illustration that sits behind the hero card.
class WeatherScene extends StatefulWidget {
  const WeatherScene({super.key, required this.condition, required this.isDay});

  final WeatherCondition condition;
  final bool isDay;

  @override
  State<WeatherScene> createState() => _WeatherSceneState();
}

class _WeatherSceneState extends State<WeatherScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) {
      _controller.stop();
      _controller.value = 0.32;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _ScenePainter(
          animation: _controller,
          condition: widget.condition,
          isDay: widget.isDay,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.animation,
    required this.condition,
    required this.isDay,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final WeatherCondition condition;
  final bool isDay;

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    final w = size.width;
    final h = size.height;
    final shortest = math.min(w, h);

    if (!isDay) _paintStars(canvas, size, t);
    _paintOrb(canvas, size, t, shortest);
    _paintClouds(canvas, size, t, shortest);

    switch (condition) {
      case WeatherCondition.drizzle:
        _paintRain(canvas, size, t, count: 18, long: false);
        break;
      case WeatherCondition.rain:
      case WeatherCondition.freezingRain:
        _paintRain(canvas, size, t, count: 28);
        break;
      case WeatherCondition.heavyRain:
        _paintRain(canvas, size, t, count: 44, long: true);
        break;
      case WeatherCondition.thunderstorm:
        _paintRain(canvas, size, t, count: 30);
        _paintLightning(canvas, size, t);
        break;
      case WeatherCondition.snow:
        _paintSnow(canvas, size, t);
        break;
      case WeatherCondition.dust:
        _paintDust(canvas, size, t);
        break;
      case WeatherCondition.fog:
        _paintFog(canvas, size, t);
        break;
      case WeatherCondition.clear:
      case WeatherCondition.mainlyClear:
      case WeatherCondition.partlyCloudy:
      case WeatherCondition.cloudy:
      case WeatherCondition.unknown:
        break;
    }
  }

  void _paintOrb(Canvas canvas, Size size, double t, double shortest) {
    final center = Offset(size.width * 0.79, size.height * 0.25);
    final radius = shortest * 0.115;
    final glowColor = isDay ? AppColors.gold : const Color(0xFFA8C8FF);

    canvas.drawCircle(
      center,
      radius * 2.6,
      Paint()
        ..shader = RadialGradient(
          colors: [
            glowColor.withValues(alpha: isDay ? 0.30 : 0.18),
            glowColor.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 2.6)),
    );

    if (isDay) {
      // Slowly rotating rays.
      final rayPaint = Paint()
        ..color = AppColors.gold.withValues(alpha: 0.35)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2.2;
      for (var i = 0; i < 10; i++) {
        final angle = i * math.pi / 5 + t * math.pi / 2;
        final start =
            center + Offset(math.cos(angle), math.sin(angle)) * (radius * 1.42);
        final end =
            center + Offset(math.cos(angle), math.sin(angle)) * (radius * 1.85);
        canvas.drawLine(start, end, rayPaint);
      }
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = const RadialGradient(
            center: Alignment(-0.3, -0.3),
            colors: [Color(0xFFFFF2C9), Color(0xFFFFCE6A), Color(0xFFF6A83B)],
            stops: [0, 0.6, 1],
          ).createShader(Rect.fromCircle(center: center, radius: radius)),
      );
    } else {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = const RadialGradient(
            center: Alignment(-0.35, -0.35),
            colors: [Color(0xFFF4F8FF), Color(0xFFD7E5FA), Color(0xFFB9CEEA)],
          ).createShader(Rect.fromCircle(center: center, radius: radius)),
      );
      final crater = Paint()
        ..color = const Color(0xFFB2C7E4).withValues(alpha: 0.55);
      canvas.drawCircle(
        center + Offset(-radius * 0.28, radius * 0.18),
        radius * 0.16,
        crater,
      );
      canvas.drawCircle(
        center + Offset(radius * 0.24, -radius * 0.22),
        radius * 0.11,
        crater,
      );
      canvas.drawCircle(
        center + Offset(radius * 0.12, radius * 0.35),
        radius * 0.08,
        crater,
      );
    }
  }

  void _paintStars(Canvas canvas, Size size, double t) {
    for (var i = 0; i < 34; i++) {
      final x = _rand(i, 1) * size.width;
      final y = _rand(i, 2) * size.height * 0.55;
      final twinkle =
          0.25 + 0.55 * ((math.sin(t * math.pi * 2 + i * 1.7) + 1) / 2);
      final radius = 0.6 + _rand(i, 3) * 1.4;
      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()..color = Colors.white.withValues(alpha: twinkle),
      );
    }
  }

  void _paintClouds(Canvas canvas, Size size, double t, double shortest) {
    final drift = math.sin(t * math.pi * 2) * size.width * 0.018;
    final cloudAlpha = switch (condition) {
      WeatherCondition.clear || WeatherCondition.mainlyClear => 0.20,
      WeatherCondition.partlyCloudy => 0.34,
      WeatherCondition.cloudy => 0.42,
      WeatherCondition.fog => 0.30,
      WeatherCondition.dust => 0.16,
      _ => 0.30,
    };

    _cloud(
      canvas,
      Offset(size.width * 0.23 + drift, size.height * 0.22),
      shortest * 0.9,
      cloudAlpha * 0.8,
    );
    _cloud(
      canvas,
      Offset(size.width * 0.63 - drift * 0.6, size.height * 0.12),
      shortest * 1.15,
      cloudAlpha,
    );
    if (condition == WeatherCondition.cloudy || condition.isRainy) {
      _cloud(
        canvas,
        Offset(size.width * 0.47 + drift * 1.4, size.height * 0.05),
        shortest * 1.35,
        cloudAlpha * 0.8,
      );
    }
  }

  void _cloud(Canvas canvas, Offset center, double scale, double alpha) {
    final path = Path()
      ..addOval(
        Rect.fromCircle(
          center: center + Offset(-scale * 0.16, scale * 0.03),
          radius: scale * 0.105,
        ),
      )
      ..addOval(
        Rect.fromCircle(
          center: center + Offset(-scale * 0.01, -scale * 0.04),
          radius: scale * 0.145,
        ),
      )
      ..addOval(
        Rect.fromCircle(
          center: center + Offset(scale * 0.15, scale * 0.025),
          radius: scale * 0.095,
        ),
      )
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center + Offset(0, scale * 0.065),
            width: scale * 0.44,
            height: scale * 0.115,
          ),
          Radius.circular(scale * 0.06),
        ),
      );
    canvas.drawPath(
      path,
      Paint()..color = Colors.white.withValues(alpha: alpha),
    );
  }

  void _paintRain(
    Canvas canvas,
    Size size,
    double t, {
    required int count,
    bool long = false,
  }) {
    final paint = Paint()
      ..color = const Color(0xFFD8F2FF).withValues(alpha: 0.45)
      ..strokeWidth = 1.25
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < count; i++) {
      final speed = 0.6 + _rand(i, 4) * 0.9;
      final x = _rand(i, 5) * (size.width + 40) - 20;
      final y = ((_rand(i, 6) + t * speed * 2.2) % 1.05) * size.height;
      final length = (long ? 22.0 : 13.0) + _rand(i, 7) * 12;
      canvas.drawLine(
        Offset(x, y),
        Offset(x - length * 0.22, y + length),
        paint,
      );
    }
  }

  void _paintSnow(Canvas canvas, Size size, double t) {
    for (var i = 0; i < 26; i++) {
      final speed = 0.25 + _rand(i, 8) * 0.5;
      final x = _rand(i, 9) * size.width + math.sin(t * math.pi * 2 + i) * 10;
      final y = ((_rand(i, 10) + t * speed) % 1.03) * size.height;
      canvas.drawCircle(
        Offset(x, y),
        1.4 + _rand(i, 11) * 2.6,
        Paint()..color = Colors.white.withValues(alpha: 0.55),
      );
    }
  }

  void _paintDust(Canvas canvas, Size size, double t) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFE0A45C).withValues(alpha: 0.10),
    );
    for (var i = 0; i < 40; i++) {
      final speed = 0.15 + _rand(i, 12) * 0.4;
      final x = ((_rand(i, 13) + t * speed) % 1.05) * size.width;
      final y =
          (_rand(i, 14) * 0.9 + math.sin(t * math.pi * 2 + i * 0.7) * 0.05) *
          size.height;
      canvas.drawCircle(
        Offset(x, y),
        1 + _rand(i, 15) * 2.8,
        Paint()
          ..color = const Color(0xFFFFE0B0)
              .withValues(alpha: 0.16 + _rand(i, 16) * 0.25),
      );
    }
  }

  void _paintFog(Canvas canvas, Size size, double t) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    for (var i = 0; i < 4; i++) {
      final y = size.height * (0.32 + i * 0.13);
      final offset = math.sin(t * math.pi * 2 + i) * 26;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-40 + offset, y, size.width * (0.8 + i * 0.08), 22),
          const Radius.circular(22),
        ),
        paint,
      );
    }
  }

  void _paintLightning(Canvas canvas, Size size, double t) {
    final flash = math.sin(t * math.pi * 16);
    if (flash < 0.93) return;
    final opacity = ((flash - 0.93) / 0.07).clamp(0.0, 1.0);
    final start = Offset(size.width * 0.58, size.height * 0.22);
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(start.dx + 14, start.dy + 38)
      ..lineTo(start.dx - 4, start.dy + 40)
      ..lineTo(start.dx + 10, start.dy + 82);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFFFEB9A).withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );
  }

  static double _rand(int index, int salt) {
    final value = math.sin(index * 127.1 + salt * 311.7) * 43758.5453;
    return value - value.floorToDouble();
  }

  @override
  bool shouldRepaint(covariant _ScenePainter oldDelegate) =>
      oldDelegate.condition != condition || oldDelegate.isDay != isDay;
}
