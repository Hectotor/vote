import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LikeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> toggleLike(String commentId) async {
    if (_auth.currentUser == null) {
      throw UnauthenticatedException();
    }

    try {
      final commentRef = _firestore.collection('comments').doc(commentId);
      final commentDoc = await commentRef.get();
      
      if (!commentDoc.exists) return;

      final likes = (commentDoc.data()?['likes'] as List<dynamic>?)?.cast<String>() ?? [];
      final userId = _auth.currentUser!.uid;

      if (likes.contains(userId)) {
        // Remove like
        await commentRef.update({
          'likes': FieldValue.arrayRemove([userId]),
          'likeCount': FieldValue.increment(-1),
        });
      } else {
        // Add like
        await commentRef.update({
          'likes': FieldValue.arrayUnion([userId]),
          'likeCount': FieldValue.increment(1),
        });
      }
    } catch (e) {
      throw LikeException('Erreur lors du like: $e');
    }
  }
}

class UnauthenticatedException implements Exception {}

class LikeException implements Exception {
  final String message;
  LikeException(this.message);
}
