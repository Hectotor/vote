import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String userId; // ID de l'utilisateur qui reçoit la notification
  final String type; // like, comment, follow, mention, etc.
  final String sourceUserId; // ID de l'utilisateur qui a déclenché la notification
  final String? sourceUserName; // Nom de l'utilisateur qui a déclenché la notification
  final String? postId; // ID du post concerné (si applicable)
  final String? commentId; // ID du commentaire concerné (si applicable)
  final String message; // Message de la notification
  final bool isRead; // Si la notification a été lue
  final Timestamp timestamp; // Date de création

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.sourceUserId,
    this.sourceUserName,
    this.postId,
    this.commentId,
    required this.message,
    required this.isRead,
    required this.timestamp,
  });

  // Convertir un document Firestore en NotificationModel
  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: data['type'] ?? '',
      sourceUserId: data['sourceUserId'] ?? '',
      sourceUserName: data['sourceUserName'],
      postId: data['postId'],
      commentId: data['commentId'],
      message: data['message'] ?? '',
      isRead: data['isRead'] ?? false,
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  // Convertir NotificationModel en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type,
      'sourceUserId': sourceUserId,
      'sourceUserName': sourceUserName,
      'postId': postId,
      'commentId': commentId,
      'message': message,
      'isRead': isRead,
      'timestamp': timestamp,
    };
  }
}
