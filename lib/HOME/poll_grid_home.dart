import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:toplyke/COMPONENTS/vote_percentages.dart';
import 'package:toplyke/COMPONENTS/heart_animation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toplyke/INSCRIPTION/connexion_screen.dart';

class PollGridHome extends StatefulWidget {
  final List<String?> images;
  final List<Color> imageFilters;
  final int numberOfBlocs;
  final List<String?> textes;
  final String postId;
  final List<int?> voteCounts;
  final List<List<dynamic>?> votes;

  const PollGridHome({
    Key? key,
    required this.images,
    required this.imageFilters,
    required this.numberOfBlocs,
    required this.textes,
    required this.postId,
    required this.voteCounts,
    required this.votes,
  }) : super(key: key);

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
        if (widget.numberOfBlocs <= 2) {
          return Stack(
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(4),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: (constraints.maxWidth - 8.0) / (2 * 200.0),
                ),
                itemCount: widget.numberOfBlocs,
                itemBuilder: (context, index) {
                  return _buildBloc(context, index);
                },
              ),
              if (_showPercentages)
                Positioned.fill(
                  child: VotePercentages(
                    postId: widget.postId,
                    numberOfBlocs: widget.numberOfBlocs,
                  ),
                ),
            ],
          );
        } else {
          return Stack(
            children: [
              Column(
                children: [
                  // Première rangée (blocs 1 et 2)
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: _buildBloc(context, 0),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: _buildBloc(context, 1),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0),
                  // Deuxième rangée (blocs 3 et 4)
                  if (widget.numberOfBlocs == 3)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: SizedBox(
                                width: (constraints.maxWidth - 8.0) / 2,
                                height: 200.0,
                                child: _buildBloc(context, 2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  else if (widget.numberOfBlocs == 4)
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: _buildBloc(context, 2),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: _buildBloc(context, 3),
                          ),
                        ),
                      ],
                    )
                ],
              ),
              if (_showPercentages)
                Positioned.fill(
                  child: VotePercentages(
                    postId: widget.postId,
                    numberOfBlocs: widget.numberOfBlocs,
                  ),
                ),
            ],
          );
        }
      },
    );
  }

  Widget _buildBloc(BuildContext context, int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    final blockWidth = screenWidth / 2 - 16;

    return GestureDetector(
      onTap: () async {
        final user = _auth.currentUser;
        if (user == null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ConnexionPage(),
            ),
          );
          return;
        }

        // Vérifier si l'utilisateur a déjà voté
        final hasVoted = await _hasUserVoted(widget.postId, user.uid);
        if (hasVoted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vous avez déjà voté sur ce sondage'),
              backgroundColor: Colors.grey,
            ),
          );
          return;
        }

        // Enregistrer le vote
        await _vote(index);
        
        // Mettre à jour l'interface
        setState(() {});
      },
      child: Container(
        width: blockWidth,
        height: 200.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            if (widget.images[index] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: CachedNetworkImage(
                  imageUrl: widget.images[index]!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            
            // Animation du cœur
            HeartAnimation(
              onTap: () async {
                final user = _auth.currentUser;
                if (user == null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ConnexionPage(),
                    ),
                  );
                  return;
                }

                // Vérifier si l'utilisateur a déjà voté
                final hasVoted = await _hasUserVoted(widget.postId, user.uid);
                if (hasVoted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vous avez déjà voté sur ce sondage'),
                      backgroundColor: Colors.grey,
                    ),
                  );
                  return;
                }

                // Enregistrer le vote
                await _vote(index);
                
                // Mettre à jour l'interface
                setState(() {});
              },
            ),
            
            // Pourcentage de votes
            FutureBuilder(
              future: _getVotePercentage(widget.postId, index),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final data = snapshot.data as Map<String, dynamic>;
                  final percentage = data['percentage'] as double;
                  if (_showPercentages || percentage > 0) {
                    return Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _getVotePercentage(String postId, int index) async {
    try {
      final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
      final postDoc = await postRef.get();
      
      if (!postDoc.exists) {
        return {'percentage': 0.0};
      }

      final data = postDoc.data() as Map<String, dynamic>;
      final blocs = data['blocs'] is List
          ? data['blocs'] as List<dynamic>
          : (data['blocs'] as Map<String, dynamic>).values.toList();

      // Calculer le nombre total de votes pour tous les blocs
      int totalVotes = blocs.fold(0, (sum, bloc) => sum + (bloc['voteCount'] as int? ?? 0));

      // Si aucun vote, retourner 0%
      if (totalVotes == 0) {
        return {'percentage': 0.0};
      }

      // Calculer le pourcentage pour ce bloc spécifique
      final bloc = blocs[index];
      final blocVotes = bloc['voteCount'] as int? ?? 0;
      final percentage = (blocVotes / totalVotes) * 100;

      return {
        'percentage': percentage,
        'totalVotes': totalVotes,
        'blocVotes': blocVotes,
      };
    } catch (e) {
      print('Erreur lors du calcul des pourcentages: $e');
      return {'percentage': 0.0};
    }
  }

  Future<void> _vote(int blockIndex) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('Vous devez être connecté pour voter');
        return;
      }

      final postRef = FirebaseFirestore.instance.collection('posts').doc(widget.postId);
      final postDoc = await postRef.get();

      if (!postDoc.exists) {
        print('Post non trouvé');
        return;
      }

      final data = postDoc.data() as Map<String, dynamic>;
      final blocs = data['blocs'] is List
          ? data['blocs'] as List<dynamic>
          : (data['blocs'] as Map<String, dynamic>).values.toList();

      // Vérifier si l'utilisateur a déjà voté
      for (final bloc in blocs) {
        final votes = bloc['votes'] as List<dynamic>? ?? [];
        if (votes.contains(user.uid)) {
          print('Vous avez déjà voté sur ce sondage');
          return;
        }
      }

      // Mettre à jour le bloc spécifique
      final bloc = blocs[blockIndex];
      final blocVotes = bloc['voteCount'] as int? ?? 0;

      // Créer le nouveau bloc avec le vote mis à jour
      final updatedBloc = {
        'index': bloc['index'],
        'position': bloc['position'],
        'text': bloc['text'],
        'postImageUrl': bloc['postImageUrl'],
        'filterColor': bloc['filterColor'],
        'voteCount': blocVotes + 1,
        'votes': bloc['votes'] != null ? [...bloc['votes'], user.uid] : [user.uid],
      };

      // Créer l'objet vote pour la collection votes
      final voteData = {
        'postId': widget.postId,
        'userId': user.uid,
        'blockIndex': blockIndex,
        'createdAt': FieldValue.serverTimestamp(),
        'postImageUrl': bloc['postImageUrl'],
        'text': bloc['text'],
      };

      // Mettre à jour le document
      final batch = FirebaseFirestore.instance.batch();
      
      // Enregistrer le vote dans la collection votes
      final votesRef = FirebaseFirestore.instance.collection('votes').doc();
      batch.set(votesRef, voteData);

      // Mettre à jour le post
      batch.update(postRef, {
        'blocs': FieldValue.arrayRemove([bloc]),
      });
      batch.update(postRef, {
        'blocs': FieldValue.arrayUnion([updatedBloc]),
      });

      await batch.commit();

      print('Vote enregistré avec succès');
    } catch (e) {
      print('Erreur lors de l\'enregistrement du vote: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du vote: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Vérifier si l'utilisateur a déjà voté sur un bloc
  Future<bool> _hasUserVoted(String postId, String userId) async {
    try {
      final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
      final postDoc = await postRef.get();
      
      if (!postDoc.exists) {
        return false;
      }

      final data = postDoc.data() as Map<String, dynamic>;
      final blocs = data['blocs'] is List
          ? data['blocs'] as List<dynamic>
          : (data['blocs'] as Map<String, dynamic>).values.toList();

      // Vérifier si l'utilisateur a voté sur n'importe quel bloc
      for (final bloc in blocs) {
        final votes = bloc['votes'] as List<dynamic>? ?? [];
        if (votes.contains(userId)) {
          return true;
        }
      }

      return false;
    } catch (e) {
      print('Erreur lors de la vérification du vote: $e');
      return false;
    }
  }
}
