import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toplyke/COMPONENTS/post_header.dart';
import 'package:toplyke/COMPONENTS/post_description.dart';
import 'package:toplyke/COMPONENTS/post_actions.dart';
import 'package:toplyke/COMPONENTS/Comment/comment_popup.dart';
import 'package:toplyke/HOME/poll_grid_home_modern_new.dart';
import 'package:toplyke/COMPONENTS/Comment/comment_input.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toplyke/HOME/home_page.dart';

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
  
  // Méthode pour convertir les blocs de données en objets BlocData
  List<BlocData> _convertToBlocs(dynamic blocsData) {
    if (blocsData == null) return [];
    
    if (blocsData is List) {
      return blocsData.map((bloc) {
        return BlocData(
          postImageUrl: bloc['postImageUrl'] as String?,
          text: bloc['text'] as String?,
          filterColor: bloc['filterColor'] != null && bloc['filterColor'].toString() != '0'
              ? Color(bloc['filterColor'] is String ? int.parse(bloc['filterColor']) : bloc['filterColor'] as int)
              : null,
          voteCount: bloc['voteCount'] as int?,
          votes: bloc['votes'] as List<dynamic>?,
        );
      }).toList();
    } else if (blocsData is Map) {
      return (blocsData as Map<String, dynamic>).entries.map((entry) {
        final bloc = entry.value as Map<String, dynamic>;
        return BlocData(
          postImageUrl: bloc['postImageUrl'] as String?,
          text: bloc['text'] as String?,
          filterColor: bloc['filterColor'] != null && bloc['filterColor'].toString() != '0'
              ? Color(bloc['filterColor'] is String ? int.parse(bloc['filterColor']) : bloc['filterColor'] as int)
              : null,
          voteCount: bloc['voteCount'] as int?,
          votes: bloc['votes'] as List<dynamic>?,
        );
      }).toList();
    }
    
    return [];
  }

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
    final _commentScrollController = ScrollController();
    
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Post'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: _firestore.collection('posts').doc(widget.postId).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(child: Text('Post non trouvé'));
                  }

                  final doc = snapshot.data!;
                  final data = doc.data() as Map<String, dynamic>;
                  
                  // Utiliser la classe PostData de home_page.dart
                  final post = PostData(
                    postId: widget.postId,
                    userId: data['userId'],
                    pseudo: data['pseudo'],
                    profilePhotoUrl: data['profilePhotoUrl'],
                    filterColor: data['filterColor'] != null ? (data['filterColor'] is String ? int.parse(data['filterColor']) : data['filterColor'] as int) : null,
                    description: data['description'] ?? '',
                    hashtags: List<String>.from(data['hashtags'] ?? []),
                    mentions: List<String>.from(data['mentions'] ?? []),
                    blocs: _convertToBlocs(data['blocs']),
                    createdAt: data['createdAt'] != null ? data['createdAt'] as Timestamp : Timestamp.now(),
                  );

                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white,
                          width: 5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          // En-tête du post
                          PostHeader(
                            pseudo: post.pseudo,
                            profilePhotoUrl: post.profilePhotoUrl,
                            filterColor: post.filterColor,
                            createdAt: post.createdAt,
                            postId: post.postId,
                            userId: post.userId,
                          ),
                          
                          // Description du post
                          if (post.description.isNotEmpty)
                            PostDescription(
                              pseudo: post.pseudo,
                              description: post.description,
                            ),
                        
                        // Contenu du post (images/sondages)
                        GestureDetector(
                          onTap: () async {
                            final user = FirebaseAuth.instance.currentUser;
                            if (user == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Connectez-vous pour voter')),
                              );
                              return;
                            }
                            
                            try {
                              final postRef = _firestore.collection('posts').doc(post.postId);
                              final postDoc = await postRef.get();
                              final postData = postDoc.data();
                              
                              if (postData == null) return;
                              
                              final blocs = postData['blocs'] is List
                                ? postData['blocs'] as List<dynamic>
                                : (postData['blocs'] as Map<String, dynamic>).values.toList();
                              
                              // Vérifier si l'utilisateur a déjà voté
                              bool hasVoted = false;
                              for (final bloc in blocs) {
                                final votes = bloc['votes'] as List<dynamic>? ?? [];
                                if (votes.contains(user.uid)) {
                                  hasVoted = true;
                                  break;
                                }
                              }
                              
                              if (hasVoted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Vous avez déjà voté sur ce post')),
                                );
                                return;
                              }
                              
                              // Mettre à jour le bloc
                              final updatedBloc = {
                                ...blocs[0],
                                'voteCount': (blocs[0]['voteCount'] as int? ?? 0) + 1,
                                'votes': [...(blocs[0]['votes'] as List<dynamic>? ?? []), user.uid],
                              };
                              
                              // Mettre à jour le post
                              final updatedBlocs = [...blocs];
                              updatedBlocs[0] = updatedBloc;
                              
                              await postRef.update({
                                'blocs': updatedBlocs,
                              });
                            } catch (e) {
                              print('Erreur lors du vote: $e');
                            }
                          },
                          child: PollGridHomeModern(
                            blocs: post.blocs.map((bloc) => {
                              'postImageUrl': bloc.postImageUrl,
                              'text': bloc.text,
                              'filterColor': bloc.filterColor?.value.toString(),
                              'voteCount': bloc.voteCount ?? 0,
                              'votes': bloc.votes ?? [],
                            }).toList(),
                            postId: post.postId,
                          ),
                        ),
                        
                        // Actions du post (like, commentaire, etc.)
                        PostActions(
                          postId: post.postId,
                          userId: post.userId,
                          isCommentPage: true,
                        ),
                        
                        // Séparateur léger
                        Divider(height: 1, thickness: 0.5, color: Colors.grey[300]),
                        
                        // Section commentaires
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: CommentPopup.withGlobalKey(
                            postId: post.postId,
                            userId: post.userId,
                            scrollController: _commentScrollController,
                          ),
                        ),
                        
                        // Espace pour le clavier
                        SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 300 : 0),
                      ],
                    ),
                  ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CommentInput(
        controller: _commentController,
        onSend: _addComment,
      ),
    );
  }
}
