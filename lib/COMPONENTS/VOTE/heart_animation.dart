import 'dart:math';
import 'package:flutter/material.dart';

class HeartAnimation extends StatelessWidget {
  final bool showHeart;
  final int heartCount;
  final Color color;
  final double minSize;
  final double maxSize;
  final Random _random = Random();

  HeartAnimation({
    Key? key,
    this.showHeart = false,
    this.heartCount = 5,
    this.color = Colors.red,
    this.minSize = 40.0,
    this.maxSize = 80.0,
  }) : super(key: key);

  // Génère une position aléatoire dans le conteneur
  Offset _getRandomPosition(Size size) {
    double left = _random.nextDouble() * (size.width - maxSize);
    double top = _random.nextDouble() * (size.height - maxSize);
    return Offset(left, top);
  }

  // Génère une taille aléatoire pour le cœur
  double _getRandomSize() {
    return minSize + _random.nextDouble() * (maxSize - minSize);
  }

  // Génère une opacité aléatoire
  double _getRandomOpacity() {
    return 0.7 + _random.nextDouble() * 0.3; // Opacité entre 0.7 et 1.0
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        
        // Créer une liste de cœurs avec des positions et tailles aléatoires
        final hearts = List.generate(
          heartCount,
          (index) {
            return Positioned(
              left: _getRandomPosition(size).dx,
              top: _getRandomPosition(size).dy,
              child: AnimatedOpacity(
                opacity: showHeart ? _getRandomOpacity() : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Text(
                  '😍', // Emoji heart_eyes (😍)
                  style: TextStyle(
                    fontSize: _getRandomSize(),
                    color: color,
                  ),
                ),
              ),
            );
          },
        );

        return Stack(
          fit: StackFit.expand,
          children: hearts,
        );
      },
    );
  }
}
