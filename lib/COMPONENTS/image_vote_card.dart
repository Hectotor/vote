import 'dart:math';
import 'package:flutter/material.dart';

class ImageVoteCard extends StatelessWidget {
  final dynamic bloc;
  final bool showPercentage;
  final double? percentage;
  final bool showHeart;
  final Random _random = Random();

  ImageVoteCard({
    Key? key,
    required this.bloc,
    this.showPercentage = false,
    this.percentage,
    this.showHeart = false,
  }) : super(key: key);

  // Génère une position aléatoire dans le conteneur
  Offset _getRandomPosition(Size size) {
    double left = _random.nextDouble() * (size.width - 40); // -40 pour garder le cœur dans les limites
    double top = _random.nextDouble() * (size.height - 40);
    return Offset(left, top);
  }

  // Génère une taille aléatoire pour le cœur
  double _getRandomSize() {
    return 40.0 + _random.nextDouble() * 40.0; // Taille entre 40 et 80
  }

  // Génère une opacité aléatoire
  double _getRandomOpacity() {
    return 0.7 + _random.nextDouble() * 0.3; // Opacité entre 0.7 et 1.0
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          
          // Créer une liste de cœurs avec des positions et tailles aléatoires
          final hearts = List.generate(
            5, // Nombre de cœurs à afficher
            (index) {
              return Positioned(
                left: _getRandomPosition(size).dx,
                top: _getRandomPosition(size).dy,
                child: AnimatedOpacity(
                  opacity: showHeart ? _getRandomOpacity() : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: _getRandomSize(),
                  ),
                ),
              );
            },
          );

          return Stack(
            fit: StackFit.expand,
            children: [
              // Image de fond
              if (bloc['postImageUrl'] != null)
                Image.network(
                  bloc['postImageUrl'],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              
              // Filtre de couleur
              if (bloc['filterColor'] != null && bloc['filterColor'].toString().isNotEmpty)
                Container(
                  color: Color(int.parse(bloc['filterColor'])).withOpacity(0.5),
                ),
              
              // Cœurs animés
              ...hearts,
              
              // Texte
              if (bloc['text'] != null && bloc['text'].isNotEmpty)
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8.0),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black87, Colors.transparent],
                      ),
                    ),
                    child: Text(
                      bloc['text'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              
              // Pourcentage de votes
              if (showPercentage && percentage != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${percentage!.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
