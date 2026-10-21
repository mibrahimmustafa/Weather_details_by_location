import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'pressable_scale.dart';

/// Glassy surface used for every card. Adapts to the active theme and gives
/// consistent spacing, border, radius and elevation.
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.margin = EdgeInsets.zero,
    this.onTap,
    this.onLongPress,
    this.gradient,
    this.color,
    this.borderRadius,
    this.borderColor,
    this.blurSigma = 0,
    this.semanticLabel,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Gradient? gradient;
  final Color? color;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final double blurSigma;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppRadius.xl);
    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? context.cardColor) : null,
        gradient: gradient,
        borderRadius: radius,
        border: Border.all(color: borderColor ?? context.cardBorder),
        boxShadow: context.softShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: padding, child: child),
    );

    final content = onTap == null && onLongPress == null
        ? card
        : PressableScale(
            onTap: onTap,
            onLongPress: onLongPress,
            semanticLabel: semanticLabel,
            child: card,
          );

    if (blurSigma <= 0) return content;
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: content,
      ),
    );
  }
}
