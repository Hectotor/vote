import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../COMPONENTS/avatar.dart';
import '../USERS/user_page.dart';

class PostDetailPage extends StatefulWidget {
  final String postId;

  const PostDetailPage({super.key, required this.postId});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _postData;
  String? _authorId;
  String? _authorName;

  @override
  void initState() {
    super.initState();
    _loadPostData();
  }

  Future<void> _loadPostData() async {
    try {
      final postDoc = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .get();

      if (postDoc.exists) {
        final data = postDoc.data() as Map<String, dynamic>;
        final authorId = data['userId'] as String;
        
        // Charger les informations de l'auteur
        final authorDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(authorId)
            .get();

        setState(() {
          _postData = data;
          _authorId = authorId;
          _authorName = authorDoc.exists && authorDoc.data() != null 
              ? authorDoc.data()!['pseudo'] ?? 'Utilisateur'
              : 'Utilisateur';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erreur lors du chargement du post: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du post'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF212121),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _postData == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Post introuvable',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // En-tête du post (auteur, date)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (_authorId != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UserPage(userId: _authorId!),
                                    ),
                                  );
                                }
                              },
                              child: Row(
                                children: [
                                  Avatar(userId: _authorId ?? '', radius: 20),
                                  const SizedBox(width: 12),
                                  Text(
                                    _authorName ?? 'Utilisateur',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _formatDate(_postData!['timestamp'] as Timestamp),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Contenu du post
                      if (_postData!['imageUrl'] != null)
                        Container(
                          width: double.infinity,
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.width,
                          ),
                          child: Image.network(
                            _postData!['imageUrl'],
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(Icons.error, color: Colors.grey),
                                ),
                              );
                            },
                          ),
                        ),
                      
                      // Texte du post
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          _postData!['text'] ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      
                      // Actions du post (like, commentaire, etc.)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Icon(Icons.favorite_border, color: Colors.grey[700]),
                            const SizedBox(width: 8),
                            Text(
                              '${_postData!['likes'] ?? 0}',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            const SizedBox(width: 24),
                            Icon(Icons.comment_outlined, color: Colors.grey[700]),
                            const SizedBox(width: 8),
                            Text(
                              '${_postData!['comments'] ?? 0}',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                      
                      const Divider(height: 32),
                      
                      // Section des commentaires (à implémenter)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Commentaires',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      
                      // Placeholder pour les commentaires
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
    );
  }
  
  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }
}
