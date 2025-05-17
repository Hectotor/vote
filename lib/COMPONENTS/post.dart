import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'post_header.dart';
import 'post_description.dart';
import 'post_actions.dart';
import '../HOME/poll_grid_home_modern_new.dart';

class Post extends StatelessWidget {
  final Map<String, dynamic> data;
  final String postId;

  const Post({
    Key? key,
    required this.data,
    required this.postId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PostHeader(
          pseudo: data['pseudo'] ?? '',
          profilePhotoUrl: data['profilePhotoUrl'],
          filterColor: data['filterColor'] != null ? 
            (data['filterColor'] is String ? 
              int.parse(data['filterColor']) : 
              data['filterColor'] as int) : 
              null,
          createdAt: data['createdAt'] ?? Timestamp.now(),
          postId: postId,
          userId: data['userId'] ?? '',
        ),
        
        if (data['description'] != null && data['description'].toString().isNotEmpty)
          PostDescription(
            pseudo: data['pseudo'] ?? '',
            description: data['description'],
          ),
        
        if (data['blocs'] != null && data['blocs'] is List && (data['blocs'] as List).isNotEmpty)
          PollGridHomeModern(
            blocs: (data['blocs'] as List).cast<Map<String, dynamic>>(),
            postId: postId,
          ),
        
        PostActions(
          postId: postId,
          userId: data['userId'] ?? '',
        ),
      ],
    );
  }
}
