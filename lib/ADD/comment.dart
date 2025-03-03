import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommentService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CommentService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : 
    _firestore = firestore ?? FirebaseFirestore.instance,
    _auth = auth ?? FirebaseAuth.instance;

  // Ajouter un commentaire
  Future<void> addComment({
    required String postId, 
    required String text,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Utilisateur non connecté');
    }

    await _firestore.collection('comments').add({
      'postId': postId,
      'userId': user.uid,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
      'likes': [],
    });
  }
}
