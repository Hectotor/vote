import 'package:flutter/material.dart';
import 'package:toplyke/COMPONENTS/image_vote_card.dart';

class PollGridDisplay extends StatelessWidget {
  final List<dynamic> blocs;
  final String type;

  const PollGridDisplay({
    Key? key,
    required this.blocs,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (type == 'triple' && blocs.length >= 3) {
      return Column(
        children: [
          // Ligne du haut avec 2 blocs
          Row(
            children: [
              Expanded(
                child: ImageVoteCard(bloc: blocs[0]),
              ),
              const SizedBox(width: 8), // Espacement entre les images
              Expanded(
                child: ImageVoteCard(bloc: blocs[1]),
              ),
            ],
          ),
          const SizedBox(height: 8), // Espacement entre les lignes
          // Bloc du bas centré
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                child: ImageVoteCard(bloc: blocs[2]),
              ),
            ],
          ),
        ],
      );
    }
    
    // Layout par défaut pour les autres types
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: blocs.length,
      itemBuilder: (context, index) {
        return ImageVoteCard(bloc: blocs[index]);
      },
    );
  }
}
