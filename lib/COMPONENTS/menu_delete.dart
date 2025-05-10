import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toplyke/INSCRIPTION/connexion_screen.dart';
import 'package:toplyke/navBar.dart';

class MenuDelete {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> deletePost(String postId, String userId, BuildContext context) async {
    // Capturer le navigateur global pour l'utiliser plus tard
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        navigator.push(
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
        debugPrint('Suppression annulée par l\'utilisateur');
        return;
      }

      debugPrint('Début de la suppression du post $postId');
      
      // Supprimer le post
      await _firestore.collection('posts').doc(postId).delete();
      
      // Afficher le message de succès
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Post supprimé avec succès'),
        ),
      );

      // Rediriger vers la NavBar
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const NavBar()),
        (route) => false,
      );
    } catch (e) {
      debugPrint('Erreur lors de la suppression du post: $e');
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isDelete ? const Color(0xFFE53E3E) : const Color(0xFF2D3748),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDelete ? Colors.white : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
