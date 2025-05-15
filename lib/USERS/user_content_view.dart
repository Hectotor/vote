import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../COMPONENTS/post_header.dart';
import '../COMPONENTS/post_description.dart';
import '../COMPONENTS/post_actions.dart';
import '../HOME/poll_grid_home_modern_new.dart';

/// Widget qui affiche soit les posts de l'utilisateur, soit les posts sauvegardés
class UserContentView extends StatefulWidget {
  final String userId;
  final bool showPosts; // true pour les posts, false pour les sauvegardés

  const UserContentView({
    Key? key,
    required this.userId,
    required this.showPosts,
  }) : super(key: key);

  @override
  State<UserContentView> createState() => _UserContentViewState();
}

class _UserContentViewState extends State<UserContentView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Stream<QuerySnapshot>? _contentStream;

  @override
  void initState() {
    super.initState();
    _initContentStream();
  }

  @override
  void didUpdateWidget(UserContentView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recharger le stream si on change entre posts et sauvegardés
    if (oldWidget.showPosts != widget.showPosts) {
      _initContentStream();
    }
  }

  void _initContentStream() {
    if (widget.showPosts) {
      // Stream pour les posts de l'utilisateur
      _contentStream = _firestore
          .collection('posts')
          .where('userId', isEqualTo: widget.userId)
          .orderBy('createdAt', descending: true)
          .snapshots();
    } else {
      // Stream pour les posts sauvegardés
      _contentStream = _firestore
          .collection('users')
          .doc(widget.userId)
          .collection('savedPosts')
          .orderBy('savedAt', descending: true)
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _initContentStream();
        });
      },
      child: StreamBuilder<QuerySnapshot>(
        stream: _contentStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Text(
                widget.showPosts ? 'Aucun post à afficher' : 'Aucun post sauvegardé',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              
              // Si c'est un post sauvegardé, on doit récupérer le post complet
              if (!widget.showPosts) {
                // Ici, on pourrait faire une requête pour obtenir le post complet
                // Pour l'instant, on affiche juste un placeholder
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D3748),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bookmark, color: Colors.blue, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Post sauvegardé le ${_formatDate(data['savedAt'])}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                );
              }
              
              // Sinon, on affiche directement le post
              return _buildPostItem(data, doc.id);
            },
          );
        },
      ),
    );
  }
  
  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '';
    
    DateTime date;
    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else {
      // Fallback si ce n'est pas un Timestamp
      return '';
    }
    
    return '${date.day}/${date.month}/${date.year}';
  }
  
  Widget _buildPostItem(Map<String, dynamic> data, String postId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[800]!,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête du post
          PostHeader(
            pseudo: data['pseudo'] ?? '',
            profilePhotoUrl: data['profilePhotoUrl'],
            filterColor: data['filterColor'] != null ? 
              (data['filterColor'] is String ? 
                int.parse(data['filterColor']) : 
                data['filterColor'] as int) : 
              null,
            createdAt: data['createdAt'] ?? Timestamp.now(),
            postId: postId,
            userId: data['userId'] ?? '',
          ),
          
          // Grille d'images du post
          if (data['blocs'] != null && data['blocs'] is List && (data['blocs'] as List).isNotEmpty)
            PollGridHomeModern(
              blocs: data['blocs'],
              postId: postId,
            ),
          
          // Description du post
          if (data['description'] != null && data['description'].toString().isNotEmpty)
            PostDescription(
              pseudo: data['pseudo'] ?? '',
              description: data['description'],
            ),
          
          // Actions du post (like, commentaire, etc.)
          PostActions(
            postId: postId,
            userId: data['userId'] ?? '',
          ),
        ],
      ),
    );
  }
}
