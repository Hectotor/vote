import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_service.dart';

class MentionService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Détecter et créer des notifications pour les mentions dans un texte
  static Future<void> processMentions({
    required String text,
    required String sourceUserId,
    required String sourceUserName,
    required String postId,
    String? commentId,
  }) async {
    // Extraire toutes les mentions du format @username
    final RegExp mentionRegex = RegExp(r'@([\w-]+)');
    final Iterable<Match> matches = mentionRegex.allMatches(text);

    for (var match in matches) {
      final String mention = match.group(1)!;
      
      // Vérifier si le mention correspond à un utilisateur existant
      final QuerySnapshot userSnapshot = await _firestore
        .collection('users')
        .where('username', isEqualTo: mention)
        .limit(1)
        .get();

      if (userSnapshot.docs.isNotEmpty) {
        final String mentionedUserId = userSnapshot.docs.first.id;
        
        // Créer une notification de mention
        await NotificationService.createMentionNotification(
          mentionedUserId: mentionedUserId,
          sourceUserId: sourceUserId,
          sourceUserName: sourceUserName,
          postId: postId,
          commentId: commentId,
        );
      }
    }
  }
}
