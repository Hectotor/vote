import 'package:flutter/material.dart';
import 'dart:math';

class HeartAnimationGroup extends StatefulWidget {
  final bool show;
  final double width;
  final double height;

  const HeartAnimationGroup({
    super.key,
    required this.show,
    required this.width,
    required this.height,
  });

  @override
  State<HeartAnimationGroup> createState() => _HeartAnimationGroupState();
}

class _HeartAnimationGroupState extends State<HeartAnimationGroup> {
  List<Offset> _heartPositions = [];

  @override
  void initState() {
    super.initState();
    _heartPositions = <Offset>[];
  }

  @override
  void didUpdateWidget(covariant HeartAnimationGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.show && !oldWidget.show) {
      _generateHeartPositions();
    }
  }

  void _generateHeartPositions() {
    final random = Random();
    final positions = <Offset>[];
    
    // Générer 5 à 10 cœurs avec des positions aléatoires
    final count = 5 + random.nextInt(6); // Entre 5 et 10 cœurs
    
    for (int i = 0; i < count; i++) {
      // Position X entre 0.2 et 0.8 de la largeur (pour éviter les bords)
      final x = 0.2 + random.nextDouble() * 0.6;
      // Position Y entre 0.2 et 0.8 de la hauteur
      final y = 0.2 + random.nextDouble() * 0.6;
      
      positions.add(Offset(x, y));
    }
    
    setState(() {
      _heartPositions = positions;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.show) return const SizedBox.shrink();

    return Stack(
      fit: StackFit.expand,
      children: [
        // Cœur central
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 900),
          builder: (context, value, child) {
            return Opacity(
              opacity: value > 0.5 ? 2 - 2 * value : 2 * value,
              child: Center(
                child: Transform.scale(
                  scale: 0.4 + value * 0.8,
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.redAccent,
                    size: 80,
                  ),
                ),
              ),
            );
          },
        ),
        
        // Cœurs aléatoires
        ..._heartPositions.map((position) {
          final random = Random();
          final delay = random.nextInt(300); // Délai aléatoire
          final size = 30.0 + random.nextInt(30); // Taille aléatoire
          
          return Positioned(
            left: position.dx * widget.width * 0.5,
            top: position.dy * widget.height * 0.5,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 800 + delay),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value > 0.7 ? 3 * (1 - value) : value,
                  child: Transform.scale(
                    scale: 0.2 + value * 0.8,
                    child: Transform.translate(
                      offset: Offset(0, -50 * value), // Monte vers le haut
                      child: Icon(
                        Icons.favorite,
                        color: Colors.redAccent,
                        size: size,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }).toList(),
      ],
    );
  }
}
