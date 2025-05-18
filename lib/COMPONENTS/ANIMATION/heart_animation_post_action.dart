import 'package:flutter/material.dart';

class HeartAnimationPostAction extends StatefulWidget {
  final bool animate;
  final bool isLiked;
  final VoidCallback? onTap;
  final double size;
  final Duration duration;

  const HeartAnimationPostAction({
    Key? key,
    required this.animate,
    required this.isLiked,
    this.onTap,
    this.size = 28,
    this.duration = const Duration(milliseconds: 500), // un peu plus long
  }) : super(key: key);

  @override
  State<HeartAnimationPostAction> createState() => _HeartAnimationPostActionState();
}

class _HeartAnimationPostActionState extends State<HeartAnimationPostAction>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnim = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.4)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.4, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 60,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant HeartAnimationPostAction oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !oldWidget.animate) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (context, child) {
        // Afficher immédiatement le cœur rouge si isLiked est true
        return Transform.scale(
          scale: _scaleAnim.value,
          child: IconButton(
            icon: Icon(
              widget.isLiked ? Icons.favorite : Icons.favorite_border,
              color: widget.isLiked ? Colors.red : Colors.white,
              size: widget.size,
            ),
            onPressed: widget.onTap,
          ),
        );
      },
    );
  }
}
