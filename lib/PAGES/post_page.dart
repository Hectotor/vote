import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toplyke/COMPONENTS/post_header.dart';
import 'package:toplyke/COMPONENTS/post_description.dart';
import 'package:toplyke/COMPONENTS/post_actions.dart';
import 'package:toplyke/COMPONENTS/Comment/comment_popup.dart';
import 'package:toplyke/HOME/poll_grid_home.dart';
import 'package:toplyke/COMPONENTS/Comment/comment_input.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

      print('Ajout du commentaire à Firestore...');
      await _firestore.collection('comments').add({
        'postId': widget.postId,
        'userId': user.uid,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': 0,
      });

      print('Commentaire ajouté avec succès');
      _commentController.clear();
    } catch (e) {
      print('Erreur lors de l\'ajout du commentaire: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _scrollController = ScrollController();
    return Scaffold(
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

          return SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PostHeader(
                  pseudo: data['pseudo'],
                  profilePhotoUrl: data['profilePhotoUrl'],
                  filterColor: data['filterColor'] != null ? int.parse(data['filterColor']) : null,
                  createdAt: (data['createdAt'] as Timestamp),
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
                PollGridHome(
                  images: (data['blocs'] as List<dynamic>).map((bloc) => bloc['postImageUrl'] as String?).toList(),
                  imageFilters: (data['blocs'] as List<dynamic>).map((bloc) => 
                    bloc['filterColor'] != null && bloc['filterColor'] != '0'
                        ? Color(int.parse(bloc['filterColor'].toString()))
                        : Colors.transparent
                  ).toList(),
                  numberOfBlocs: (data['blocs'] as List<dynamic>).length,
                  textes: (data['blocs'] as List<dynamic>).map((bloc) => bloc['text'] as String?).toList(),
                ),
                //const SizedBox(height: 6),
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
                        width: 1,
                      ),
                    ),
                  ),
                ),
                CommentPopup(
                  postId: widget.postId,
                  userId: data['userId'],
                  scrollController: _scrollController,
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: CommentInput(
        controller: _commentController,
        onSend: _addComment,
      ),
    );
  }
}
