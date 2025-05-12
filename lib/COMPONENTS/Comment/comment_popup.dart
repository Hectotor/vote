import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../INSCRIPTION/connexion_screen.dart';
import '../../../COMPONENTS/avatar.dart';
import '../../../COMPONENTS/date_formatter.dart';
import '../../../COMPONENTS/Post/comment_service.dart';
import 'like_service.dart';

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
  final CommentService _commentService = CommentService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _handleLike(String commentId, String commentAuthorId) async {
    try {
      final user = _auth.currentUser;
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
      await likeService.toggleLike(commentId, commentAuthorId);

      setState(() {});
    } catch (e) {
      print('Erreur lors du like: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(4),
          children: [
            _buildCommentsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _commentService.getCommentsForPost(widget.postId),
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
            for (var comment in comments)
              CommentItem(
                comment: {
                  'id': comment.id,
                  'postId': (comment.data() as Map<String, dynamic>)['postId'],
                  'userId': (comment.data() as Map<String, dynamic>)['userId'],
                  'text': (comment.data() as Map<String, dynamic>)['text'],
                  'createdAt': (comment.data() as Map<String, dynamic>)['createdAt'],
                  'likeCount': (comment.data() as Map<String, dynamic>)['likeCount'] ?? 0,
                },
                onLike: () => _handleLike(comment.id, (comment.data() as Map<String, dynamic>)['userId']),
                onDelete: (commentId) => _deleteComment(commentId, comment['postId']),
                currentUserId: _auth.currentUser?.uid,
              ),
          ],
        );
      },
    );
  }

  Future<void> _deleteComment(String commentId, String postId) async {
    try {
      await _commentService.deleteComment(
        commentId: commentId,
        postId: postId,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Commentaire supprimé')),
        );
      }
    } catch (e) {
      print('Erreur lors de la suppression du commentaire: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }
}

class CommentItem extends StatelessWidget {
  final Map<String, dynamic> comment;
  final VoidCallback onLike;
  final Function(String) onDelete;
  final String? currentUserId;

  const CommentItem({
    Key? key,
    required this.comment,
    required this.onLike,
    required this.onDelete,
    this.currentUserId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = comment['userId'] == currentUserId;
    
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

        final userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        final pseudo = userData['pseudo'] ?? 'Utilisateur';

        return Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8, left: 8, right: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Avatar(
                userId: comment['userId'],
                radius: 20,
              ),
              const SizedBox(width: 8),
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
                        if (isCurrentUser)
                          GestureDetector(
                            onTap: () => onDelete(comment['id']),
                            child: const Icon(Icons.delete, color: Colors.grey, size: 16),
                          ),
                        const SizedBox(width: 8),
                        Text(
                          _formatCommentDate(comment['createdAt']),
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comment['text'] ?? '',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: onLike,
                          child: Row(
                            children: [
                              const Icon(Icons.favorite_border, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                '${comment['likeCount'] ?? 0}',
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
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

  // Méthode pour formater la date du commentaire
  String _formatCommentDate(dynamic date) {
    if (date == null) return 'À l\'instant';
    
    try {
      if (date is Timestamp) {
        return DateFormatter.formatDate(date.toDate());
      } else if (date is DateTime) {
        return DateFormatter.formatDate(date);
      } else if (date is Map && date['_seconds'] != null) {
        // Cas où la date est un Timestamp sérialisé
        return DateFormatter.formatDate(DateTime.fromMillisecondsSinceEpoch(
          date['_seconds'] * 1000,
          isUtc: true,
        ));
      } else {
        return 'Date inconnue';
      }
    } catch (e) {
      print('Erreur de format de date: $e');
      return 'Date invalide';
    }
  }
}