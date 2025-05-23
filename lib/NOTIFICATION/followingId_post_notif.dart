import 'package:cloud_firestore/cloud_firestore.dart';

class FollowingPostNotification {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  // Créer une notification de nouveau post pour les abonnés
  static Future<void> createFollowingPostNotification({
    required String sourceUserId,
    required String sourceUserName,
    required String postId,
  }) async {
    try {
      final batch = _firestore.batch();
      
      // Récupérer les abonnés de l'utilisateur
      final QuerySnapshot followersSnapshot = await _firestore
          .collection('followers')
          .where('followingId', isEqualTo: sourceUserId)
          .get();

      // Pour chaque abonné, créer une notification
      for (var doc in followersSnapshot.docs) {
        final String followerId = doc['followerId'];
        
        // Ne pas créer de notification pour l'utilisateur lui-même
        if (followerId == sourceUserId) continue;

        batch.set(
          _firestore.collection('notifications').doc(),
          {
            'userId': followerId,
            'type': 'new_post',
            'sourceUserId': sourceUserId,
            'sourceUserName': sourceUserName,
            'postId': postId,
            'message': '$sourceUserName a publié un nouveau post',
            'isRead': false,
            'timestamp': FieldValue.serverTimestamp(),
          },
        );
      }

      await batch.commit();
    } catch (e) {
      print('Erreur lors de la création des notifications pour les nouveaux posts: $e');
    }
  }
}
