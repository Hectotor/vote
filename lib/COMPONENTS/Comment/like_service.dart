import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../SERVICES/auth_redirect_service.dart';

class LikeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  /// Méthode statique pour gérer le like avec redirection vers la page de connexion si l'utilisateur n'est pas connecté
  /// Retourne true si l'action a été effectuée, false si l'utilisateur a été redirigé vers la page de connexion
  static Future<bool> likeWithAuthCheck(BuildContext context, String commentId, String commentAuthorId) async {
    // Utiliser le service d'authentification pour vérifier si l'utilisateur est connecté
    return await AuthRedirectService.executeIfAuthenticated(
      context, 
      () async {
        final service = LikeService();
        await service.toggleLike(commentId, commentAuthorId);
        return true;
      }
    ) ?? false;
  }

  /// Ajoute ou supprime un like sur un commentaire
  /// 
  /// Les commentaires sont stockés dans 'users/{userId}/commentsPosts'
  /// Les likes sont stockés dans 'users/{userId}/likedComments'
  Future<void> toggleLike(String commentId, String commentAuthorId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw UnauthenticatedException();
    }

    try {
      // Vérifier que le commentaire existe dans la collection de l'auteur
      final commentRef = _firestore
          .collection('users')
          .doc(commentAuthorId)
          .collection('commentsPosts')
          .doc(commentId);
          
      final commentDoc = await commentRef.get();
      
      if (!commentDoc.exists) {
        throw Exception('Commentaire non trouvé');
      }

      // Référence au like de l'utilisateur
      final userLikeRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('likedComments')
          .doc(commentId);

      final userLikeDoc = await userLikeRef.get();
      
      if (userLikeDoc.exists) {
        // Retirer le like
        await userLikeRef.delete();
        await commentRef.update({
          'likeCount': FieldValue.increment(-1),
        });
      } else {
        // Ajouter le like
        await userLikeRef.set({
          'commentId': commentId,
          'commentAuthorId': commentAuthorId,
          'likedAt': FieldValue.serverTimestamp(),
        });
        await commentRef.update({
          'likeCount': FieldValue.increment(1),
        });
      }
    } catch (e) {
      print('Erreur lors du like du commentaire: $e');
      rethrow;
    }
  }

  /// Vérifie si l'utilisateur actuel a aimé un commentaire spécifique
  Future<bool> hasUserLiked(String commentId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final likeDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('likedComments')
          .doc(commentId)
          .get();

      return likeDoc.exists;
    } catch (e) {
      print('Erreur lors de la vérification du like: $e');
      return false;
    }
  }

  /// Récupère le nombre de likes d'un commentaire
  Future<int> getLikeCount(String commentId, String commentAuthorId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(commentAuthorId)
          .collection('commentsPosts')
          .doc(commentId)
          .get();
          
      return (doc.data()?['likeCount'] as int?) ?? 0;
    } catch (e) {
      print('Erreur lors de la récupération du nombre de likes: $e');
      return 0;
    }
  }
}

class UnauthenticatedException implements Exception {
  final String message;
  UnauthenticatedException([this.message = 'Utilisateur non authentifié']);
  
  @override
  String toString() => 'UnauthenticatedException: $message';
}
