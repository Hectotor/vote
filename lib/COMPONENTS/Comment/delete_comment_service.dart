import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DeleteCommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Supprime un commentaire et tous ses likes associés
  Future<void> deleteCommentAndLikes({
    required String commentId,
    required String postId,
    required BuildContext context,
    required Function onSuccess,
    required Function onError,
    required Function(String) removeCommentLocally,
  }) async {
    // Vérifier que l'utilisateur est authentifié
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous devez être connecté pour supprimer un commentaire')),
      );
      return;
    }

    // Supprimer le commentaire localement d'abord pour une meilleure UX
    removeCommentLocally(commentId);
    
    try {
      // Récupérer le commentaire pour vérifier que l'utilisateur est bien l'auteur
      final commentDoc = await _firestore.collection('commentsPosts').doc(commentId).get();
      if (!commentDoc.exists) {
        throw Exception('Commentaire introuvable');
      }
      
      final commentData = commentDoc.data() as Map<String, dynamic>;
      if (commentData['userId'] != user.uid) {
        throw Exception('Vous n\'êtes pas autorisé à supprimer ce commentaire');
      }

      // Créer un batch pour supprimer le commentaire et tous ses likes
      final batch = _firestore.batch();
      
      // Référence au commentaire
      final commentRef = _firestore.collection('commentsPosts').doc(commentId);
      batch.delete(commentRef);
      
      // Décrémenter le compteur de commentaires du post
      final postRef = _firestore.collection('posts').doc(postId);
      batch.update(postRef, {
        'commentCount': FieldValue.increment(-1),
      });
      
      // Récupérer tous les likes associés à ce commentaire
      final likesQuery = await _firestore
          .collection('commentLikes')
          .where('commentId', isEqualTo: commentId)
          .get();
      
      // Supprimer tous les likes
      for (final doc in likesQuery.docs) {
        batch.delete(doc.reference);
      }
      
      // Exécuter le batch
      await batch.commit();
      
      // Appeler le callback de succès
      onSuccess();
    } catch (e) {
      print('Erreur lors de la suppression du commentaire: $e');
      onError(e);
    }
  }
}
