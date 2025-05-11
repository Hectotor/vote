import 'package:flutter/material.dart';
import 'package:toplyke/COMPONENTS/heart_animation.dart';

class ImageVoteCard extends StatelessWidget {
  final dynamic bloc;
  final bool showPercentage;
  final double? percentage;
  final bool showHeart;
  final int heartCount;
  final double borderRadius;

  const ImageVoteCard({
    Key? key,
    required this.bloc,
    this.showPercentage = false,
    this.percentage,
    this.showHeart = false,
    this.heartCount = 5,
    this.borderRadius = 12.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: LayoutBuilder(
          builder: (context, constraints) {
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
                
                // Animation des cœurs
                HeartAnimation(
                  showHeart: showHeart,
                  heartCount: heartCount,
                  color: Colors.red,
                ),
                
                // Texte
                if (bloc['text'] != null && bloc['text'].isNotEmpty)
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(borderRadius),
                          bottomRight: Radius.circular(borderRadius),
                        ),
                        gradient: const LinearGradient(
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
      ),
    );
  }
}
