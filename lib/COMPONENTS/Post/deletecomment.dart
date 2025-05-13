import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteCommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Supprimer un commentaire ET tous ses likes
  Future<void> deleteCommentAndLikes({
    required String commentId,
    required String postId,
  }) async {
    final batch = _firestore.batch();
    final commentRef = _firestore.collection('commentsPosts').doc(commentId);
    final postRef = _firestore.collection('posts').doc(postId);
    // Supprimer le commentaire
    batch.delete(commentRef);
    // Décrémenter le compteur de commentaires du post
    batch.update(postRef, {
      'commentCount': FieldValue.increment(-1),
    });
    // Récupérer tous les likes de ce commentaire
    final likesQuery = await _firestore
        .collection('commentLikes')
        .where('commentId', isEqualTo: commentId)
        .get();
    for (final doc in likesQuery.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
