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
      _scale = 1.6;
    });

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() {
          _scale = 1.0;
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 800), () {
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
      child: _visible
          ? TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: _scale),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Image.asset(
                    'assets/logo/icon.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                );
              },
            )
          : const SizedBox.shrink(),
    );
  }
}
