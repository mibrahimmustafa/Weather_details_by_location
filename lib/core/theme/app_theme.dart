import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Brand palette. Kept as plain constants so painters, charts and themes can
/// share exactly the same values.
abstract final class AppColors {
  static const Color navy950 = Color(0xFF050C18);
  static const Color navy900 = Color(0xFF07101F);
  static const Color navy800 = Color(0xFF0B1B33);
  static const Color navy700 = Color(0xFF102A4C);
  static const Color navy600 = Color(0xFF173B67);

  static const Color teal = Color(0xFF46D5C0);
  static const Color tealDeep = Color(0xFF0B7A6E);
  static const Color tealSoft = Color(0xFF8CEEE1);

  static const Color gold = Color(0xFFFFC65C);
  static const Color amber = Color(0xFFF0A63A);
  static const Color coral = Color(0xFFFF7A6B);
  static const Color sky = Color(0xFF63B3FF);
  static const Color lilac = Color(0xFF9C8CFF);

  static const Color mist = Color(0xFFEAF2FB);
  static const Color cloud = Color(0xFFF5F8FC);

  static const Color success = Color(0xFF3FBF8F);
  static const Color warning = Color(0xFFE9A23B);
  static const Color danger = Color(0xFFE85C4A);

  static const Color textOnDark = Color(0xFFF2F7FF);
  static const Color mutedOnDark = Color(0xFFA8BBD4);
  static const Color textOnLight = Color(0xFF0B1B33);
  static const Color mutedOnLight = Color(0xFF5B6B82);
}

abstract final class AppRadius {
  static const double sm = 12;
  static const double md = 18;
  static const double lg = 24;
  static const double xl = 30;
  static const double xxl = 36;
  static const double pill = 999;
}

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;
}

abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final scheme = isDark
        ? const ColorScheme.dark(
            primary: AppColors.teal,
            onPrimary: Color(0xFF04231F),
            primaryContainer: Color(0xFF12433E),
            onPrimaryContainer: Color(0xFFB9FFF3),
            secondary: AppColors.gold,
            onSecondary: Color(0xFF2A1B00),
            secondaryContainer: Color(0xFF3C2E12),
            onSecondaryContainer: Color(0xFFFFE7B8),
            tertiary: AppColors.sky,
            onTertiary: Color(0xFF001B33),
            error: Color(0xFFFF8A7D),
            onError: Color(0xFF3A0500),
            errorContainer: Color(0xFF5A1710),
            onErrorContainer: Color(0xFFFFDAD4),
            surface: Color(0xFF0B1526),
            onSurface: AppColors.textOnDark,
            surfaceContainerHighest: Color(0xFF1B2A42),
            onSurfaceVariant: AppColors.mutedOnDark,
            outline: Color(0xFF3A4C67),
            outlineVariant: Color(0xFF25344B),
            shadow: Colors.black,
            inverseSurface: AppColors.cloud,
            onInverseSurface: AppColors.textOnLight,
            inversePrimary: AppColors.tealDeep,
          )
        : const ColorScheme.light(
            primary: AppColors.tealDeep,
            onPrimary: Colors.white,
            primaryContainer: Color(0xFFC8F4ED),
            onPrimaryContainer: Color(0xFF00201C),
            secondary: Color(0xFF8A5A00),
            onSecondary: Colors.white,
            secondaryContainer: Color(0xFFFFE9BE),
            onSecondaryContainer: Color(0xFF2A1B00),
            tertiary: Color(0xFF0B5FA5),
            onTertiary: Colors.white,
            error: Color(0xFFB3261E),
            onError: Colors.white,
            errorContainer: Color(0xFFF9DEDC),
            onErrorContainer: Color(0xFF410E0B),
            surface: Color(0xFFF8FBFF),
            onSurface: AppColors.textOnLight,
            surfaceContainerHighest: Color(0xFFE7EFF9),
            onSurfaceVariant: AppColors.mutedOnLight,
            outline: Color(0xFFB7C4D6),
            outlineVariant: Color(0xFFDCE5F0),
            shadow: Color(0xFF0B1B33),
            inverseSurface: AppColors.navy800,
            onInverseSurface: AppColors.textOnDark,
            inversePrimary: AppColors.tealSoft,
          );

    final textTheme = _textTheme(scheme.onSurface);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: 'PlexArabic',
      textTheme: textTheme,
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: scheme.surface,
      dividerColor: scheme.outlineVariant,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: textTheme.labelLarge?.copyWith(fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          side: BorderSide(color: scheme.outlineVariant),
          textStyle: textTheme.labelLarge?.copyWith(fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(44, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.92),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        prefixIconColor: scheme.onSurfaceVariant,
        suffixIconColor: scheme.onSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? const Color(0xFF0D1929) : Colors.white,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: AppColors.navy950.withValues(alpha: 0.55),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xxl),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: scheme.outlineVariant,
        constraints: const BoxConstraints(maxWidth: 720),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? const Color(0xFF0D1929) : Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? const Color(0xFF1C2C44) : AppColors.navy800,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.textOnDark,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        insetPadding: const EdgeInsets.all(AppSpacing.lg),
      ),
      tooltipTheme: TooltipThemeData(
        waitDuration: const Duration(milliseconds: 500),
        textStyle: textTheme.labelMedium?.copyWith(
          color: isDark ? AppColors.navy900 : Colors.white,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.mist : AppColors.navy800,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.primary.withValues(alpha: 0.14),
        circularTrackColor: scheme.primary.withValues(alpha: 0.14),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.onPrimary
              : scheme.onSurfaceVariant,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.surfaceContainerHighest,
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        iconColor: scheme.onSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: scheme.primary,
        selectionColor: scheme.primary.withValues(alpha: 0.22),
        selectionHandleColor: scheme.primary,
      ),
    );
  }

  static TextTheme _textTheme(Color color) {
    TextStyle style(
      double size,
      FontWeight weight, {
      double height = 1.3,
      double tracking = 0,
    }) => TextStyle(
      fontFamily: 'PlexArabic',
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: tracking,
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return TextTheme(
      displayLarge: style(64, FontWeight.w600, height: 1.02, tracking: -1.6),
      displayMedium: style(48, FontWeight.w600, height: 1.05, tracking: -1.2),
      displaySmall: style(34, FontWeight.w600, height: 1.1, tracking: -0.6),
      headlineLarge: style(28, FontWeight.w600, height: 1.2, tracking: -0.3),
      headlineMedium: style(24, FontWeight.w600, height: 1.25),
      headlineSmall: style(20, FontWeight.w600, height: 1.3),
      titleLarge: style(19, FontWeight.w600, height: 1.3),
      titleMedium: style(16, FontWeight.w600, height: 1.35),
      titleSmall: style(14, FontWeight.w600, height: 1.35),
      bodyLarge: style(15, FontWeight.w400, height: 1.55),
      bodyMedium: style(14, FontWeight.w400, height: 1.5),
      bodySmall: style(12.5, FontWeight.w400, height: 1.45),
      labelLarge: style(14, FontWeight.w600, height: 1.3, tracking: 0.1),
      labelMedium: style(12, FontWeight.w500, height: 1.3, tracking: 0.2),
      labelSmall: style(10.5, FontWeight.w500, height: 1.4, tracking: 0.4),
    );
  }
}

/// Small helpers that keep widget code readable and theme-consistent.
extension AjwaaTheme on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get texts => Theme.of(this).textTheme;

  Color get muted => isDark ? AppColors.mutedOnDark : AppColors.mutedOnLight;

  Color get cardColor => isDark
      ? Colors.white.withValues(alpha: 0.055)
      : Colors.white.withValues(alpha: 0.86);

  Color get cardBorder => isDark
      ? Colors.white.withValues(alpha: 0.09)
      : Colors.white.withValues(alpha: 0.9);

  List<BoxShadow> get softShadow => isDark
      ? const []
      : [
          BoxShadow(
            color: AppColors.navy800.withValues(alpha: 0.055),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: AppColors.navy800.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ];
}
