import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'poll_grid_home.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                final post = posts[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            post.pseudo,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        post.description,
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 10),
                      PollGridHome(
                        images: post.blocs.map((bloc) => bloc.postImageUrl).toList(),
                        imageFilters: post.blocs.map((bloc) => bloc.filterColor ?? Colors.transparent).toList(),
                        numberOfBlocs: post.blocs.length,
                        textes: post.blocs.map((bloc) => bloc.text).toList(),
                      ),
                    ],
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
