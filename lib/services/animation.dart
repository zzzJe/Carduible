import 'dart:ui';

import 'package:flutter/material.dart';

const Duration iosTransitionDuration = Duration(milliseconds: 400);
const Duration iosReverseTransitionDuration = Duration(milliseconds: 300);

Widget iosTransitionsBuilder(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  const Offset enterStartOffset = Offset(1.0, 0.0); // 从右滑进
  const Offset exitEndOffset = Offset(-0.3, 0.0);   // 原页微微左滑 (只有 30%)

  final CurvedAnimation curvedAnimation = CurvedAnimation(
    parent: animation,
    curve: Curves.easeOutQuart,
    reverseCurve: Curves.easeIn,
  );

  final CurvedAnimation secondaryCurvedAnimation = CurvedAnimation(
    parent: secondaryAnimation,
    curve: Curves.easeOutQuart,
    reverseCurve: Curves.easeIn,
  );

  final Animation<Offset> enterAnimation = Tween<Offset>(
    begin: enterStartOffset,
    end: Offset.zero,
  ).animate(curvedAnimation);

  final Animation<Offset> exitAnimation = Tween<Offset>(
    begin: Offset.zero,
    end: exitEndOffset,
  ).animate(secondaryCurvedAnimation);
  
  // 添加阴影透明度动画
  final Animation<double> shadowOpacity = Tween<double>(
    begin: 0.0,
    end: 0.3,
  ).animate(curvedAnimation);
  
  return Stack(
    children: [
      AnimatedBuilder(
        animation: shadowOpacity,
        builder: (context, _) {
          return Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((shadowOpacity.value * 255).round()),
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          );
        }
      ),
      SlideTransition(
        position: enterAnimation,
        child: SlideTransition(
          position: exitAnimation,
          child: child,
        ),
      ),
    ],
  );
}