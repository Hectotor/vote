import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:toplyke/INSCRIPTION/connexion_screen.dart';
import 'package:toplyke/navBar.dart';

class PostDeleteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> deletePost(String postId, String userId, BuildContext context) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ConnexionPage()),
        );
        return;
      }

      if (currentUser.uid != userId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vous ne pouvez pas supprimer ce post'),
          ),
        );
        return;
      }

      // Supprimer le post
      await _firestore.collection('posts').doc(postId).delete();

      // Supprimer les hashtags associés
      final hashtagsRef = _firestore.collection('hashtags');
      final hashtagsSnapshot = await hashtagsRef.get();
      for (var doc in hashtagsSnapshot.docs) {
        await hashtagsRef.doc(doc.id).update({
          'postIds': FieldValue.arrayRemove([postId]),
        });
      }

      // Supprimer les mentions associées
      final mentionsRef = _firestore.collection('mentions');
      final mentionsSnapshot = await mentionsRef.get();
      for (var doc in mentionsSnapshot.docs) {
        await mentionsRef.doc(doc.id).update({
          'postIds': FieldValue.arrayRemove([postId]),
        });
      }

      // Supprimer les images du post
      final postRef = _firestore.collection('posts').doc(postId);
      final postDoc = await postRef.get();
      if (postDoc.exists) {
        final data = postDoc.data() as Map<String, dynamic>;
        final blocs = List<Map<String, dynamic>>.from(data['blocs'] ?? []);
        for (var bloc in blocs) {
          if (bloc['postImageUrl'] != null) {
            final storageRef = _storage.refFromURL(bloc['postImageUrl']);
            await storageRef.delete();
          }
        }
      }

      // Naviguer vers la page d'accueil
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const NavBar()),
        (route) => false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post supprimé avec succès'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la suppression: $e'),
        ),
      );
    }
  }
}
