import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notification_model.dart';

class NotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Récupérer les notifications de l'utilisateur connecté
  static Stream<List<NotificationModel>> getNotifications() {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: currentUser.uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => NotificationModel.fromFirestore(doc))
              .toList();
        });
  }

  // Marquer une notification comme lue
  static Future<void> markAsRead(String notificationId) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    await _firestore
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  // Marquer toutes les notifications comme lues
  static Future<void> markAllAsRead() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final batch = _firestore.batch();
    final notifications = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: currentUser.uid)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in notifications.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }

  // Supprimer une notification
  static Future<void> deleteNotification(String notificationId) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    await _firestore.collection('notifications').doc(notificationId).delete();
  }

  // Créer une notification (à appeler lors d'un événement comme un like, commentaire, etc.)
  static Future<void> createNotification({
    required String userId,
    required String type,
    required String sourceUserId,
    String? sourceUserName,
    String? postId,
    String? commentId,
    required String message,
  }) async {
    // Ne pas créer de notification si l'utilisateur s'auto-notifie
    if (userId == sourceUserId) return;

    await _firestore.collection('notifications').add({
      'userId': userId,
      'type': type,
      'sourceUserId': sourceUserId,
      'sourceUserName': sourceUserName,
      'postId': postId,
      'commentId': commentId,
      'message': message,
      'isRead': false,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Obtenir le nombre de notifications non lues
  static Stream<int> getUnreadCount() {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value(0);
    }

    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: currentUser.uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
