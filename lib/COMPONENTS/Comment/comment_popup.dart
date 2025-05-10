import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'like_service.dart';
import '../../../INSCRIPTION/connexion_screen.dart';

import '../../../COMPONENTS/avatar.dart';
import '../../../COMPONENTS/date_formatter.dart';

class CommentPopup extends StatefulWidget {
  final String postId;
  final String userId;
  final ScrollController? scrollController;

  const CommentPopup({
    Key? key,
    required this.postId,
    required this.userId,
    this.scrollController,
  }) : super(key: key);

  @override
  State<CommentPopup> createState() => _CommentPopupState();
}

class _CommentPopupState extends State<CommentPopup> {
  final TextEditingController _commentController = TextEditingController();
  final LikeService _likeService = LikeService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }



  Future<void> _handleLike(String commentId) async {
    try {
      await _likeService.toggleLike(commentId);
      setState(() {}); // Refresh the UI
    } on UnauthenticatedException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez vous connecter pour liker un commentaire'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ConnexionPage(),
        ),
      );
    } on LikeException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        height: 650,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: _buildCommentsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsList() {
    print('Chargement des commentaires pour le post ${widget.postId}');
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('comments')
          .where('postId', isEqualTo: widget.postId)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.grey[600],
                strokeWidth: 2,
              ),
            ),
          );
        }

        final comments = snapshot.data?.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'postId': data['postId'],
            'userId': data['userId'],
            'text': data['text'],
            'createdAt': data['createdAt'],
            'likeCount': data['likeCount'] ?? 0,
          };
        }).toList() ?? [];

        if (comments.isEmpty) {
          return const Center(
            child: Text(
              'Aucun commentaire',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              if (comments.isEmpty)
                const Center(
                  child: Text(
                    'Aucun commentaire',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  controller: widget.scrollController,
                  padding: EdgeInsets.zero,
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return CommentItem(
                      comment: comment,
                      onLike: () => _handleLike(comment['id']),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CommentItem extends StatelessWidget {
  final Map<String, dynamic> comment;
  final VoidCallback onLike;

  const CommentItem({
    Key? key,
    required this.comment,
    required this.onLike,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(comment['userId'])
          .get(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.grey[600],
                strokeWidth: 2,
              ),
            ),
          );
        }

        final userData =
            snapshot.data?.data() as Map<String, dynamic>?;
        final pseudo = userData?['pseudo'] as String?;

        return Container(
          padding: const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 0),
          decoration: BoxDecoration(
            color: const Color(0xFF2D3748),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Avatar(
                    userId: comment['userId'],
                    radius: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pseudo ?? 'Utilisateur',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          DateFormatter.formatDate(comment['createdAt']),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          comment['text'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 20,
                    ),
                    onPressed: onLike,
                  ),
                  Text(
                    '${comment['likeCount']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
