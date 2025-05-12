import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostSaveService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Vérifier si un post est sauvegardé par l'utilisateur actuel
  Future<bool> isPostSaved(String postId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('savedPosts')
        .doc(postId)
        .get();

    return doc.exists;
  }

  // Sauvegarder ou supprimer un post des favoris
  Future<void> toggleSavePost(String postId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final savedPostsRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('savedPosts')
        .doc(postId);

    final isSaved = await isPostSaved(postId);
    
    if (isSaved) {
      await savedPostsRef.delete();
    } else {
      await savedPostsRef.set({
        'savedAt': FieldValue.serverTimestamp(),
        'postId': postId,
      });
    }
  }
}
