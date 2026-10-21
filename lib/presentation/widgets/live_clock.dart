import 'dart:async';

import 'package:flutter/material.dart';

/// A clock that ticks only for the city it belongs to.
///
/// Isolated in its own widget so only this text rebuilds every second instead
/// of the whole weather screen.
class LiveClock extends StatefulWidget {
  const LiveClock({
    super.key,
    required this.offsetSeconds,
    this.style,
    this.showSeconds = true,
  });

  final int offsetSeconds;
  final TextStyle? style;
  final bool showSeconds;

  @override
  State<LiveClock> createState() => _LiveClockState();
}

class _LiveClockState extends State<LiveClock> {
  Timer? _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = _cityNow();
    _start();
  }

  @override
  void didUpdateWidget(covariant LiveClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.offsetSeconds != widget.offsetSeconds ||
        oldWidget.showSeconds != widget.showSeconds) {
      _timer?.cancel();
      _start();
    }
  }

  void _start() {
    _now = _cityNow();
    _timer = Timer.periodic(
      widget.showSeconds
          ? const Duration(seconds: 1)
          : const Duration(minutes: 1),
      (_) {
        if (!mounted) return;
        setState(() => _now = _cityNow());
      },
    );
  }

  DateTime _cityNow() =>
      DateTime.now().toUtc().add(Duration(seconds: widget.offsetSeconds));

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hh = _now.hour.toString().padLeft(2, '0');
    final mm = _now.minute.toString().padLeft(2, '0');
    final ss = _now.second.toString().padLeft(2, '0');
    final text = widget.showSeconds ? '$hh:$mm:$ss' : '$hh:$mm';
    return Text(
      text,
      style: widget.style,
      semanticsLabel: text,
      textDirection: TextDirection.ltr,
    );
  }
}
