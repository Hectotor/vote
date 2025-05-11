import 'package:flutter/material.dart';

class ImageVoteCard extends StatelessWidget {
  final dynamic bloc;
  final bool showPercentage;
  final double? percentage;

  const ImageVoteCard({
    Key? key,
    required this.bloc,
    this.showPercentage = false,
    this.percentage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1, // Force un ratio carré 1:1
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand, // Remplit tout l'espace disponible
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
            
            // Texte
            if (bloc['text'] != null && bloc['text'].isNotEmpty)
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
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
                      fontWeight: FontWeight.bold,
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
        ),
      ),
    );
  }
}
