import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'poll_grid_home.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Stream<QuerySnapshot>? _postsStream;

  @override
  void initState() {
    super.initState();
    _postsStream = _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Widget _buildPost(PostData post) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête du post
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.pseudo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      post.description,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Grille d'images
          if (post.blocs.isNotEmpty)
            PollGridHome(
              images: post.blocs.map((bloc) => bloc.postImageUrl ?? null).toList(),
              imageFilters: post.blocs.map((bloc) => bloc.filterColor ?? Colors.transparent).toList(),
              numberOfBlocs: post.blocs.length,
              textControllers: post.blocs.map((_) => TextEditingController()).toList(),
              onImageChange: (index) {},
              onBlocRemoved: (index) {},
              onStateUpdate: () {},
            ),

          // Hashtags et mentions
          if (post.hashtags.isNotEmpty || post.mentions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post.hashtags.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      children: post.hashtags.map((hashtag) =>
                        Chip(
                          label: Text('#$hashtag'),
                          backgroundColor: Colors.grey[800],
                        )
                      ).toList(),
                    ),
                  if (post.mentions.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      children: post.mentions.map((mention) =>
                        Chip(
                          label: Text('@$mention'),
                          backgroundColor: Colors.grey[800],
                        )
                      ).toList(),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder<QuerySnapshot>(
        stream: _postsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final posts = snapshot.data?.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return PostData(
              postId: doc.id,
              userId: data['userId'],
              pseudo: data['pseudo'],
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
            );
          }).toList() ?? [];

          return ListView.builder(
            padding: const EdgeInsets.only(top: 20),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return _buildPost(posts[index]);
            },
          );
        },
      ),
    );
  }
}

class PostData {
  final String postId;
  final String userId;
  final String pseudo;
  final String description;
  final List<String> hashtags;
  final List<String> mentions;
  final List<BlocData> blocs;

  PostData({
    required this.postId,
    required this.userId,
    required this.pseudo,
    required this.description,
    required this.hashtags,
    required this.mentions,
    required this.blocs,
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
