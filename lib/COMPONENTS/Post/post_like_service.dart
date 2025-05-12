import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../SERVICES/auth_redirect_service.dart';

class PostLikeException implements Exception {
  final String message;
  PostLikeException(this.message);
}

class PostUnauthenticatedException implements Exception {}

class PostLikeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
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
      final userId = user.uid;
      final userLikesRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('likedPosts')
          .doc(postId);
      
      final postRef = _firestore.collection('posts').doc(postId);
      final postDoc = await postRef.get();
      
      if (!postDoc.exists) {
        throw PostLikeException('Post non trouvé');
      }
      
      final currentLikeCount = (postDoc.data()?['likeCount'] as int?) ?? 0;
      
      final likeDoc = await userLikesRef.get();
      
      if (likeDoc.exists) {
        // Remove like
        await userLikesRef.delete();
        
        // Update post like count (ne pas descendre en dessous de 0)
        final newLikeCount = currentLikeCount > 0 ? currentLikeCount - 1 : 0;
        await postRef.update({
          'likeCount': newLikeCount,
        });
      } else {
        // Add like
        await userLikesRef.set({
          'postId': postId,
          'likedAt': FieldValue.serverTimestamp(),
        });
        
        // Update post like count
        await postRef.update({
          'likeCount': FieldValue.increment(1),
        });
      }
    } catch (e) {
      throw PostLikeException('Erreur lors du like: $e');
    }
  }

  Future<bool> isPostLiked(String postId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final likeDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('likedPosts')
          .doc(postId)
          .get();
      
      return likeDoc.exists;
    } catch (e) {
      throw PostLikeException('Erreur lors de la vérification du like: $e');
    }
  }

  Future<int> getPostLikeCount(String postId) async {
    try {
      // Utilisation de collectionGroup pour compter les likes à travers tous les utilisateurs
      final likes = await _firestore
          .collectionGroup('likedPosts')
          .where('postId', isEqualTo: postId)
          .get();
      
      return likes.docs.length;
    } catch (e) {
      // En cas d'erreur, on peut essayer de récupérer le compteur depuis le post
      try {
        final postDoc = await _firestore.collection('posts').doc(postId).get();
        return (postDoc.data()?['likeCount'] as int?) ?? 0;
      } catch (e) {
        throw PostLikeException('Erreur lors de la récupération du compteur de likes: $e');
      }
    }
  }
}
