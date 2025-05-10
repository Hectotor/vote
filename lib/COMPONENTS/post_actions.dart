import 'package:flutter/material.dart';
import 'package:toplyke/PAGES/post_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Post/post_like_service.dart';
import 'package:toplyke/INSCRIPTION/connexion_screen.dart';
import 'dart:async';

class PostActions extends StatefulWidget {
  final String postId;
  final String userId;
  final bool isCommentPage;

  const PostActions({
    Key? key,
    required this.postId,
    required this.userId,
    this.isCommentPage = false,
  }) : super(key: key);

  @override
  State<PostActions> createState() => _PostActionsState();
}

class _PostActionsState extends State<PostActions> {
  bool _isPostLiked = false;
  int _likeCount = 0;
  StreamSubscription<QuerySnapshot>? _commentSubscription;

  final PostLikeService _postLikeService = PostLikeService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _checkPostLikeStatus();
    _fetchLikeCount();
  }

  @override
  void dispose() {
    _commentSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkPostLikeStatus() async {
    if (!mounted) return;
    try {
      final isLiked = await _postLikeService.isPostLiked(widget.postId);
      if (!mounted) return;
      setState(() {
        _isPostLiked = isLiked;
      });
    } catch (e) {
      print('Erreur lors de la vérification du like: $e');
    }
  }

  Future<void> _fetchLikeCount() async {
    if (!mounted) return;
    try {
      final postDoc = await _firestore.collection('posts').doc(widget.postId).get();
      final likeCount = postDoc.data()?['likeCount'] as int? ?? 0;
      if (!mounted) return;
      setState(() {
        _likeCount = likeCount;
      });
    } catch (e) {
      print('Erreur lors de la récupération du compteur de likes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4, bottom: 4),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _isPostLiked ? Icons.favorite : Icons.favorite_border,
              color: _isPostLiked ? Colors.red : Colors.white,
              size: 28,
            ),
            onPressed: () {
              if (FirebaseAuth.instance.currentUser == null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ConnexionPage(),
                  ),
                );
                return;
              }

              _postLikeService.togglePostLike(widget.postId).then((_) {
                if (!mounted) return;
                setState(() {
                  _isPostLiked = !_isPostLiked;
                  _likeCount = _isPostLiked ? _likeCount + 1 : _likeCount - 1;
                });
              }).catchError((e) {
                print('Erreur lors du like: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur: ${e.toString()}')),
                );
              });
            },
          ),
          Text(
            '$_likeCount',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 16),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('comments')
                .where('postId', isEqualTo: widget.postId)
                .snapshots().handleError((error) {
                  print('Erreur du stream de commentaires: $error');
                  return const Stream.empty();
                }),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final commentCount = snapshot.data!.docs.length;
                return Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: widget.isCommentPage
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PostPage(
                                    postId: widget.postId,
                                  ),
                                ),
                              );
                            },
                    ),
                    Text(
                      '$commentCount',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              }
              return IconButton(
                icon: Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: widget.isCommentPage
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostPage(
                              postId: widget.postId,
                            ),
                          ),
                        );
                      },
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.send_outlined,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () {
              // TODO: Implement share functionality
            },
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              Icons.bookmark_border,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () {
              // TODO: Implement save functionality
            },
          ),
        ],
      ),
    );
  }
}
