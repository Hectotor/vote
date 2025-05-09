import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'poll_grid_home.dart';
import 'package:toplyke/COMPONENTS/post_header.dart';
import 'package:toplyke/COMPONENTS/post_description.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                  .collection('posts')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
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
                      filterColor: data['filterColor'] != null ? Color(int.parse(data['filterColor'])) : null,
                      description: data['description'] ?? '',
                      hashtags: List<String>.from(data['hashtags'] ?? []),
                      mentions: List<String>.from(data['mentions'] ?? []),
                      blocs: (data['blocs'] as List<dynamic>).map((bloc) {
                        return BlocData(
                          postImageUrl: bloc['postImageUrl'] as String?,
                          text: bloc['text'] as String?,
                          filterColor: bloc['filterColor'] != null && bloc['filterColor'] != '0'
                              ? Color(int.parse(bloc['filterColor'].toString()))
                              : null,
                        );
                      }).toList(),
                      createdAt: data['createdAt'] as Timestamp,
                    );
                  }).toList() ?? [];

                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey[800]!,
                              width: 0.5,
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
                              PostDescription(
                                pseudo: post.pseudo,
                                description: post.description,
                              ),

                            // Grille d'images
                            if (post.blocs.isNotEmpty)
                              PollGridHome(
                                images: post.blocs.map((bloc) => bloc.postImageUrl).toList(),
                                imageFilters: post.blocs.map((bloc) => bloc.filterColor ?? Colors.transparent).toList(),
                                numberOfBlocs: post.blocs.length,
                                textes: post.blocs.map((bloc) => bloc.text).toList(),
                              ),

                            // Actions du post
                            Padding(
                              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8, top: 4),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.favorite_border,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                    onPressed: () {},
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.chat_bubble_outline,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    onPressed: () {},
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.send_outlined,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    onPressed: () {},
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: Icon(
                                      Icons.bookmark_border,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
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
    );
  }
}

class PostData {
  final String postId;
  final String userId;
  final String pseudo;
  final String? profilePhotoUrl;
  final Color? filterColor;
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
