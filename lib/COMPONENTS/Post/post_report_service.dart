import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../SERVICES/auth_redirect_service.dart';

class PostReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  /// Méthode statique pour gérer le signalement avec redirection vers la page de connexion si l'utilisateur n'est pas connecté
  /// Retourne true si l'action a été effectuée, false si l'utilisateur a été redirigé vers la page de connexion
  static Future<bool> reportWithAuthCheck(BuildContext context, String postId) async {
    // Utiliser le service d'authentification pour vérifier si l'utilisateur est connecté
    return await AuthRedirectService.executeIfAuthenticated(
      context, 
      () async {
        final service = PostReportService();
        final success = await service.toggleReportPost(postId);
        
        // Afficher un message de confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Post signalé' : 'Signalement annulé',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: success ? Colors.red : Colors.green,
          ),
        );
        
        return success;
      }
    ) ?? false;
  }

  // Vérifier si l'utilisateur a déjà signalé ce post
  Future<bool> isPostReportedByUser(String postId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final doc = await _firestore
          .collection('reportedPosts')
          .doc('${user.uid}_$postId')
          .get();

      return doc.exists;
    } catch (e) {
      print('Erreur lors de la vérification du signalement: $e');
      return false;
    }
  }

  // Signaler ou annuler le signalement d'un post
  Future<bool> toggleReportPost(String postId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final globalReportRef = _firestore
          .collection('reportedPosts')
          .doc('${user.uid}_$postId');

      final isReported = await isPostReportedByUser(postId);
      
      if (isReported) {
        // Annuler le signalement
        await globalReportRef.delete();
        // Mettre à jour le compteur global des signalements
        await _updateReportCount(postId, -1);
      } else {
        // Signaler le post
        await globalReportRef.set({
          'userId': user.uid,
          'postId': postId,
          'reportedAt': FieldValue.serverTimestamp(),
        });
        await _updateReportCount(postId, 1);
      }
      
      return !isReported; // Retourne le nouvel état
    } catch (e) {
      print('Erreur lors du signalement: $e');
      return false;
    }
  }

  // Mettre à jour le compteur global des signalements pour un post
  Future<void> _updateReportCount(String postId, int increment) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'reportCount': FieldValue.increment(increment),
      });
    } catch (e) {
      print('Erreur lors de la mise à jour du compteur de signalements: $e');
    }
  }

  // Obtenir le nombre total de signalements pour un post
  Future<int> getReportCount(String postId) async {
    try {
      final doc = await _firestore.collection('posts').doc(postId).get();
      return (doc.data()?['reportCount'] as int?) ?? 0;
    } catch (e) {
      print('Erreur lors de la récupération du nombre de signalements: $e');
      return 0;
    }
  }
}
