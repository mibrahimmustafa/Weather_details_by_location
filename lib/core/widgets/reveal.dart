import 'package:flutter/material.dart';

/// Fade + rise entrance used to stagger sections without a package.
class Reveal extends StatefulWidget {
  const Reveal({
    super.key,
    required this.child,
    this.index = 0,
    this.offset = 18,
  });

  final Widget child;
  final int index;
  final double offset;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 620 + widget.index * 70),
    );
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        (widget.index * 0.035).clamp(0.0, 0.35),
        1,
        curve: Curves.easeOutCubic,
      ),
    );
    _fade = curve;
    _slide = Tween<Offset>(
      begin: Offset(0, widget.offset / 200),
      end: Offset.zero,
    ).animate(curve);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
      return widget.child;
    }
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
