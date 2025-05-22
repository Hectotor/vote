import 'package:cloud_firestore/cloud_firestore.dart';

class LikesCountNotification {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Crée une notification lorsqu'un post atteint un jalon important en nombre de likes
  /// 
  /// Cette méthode vérifie si le nombre de likes a atteint un jalon (100, 200, 500, etc.)
  /// et crée une notification pour informer l'utilisateur de cette réalisation.
  static Future<void> createLikeMilestoneNotification({
    required String userId,
    required String postId,
  }) async {
    try {
      // Récupérer le post pour vérifier le nombre de likes actuel
      final postDoc = await _firestore.collection('posts').doc(postId).get();
      if (!postDoc.exists) return;

      final postData = postDoc.data();
      if (postData == null) return;

      // Récupérer le nombre de likes
      final int likesCount = postData['likes'] ?? 0;

      // Vérifier si on a atteint un jalon (100, 200, etc.)
      if (likesCount == 100 || 
          likesCount == 200 || 
          likesCount == 500 || 
          likesCount == 1000 || 
          likesCount == 5000 || 
          likesCount == 10000) {
        // Créer une notification de jalon
        await _firestore.collection('notifications').add({
          'userId': userId,
          'type': 'like_milestone',
          'sourceUserId': 'system', // Notification système
          'sourceUserName': 'Système',
          'postId': postId,
          'commentId': null,
          'message': 'Ton post vient de franchir les $likesCount j\'aime ! ',
          'isRead': false,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Erreur lors de la création de la notification de jalon pour likes: $e');
    }
  }

  /// Met à jour le compteur de likes et vérifie si un jalon a été atteint
  /// 
  /// Cette méthode peut être appelée après qu'un like a été ajouté ou retiré
  /// pour mettre à jour le compteur et vérifier si une notification doit être envoyée.
  static Future<void> updateLikesCount({
    required String postId,
    required int newLikesCount,
  }) async {
    try {
      // Mettre à jour le compteur de likes dans le document du post
      await _firestore.collection('posts').doc(postId).update({
        'likes': newLikesCount,
      });
      
      // Récupérer l'ID de l'utilisateur propriétaire du post
      final postDoc = await _firestore.collection('posts').doc(postId).get();
      if (!postDoc.exists) return;
      
      final postData = postDoc.data();
      if (postData == null) return;
      
      final String? postOwnerId = postData['userId'];
      if (postOwnerId == null) return;
      
      // Vérifier si un jalon a été atteint et créer une notification si nécessaire
      await createLikeMilestoneNotification(
        userId: postOwnerId,
        postId: postId,
      );
    } catch (e) {
      print('Erreur lors de la mise à jour du compteur de likes: $e');
    }
  }
}
