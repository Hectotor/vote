import 'package:flutter/material.dart';
import 'package:toplyke/COMPONENTS/VOTE/heart_animation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:toplyke/COMPONENTS/VOTE/vote_percentage_badge.dart';
import 'editable_text_card.dart';

class ImageVoteCard extends StatelessWidget {
  final dynamic bloc;
  final bool showPercentage;
  final double? percentage;
  final bool showHeart;
  final bool showHeartOnPercentage;
  final int heartCount;
  final double borderRadius;

  const ImageVoteCard({
    Key? key,
    required this.bloc,
    this.showPercentage = false,
    this.percentage,
    this.showHeart = false,
    this.showHeartOnPercentage = false,
    this.heartCount = 5,
    this.borderRadius = 12.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image de fond avec cache
            if (bloc['postImageUrl'] != null)
              CachedNetworkImage(
                imageUrl: bloc['postImageUrl'],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                memCacheWidth: 500,
                memCacheHeight: 500,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                ),
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
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.0),
                        Colors.black.withOpacity(0.8), 
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: EditableTextCard(
                      initialText: bloc['text'],
                      onTextChanged: (value) {
                        // Mettre à jour le texte du bloc
                        bloc['text'] = value;
                      },
                    ),
                  ),
                ),
              ),
            
            // Pourcentage de votes
            if (showPercentage && percentage != null)
              VotePercentageBadge(
                percentage: percentage!,
                showHeart: showHeartOnPercentage,
              ),
          ],
        ),
      ),
    );
  }
}
