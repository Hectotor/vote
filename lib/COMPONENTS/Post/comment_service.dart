import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Ajouter un commentaire
  Future<void> addComment({
    required String postId,
    required String text,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Utilisateur non connecté');

      print('Début de l\'ajout du commentaire pour le post: $postId');
      
      // Créer l'objet commentaire complet
      final commentData = {
        'postId': postId,
        'userId': user.uid,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': 0,
      };

      // Ajouter le commentaire directement dans la collection de l'utilisateur
      final userCommentRef = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('commentsPosts')
          .add(commentData);

      print('Commentaire ajouté avec l\'ID: ${userCommentRef.id} dans la collection utilisateur');
      
      // Mettre à jour le compteur de commentaires du post
      print('Mise à jour du compteur de commentaires pour le post: $postId');
      await _firestore.collection('posts').doc(postId).update({
        'commentCount': FieldValue.increment(1),
      });
      
      print('Commentaire ajouté avec succès');
    } catch (e) {
      print('Erreur lors de l\'ajout du commentaire: $e');
      rethrow;
    }
  }

  // Supprimer un commentaire
  Future<void> deleteComment({
    required String commentId,
    required String postId,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Utilisateur non connecté');

      // Supprimer le commentaire de la collection de l'utilisateur
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('commentsPosts')
          .doc(commentId)
          .delete();

      // Mettre à jour le compteur de commentaires du post
      await _firestore.collection('posts').doc(postId).update({
        'commentCount': FieldValue.increment(-1),
      });
    } catch (e) {
      print('Erreur lors de la suppression du commentaire: $e');
      rethrow;
    }
  }

  // Obtenir les commentaires d'un post (une seule fois)
  Future<QuerySnapshot> getCommentsForPostOnce(String postId) {
    return _firestore
        .collectionGroup('commentsPosts')
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();
  }

  // Obtenir les commentaires d'un post (en temps réel)
  Stream<QuerySnapshot> getCommentsForPost(String postId) {
    return _firestore
        .collectionGroup('commentsPosts')
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: true)
        .limit(50) // Limiter le nombre de résultats pour des raisons de performance
        .snapshots();
  }

  // Obtenir les commentaires d'un utilisateur
  Stream<QuerySnapshot> getUserComments(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('commentsPosts')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Vérifier si un utilisateur a commenté un post spécifique
  Future<bool> hasUserCommented(String postId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final query = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('commentsPosts')
          .where('postId', isEqualTo: postId)
          .limit(1)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      print('Erreur lors de la vérification du commentaire: $e');
      return false;
    }
  }
}
