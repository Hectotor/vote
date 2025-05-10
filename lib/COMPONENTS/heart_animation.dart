import 'package:flutter/material.dart';

class HeartAnimation extends StatefulWidget {
  final VoidCallback? onTap;

  const HeartAnimation({Key? key, this.onTap}) : super(key: key);

  @override
  State<HeartAnimation> createState() => _HeartAnimationState();
}

class _HeartAnimationState extends State<HeartAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  bool _show = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scale = Tween<double>(begin: 0.4, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _opacity = Tween<double>(begin: 0.8, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _triggerAnimation() {
    setState(() => _show = true);
    _controller.forward(from: 0).whenComplete(() {
      if (mounted) setState(() => _show = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _triggerAnimation();
        widget.onTap?.call();
      },
      behavior: HitTestBehavior.translucent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_show)
            AnimatedBuilder(
              animation: _controller,
              builder: (_, __) => Opacity(
                opacity: _opacity.value,
                child: Transform.scale(
                  scale: _scale.value,
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.redAccent,
                    size: 50,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
