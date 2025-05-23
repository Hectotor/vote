import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../HOME/post_page.dart';
import '../COMPONENTS/post_header.dart';
import '../COMPONENTS/post_description.dart';
import '../COMPONENTS/post_actions.dart';
import '../HOME/poll_grid_home_modern_new.dart';

class TrendingPostsWidget extends StatefulWidget {
  const TrendingPostsWidget({Key? key}) : super(key: key);

  @override
  State<TrendingPostsWidget> createState() => _TrendingPostsWidgetState();
}

class _TrendingPostsWidgetState extends State<TrendingPostsWidget> {
  List<Map<String, dynamic>> _trendingPosts = [];
  bool _isLoadingTrending = true;

  @override
  void initState() {
    super.initState();
    _loadTrendingPosts();
  }

  Future<void> _loadTrendingPosts() async {
    setState(() {
      _isLoadingTrending = true;
    });
    
    try {
      // Obtenir la date de du00e9but d'aujourd'hui
      final DateTime now = DateTime.now();
      final DateTime todayStart = DateTime(now.year, now.month, now.day);
      
      // Ru00e9cupu00e9rer les posts d'aujourd'hui (solution sans index composite)
      final QuerySnapshot todayPostsSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
        .get();
        
      // Trier par totalVotesCount cu00f4tu00e9 client
      final sortedDocs = todayPostsSnapshot.docs.toList()
        ..sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final int aVotes = aData['totalVotesCount'] as int? ?? 0;
          final int bVotes = bData['totalVotesCount'] as int? ?? 0;
          return bVotes.compareTo(aVotes);  // Tri du00e9croissant par votes
        });
      
      // Prendre les 3 premiers posts les plus populaires
      final topPosts = sortedDocs.take(3).toList();
      
      final List<Map<String, dynamic>> posts = [];
      
      for (var doc in topPosts) {
        final data = doc.data() as Map<String, dynamic>;
        // S'assurer que tous les champs nu00e9cessaires sont pru00e9sents
        posts.add({
          'id': doc.id,
          'userId': data['userId'] ?? '',
          'pseudo': data['pseudo'] ?? 'Utilisateur',
          'profilePhotoUrl': data['profilePhotoUrl'] ?? '',
          'filterColor': data['filterColor'],
          'description': data['description'] ?? '',
          'createdAt': data['createdAt'] ?? Timestamp.now(),
          'blocs': data['blocs'] ?? [],
          'totalVotesCount': data['totalVotesCount'] ?? 0,
          ...data,
        });
      }
      
      setState(() {
        _trendingPosts = posts;
        _isLoadingTrending = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des posts tendance: $e');
      setState(() {
        _isLoadingTrending = false;
      });
    }
  }

  Future<void> _refreshTrendingPosts() async {
    // Ru00e9initialiser le chargement
    await _loadTrendingPosts();
    return Future.value();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshTrendingPosts,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        // Afficher le titre seulement s'il y a des posts tendance ou si le chargement est en cours
        if (_isLoadingTrending || !_trendingPosts.isEmpty)
          const Padding(
            padding: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
            child: Text(
              'En top tendance',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
          ),
        _isLoadingTrending
            ? const Center(child: CircularProgressIndicator())
            : _trendingPosts.isEmpty
                ? const SizedBox() // Ne rien afficher quand il n'y a pas de posts tendance
                : Column(
                    children: _trendingPosts.map((post) {
                      // Extraire les informations du post
                      final String postId = post['id'] ?? '';
                      final String userId = post['userId'] ?? '';
                      final String pseudo = post['pseudo'] ?? 'Utilisateur';
                      final String? profilePhotoUrl = post['profilePhotoUrl'];
                      final int? filterColor = post['filterColor'] != null 
                          ? (post['filterColor'] is String ? int.parse(post['filterColor']) : post['filterColor'] as int) 
                          : null;
                      final String description = post['description'] ?? '';
                      final Timestamp createdAt = post['createdAt'] as Timestamp? ?? Timestamp.now();
                      
                      // Extraire les blocs du post
                      final List<dynamic> blocs = post['blocs'] ?? [];
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // En-tu00eate du post avec avatar et pseudo
                            PostHeader(
                              key: Key('header_$postId'),
                              pseudo: pseudo,
                              profilePhotoUrl: profilePhotoUrl,
                              filterColor: filterColor,
                              createdAt: createdAt,
                              postId: postId,
                              userId: userId,
                            ),
                            
                            // Description du post
                            if (description.isNotEmpty)
                              PostDescription(
                                key: Key('desc_$postId'),
                                pseudo: pseudo,
                                description: description,
                              ),
                            
                            // Grille de sondage (si le post a des blocs)
                            if (blocs.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PostPage(postId: postId),
                                    ),
                                  );
                                },
                                child: PollGridHomeModern(
                                  key: Key('poll_$postId'),
                                  blocs: blocs.map((bloc) => {
                                    'postImageUrl': bloc['postImageUrl'],
                                    'text': bloc['text'],
                                    'filterColor': bloc['filterColor']?.toString(),
                                    'voteCount': bloc['voteCount'] ?? 0,
                                    'votes': bloc['votes'] ?? [],
                                  }).toList(),
                                  postId: postId,
                                ),
                              ),
                            
                            // Actions du post (likes, commentaires, etc.)
                            PostActions(
                              key: Key('actions_$postId'),
                              postId: postId,
                              userId: userId,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
