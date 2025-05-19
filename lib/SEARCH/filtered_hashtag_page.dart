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
        elevation: 0,
        title: Text(
          '#${widget.hashtag}',
          style: const TextStyle(color: Color(0xFF212121)),
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
            padding: const EdgeInsets.only(left: 15, right: 15),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
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
