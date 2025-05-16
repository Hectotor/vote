import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../SERVICES/auth_redirect_service.dart';

class PostLikeException implements Exception {
  final String message;
  PostLikeException(this.message);
}

class PostUnauthenticatedException implements Exception {
  const PostUnauthenticatedException();
}

class PostLikeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Ajout d'un verrou local pour empêcher les likes multiples rapides
  static final Map<String, bool> _likeInProgress = {};

  /// Méthode statique pour gérer le like avec redirection vers la page de connexion si l'utilisateur n'est pas connecté
  /// Retourne true si l'action a été effectuée, false si l'utilisateur a été redirigé vers la page de connexion ou si un like est déjà en cours
  static Future<bool> likeWithAuthCheck(BuildContext context, String postId) async {
    if (_likeInProgress[postId] == true) {
      // Un like est déjà en cours pour ce post, on ignore
      return false;
    }
    _likeInProgress[postId] = true;
    try {
      // Utiliser le service d'authentification pour vérifier si l'utilisateur est connecté
      return await AuthRedirectService.executeIfAuthenticated(
        context, 
        () async {
          try {
            final service = PostLikeService();
            await service.togglePostLike(context, postId);
            return true;
          } catch (e) {
            // Ignorer silencieusement l'erreur et retourner false
            return false;
          }
        }
      ) ?? false;
    } finally {
      _likeInProgress[postId] = false;
    }
  }

  Future<void> togglePostLike(BuildContext context, String postId) async {
    print('[PostLikeService] togglePostLike called for postId: $postId');
    final user = _auth.currentUser;
    if (user == null) {
      AuthRedirectService.redirectToLogin(context);
      throw PostUnauthenticatedException();
    }
    
    try {
      // Obtenir un token d'ID frais pour s'assurer que l'authentification est valide
      await user.getIdToken(true); // Rafraichit le token mais ne l'utilise pas directement
      print('[PostLikeService] Token d\'authentification rafraichi');
      
      // Référence au document du post pour mettre à jour le compteur
      final postRef = _firestore.collection('posts').doc(postId);
      
      // Vérifier si le post est déjà liké
      final likeQuery = await _firestore
          .collection('likes')
          .where('postId', isEqualTo: postId)
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();
      
      final bool isLiked = likeQuery.docs.isNotEmpty;
      
      // Utiliser une transaction pour garantir la cohérence
      await _firestore.runTransaction((transaction) async {
        if (isLiked) {
          // UNLIKE - Supprimer le document de like
          final likeDoc = likeQuery.docs.first;
          transaction.delete(likeDoc.reference);
          
          // Décrémenter le compteur de likes
          transaction.update(postRef, {
            'likesCount': FieldValue.increment(-1)
          });
          print('[PostLikeService] Post unliké par l\'utilisateur ${user.uid} (${user.email})');
        } else {
          // LIKE - Créer un nouveau document de like
          final likeRef = _firestore.collection('likes').doc();
          transaction.set(likeRef, {
            'postId': postId,
            'userId': user.uid,
            'createdAt': FieldValue.serverTimestamp()
          });
          
          // Incrémenter le compteur de likes
          transaction.update(postRef, {
            'likesCount': FieldValue.increment(1)
          });
          print('[PostLikeService] Post liké par l\'utilisateur ${user.uid} (${user.email})');
        }
      });
      
      return;
    } catch (e, stack) {
      print('[PostLikeService] Error toggling like: ${e.toString()}');
      print(stack);
      throw PostLikeException('Erreur lors du like: ${e.toString()}');
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
      print('[PostLikeService] Vérification du like pour postId: $postId, userId: ${user.uid}');
      
      // Vérifie si un document existe dans la collection likes
      final likeDoc = await _firestore
          .collection('likes')
          .where('postId', isEqualTo: postId)
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();
      
      final result = likeDoc.docs.isNotEmpty;
      print('[PostLikeService] Post liké: $result');
      return result;
    } catch (e) {
      print('[PostLikeService] Erreur lors de la vérification du like: $e');
      // Ne pas propager l'erreur, simplement retourner false
      return false;
    }
  }
}
