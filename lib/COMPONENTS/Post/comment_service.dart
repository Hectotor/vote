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

      // Ajouter le commentaire directement dans la collection globale commentsPosts
      final commentRef = await _firestore
          .collection('commentsPosts')
          .add(commentData);

      print('Commentaire ajouté avec l\'ID: ${commentRef.id} dans la collection globale');
      
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

  // Ajouter un commentaire à la collection globale commentsPosts et incrémenter le compteur dans posts
  Future<void> addCommentGlobal({
    required String postId,
    required String commentText,
    required String pseudo,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utilisateur non authentifié');
    final batch = _firestore.batch();
    final commentRef = _firestore.collection('commentsPosts').doc();
    final postRef = _firestore.collection('posts').doc(postId);
    batch.set(commentRef, {
      'postId': postId,
      'userId': user.uid,
      'pseudo': pseudo,
      'text': commentText,
      'likesCountComment': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.update(postRef, {
      'countComment': FieldValue.increment(1),
    });
    await batch.commit();
  }

  // Supprimer un commentaire
  Future<void> deleteComment({
    required String commentId,
    required String postId,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Utilisateur non connecté');

      // Supprimer le commentaire de la collection globale commentsPosts
      await _firestore
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

  // Supprimer un commentaire et décrémenter le compteur dans posts
  Future<void> deleteCommentGlobal({
    required String commentId,
    required String postId,
  }) async {
    final batch = _firestore.batch();
    final commentRef = _firestore.collection('commentsPosts').doc(commentId);
    final postRef = _firestore.collection('posts').doc(postId);
    batch.delete(commentRef);
    batch.update(postRef, {
      'countComment': FieldValue.increment(-1),
    });
    await batch.commit();
  }

  // Obtenir les commentaires d'un post (une seule fois)
  Future<QuerySnapshot> getCommentsForPostOnce(String postId) {
    return _firestore
        .collection('commentsPosts')
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();
  }

  // Obtenir les commentaires d'un post (en temps réel)
  Stream<QuerySnapshot> getCommentsForPost(String postId) {
    return _firestore
        .collection('commentsPosts')
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: true)
        .limit(50) // Limiter le nombre de résultats pour des raisons de performance
        .snapshots();
  }

  // Obtenir les commentaires d'un utilisateur
  Stream<QuerySnapshot> getUserComments(String userId) {
    return _firestore
        .collection('commentsPosts')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Vérifier si un utilisateur a commenté un post spécifique
  Future<bool> hasUserCommented(String postId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final query = await _firestore
          .collection('commentsPosts')
          .where('postId', isEqualTo: postId)
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      print('Erreur lors de la vérification du commentaire: $e');
      return false;
    }
  }

  // LIKE/UNLIKE un commentaire (toggle)
  Future<void> toggleCommentLike(String commentId, String postId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utilisateur non authentifié');
    final likesRef = _firestore.collection('commentLikes');
    final query = await likesRef
        .where('commentId', isEqualTo: commentId)
        .where('userId', isEqualTo: user.uid)
        .limit(1)
        .get();
    final commentRef = _firestore.collection('commentsPosts').doc(commentId);
    if (query.docs.isNotEmpty) {
      // UNLIKE
      await likesRef.doc(query.docs.first.id).delete();
      await commentRef.update({'likesCountComment': FieldValue.increment(-1)});
    } else {
      // LIKE
      await likesRef.add({
        'commentId': commentId,
        'postId': postId,
        'userId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await commentRef.update({'likesCountComment': FieldValue.increment(1)});
    }
  }

  // Vérifier si l'utilisateur a liké un commentaire
  Future<bool> isCommentLiked(String commentId) async {
    final user = _auth.currentUser;
    if (user == null) return false;
    final query = await _firestore
        .collection('commentLikes')
        .where('commentId', isEqualTo: commentId)
        .where('userId', isEqualTo: user.uid)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  // Obtenir le nombre de likes d'un commentaire (stream)
  Stream<int> commentLikesCountStream(String commentId) {
    return _firestore
        .collection('commentLikes')
        .where('commentId', isEqualTo: commentId)
        .snapshots()
        .map((snap) => snap.docs.length);
  }
}
