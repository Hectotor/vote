import 'package:flutter/material.dart';
import 'package:toplyke/HOME/post_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Post/post_like_service.dart';
import 'package:toplyke/SERVICES/post_save_service.dart';
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
  bool _isPostSaved = false;
  int _likeCount = 0;
  StreamSubscription<QuerySnapshot>? _commentSubscription;
  final PostLikeService _postLikeService = PostLikeService();
  final PostSaveService _postSaveService = PostSaveService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _checkPostLikeStatus();
    _fetchLikeCount();
    _checkSavedStatus();
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

  Future<void> _checkSavedStatus() async {
    if (!mounted) return;
    try {
      final isSaved = await _postSaveService.isPostSaved(widget.postId);
      if (!mounted) return;
      setState(() {
        _isPostSaved = isSaved;
      });
    } catch (e) {
      debugPrint('Error checking save status: $e');
    }
  }

  Future<void> _toggleSave() async {
    if (!mounted) return;
    
    // Utiliser la mu00e9thode statique qui gu00e8re la redirection vers la page de connexion
    final success = await PostSaveService.saveWithAuthCheck(context, widget.postId);
    
    // Si l'action a ru00e9ussi, mettre u00e0 jour l'interface
    if (success && mounted) {
      setState(() {
        _isPostSaved = !_isPostSaved;
      });
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
            onPressed: () async {
              // Utiliser la mu00e9thode statique qui gu00e8re la redirection vers la page de connexion
              final success = await PostLikeService.likeWithAuthCheck(context, widget.postId);
              
              // Si l'action a ru00e9ussi, mettre u00e0 jour l'interface
              if (success && mounted) {
                setState(() {
                  _isPostLiked = !_isPostLiked;
                  _likeCount = _isPostLiked ? _likeCount + 1 : _likeCount - 1;
                });
              }
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
          StreamBuilder<DocumentSnapshot>(
            stream: _firestore.collection('posts').doc(widget.postId).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final commentCount = (snapshot.data!.data() as Map<String, dynamic>?)?['commentCount'] ?? 0;
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
              _isPostSaved ? Icons.bookmark : Icons.bookmark_border,
              color: _isPostSaved ? Colors.amber : Colors.white,
              size: 24,
            ),
            onPressed: _toggleSave,
          ),
        ],
      ),
    );
  }
}
