import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:toplyke/COMPONENTS/vote_percentages.dart';
import 'package:toplyke/COMPONENTS/heart_animation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Initialiser Cloud Firestore
final firestore = FirebaseFirestore.instance;

class PollGridHome extends StatefulWidget {
  final List<String?> images;
  final List<Color> imageFilters;
  final int numberOfBlocs;
  final List<String?> textes;
  final String postId;
  final List<int?> voteCounts;
  final List<List<dynamic>?> votes;
  final List<dynamic>? blocs;

  const PollGridHome({
    super.key,
    required this.images,
    required this.imageFilters,
    required this.numberOfBlocs,
    required this.textes,
    required this.postId,
    required this.voteCounts,
    required this.votes,
    required this.blocs,
  }) : assert(images.length == numberOfBlocs),
       assert(imageFilters.length == numberOfBlocs),
       assert(textes.length == numberOfBlocs),
       assert(voteCounts.length == numberOfBlocs),
       assert(votes.length == numberOfBlocs);

  @override
  State<PollGridHome> createState() => _PollGridHomeState();
}

class _PollGridHomeState extends State<PollGridHome> with SingleTickerProviderStateMixin {
  bool _showPercentages = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Gérer le cas où la hauteur est infinie
        final double maxHeight = constraints.maxHeight.isFinite 
            ? constraints.maxHeight 
            : 400; // Hauteur par défaut si infinie
        
        final double blocHeight = maxHeight / 2; // Diviser l'espace en 2 pour les rangées
        
        return SizedBox(
          height: maxHeight,
          child: Stack(
            children: [
              // Conteneur des blocs
              Column(
                children: [
                  // Première rangée (blocs 1 et 2)
                  SizedBox(
                    height: blocHeight,
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: _buildBloc(0),
                          ),
                        ),
                        if (widget.numberOfBlocs > 1)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: _buildBloc(1),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Deuxième rangée (blocs 3 et 4)
                  if (widget.numberOfBlocs == 3)
                    SizedBox(
                      height: blocHeight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: SizedBox(
                                  width: (constraints.maxWidth - 8.0) / 2,
                                  height: blocHeight - 8.0, // Soustraire le padding
                                  child: _buildBloc(2),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (widget.numberOfBlocs == 4)
                    SizedBox(
                      height: blocHeight,
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: _buildBloc(2),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: _buildBloc(3),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              // Pourcentages de vote
              if (_showPercentages)
                VotePercentages(
                  postId: widget.postId,
                  showPercentages: _showPercentages,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBloc(int index) {
    final blocKey = ValueKey('${widget.postId}_bloc_$index');
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: constraints.maxHeight,
          width: constraints.maxWidth,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              if (widget.images[index] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: CachedNetworkImage(
                    key: blocKey,
                    imageUrl: widget.images[index]!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              
              // Animation du cœur
              HeartAnimation(
                key: blocKey,
                onTap: () async {
                  final user = _auth.currentUser;
                  if (user == null) {
                    print('Utilisateur non authentifié');
                    return;
                  }

                  try {
                    final postRef = firestore.collection('posts').doc(widget.postId);
                    final postDoc = await postRef.get();

                    if (!postDoc.exists) {
                      print('Post non trouvé');
                      return;
                    }

                    final postData = postDoc.data()!;
                    final blocs = postData['blocs'] as List<dynamic>;
                    final bloc = blocs[index];

                    // Vérifier si l'utilisateur a déjà voté
                    bool hasVoted = false;
                    for (final b in blocs) {
                      if (b['votes'] != null && (b['votes'] as List<dynamic>).contains(user.uid)) {
                        hasVoted = true;
                        break;
                      }
                    }

                    if (hasVoted) {
                      print('L\'utilisateur a déjà voté');
                      return;
                    }

                    // Mettre à jour le bloc
                    final updatedBloc = {
                      ...bloc,
                      'voteCount': (bloc['voteCount'] as int? ?? 0) + 1,
                      'votes': [...(bloc['votes'] as List<dynamic>? ?? []), user.uid],
                    };

                    // Mettre à jour le post
                    final updatedBlocs = [...blocs];
                    updatedBlocs[index] = updatedBloc;

                    await postRef.update({
                      'blocs': updatedBlocs,
                    });

                    print('Vote enregistré avec succès');
                  } catch (e) {
                    print('Erreur lors du vote: $e');
                  }
                },
              ),

              // Pourcentages de vote
              Positioned(
                bottom: 8,
                right: 8,
                child: VotePercentages(
                  postId: widget.postId,
                  blocIndex: index,
                  showPercentages: true, // Toujours afficher les pourcentages
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
