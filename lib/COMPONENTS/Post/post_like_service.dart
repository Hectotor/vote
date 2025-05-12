import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostLikeException implements Exception {
  final String message;
  PostLikeException(this.message);
}

class PostUnauthenticatedException implements Exception {}

class PostLikeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
      
      final likeDoc = await userLikesRef.get();
      
      if (likeDoc.exists) {
        // Remove like
        await userLikesRef.delete();
        
        // Update post like count
        await _firestore.collection('posts').doc(postId).update({
          'likeCount': FieldValue.increment(-1),
        });
      } else {
        // Add like
        await userLikesRef.set({
          'postId': postId,
          'likedAt': FieldValue.serverTimestamp(),
        });
        
        // Update post like count
        await _firestore.collection('posts').doc(postId).update({
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
