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

      // Afficher la boîte de dialogue de confirmation
      final shouldDelete = await showDialog<bool>(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF151019),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 1,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Supprimer ce post ?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Ce post sera définitivement supprimé.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                _buildModernTile(
                  title: 'Supprimer',
                  onTap: () => Navigator.pop(context, true),
                  isDelete: true,
                ),
                const SizedBox(height: 16),
                _buildModernTile(
                  title: 'Annuler',
                  onTap: () => Navigator.pop(context, false),
                ),
              ],
            ),
          ),
        ),
      );

      // Si l'utilisateur a annulé ou a fermé la boîte de dialogue
      if (shouldDelete != true) {
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

  Widget _buildModernTile({
    required String title,
    required VoidCallback onTap,
    bool isDelete = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDelete ? Colors.red : const Color(0xFF151019),
          borderRadius: BorderRadius.circular(20),
          border: isDelete
              ? Border.all(
                  color: Colors.red,
                  width: 1,
                )
              : null,
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isDelete ? Colors.white : Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
