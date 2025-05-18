import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toplyke/COMPONENTS/post_header.dart';
import 'package:toplyke/COMPONENTS/post_description.dart';
import 'package:toplyke/COMPONENTS/post_actions.dart';
import 'package:toplyke/COMPONENTS/Comment/comment_popup.dart';
import 'package:toplyke/HOME/poll_grid_home_modern_new.dart';
import 'package:toplyke/COMPONENTS/Comment/comment_input.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../page_wrapper.dart';
// import 'package:toplyke/COMPONENTS/Post/comment_service.dart'; // Non utilisu00e9 car nous utilisons la mu00e9thode de CommentPopup

class PostPage extends StatefulWidget {
  final String postId;

  const PostPage({
    Key? key,
    required this.postId,
  }) : super(key: key);

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _commentController = TextEditingController();

  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vous devez être connecté pour commenter')),
        );
        return;
      }

      // Utiliser la méthode addComment du CommentPopup pour une mise à jour optimiste
      CommentPopup.addComment(text);
      
      // Vider le champ de commentaire
      _commentController.clear();
    } catch (e) {
      print('Erreur lors de l\'ajout du commentaire: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
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
    final _mainScrollController = ScrollController();
    final _commentScrollController = ScrollController();
    
    return PageWrapper(
      showNavBar: true,
      currentIndex: 0, // Home
      bottomWidget: CommentInput(
        controller: _commentController,
        onSend: _addComment,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: _firestore.collection('posts').doc(widget.postId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Post non trouvé', style: TextStyle(color: Colors.white)));
          }

          final post = snapshot.data!;
          final data = post.data() as Map<String, dynamic>;

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                controller: _mainScrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PostHeader(
                        pseudo: data['pseudo'],
                        profilePhotoUrl: data['profilePhotoUrl'],
                        filterColor: data['filterColor'] != null ? (data['filterColor'] is String ? int.parse(data['filterColor']) : data['filterColor'] as int) : null,
                        createdAt: data['createdAt'] != null ? data['createdAt'] as Timestamp : Timestamp.now(),
                        postId: widget.postId,
                        userId: data['userId'],
                      ),
                      if (data['description'] != null && data['description'].isNotEmpty)
                        Column(
                          children: [
                            PostDescription(
                              pseudo: data['pseudo'],
                              description: data['description'],
                            ),
                          ],
                        ),
                      PollGridHomeModern(
                        blocs: data['blocs'] is Map
                          ? (data['blocs'] as Map<String, dynamic>).values.map<Map<String, dynamic>>((bloc) => Map<String, dynamic>.from(bloc)).toList()
                          : (data['blocs'] as List<dynamic>).map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList(),
                        postId: data['postId'],
                      ),
                      PostActions(
                        postId: widget.postId,
                        userId: data['userId'],
                        isCommentPage: true,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey[800]!,
                              width: 0.5,
                            ),
                          ),
                        ),
                      ),
                      CommentPopup.withGlobalKey(
                        postId: widget.postId,
                        userId: data['userId'],
                        scrollController: _commentScrollController,
                      ),
                      SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 300 : 0),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      ),
    );
  }
}
