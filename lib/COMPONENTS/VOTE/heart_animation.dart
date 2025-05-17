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

class _HeartAnimationState extends State<HeartAnimation> {
  @override
  void didUpdateWidget(HeartAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showHeart && !oldWidget.showHeart) {
      HapticFeedback.mediumImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: AnimatedOpacity(
        opacity: widget.showHeart ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 150),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          child: Icon(
            Icons.favorite,
            color: Colors.white,
            size: widget.showHeart ? 40 : 35,
          ),
        ),
      ),
    );
  }
}
