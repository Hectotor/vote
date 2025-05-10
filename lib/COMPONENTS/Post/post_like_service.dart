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
    if (_auth.currentUser == null) {
      throw PostUnauthenticatedException();
    }

    try {
      final userId = _auth.currentUser!.uid;
      final likeRef = _firestore.collection('likes').doc('$postId-$userId');
      final likeDoc = await likeRef.get();
      
      if (likeDoc.exists) {
        // Remove like
        await likeRef.delete();
        
        // Update post like count
        final postRef = _firestore.collection('posts').doc(postId);
        await postRef.update({
          'likeCount': FieldValue.increment(-1),
        });
      } else {
        // Add like
        await likeRef.set({
          'postId': postId,
          'userId': userId,
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        // Update post like count
        final postRef = _firestore.collection('posts').doc(postId);
        await postRef.update({
          'likeCount': FieldValue.increment(1),
        });
      }
    } catch (e) {
      throw PostLikeException('Erreur lors du like: $e');
    }
  }

  Future<bool> isPostLiked(String postId) async {
    if (_auth.currentUser == null) return false;

    try {
      final userId = _auth.currentUser!.uid;
      final likeRef = _firestore.collection('likes').doc('$postId-$userId');
      final likeDoc = await likeRef.get();
      
      return likeDoc.exists;
    } catch (e) {
      throw PostLikeException('Erreur lors de la vérification du like: $e');
    }
  }

  Future<int> getPostLikeCount(String postId) async {
    try {
      final likes = await _firestore
          .collection('likes')
          .where('postId', isEqualTo: postId)
          .get();
      
      return likes.docs.length;
    } catch (e) {
      throw PostLikeException('Erreur lors de la récupération du compteur de likes: $e');
    }
  }
}
