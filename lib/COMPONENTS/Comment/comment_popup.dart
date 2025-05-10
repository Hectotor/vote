import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../INSCRIPTION/connexion_screen.dart';
import '../../../SERVICES/like_service.dart';
import 'comment_input.dart';
  
import '../../../COMPONENTS/avatar.dart';

class CommentPopup extends StatefulWidget {
  final String postId;
  final String userId;

  const CommentPopup({
    Key? key,
    required this.postId,
    required this.userId,
  }) : super(key: key);

  @override
  State<CommentPopup> createState() => _CommentPopupState();
}

class _CommentPopupState extends State<CommentPopup> {
  final TextEditingController _commentController = TextEditingController();
  final LikeService _likeService = LikeService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _addComment() async {
    if (_commentController.text.isEmpty) return;

    try {
      await _firestore.collection('comments').add({
        'postId': widget.postId,
        'userId': _auth.currentUser!.uid,
        'text': _commentController.text,
        'createdAt': FieldValue.serverTimestamp(),
        'likes': [],
      });

      _commentController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
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
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(
            color: Colors.grey[800]!,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const Divider(color: Colors.grey),
            Expanded(
              child: _buildCommentsList(),
            ),
            CommentInput(
              controller: _commentController,
              onSend: _addComment,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 5, left: 20, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Commentaires',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
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
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        final comments = snapshot.data?.docs.map((doc) {
          return CommentData.fromMap(
            doc.id,
            doc.data() as Map<String, dynamic>,
          );
        }).toList() ?? [];

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: comments.length,
          itemBuilder: (context, index) {
            final comment = comments[index];
            return CommentItem(
              comment: comment,
              onLike: () => _handleLike(comment.id),
            );
          },
        );
      },
    );
  }
}

class CommentItem extends StatelessWidget {
  final CommentData comment;
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
          .doc(comment.userId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(color: Colors.white);
        }

        final userData =
            snapshot.data?.data() as Map<String, dynamic>?;
        final pseudo = userData?['pseudo'] as String?;

        return Container(
          padding: const EdgeInsets.only(top: 10, bottom: 10, left: 0, right: 0),
          decoration: BoxDecoration(
            color: const Color(0xFF2D3748),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Avatar(
                    userId: comment.userId,
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
                          ),
                        ),
                        Text(
                          comment.text,
                          style: const TextStyle(
                            color: Colors.white,
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
                      comment.hasLiked(FirebaseAuth.instance.currentUser?.uid ?? '')
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: comment.hasLiked(FirebaseAuth.instance.currentUser?.uid ?? '')
                          ? Colors.red
                          : Colors.white,
                      size: 20,
                    ),
                    onPressed: onLike,
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

class CommentData {
  final String id;
  final String userId;
  final String text;
  final Timestamp createdAt;
  final List<String> likes;

  CommentData({
    required this.id,
    required this.userId,
    required this.text,
    required this.createdAt,
    this.likes = const [],
  });

  bool hasLiked(String userId) {
    return likes.contains(userId);
  }

  factory CommentData.fromMap(String id, Map<String, dynamic> data) {
    return CommentData(
      id: id,
      userId: data['userId'] as String,
      text: data['text'] as String,
      createdAt: data['createdAt'] as Timestamp,
      likes: (data['likes'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}
