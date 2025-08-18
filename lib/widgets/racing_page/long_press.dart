import 'dart:async';
import 'package:flutter/material.dart';

class LongPress extends StatefulWidget {
  final Function onPressChange;
  final Function finalCallback;
  final Duration duration;
  final Widget child;

  const LongPress({
    super.key,
    required this.onPressChange,
    required this.finalCallback,
    required this.duration,
    required this.child,
  });

  @override
  State<LongPress> createState() => _LongPressState();
}

class _LongPressState extends State<LongPress> {
  Timer? _holdTimer;
  bool _isPressed = false;

  void _startHoldTimer() {
    _holdTimer?.cancel();
    setState(() => widget.onPressChange(_isPressed = true));

    _holdTimer = Timer(widget.duration, () {
      if (_isPressed) {
        widget.finalCallback();
        _cancelHoldTimer();
      }
    });
  }

  void _cancelHoldTimer() {
    if (!_isPressed) {
      return;
    }
    _holdTimer?.cancel();
    setState(() => widget.onPressChange(_isPressed = false));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (_) => _startHoldTimer(),
      onPanEnd: (_) => _cancelHoldTimer(),
      onPanCancel: () => _cancelHoldTimer(),
      child: widget.child,
    );
  }
}
