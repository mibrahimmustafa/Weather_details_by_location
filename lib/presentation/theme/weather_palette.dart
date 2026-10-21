import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/weather_condition.dart';

/// Atmospheric gradients and accents per condition and time of day.
class WeatherPalette {
  const WeatherPalette({
    required this.gradient,
    required this.glow,
    required this.accent,
    required this.textColor,
    required this.secondaryTextColor,
  });

  final List<Color> gradient;
  final Color glow;
  final Color accent;
  final Color textColor;
  final Color secondaryTextColor;

  static WeatherPalette of(WeatherCondition condition, {required bool isDay}) {
    if (!isDay) {
      return switch (condition) {
        WeatherCondition.clear ||
        WeatherCondition.mainlyClear => const WeatherPalette(
          gradient: [Color(0xFF081326), Color(0xFF0D2547), Color(0xFF16406E)],
          glow: Color(0xFF5C8CFF),
          accent: Color(0xFF9DC4FF),
          textColor: Colors.white,
          secondaryTextColor: Color(0xFFB7CBE5),
        ),
        WeatherCondition.dust => const WeatherPalette(
          gradient: [Color(0xFF241A18), Color(0xFF4A3122), Color(0xFF6B4526)],
          glow: Color(0xFFD99A4E),
          accent: Color(0xFFFFC978),
          textColor: Colors.white,
          secondaryTextColor: Color(0xFFE6CFB4),
        ),
        _ => const WeatherPalette(
          gradient: [Color(0xFF0A1524), Color(0xFF172B45), Color(0xFF28445F)],
          glow: Color(0xFF6C9BC4),
          accent: Color(0xFF9DC4FF),
          textColor: Colors.white,
          secondaryTextColor: Color(0xFFB7CBE5),
        ),
      };
    }

    return switch (condition) {
      WeatherCondition.clear => const WeatherPalette(
        gradient: [Color(0xFF0E4C9A), Color(0xFF1F7BD3), Color(0xFF57B6F2)],
        glow: Color(0xFFFFD37A),
        accent: Color(0xFFFFE3A3),
        textColor: Colors.white,
        secondaryTextColor: Color(0xFFE4F3FF),
      ),
      WeatherCondition.mainlyClear => const WeatherPalette(
        gradient: [Color(0xFF16599F), Color(0xFF3387CB), Color(0xFF74BEEA)],
        glow: Color(0xFFFFD37A),
        accent: Color(0xFFFFE3A3),
        textColor: Colors.white,
        secondaryTextColor: Color(0xFFE4F3FF),
      ),
      WeatherCondition.partlyCloudy => const WeatherPalette(
        gradient: [Color(0xFF255E92), Color(0xFF4A84B5), Color(0xFF8CB8D8)],
        glow: Color(0xFFFFDCA0),
        accent: Color(0xFFFFE7B8),
        textColor: Colors.white,
        secondaryTextColor: Color(0xFFEAF4FB),
      ),
      WeatherCondition.cloudy => const WeatherPalette(
        gradient: [Color(0xFF3B4E64), Color(0xFF5C7188), Color(0xFF8CA0B4)],
        glow: Color(0xFFDCE8F4),
        accent: Color(0xFFE8F1F8),
        textColor: Colors.white,
        secondaryTextColor: Color(0xFFE3ECF4),
      ),
      WeatherCondition.fog => const WeatherPalette(
        gradient: [Color(0xFF4B5764), Color(0xFF6E7C8A), Color(0xFF9AA7B3)],
        glow: Color(0xFFE7EEF4),
        accent: Color(0xFFEFF5FA),
        textColor: Colors.white,
        secondaryTextColor: Color(0xFFE9F0F5),
      ),
      WeatherCondition.drizzle || WeatherCondition.rain => const WeatherPalette(
        gradient: [Color(0xFF1B3550), Color(0xFF2B5375), Color(0xFF4A7E9F)],
        glow: Color(0xFF7FD4E8),
        accent: Color(0xFF8FE3F0),
        textColor: Colors.white,
        secondaryTextColor: Color(0xFFD3EBF5),
      ),
      WeatherCondition.heavyRain ||
      WeatherCondition.freezingRain => const WeatherPalette(
        gradient: [Color(0xFF122943), Color(0xFF214566), Color(0xFF356C8B)],
        glow: Color(0xFF6FC8DE),
        accent: Color(0xFF89DFEF),
        textColor: Colors.white,
        secondaryTextColor: Color(0xFFD3EBF5),
      ),
      WeatherCondition.thunderstorm => const WeatherPalette(
        gradient: [Color(0xFF171C33), Color(0xFF2A2F54), Color(0xFF454B7A)],
        glow: Color(0xFF9C8CFF),
        accent: Color(0xFFFFD86B),
        textColor: Colors.white,
        secondaryTextColor: Color(0xFFD7DCF4),
      ),
      WeatherCondition.snow => const WeatherPalette(
        gradient: [Color(0xFF3E617F), Color(0xFF6E93B1), Color(0xFFA9CBE2)],
        glow: Color(0xFFEAF7FF),
        accent: Color(0xFFF4FBFF),
        textColor: Colors.white,
        secondaryTextColor: Color(0xFFF0F8FD),
      ),
      WeatherCondition.dust => const WeatherPalette(
        gradient: [Color(0xFF7A4A21), Color(0xFFA9703A), Color(0xFFD9A05F)],
        glow: Color(0xFFFFD08A),
        accent: Color(0xFFFFE0AE),
        textColor: Colors.white,
        secondaryTextColor: Color(0xFFFFEFD9),
      ),
      WeatherCondition.unknown => const WeatherPalette(
        gradient: [Color(0xFF27405C), Color(0xFF44617F), Color(0xFF6C8BA7)],
        glow: Color(0xFFBBD5EA),
        accent: Color(0xFFDDEBF7),
        textColor: Colors.white,
        secondaryTextColor: Color(0xFFE3EEF7),
      ),
    };
  }

  LinearGradient get linearGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: gradient,
  );

  Color levelColor(double value, double warning, double danger) {
    if (value >= danger) return AppColors.coral;
    if (value >= warning) return AppColors.amber;
    return AppColors.teal;
  }
}
