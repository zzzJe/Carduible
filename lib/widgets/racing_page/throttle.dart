import 'package:flutter/material.dart';

class ThrottleWidget extends StatefulWidget {
  final Function onUpdate;

  const ThrottleWidget({
    super.key,
    required this.onUpdate,
  });

  @override
  State<ThrottleWidget> createState() => _ThrottleWidgetState();
}

class _ThrottleWidgetState extends State<ThrottleWidget> {
  double fillRatio = 0.0; // 比例：0.0（沒填）～ 1.0（全填）

  void _updateFromLocalOffset(Offset localPosition, double height) {
    final y = localPosition.dy.clamp(0.0, height);
    final ratio = 1.0 - (y / height); // 注意：從底部往上填，所以反過來算
    setState(() {
      fillRatio = ratio;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final width = constraints.maxWidth;

        return GestureDetector(
          onPanDown: (details) {
            _updateFromLocalOffset(details.localPosition, height);
            widget.onUpdate(fillRatio);
          },
          onPanUpdate: (details) {
            _updateFromLocalOffset(details.localPosition, height);
            widget.onUpdate(fillRatio);
          },
          onPanEnd: (details) {
            fillRatio = 0.0;
            widget.onUpdate(fillRatio);
          },
          onPanCancel: () {
            fillRatio = 0.0;
            widget.onUpdate(fillRatio);
          },
          child: CustomPaint(
            size: Size(width, height),
            painter: _FillPainter(
              fillRatio: fillRatio,
              fillColor: const Color.fromARGB(255, 116, 116, 116),
              backgroundColor: Color.fromARGB(255, 40, 40, 40),
              highlightColor: const Color.fromARGB(255, 40, 120, 42),
              divisions: 10,
            ),
          ),
        );
      },
    );
  }
}

class _FillPainter extends CustomPainter {
  final double fillRatio; // 0.0 ~ 1.0
  final Color fillColor;
  final Color highlightColor; // 最上層 block 的顏色
  final Color backgroundColor;
  final int divisions;

  const _FillPainter({
    required this.fillRatio,
    required this.fillColor,
    required this.highlightColor,
    required this.backgroundColor,
    required this.divisions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double blockHeight = size.height / divisions;
    final double blockWidth = size.width;
    final int filledBlocks = (fillRatio * divisions).floor();

    final Paint backgroundPaint = Paint()..color = backgroundColor;
    final Paint borderPaint = Paint()
      ..color = Colors.black.withAlpha(20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    Rect blockRectAt(int index) {
      final double top = size.height - (index + 1) * blockHeight;
      final double bottom = size.height - index * blockHeight;
      return Rect.fromLTRB(0, top, blockWidth, bottom);
    }

    for (int i = 0; i < divisions; i++) {
      final Rect rect = blockRectAt(i);

      if (i <= filledBlocks && fillRatio != 0.0) {
        final paint = Paint()
          ..color = i == filledBlocks || fillRatio == 1.0
              ? highlightColor
              : fillColor;
        canvas.drawRect(rect, paint);
      } else {
        canvas.drawRect(rect, backgroundPaint);
      }

      canvas.drawRect(rect, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _FillPainter oldDelegate) {
    return oldDelegate.fillRatio != fillRatio ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.highlightColor != highlightColor ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.divisions != divisions;
  }
}
