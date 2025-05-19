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
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(12),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _comments.isEmpty
                ? const Center(child: Text('Aucun commentaire', style: TextStyle(color: Colors.white54)))
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _comments.length,
                    itemBuilder: (context, index) => CommentItem(
                      comment: _comments[index],
                      onDelete: (id) => _deleteComment(id, _comments[index]['postId']),
                      currentUserId: _auth.currentUser?.uid,
                    ),
                  ),
      ),
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Avatar(userId: widget.comment['userId'], radius: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(pseudo, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text(_formatCommentDate(widget.comment['createdAt']), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(child: Text(widget.comment['text'], style: const TextStyle(color: Colors.white))),
                    if (isCurrentUser)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                        onPressed: () => widget.onDelete(widget.comment['id']),
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
              child: Row(
                children: [
                  Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : Colors.grey, size: 16),
                  const SizedBox(width: 4),
                  Text('$likeCount', style: TextStyle(color: isLiked ? Colors.red : Colors.grey, fontSize: 12)),
                ],
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
