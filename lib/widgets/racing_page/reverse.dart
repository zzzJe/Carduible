import 'package:flutter/material.dart';

class ReverseButtonWidget extends StatefulWidget {
  final Function onUpdate;
  final Color pedalColorRest;
  final Color pedalColorActive;

  const ReverseButtonWidget({
    super.key,
    required this.onUpdate,
    required this.pedalColorRest,
    required this.pedalColorActive,
  });

  @override
  State<ReverseButtonWidget> createState() => _ReverseButtonWidgetState();
}

class _ReverseButtonWidgetState extends State<ReverseButtonWidget> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (_) => setState(() => widget.onUpdate(_pressed = true)),
      onPanEnd: (_) => setState(() => widget.onUpdate(_pressed = false)),
      onPanCancel: () => setState(() => widget.onUpdate(_pressed = false)),
      child: TweenAnimationBuilder<Color?>(
        tween: ColorTween(
          begin: widget.pedalColorRest,
          end: _pressed ? widget.pedalColorActive : widget.pedalColorRest,
        ),
        duration: const Duration(milliseconds: 300),
        builder: (context, color, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            color: color,
          );
        },
      ),
    );
  }
}
