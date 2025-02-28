import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PublishService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Extraire les hashtags du texte
  List<String> _extractHashtags(String text) {
    final hashtags = RegExp(r'#\w+').allMatches(text).map((m) => m.group(0)!.substring(1)).toList();
    return hashtags;
  }

  // Extraire les mentions du texte
  List<String> _extractMentions(String text) {
    final mentions = RegExp(r'@\w+').allMatches(text).map((m) => m.group(0)!.substring(1)).toList();
    return mentions;
  }

  // Méthode pour publier du contenu
  Future<bool> publishContent({
    required String description,
    required bool isPoll,
    required List<String> pollOptions,
    List<Widget>? blocContent,
    BuildContext? context,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Extraire hashtags et mentions
      final hashtags = _extractHashtags(description);
      final mentions = _extractMentions(description);

      // Créer la publication
      final postRef = await _firestore.collection('posts').add({
        'userId': user.uid,
        'description': description,
        'type': isPoll ? 'poll' : 'bloc',
        'content': isPoll ? pollOptions.where((opt) => opt.isNotEmpty).toList() : blocContent,
        'timestamp': FieldValue.serverTimestamp(),
        'hashtags': hashtags,
        'mentions': mentions,
      });

      // Mettre à jour la collection hashtags
      for (String hashtag in hashtags) {
        await _firestore.collection('hashtags').doc(hashtag).set({
          'name': '#$hashtag',
          'posts': FieldValue.arrayUnion([postRef.id]),
          'lastUsed': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      // Mettre à jour la collection mentions
      for (String mention in mentions) {
        await _firestore.collection('mentions').doc(mention).set({
          'name': '@$mention',
          'posts': FieldValue.arrayUnion([postRef.id]),
          'lastUsed': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      return true;
    } catch (e) {
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la publication: ${e.toString()}')),
        );
      }
      return false;
    }
  }
}
