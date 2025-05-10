import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'poll_grid_home.dart';
import 'package:toplyke/COMPONENTS/post_header.dart';
import 'package:toplyke/COMPONENTS/post_description.dart';
import 'package:toplyke/COMPONENTS/post_actions.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Stream<QuerySnapshot>? _postsStream;
  bool _showVotePercentages = true;

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
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
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
                          );
                        }).toList(),
                        createdAt: data['createdAt'] != null ? data['createdAt'] as Timestamp : Timestamp.now(),
                      );
                    }).toList() ?? [];

                    return ListView.builder(
                      padding: const EdgeInsets.only(),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            border: Border(
                              bottom: BorderSide(
                                color: const Color(0xFF2D3748),
                                width: 4,
                              ),
                            ),
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
                                PollGridHome(
                                  images: post.blocs.map((bloc) => bloc.postImageUrl).toList(),
                                  imageFilters: post.blocs.map((bloc) => bloc.filterColor ?? Colors.transparent).toList(),
                                  numberOfBlocs: post.blocs.length,
                                  textes: post.blocs.map((bloc) => bloc.text).toList(),
                                  postId: post.postId,
                                  showPercentages: _showVotePercentages,
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

  BlocData({
    required this.postImageUrl,
    required this.text,
    this.filterColor,
  });
}
