import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:toplyke/COMPONENTS/vote_percentages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toplyke/INSCRIPTION/connexion_screen.dart';

class PollGridHome extends StatefulWidget {
  final List<String?> images;
  final List<Color> imageFilters;
  final int numberOfBlocs;
  final List<String?> textes;
  final String postId;

  const PollGridHome({
    Key? key,
    required this.images,
    required this.imageFilters,
    required this.numberOfBlocs,
    required this.textes,
    required this.postId,
  }) : super(key: key);

  @override
  State<PollGridHome> createState() => _PollGridHomeState();
}

class _PollGridHomeState extends State<PollGridHome> {
  bool _showPercentages = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
    final blockWidth = (screenWidth - 24.0 - 8.0) / 2;

    return GestureDetector(
      onDoubleTap: () {
        // Enregistrer le vote
        _vote(index);
        
        // Afficher les pourcentages
        setState(() {
          _showPercentages = true;
        });
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
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              )
            else
              Center(
                child: Icon(
                  Icons.add_photo_alternate_outlined, 
                  size: 40, 
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            // Filtre
            if (widget.imageFilters[index] != Colors.transparent)
              Container(
                decoration: BoxDecoration(
                  color: widget.imageFilters[index],
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
            // Texte
            if (widget.textes[index] != null && widget.textes[index]!.isNotEmpty)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(15),
                    ),
                  ),
                  child: Text(
                    widget.textes[index]!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            // Pourcentage de votes
            FutureBuilder(
              future: _getVotePercentage(widget.postId, index),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final percentage = snapshot.data as double;
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

  Future<double> _getVotePercentage(String postId, int blocIndex) async {
    try {
      final postDoc = await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .get();
      
      if (!postDoc.exists) return 0.0;
      
      final data = postDoc.data();
      if (data == null) return 0.0;
      
      final blocs = data['blocs'] is List
          ? data['blocs'] as List<dynamic>
          : (data['blocs'] as Map<String, dynamic>).values.toList();
      
      final totalVotes = blocs.fold(0, (sum, bloc) => sum + (bloc['voteCount'] as int? ?? 0));
      final blocVotes = blocs[blocIndex]['voteCount'] as int? ?? 0;
      
      return totalVotes > 0 ? (blocVotes / totalVotes) * 100 : 0.0;
    } catch (e) {
      print('Erreur lors du chargement des pourcentages: $e');
      return 0.0;
    }
  }

  // Enregistrer un vote pour un bloc
  Future<void> _vote(int blockIndex) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('Vous devez être connecté pour voter');
        // Rediriger vers l'écran de connexion
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ConnexionPage(),
          ),
        );
        return;
      }

      // Vérifier si l'utilisateur a déjà voté sur ce sondage
      final hasVoted = await _hasUserVoted(widget.postId, user.uid);
      if (hasVoted) {
        print('Vous avez déjà voté sur ce sondage');
        return;
      }

      // Mettre à jour le vote dans Firestore
      try {
        // Vérifier si le champ voteCount existe déjà
        final postDoc = await _firestore.collection('posts').doc(widget.postId).get();
        final data = postDoc.data();
        if (data == null) return;
        
        final blocs = data['blocs'] is List
            ? data['blocs'] as List<dynamic>
            : (data['blocs'] as Map<String, dynamic>).values.toList();
        
        // Si les blocs sont stockés sous forme de liste
        if (data['blocs'] is List) {
          // Mettre à jour le vote dans le bloc spécifique
          final blocData = blocs[blockIndex] as Map<String, dynamic>;
          final voteCount = blocData['voteCount'] as int? ?? 0;
          
          // Créer une copie de la liste des blocs
          final updatedBlocs = List<dynamic>.from(blocs);
          
          // Mettre à jour le bloc spécifique
          updatedBlocs[blockIndex] = {
            ...blocData,
            'voteCount': voteCount + 1,
          };
          
          // Mettre à jour le document avec la nouvelle liste de blocs
          await _firestore.collection('posts').doc(widget.postId).update({
            'blocs': updatedBlocs,
            'voters': FieldValue.arrayUnion([user.uid]),
          });
        } 
        // Si les blocs sont stockés sous forme de map
        else {
          await _firestore.collection('posts').doc(widget.postId).update({
            'blocs.$blockIndex.voteCount': FieldValue.increment(1),
            'voters': FieldValue.arrayUnion([user.uid]),
          });
        }
      } catch (e) {
        print('Erreur lors de la mise à jour du vote: $e');
      }

      // Enregistrer le vote de l'utilisateur
      await _firestore.collection('votes').add({
        'postId': widget.postId,
        'userId': user.uid,
        'blockIndex': blockIndex,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erreur lors du vote: $e');
    }
  }

  // Vérifier si l'utilisateur a déjà voté sur un sondage
  Future<bool> _hasUserVoted(String postId, String userId) async {
    try {
      final postDoc = await _firestore.collection('posts').doc(postId).get();
      final voters = postDoc.data()?['voters'] as List<dynamic>? ?? [];
      return voters.contains(userId);
    } catch (e) {
      print('Erreur lors de la vérification du vote: $e');
      return false;
    }
  }
}
