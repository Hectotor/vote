import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../COMPONENTS/post.dart';

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
          .collection('savedPosts')
          .where('userId', isEqualTo: widget.userId)
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
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Text(
                  widget.showPosts ? 'Aucun post' : 'Aucun post sauvegardé',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }

          return Column(
            children: List.generate(docs.length, (index) {
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
            }),
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
          Post(
            data: data,
            postId: postId,
          ),
        ],
      ),
    );
  }
}
