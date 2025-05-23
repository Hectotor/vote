import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../HOME/post_page.dart';

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
        posts.add({
          'id': doc.id,
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Text(
              'Tendances du jour',
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
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Aucun post tendance aujourd\'hui',
                          style: TextStyle(
                            color: Color(0xFF757575),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  : Column(
                      children: _trendingPosts.map((post) {
                        // Extraire les informations du post
                        final String postId = post['id'] ?? '';
                        final String pseudo = post['pseudo'] ?? 'Utilisateur';
                        final String profilePhotoUrl = post['profilePhotoUrl'] ?? '';
                        final int totalVotes = post['totalVotesCount'] ?? 0;
                        
                        // Cru00e9er un aperu00e7u du texte du post (limitu00e9 u00e0 100 caractu00e8res)
                        final String text = post['text'] ?? '';
                        final String previewText = text.length > 100 
                            ? '${text.substring(0, 97)}...' 
                            : text;
                        
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PostPage(postId: postId),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16.0),
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Avatar de l'utilisateur
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: profilePhotoUrl.isNotEmpty
                                      ? NetworkImage(profilePhotoUrl)
                                      : null,
                                  child: profilePhotoUrl.isEmpty
                                      ? const Icon(Icons.person)
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                // Contenu du post
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pseudo,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        previewText,
                                        style: const TextStyle(fontSize: 14),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      // Statistiques du post
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.how_to_vote,
                                            size: 16,
                                            color: Color(0xFF757575),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '$totalVotes votes',
                                            style: const TextStyle(
                                              color: Color(0xFF757575),
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
        ],
      ),
    );
  }
}
