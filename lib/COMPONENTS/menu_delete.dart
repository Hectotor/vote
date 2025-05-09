import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:toplyke/INSCRIPTION/connexion_screen.dart';


class MenuDelete {
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

      // Supprimer les images du post
      final postRef = _firestore.collection('posts').doc(postId);
      final postDoc = await postRef.get();
      if (postDoc.exists) {
        final data = postDoc.data() as Map<String, dynamic>;
        final blocs = data['blocs'] as List<dynamic>;

        for (var bloc in blocs) {
          if (bloc['postImageUrl'] != null) {
            final imageUrl = bloc['postImageUrl'] as String;
            try {
              final ref = _storage.refFromURL(imageUrl);
              await ref.delete();
            } catch (e) {
              print('Erreur lors de la suppression de l\'image: $e');
            }
          }
        }

        // Supprimer le post
        await postRef.delete();

        // Supprimer les commentaires associés
        await _firestore
            .collection('comments')
            .where('postId', isEqualTo: postId)
            .get()
            .then((snapshot) {
          for (var doc in snapshot.docs) {
            doc.reference.delete();
          }
        });

        // Supprimer les likes associés
        await _firestore
            .collection('likes')
            .where('postId', isEqualTo: postId)
            .get()
            .then((snapshot) {
          for (var doc in snapshot.docs) {
            doc.reference.delete();
          }
        });

        // Supprimer les hashtags associés
        await _firestore
            .collection('hashtags')
            .where('postId', isEqualTo: postId)
            .get()
            .then((snapshot) {
          for (var doc in snapshot.docs) {
            doc.reference.delete();
          }
        });

        // Supprimer les mentions associées
        await _firestore
            .collection('mentions')
            .where('postId', isEqualTo: postId)
            .get()
            .then((snapshot) {
          for (var doc in snapshot.docs) {
            doc.reference.delete();
          }
        });

        // Supprimer les notifications associées
        await _firestore
            .collection('notifications')
            .where('postId', isEqualTo: postId)
            .get()
            .then((snapshot) {
          for (var doc in snapshot.docs) {
            doc.reference.delete();
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post supprimé avec succès'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la suppression: $e'),
        ),
      );
    }
  }
}
