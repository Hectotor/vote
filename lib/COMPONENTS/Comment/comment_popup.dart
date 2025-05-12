import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../COMPONENTS/avatar.dart';
import 'like_service.dart';
import '../Post/comment_service.dart';
import '../../../COMPONENTS/date_formatter.dart' as formatter;

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
    return FutureBuilder<QuerySnapshot>(
      future: _commentService.getCommentsForPostOnce(widget.postId),
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

class CommentItem extends StatefulWidget {
  final Map<String, dynamic> comment;
  final Function(String) onDelete;
  final String? currentUserId;

  const CommentItem({
    Key? key,
    required this.comment,
    required this.onDelete,
    this.currentUserId,
  }) : super(key: key);

  @override
  _CommentItemState createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  bool _isLiked = false;
  int _likeCount = 0;
  bool _isLoading = true;
  DocumentSnapshot? _userDoc;
  final LikeService _likeService = LikeService();

  @override
  void initState() {
    super.initState();
    _likeCount = widget.comment['likeCount'] ?? 0;
    _checkIfLiked();
    _loadUserData();
  }

  Future<void> _checkIfLiked() async {
    if (widget.currentUserId == null) return;
    
    try {
      final hasLiked = await _likeService.hasUserLiked(widget.comment['id']);
      if (mounted) {
        setState(() {
          _isLiked = hasLiked;
        });
      }
    } catch (e) {
      print('Erreur lors de la vérification du like: $e');
    }
  }

  Future<void> _loadUserData() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.comment['userId'])
          .get();
      
      if (mounted) {
        setState(() {
          _userDoc = userDoc;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erreur lors du chargement des données utilisateur: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleLike() async {
    if (widget.currentUserId == null) return;
    
    setState(() {
      _isLiked = !_isLiked;
      _likeCount = _isLiked ? _likeCount + 1 : _likeCount - 1;
    });

    try {
      await _likeService.toggleLike(
        widget.comment['id'],
        widget.comment['userId'],
      );
    } catch (e) {
      // En cas d'erreur, on annule le changement
      setState(() {
        _isLiked = !_isLiked;
        _likeCount = _isLiked ? _likeCount - 1 : _likeCount + 1;
      });
      print('Erreur lors du like: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    final userData = _userDoc?.data() as Map<String, dynamic>? ?? {};
    final pseudo = userData['pseudo'] ?? 'Utilisateur';
    final isCurrentUser = widget.comment['userId'] == widget.currentUserId;

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8, left: 8, right: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Avatar(
            userId: widget.comment['userId'],
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
                        onTap: () => widget.onDelete(widget.comment['id']),
                        child: const Icon(Icons.delete, color: Colors.grey, size: 16),
                      ),
                    const SizedBox(width: 8),
                    Text(
                      _formatCommentDate(widget.comment['createdAt']),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.comment['text'] ?? '',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    GestureDetector(
                      onTap: _toggleLike,
                      child: Row(
                        children: [
                          Icon(
                            _isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color: _isLiked ? Colors.red : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$_likeCount',
                            style: TextStyle(
                              color: _isLiked ? Colors.red : Colors.grey,
                              fontSize: 12,
                            ),
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
  }

  // Méthode pour formater la date du commentaire
  String _formatCommentDate(dynamic date) {
    if (date == null) return 'À l\'instant';
    
    try {
      if (date is Timestamp) {
        return formatter.DateFormatter.formatDate(date.toDate());
      } else if (date is DateTime) {
        return formatter.DateFormatter.formatDate(date);
      } else if (date is Map && date['_seconds'] != null) {
        // Cas où la date est un Timestamp sérialisé
        return formatter.DateFormatter.formatDate(DateTime.fromMillisecondsSinceEpoch(
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