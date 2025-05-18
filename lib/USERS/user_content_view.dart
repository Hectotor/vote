import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'post.dart';

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
    return StreamBuilder<QuerySnapshot>(
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

        // Utiliser Column au lieu de ListView pour fonctionner dans un SingleChildScrollView
        return Column(
          children: List.generate(docs.length, (index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            
            // Si c'est un post sauvegardé, on utilise le postId pour récupérer le post complet
            if (!widget.showPosts) {
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
                      postId: data['postId'],
                      isSavedPost: true,
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
    );
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
