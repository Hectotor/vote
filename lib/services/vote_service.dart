import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Vérifie si l'utilisateur a déjà voté pour un post
  Future<bool> hasUserVoted(String postId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final doc = await _firestore
        .collection('votes')
        .doc('${postId}_${user.uid}')
        .get();

    return doc.exists;
  }

  // Enregistre le vote d'un utilisateur
  Future<void> vote(String postId, String blocId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    final voteId = '${postId}_${user.uid}';
    
    // Vérifie si l'utilisateur a déjà voté
    final hasVoted = await hasUserVoted(postId);
    if (hasVoted) throw Exception('Vous avez déjà voté');

    // Utilisation d'un batch pour les opérations atomiques
    final batch = _firestore.batch();
    
    // 1. Enregistre le vote
    final voteRef = _firestore.collection('votes').doc(voteId);
    batch.set(voteRef, {
      'userId': user.uid,
      'postId': postId,
      'blocId': blocId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 2. Met à jour le compteur de votes pour le bloc
    final blocRef = _firestore
        .collection('posts')
        .doc(postId)
        .collection('blocs')
        .doc(blocId);
        
    batch.update(blocRef, {
      'votes': FieldValue.increment(1),
    });

    // Exécute le batch
    await batch.commit();
  }


  // Récupère le nombre de votes pour un bloc
  Stream<int> getVoteCount(String postId, String blocId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('blocs')
        .doc(blocId)
        .snapshots()
        .map((doc) => (doc.data()?['votes'] as int?) ?? 0);
  }

  // Vérifie si l'utilisateur a voté pour un post
  Stream<bool> getUserVoteStatus(String postId) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(false);

    return _firestore
        .collection('votes')
        .where('userId', isEqualTo: user.uid)
        .where('postId', isEqualTo: postId)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty);
  }
}
