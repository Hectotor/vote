import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../COMPONENTS/avatar.dart';
import '../Post/comment_service.dart';
import 'delete_comment_service.dart';
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

  static void addComment(String text) {
    _commentPopupGlobalKey.currentState?.addComment(text);
  }

  static final GlobalKey<_CommentPopupState> _commentPopupGlobalKey = GlobalKey<_CommentPopupState>();

  @override
  State<CommentPopup> createState() => _CommentPopupState();

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
    setState(() => _isLoading = true);
    try {
      final snapshot = await _commentService.getCommentsForPostOnce(widget.postId);
      if (mounted) {
        setState(() {
          _comments = snapshot.docs.map((doc) => {
            'id': doc.id,
            ...doc.data() as Map<String, dynamic>,
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> addComment(String text) async {
    if (text.trim().isEmpty) return;
    final user = _auth.currentUser;
    if (user == null) return;
    final tempComment = {
      'id': 'temp_${DateTime.now().millisecondsSinceEpoch}',
      'postId': widget.postId,
      'userId': user.uid,
      'text': text,
      'createdAt': DateTime.now(),
      'likesCountComment': 0,
    };
    setState(() => _comments.insert(0, tempComment));
    try {
      await _commentService.addComment(postId: widget.postId, text: text);
    } catch (e) {
      setState(() => _comments.removeWhere((c) => c['id'] == tempComment['id']));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête de la section commentaires
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Text(
                'Commentaires',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_comments.length}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Liste des commentaires
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_comments.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun commentaire',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Soyez le premier à commenter',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _comments.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              thickness: 0.5,
              color: Colors.grey[200],
              indent: 68,
            ),
            itemBuilder: (context, index) => CommentItem(
              comment: _comments[index],
              onDelete: (id) => _deleteComment(id, _comments[index]['postId']),
              currentUserId: _auth.currentUser?.uid,
            ),
          ),
      ],
    );
  }

  Future<void> _deleteComment(String commentId, String postId) async {
    final deleteService = DeleteCommentService();
    await deleteService.deleteCommentAndLikes(
      commentId: commentId,
      postId: postId,
      context: context,
      removeCommentLocally: (id) => setState(() => _comments.removeWhere((c) => c['id'] == id)),
      onSuccess: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Commentaire supprimé'))),
      onError: (e) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}'))),
    );
  }
}

class CommentItem extends StatefulWidget {
  final Map<String, dynamic> comment;
  final Function(String) onDelete;
  final String? currentUserId;

  const CommentItem({Key? key, required this.comment, required this.onDelete, this.currentUserId}) : super(key: key);

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
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.comment['userId']).get();
      if (mounted) setState(() => _userDoc = userDoc);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox.shrink();
    final data = _userDoc?.data() as Map<String, dynamic>? ?? {};
    final pseudo = data['pseudo'] ?? 'Utilisateur';
    final isCurrentUser = widget.comment['userId'] == widget.currentUserId;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar de l'utilisateur
          Avatar(userId: widget.comment['userId'], radius: 24),
          const SizedBox(width: 12),
          
          // Contenu du commentaire
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête: nom d'utilisateur et date
                Row(
                  children: [
                    Text(
                      pseudo,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '•', // Bullet point
                      style: TextStyle(color: Colors.grey[500], fontSize: 10),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatCommentDate(widget.comment['createdAt']),
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
                
                // Texte du commentaire
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Text(
                    widget.comment['text'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
                
                // Actions: like et supprimer
                Row(
                  children: [
                    // Bouton like
                    _buildLikeRow(widget.comment),
                    
                    // Bouton répondre (pour une future fonctionnalité)
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        // Fonctionnalité à implémenter plus tard
                      },
                      child: Row(
                        children: [
                          Icon(Icons.reply, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            'Répondre',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    
                    // Bouton supprimer (seulement pour l'auteur)
                    if (isCurrentUser) const Spacer(),
                    if (isCurrentUser)
                      GestureDetector(
                        onTap: () => widget.onDelete(widget.comment['id']),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                'Supprimer',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
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

  Widget _buildLikeRow(Map<String, dynamic> comment) {
    final commentId = comment['id'];
    final postId = comment['postId'];
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('commentsPosts').doc(commentId).snapshots(),
      builder: (context, snap) {
        final likeCount = (snap.data?.data() as Map<String, dynamic>?)?['likesCountComment'] ?? 0;
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('commentLikes')
              .where('commentId', isEqualTo: commentId)
              .where('userId', isEqualTo: user.uid)
              .limit(1)
              .snapshots(),
          builder: (context, snapshot) {
            final isLiked = (snapshot.data?.docs.isNotEmpty ?? false);
            return GestureDetector(
              onTap: () async => await _commentService.toggleCommentLike(commentId, postId),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_outline,
                        key: ValueKey<bool>(isLiked),
                        color: isLiked ? Colors.red : Colors.grey[600],
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      likeCount > 0 ? '$likeCount' : 'J\'aime',
                      style: TextStyle(
                        fontSize: 12,
                        color: isLiked ? Colors.red : Colors.grey[600],
                        fontWeight: isLiked ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatCommentDate(dynamic date) {
    if (date == null) return 'À linstant';
    try {
      if (date is Timestamp) return formatter.DateFormatter.formatDate(date.toDate());
      if (date is DateTime) return formatter.DateFormatter.formatDate(date);
      if (date is Map && date['_seconds'] != null) {
        return formatter.DateFormatter.formatDate(
          DateTime.fromMillisecondsSinceEpoch(date['_seconds'] * 1000, isUtc: true),
        );
      }
      return 'Date inconnue';
    } catch (_) {
      return 'Date invalide';
    }
  }
}
