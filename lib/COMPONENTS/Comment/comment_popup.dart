import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _handleLike(String commentId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ConnexionPage(),
          ),
        );
        return;
      }

      final commentRef = _firestore.collection('comments').doc(commentId);
      final commentDoc = await commentRef.get();
      final data = commentDoc.data() as Map<String, dynamic>;
      final likes = data['likes'] as List<dynamic>;
      final likeCount = data['likeCount'] as int;

      if (likes.contains(user.uid)) {
        // L'utilisateur a déjà liké, on ne fait rien
        return;
      }

      // Ajouter le like
      await commentRef.update({
        'likes': FieldValue.arrayUnion([user.uid]),
        'likeCount': likeCount + 1,
      });

      setState(() {});
    } catch (e) {
      print('Erreur lors du like: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        height: 650,
        padding: const EdgeInsets.only(top: 5),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Expanded(child: _buildCommentsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('comments')
          .where('postId', isEqualTo: widget.postId)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final comments = snapshot.data?.docs ?? [];

        if (comments.isEmpty) {
          return Center(
            child: Text(
              'Aucun commentaire',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 16,
              ),
            ),
          );
        }

        return Column(
          children: [
            Center(
              child: Text(
                'Aucun commentaire',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 16,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: widget.scrollController,
                itemCount: comments.length,
                padding: const EdgeInsets.all(4),
                itemBuilder: (context, index) {
                  final data = comments[index].data() as Map<String, dynamic>;
                  final comment = {
                    'id': comments[index].id,
                    'postId': data['postId'],
                    'userId': data['userId'],
                    'text': data['text'],
                    'createdAt': data['createdAt'],
                    'likeCount': data['likeCount'] ?? 0,
                  };

                  return CommentItem(
                    comment: comment,
                    onLike: () => _handleLike(comment['id']),
                  );
                },
              ),
            ),
          ],
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
        if (!snapshot.hasData) return const SizedBox.shrink();

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final pseudo = userData['pseudo'] ?? 'Utilisateur';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[900]!,
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Avatar(
                    userId: comment['userId'],
                    radius: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            children: [
                              TextSpan(
                                text: '$pseudo ',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              DateFormatter.formatDate(comment['createdAt']),
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          comment['text'],
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('comments')
                        .doc(comment['id'])
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Icon(Icons.favorite_border, size: 20, color: Colors.grey);
                      }

                      final data = snapshot.data!.data() as Map<String, dynamic>;
                      final likes = data['likes'] as List<dynamic>;
                      final user = FirebaseAuth.instance.currentUser;
                      final isLiked = likes.contains(user?.uid);

                      return GestureDetector(
                        onTap: onLike,
                        child: Row(
                          children: [
                            Icon(
                              Icons.favorite,
                              size: 20,
                              color: isLiked ? Colors.red : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${comment['likeCount']}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}