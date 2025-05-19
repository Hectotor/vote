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
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.showPosts ? Icons.post_add : Icons.bookmark,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.showPosts ? 'Aucun post' : 'Aucun post sauvegardé',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 250),
    
              ],
            ),
          );
        }

        // Utiliser ListView.builder comme dans home_page.dart
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(left: 15, right: 15),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            
            // Si c'est un post sauvegardé, on utilise le postId pour récupérer le post complet
            if (!widget.showPosts) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFF5F5F5),
                    width: 5,
                  ),
                ),
                child: Post(
                  data: data,
                  postId: data['postId'],
                  isSavedPost: true,
                ),
              );
            }
            
            // Sinon, on affiche directement le post
            return _buildPostItem(data, doc.id);
          },
        );
      },
    );
  }
  

  
  Widget _buildPostItem(Map<String, dynamic> data, String postId) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white,
          width: 5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Post(
        data: data,
        postId: postId,
      ),
    );
  }
}
