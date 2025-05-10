import 'package:flutter/material.dart';
import 'dart:math' as math;

class SpiralLoading extends StatefulWidget {
  final double size;
  final Color color;

  const SpiralLoading({
    Key? key,
    this.size = 50.0,
    this.color = Colors.white,
  }) : super(key: key);

  @override
  _SpiralLoadingState createState() => _SpiralLoadingState();
}

class _SpiralLoadingState extends State<SpiralLoading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: SpiralPainter(
            animation: _animation,
            color: widget.color,
          ),
        ),
      ),
    );
  }
}

class SpiralPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  SpiralPainter({
    required this.animation,
    required this.color,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;

    final path = Path();
    path.moveTo(center.dx, center.dy);

    for (double t = 0; t <= 2 * math.pi * animation.value * 3; t += 0.1) {
      final x = center.dx + radius * t * math.cos(t);
      final y = center.dy + radius * t * math.sin(t);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SpiralPainter oldDelegate) {
    return oldDelegate.animation.value != animation.value ||
        oldDelegate.color != color;
  }
}
