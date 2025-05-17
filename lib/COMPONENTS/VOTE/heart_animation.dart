import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HeartAnimation extends StatefulWidget {
  final bool showHeart;

  const HeartAnimation({
    Key? key,
    required this.showHeart,
  }) : super(key: key);

  @override
  State<HeartAnimation> createState() => _HeartAnimationState();
}

class _HeartAnimationState extends State<HeartAnimation>
    with SingleTickerProviderStateMixin {
  double _scale = 0.0;
  bool _visible = false;

  @override
  void didUpdateWidget(covariant HeartAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showHeart && !oldWidget.showHeart) {
      _showHeart();
    }
  }

  void _showHeart() {
    HapticFeedback.mediumImpact();
    setState(() {
      _visible = true;
      _scale = 1.4;
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _scale = 1.0;
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _visible = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _visible ? 1.0 : 0.0,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: _scale),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    if (_visible)
                      BoxShadow(
                        color: Colors.pinkAccent.withOpacity(0.6),
                        blurRadius: 5,
                        spreadRadius: 5,
                      ),
                  ],
                ),
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      colors: [Colors.pink, Colors.red],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds);
                  },
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 80,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
