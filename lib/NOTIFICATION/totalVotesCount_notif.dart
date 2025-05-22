import 'package:cloud_firestore/cloud_firestore.dart';

class TotalVotesCountNotification {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Crée une notification lorsqu'un post atteint un jalon important en nombre total de votes
  /// 
  /// Cette méthode vérifie si le nombre total de votes a atteint un jalon (100, 200, 500, etc.)
  /// et crée une notification pour informer l'utilisateur de cette réalisation.
  static Future<void> createVotesMilestoneNotification({
    required String userId,
    required String postId,
  }) async {
    try {
      // Récupérer le post pour vérifier le nombre total de votes actuel
      final postDoc = await _firestore.collection('posts').doc(postId).get();
      if (!postDoc.exists) return;

      final postData = postDoc.data();
      if (postData == null) return;

      // Récupérer le nombre total de votes
      final int totalVotesCount = postData['totalVotesCount'] ?? 0;

      // Vérifier si on a atteint un jalon (100, 200, etc.)
      if (totalVotesCount == 100 || 
          totalVotesCount == 200 || 
          totalVotesCount == 500 || 
          totalVotesCount == 1000 || 
          totalVotesCount == 5000 || 
          totalVotesCount == 10000) {
        // Créer une notification de jalon
        await _firestore.collection('notifications').add({
          'userId': userId,
          'type': 'votes_milestone',
          'sourceUserId': 'system', // Notification système
          'sourceUserName': 'Système',
          'postId': postId,
          'commentId': null,
          'message': 'Ton post vient de franchir les $totalVotesCount votes au total ! ',
          'isRead': false,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Erreur lors de la création de la notification de jalon pour votes: $e');
    }
  }

  /// Met à jour le compteur de votes total et vérifie si un jalon a été atteint
  /// 
  /// Cette méthode peut être appelée après qu'un vote a été ajouté ou retiré
  /// pour mettre à jour le compteur et vérifier si une notification doit être envoyée.
  static Future<void> updateTotalVotesCount({
    required String postId,
    required int newTotalVotes,
  }) async {
    try {
      // Mettre à jour le compteur de votes total dans le document du post
      await _firestore.collection('posts').doc(postId).update({
        'totalVotesCount': newTotalVotes,
      });
      
      // Récupérer l'ID de l'utilisateur propriétaire du post
      final postDoc = await _firestore.collection('posts').doc(postId).get();
      if (!postDoc.exists) return;
      
      final postData = postDoc.data();
      if (postData == null) return;
      
      final String? postOwnerId = postData['userId'];
      if (postOwnerId == null) return;
      
      // Vérifier si un jalon a été atteint et créer une notification si nécessaire
      await createVotesMilestoneNotification(
        userId: postOwnerId,
        postId: postId,
      );
    } catch (e) {
      print('Erreur lors de la mise à jour du compteur de votes total: $e');
    }
  }
}
