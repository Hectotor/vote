import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../COMPONENTS/post_header.dart';
import '../COMPONENTS/post_description.dart';
import '../COMPONENTS/post_actions.dart';
import '../HOME/poll_grid_home_modern_new.dart';

class Post extends StatelessWidget {
  final Map<String, dynamic> data;
  final String postId;
  final bool isSavedPost;

  const Post({
    Key? key,
    required this.data,
    required this.postId,
    this.isSavedPost = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Si c'est un post sauvegardé, nous devons récupérer les détails complets du post
    if (isSavedPost) {
      return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('posts').doc(postId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return const Center(child: Text('Erreur de chargement'));
          }
          
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Post non trouvé'));
          }
          
          // Récupérer les données du post
          final postData = snapshot.data!.data() as Map<String, dynamic>;
          
          return _buildPostContent(context, postData);
        },
      );
    }
    
    // Si c'est un post normal, on utilise directement les données
    return _buildPostContent(context, data);
  }
  
  Widget _buildPostContent(BuildContext context, Map<String, dynamic> postData) {
    // Convertir les blocs en format attendu par PollGridHomeModern
    List<Map<String, dynamic>> formattedBlocs = [];
    if (postData['blocs'] != null) {
      if (postData['blocs'] is List) {
        formattedBlocs = (postData['blocs'] as List).map((bloc) {
          if (bloc is Map) {
            return Map<String, dynamic>.from(bloc);
          }
          return <String, dynamic>{};
        }).toList();
      } else if (postData['blocs'] is Map) {
        formattedBlocs = (postData['blocs'] as Map).values.map((bloc) {
          if (bloc is Map) {
            return Map<String, dynamic>.from(bloc);
          }
          return <String, dynamic>{};
        }).toList();
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête du post
        PostHeader(
          pseudo: postData['pseudo'] ?? '',
          profilePhotoUrl: postData['profilePhotoUrl'],
          filterColor: postData['filterColor'] != null ? 
            (postData['filterColor'] is String ? 
              int.parse(postData['filterColor']) : 
              postData['filterColor'] as int) : 
              null,
          createdAt: postData['createdAt'] ?? Timestamp.now(),
          postId: postId,
          userId: postData['userId'] ?? '',
        ),
        
        // Description du post
        if (postData['description'] != null && postData['description'].toString().isNotEmpty)
          PostDescription(
            pseudo: postData['pseudo'] ?? '',
            description: postData['description'],
          ),
        
        // Contenu du post (images/sondages)
        if (formattedBlocs.isNotEmpty)
          GestureDetector(
            onTap: () {
              // Navigation vers la page du post si on clique sur le contenu
              Navigator.of(context).pushNamed('/post', arguments: postId);
            },
            child: PollGridHomeModern(
              blocs: formattedBlocs,
              postId: postId,
            ),
          ),
        
        // Actions du post (like, commentaire, etc.)
        PostActions(
          postId: postId,
          userId: postData['userId'] ?? '',
        ),
      ],
    );
  }
}
