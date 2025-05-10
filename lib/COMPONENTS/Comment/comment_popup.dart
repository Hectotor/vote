import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../INSCRIPTION/connexion_screen.dart';
import '../../../COMPONENTS/avatar.dart';
import '../../../COMPONENTS/date_formatter.dart';
import 'like_service.dart';
import 'comment_expander.dart';

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

      final likeService = LikeService();
      await likeService.toggleLike(commentId);

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
        }

        return ListView.builder(
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
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final pseudo = userData['pseudo'] ?? 'Utilisateur';

        return Padding(
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
                    Row(
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
                        const Spacer(),
                        Text(
                          DateFormatter.formatDate(comment['createdAt'] ?? Timestamp.now()),
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CommentExpander(
                                text: comment['text'] ?? '',
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                              icon: Icon(
                                comment['likes']?.contains(FirebaseAuth.instance.currentUser?.uid) ?? false
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: comment['likes']?.contains(FirebaseAuth.instance.currentUser?.uid) ?? false
                                    ? Colors.red
                                    : Colors.white,
                                size: 15,
                              ),
                              onPressed: onLike,
                            ),
                            Text(
                              '${comment['likeCount'] ?? 0}',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}