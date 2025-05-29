import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toplyke/HOME/poll_grid_home_modern_new.dart';
import 'package:toplyke/COMPONENTS/post_header.dart';
import 'package:toplyke/COMPONENTS/post_description.dart';
import 'package:toplyke/COMPONENTS/post_actions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Stream<QuerySnapshot>? _postsStream;

  @override
  void initState() {
    super.initState();
    _initPostsStream();
  }

  void _initPostsStream() {
    _postsStream = _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _initPostsStream();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Fermer le clavier lorsque l'utilisateur touche l'u00e9cran
    return GestureDetector(
      onTap: () {
        // Fermer le clavier
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
      //backgroundColor: Colors.black,
      extendBody: true, // Permet au contenu de défiler derrière la navbar
      body: SafeArea(
        bottom: false, // Désactive le padding de sécurité en bas pour permettre le défilement complet
        child: RefreshIndicator(
          onRefresh: _refreshPosts,
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _postsStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      );
                    }

                    final posts = snapshot.data?.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return PostData(
                        postId: doc.id,
                        userId: data['userId'],
                        pseudo: data['pseudo'],
                        profilePhotoUrl: data['profilePhotoUrl'],
                        filterColor: data['filterColor'] != null ? (data['filterColor'] is String ? int.parse(data['filterColor']) : data['filterColor'] as int) : null,
                        description: data['description'] ?? '',
                        hashtags: List<String>.from(data['hashtags'] ?? []),
                        mentions: List<String>.from(data['mentions'] ?? []),
                        blocs: data['blocs'] is List
                        ? (data['blocs'] as List<dynamic>).map((bloc) {
                          return BlocData(
                            postImageUrl: bloc['postImageUrl'] as String?,
                            text: bloc['text'] as String?,
                            filterColor: bloc['filterColor'] != null && bloc['filterColor'].toString() != '0'
                                ? Color(bloc['filterColor'] is String ? int.parse(bloc['filterColor']) : bloc['filterColor'] as int)
                                : null,
                            voteCount: bloc['voteCount'] as int?,
                            votes: bloc['votes'] as List<dynamic>?,
                          );
                        }).toList()
                        : (data['blocs'] as Map<String, dynamic>).entries.map((entry) {
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
                        }).toList(),
                        createdAt: data['createdAt'] != null ? data['createdAt'] as Timestamp : Timestamp.now(),
                      );
                    }).toList() ?? [];

                    return ListView.builder(
                      // Ajouter un padding en bas pour u00e9viter que la barre de navigation ne cache les actions du post
                      padding: const EdgeInsets.only(left: 5, right: 5, bottom: 100),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 10,),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white,
                              width: 5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PostHeader(
                                pseudo: post.pseudo,
                                profilePhotoUrl: post.profilePhotoUrl,
                                filterColor: post.filterColor,
                                createdAt: post.createdAt,
                                postId: post.postId,
                                userId: post.userId,
                              ),
                              
                              // Description
                              if (post.description.isNotEmpty)
                                Column(
                                  children: [
                                    PostDescription(
                                      pseudo: post.pseudo,
                                      description: post.description,
                                    ),
                                  
                                  ],
                                ),

                              // Grid de photos
                              if (post.blocs.isNotEmpty)
                                GestureDetector(
                                  onTap: () async {
                                    final user = FirebaseAuth.instance.currentUser;
                                    if (user == null) {
                                      print('Utilisateur non authentifié');
                                      return;
                                    }

                                    // Trouver l'animation du cœur et la déclencher
                                    final heartAnimationState = context.findRenderObject()?.paintBounds;
                                    if (heartAnimationState != null) {
                                      print('Animation du cœur trouvée');
                                    }

                                    try {
                                      final postRef = _firestore.collection('posts').doc(post.postId);
                                      final postDoc = await postRef.get();

                                      if (!postDoc.exists) {
                                        print('Post non trouvé');
                                        return;
                                      }

                                      final postData = postDoc.data()!;
                                      final blocs = postData['blocs'] is Map
                                      ? (postData['blocs'] as Map<String, dynamic>).values.map<Map<String, dynamic>>((b) => Map<String, dynamic>.from(b)).toList()
                                      : (postData['blocs'] as List<dynamic>).map<Map<String, dynamic>>((b) => Map<String, dynamic>.from(b)).toList();
                                       
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
                                        print('L\'utilisateur a déjà voté');
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

                                      print('Vote enregistré avec succès');
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
                              //const SizedBox(height: 16),
                              // Actions du post
                              PostActions(
                                postId: post.postId,
                                userId: post.userId,
                              ),
                          
                          
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}

class PostData {
  final String postId;
  final String userId;
  final String pseudo;
  final String? profilePhotoUrl;
  final int? filterColor;
  final String description;
  final List<String> hashtags;
  final List<String> mentions;
  final List<BlocData> blocs;
  final Timestamp createdAt;

  PostData({
    required this.postId,
    required this.userId,
    required this.pseudo,
    this.profilePhotoUrl,
    this.filterColor,
    required this.description,
    required this.hashtags,
    required this.mentions,
    required this.blocs,
    required this.createdAt,
  });
}

class BlocData {
  final String? postImageUrl;
  final String? text;
  final Color? filterColor;
  final int? voteCount;
  final List<dynamic>? votes;

  BlocData({
    required this.postImageUrl,
    required this.text,
    this.filterColor,
    this.voteCount,
    this.votes,
  });

  Map<String, dynamic> toJson() {
    return {
      'postImageUrl': postImageUrl,
      'text': text,
      'filterColor': filterColor?.value,
      'voteCount': voteCount,
      'votes': votes,
    };
  }
}
