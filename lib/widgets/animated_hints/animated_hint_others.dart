import 'package:flutter/material.dart';

class AnimatedHintOthers extends StatefulWidget {
  const AnimatedHintOthers({super.key});

  @override
  State<AnimatedHintOthers> createState() => _AnimatedHintOthersState();
}

class _AnimatedHintOthersState extends State<AnimatedHintOthers> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // 使用更長的動畫時間以模擬呼吸燈緩慢的效果
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true); // 添加reverse讓動畫反向執行，形成呼吸效果
    
    // 透明度動畫，從0.5到1.0
    _opacityAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    
    // 縮放動畫，從0.9到1.1
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: const Icon(
              Icons.navigation,
              size: 100,
            ),
          ),
        );
      },
    );
  }
}