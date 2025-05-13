import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../SERVICES/auth_redirect_service.dart';

class PostLikeException implements Exception {
  final String message;
  PostLikeException(this.message);
}

class PostUnauthenticatedException implements Exception {}

class PostLikeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  
  /// Méthode statique pour gérer le like avec redirection vers la page de connexion si l'utilisateur n'est pas connecté
  /// Retourne true si l'action a été effectuée, false si l'utilisateur a été redirigé vers la page de connexion
  static Future<bool> likeWithAuthCheck(BuildContext context, String postId) async {
    // Utiliser le service d'authentification pour vérifier si l'utilisateur est connecté
    return await AuthRedirectService.executeIfAuthenticated(
      context, 
      () async {
        try {
          final service = PostLikeService();
          await service.togglePostLike(postId);
          return true;
        } catch (e) {
          // Ignorer silencieusement l'erreur et retourner false
          return false;
        }
      }
    ) ?? false;
  }

  Future<void> togglePostLike(String postId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw PostUnauthenticatedException();
    }
    try {
      final callable = _functions.httpsCallable('togglePostLike');
      await callable.call({'postId': postId});
    } catch (e) {
      throw PostLikeException('Erreur lors du like: $e');
    }
  }

  Future<int> getPostLikeCount(String postId) async {
    try {
      final postDoc = await _firestore.collection('posts').doc(postId).get();
      return (postDoc.data()?['likesCount'] as int?) ?? 0;
    } catch (e) {
      throw PostLikeException('Erreur lors de la récupération du compteur de likes: $e');
    }
  }

  Future<bool> isPostLiked(String postId) async {
    final user = _auth.currentUser;
    if (user == null) return false;
    try {
      final likeDoc = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('likedPosts')
          .doc(user.uid)
          .get();
      return likeDoc.exists;
    } catch (e) {
      throw PostLikeException('Erreur lors de la vérification du like: $e');
    }
  }
}
