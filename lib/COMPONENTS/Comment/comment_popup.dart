import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../COMPONENTS/avatar.dart';
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
  
  // Méthode publique statique pour ajouter un commentaire
  static void addComment(String text) {
    // Utilise une fonction du State pour ajouter le commentaire
    _commentPopupGlobalKey.currentState?.addComment(text);
  }
  
  // Clé globale pour accéder au state depuis l'extérieur
  static final GlobalKey<_CommentPopupState> _commentPopupGlobalKey = GlobalKey<_CommentPopupState>();

  @override
  State<CommentPopup> createState() => _CommentPopupState();
  
  // Méthode factory pour créer une instance avec la clé globale
  factory CommentPopup.withGlobalKey({
    required String postId,
    required String userId,
    ScrollController? scrollController,
  }) {
    return CommentPopup(
      key: _commentPopupGlobalKey,
      postId: postId,
      userId: userId,
      scrollController: scrollController,
    );
  }
}

class _CommentPopupState extends State<CommentPopup> {
  final TextEditingController _commentController = TextEditingController();
  final CommentService _commentService = CommentService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<Map<String, dynamic>> _comments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final snapshot = await _commentService.getCommentsForPostOnce(widget.postId);
      
      if (mounted) {
        setState(() {
          _comments = snapshot.docs.map((doc) => {
            'id': doc.id,
            'postId': (doc.data() as Map<String, dynamic>)['postId'],
            'userId': (doc.data() as Map<String, dynamic>)['userId'],
            'text': (doc.data() as Map<String, dynamic>)['text'],
            'createdAt': (doc.data() as Map<String, dynamic>)['createdAt'],
            'likesCountComment': (doc.data() as Map<String, dynamic>)['likesCountComment'] ?? 0,
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erreur lors du chargement des commentaires: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Ajouter un commentaire localement puis sur le serveur
  Future<void> addComment(String text) async {
    if (text.trim().isEmpty) return;
    
    final user = _auth.currentUser;
    if (user == null) return;
    
    // Créer un commentaire temporaire
    final tempComment = {
      'id': 'temp_${DateTime.now().millisecondsSinceEpoch}',
      'postId': widget.postId,
      'userId': user.uid,
      'text': text,
      'createdAt': DateTime.now(),
      'likesCountComment': 0,
    };
    
    // Ajouter localement
    setState(() {
      _comments.insert(0, tempComment);
    });
    
    try {
      // Envoyer au serveur
      await _commentService.addComment(
        postId: widget.postId,
        text: text,
      );
      
      // Optionnel: rafraîchir les commentaires pour avoir l'ID réel
      // _loadComments();
    } catch (e) {
      print('Erreur lors de l\'ajout du commentaire: $e');
      
      // Supprimer le commentaire temporaire en cas d'erreur
      if (mounted) {
        setState(() {
          _comments.removeWhere((c) => c['id'] == tempComment['id']);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}'))
        );
      }
    }
  }

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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_comments.isEmpty) {
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
        for (var comment in _comments)
          CommentItem(
            comment: comment,
            onDelete: (commentId) => _deleteComment(commentId, comment['postId']),
            currentUserId: _auth.currentUser?.uid,
          ),
      ],
    );
  }

  Future<void> _deleteComment(String commentId, String postId) async {
    // Supprimer localement d'abord
    setState(() {
      _comments.removeWhere((c) => c['id'] == commentId);
    });
    
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
      
      // Recharger les commentaires en cas d'erreur
      _loadComments();
      
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
  bool _isLoading = true;
  DocumentSnapshot? _userDoc;
  final CommentService _commentService = CommentService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
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
                    Text(
                      _formatCommentDate(widget.comment['createdAt']),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.comment['text'] ?? '',
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                    if (isCurrentUser)
                      GestureDetector(
                        onTap: () => widget.onDelete(widget.comment['id']),
                        child: const Icon(Icons.delete, color: Colors.grey, size: 14),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                _buildLikeRow(widget.comment),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLikeRow(Map<String, dynamic> comment) {
    final commentId = comment['id'];
    final postId = comment['postId'];
    final likeCount = comment['likesCountComment'] ?? 0;
    return FutureBuilder<bool>(
      future: _commentService.isCommentLiked(commentId),
      builder: (context, snapshot) {
        final isLiked = snapshot.data ?? false;
        return GestureDetector(
          onTap: () async {
            await _commentService.toggleCommentLike(commentId, postId);
          },
          child: Row(
            children: [
              Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                size: 16,
                color: isLiked ? Colors.red : Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                '$likeCount',
                style: TextStyle(
                  color: isLiked ? Colors.red : Colors.grey,
                  fontSize: 12,
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