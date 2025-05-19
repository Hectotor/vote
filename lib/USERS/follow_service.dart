import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FollowService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> followUser(String userIdToFollow) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    // Ajouter l'utilisateur à suivre dans la liste des suivis de l'utilisateur actuel
    await _firestore.collection('users').doc(currentUser.uid).update({
      'following': FieldValue.arrayUnion([userIdToFollow])
    });

    // Ajouter l'utilisateur actuel dans la liste des followers de l'utilisateur à suivre
    await _firestore.collection('users').doc(userIdToFollow).update({
      'followers': FieldValue.arrayUnion([currentUser.uid])
    });
  }

  Future<void> unfollowUser(String userIdToUnfollow) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    // Supprimer l'utilisateur à ne plus suivre de la liste des suivis de l'utilisateur actuel
    await _firestore.collection('users').doc(currentUser.uid).update({
      'following': FieldValue.arrayRemove([userIdToUnfollow])
    });

    // Supprimer l'utilisateur actuel de la liste des followers de l'utilisateur à ne plus suivre
    await _firestore.collection('users').doc(userIdToUnfollow).update({
      'followers': FieldValue.arrayRemove([currentUser.uid])
    });
  }

  Future<bool> isFollowing(String userId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return false;
    }

    final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
    return userDoc.data()?['following']?.contains(userId) ?? false;
  }
}
