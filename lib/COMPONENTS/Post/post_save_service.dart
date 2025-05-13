import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/auth_redirect_service.dart';

class PostSaveService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  /// Méthode statique pour gérer la sauvegarde avec redirection vers la page de connexion si l'utilisateur n'est pas connecté
  /// Retourne true si l'action a été effectuée, false si l'utilisateur a été redirigé vers la page de connexion
  static Future<bool> saveWithAuthCheck(BuildContext context, String postId) async {
    // Utiliser le service d'authentification pour vérifier si l'utilisateur est connecté
    return await AuthRedirectService.executeIfAuthenticated(
      context, 
      () async {
        final service = PostSaveService();
        await service.toggleSavePost(postId);
        return true;
      }
    ) ?? false;
  }

  // Vérifier si un post est sauvegardé par l'utilisateur actuel
  Future<bool> isPostSaved(String postId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final doc = await _firestore
        .collection('savedPosts')
        .doc('${user.uid}_$postId')
        .get();

    return doc.exists;
  }

  // Sauvegarder ou supprimer un post des favoris
  Future<void> toggleSavePost(String postId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final globalSavedPostsRef = _firestore
        .collection('savedPosts')
        .doc('${user.uid}_$postId');

    final postRef = _firestore.collection('posts').doc(postId);

    final isSaved = await isPostSaved(postId);
    
    if (isSaved) {
      await globalSavedPostsRef.delete();
      await postRef.update({'saveCount': FieldValue.increment(-1)});
    } else {
      await globalSavedPostsRef.set({
        'userId': user.uid,
        'postId': postId,
        'savedAt': FieldValue.serverTimestamp(),
      });
      await postRef.update({'saveCount': FieldValue.increment(1)});
    }
  }
}
