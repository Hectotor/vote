import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';


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
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec pseudo
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.1),
                  child: Text(
                    post.pseudo[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  post.pseudo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Grille d'images
          if (post.blocs.isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(4),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: post.blocs.length,
              itemBuilder: (context, index) {
                final bloc = post.blocs[index];
                if (bloc.postImageUrl != null) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: bloc.filterColor != null
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              CachedNetworkImage(
                                imageUrl: bloc.postImageUrl!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) => const Icon(Icons.error),
                              ),
                              Container(
                                color: bloc.filterColor!.withOpacity(0.5),
                              ),
                            ],
                          )
                        : CachedNetworkImage(
                            imageUrl: bloc.postImageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          ),
                  );
                }
                return Container();
              },
            ),

          // Texte du post
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              height: 24, // Hauteur minimale pour le texte
              child: Text(
                post.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),

          // Hashtags et mentions
          if (post.hashtags.isNotEmpty || post.mentions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 8,
                children: [
                  ...post.hashtags.map(
                    (hashtag) => Chip(
                      label: Text(
                        hashtag,
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.blue,
                    ),
                  ),
                  ...post.mentions.map(
                    (mention) => Chip(
                      label: Text(
                        mention,
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.purple,
                    ),
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
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Vote',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
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
              text: data['text'] ?? '',
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
            padding: const EdgeInsets.only(top: 8),
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
  final String text;
  final List<String> hashtags;
  final List<String> mentions;
  final List<BlocData> blocs;

  PostData({
    required this.postId,
    required this.userId,
    required this.pseudo,
    required this.text,
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
