import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Subtle press + hover feedback used across every interactive surface.
class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scale = 0.975,
    this.hoverScale = 1.012,
    this.semanticLabel,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scale;
  final double hoverScale;
  final String? semanticLabel;
  final bool enabled;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;
  bool _hovered = false;

  bool get _interactive =>
      widget.enabled && (widget.onTap != null || widget.onLongPress != null);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: _interactive,
      label: widget.semanticLabel,
      child: MouseRegion(
        cursor: _interactive ? SystemMouseCursors.click : MouseCursor.defer,
        onEnter: (_) => _setHovered(true),
        onExit: (_) => _setHovered(false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _interactive ? (_) => _setPressed(true) : null,
          onTapCancel: _interactive ? () => _setPressed(false) : null,
          onTapUp: _interactive ? (_) => _setPressed(false) : null,
          onTap: _interactive
              ? () {
                  HapticFeedback.lightImpact();
                  widget.onTap?.call();
                }
              : null,
          onLongPress: _interactive && widget.onLongPress != null
              ? () {
                  HapticFeedback.mediumImpact();
                  widget.onLongPress!.call();
                }
              : null,
          child: AnimatedScale(
            scale: _pressed
                ? widget.scale
                : _hovered && _interactive
                ? widget.hoverScale
                : 1,
            duration: const Duration(milliseconds: 170),
            curve: Curves.easeOutCubic,
            child: widget.child,
          ),
        ),
      ),
    );
  }

  void _setPressed(bool value) {
    if (!mounted || _pressed == value) return;
    setState(() => _pressed = value);
  }

  void _setHovered(bool value) {
    if (!mounted || _hovered == value) return;
    setState(() => _hovered = value);
  }
}
