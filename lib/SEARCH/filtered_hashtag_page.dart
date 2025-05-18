import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../USERS/post.dart';

class FilteredHashtagPage extends StatefulWidget {
  final String hashtag;
  const FilteredHashtagPage({super.key, required this.hashtag});

  @override
  State<FilteredHashtagPage> createState() => _FilteredHashtagPageState();
}

class _FilteredHashtagPageState extends State<FilteredHashtagPage> {
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
        .where('hashtags', arrayContains: widget.hashtag)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          '#${widget.hashtag}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _postsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            );
          }

          final posts = snapshot.data?.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              'postId': doc.id,
              'userId': data['userId'],
              'pseudo': data['pseudo'],
              'profilePhotoUrl': data['profilePhotoUrl'],
              'description': data['description'] ?? '',
              'hashtags': List<String>.from(data['hashtags'] ?? []),
              'mentions': List<String>.from(data['mentions'] ?? []),
              'blocs': data['blocs'] ?? [],
              'createdAt': data['createdAt'] ?? Timestamp.now(),
            };
          }).toList() ?? [];

          if (posts.isEmpty) {
            return const Center(
              child: Text(
                'Aucun post trouvé avec ce hashtag',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

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
                      color: Colors.grey[800]!,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Post(
                  data: post,
                  postId: post['postId'],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
