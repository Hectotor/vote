import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math' as math;

class BlocParallaxEffect extends StatefulWidget {
  final Widget child;
  final double maxTranslation;

  const BlocParallaxEffect({
    Key? key,
    required this.child,
    this.maxTranslation = 15.0,
  }) : super(key: key);

  @override
  _BlocParallaxEffectState createState() => _BlocParallaxEffectState();
}

class _BlocParallaxEffectState extends State<BlocParallaxEffect> {
  double _xTranslation = 0.0;
  double _yTranslation = 0.0;

  @override
  void initState() {
    super.initState();
    
    // Écouter les événements de l'accéléromètre
    accelerometerEvents.listen((AccelerometerEvent event) {
      if (mounted) {
        setState(() {
          // Convertir les valeurs de l'accéléromètre en translation
          _xTranslation = _calculateTranslation(event.x);
          _yTranslation = _calculateTranslation(event.y);
        });
      }
    });
  }

  double _calculateTranslation(double value) {
    // Limiter et normaliser la translation
    return math.max(-widget.maxTranslation, 
           math.min(widget.maxTranslation, value * 3));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      transform: Matrix4.identity()
        ..translate(_xTranslation, _yTranslation),
      child: widget.child,
    );
  }
}

// Widget utilitaire pour simplifier l'utilisation du parallax
class ParallaxBloc extends StatelessWidget {
  final Widget? image;
  final Widget? textWidget;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const ParallaxBloc({
    Key? key,
    this.image,
    this.textWidget,
    this.backgroundColor,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocParallaxEffect(
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
          borderRadius: borderRadius ?? BorderRadius.circular(15),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (image != null) 
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: borderRadius ?? BorderRadius.circular(15),
                  child: image!,
                ),
              ),
            if (textWidget != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: textWidget!,
              ),
          ],
        ),
      ),
    );
  }
}
