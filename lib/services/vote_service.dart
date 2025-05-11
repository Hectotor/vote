import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Vérifie si l'utilisateur a déjà voté pour un post
  Stream<bool> hasUserVoted(String postId) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(false);

    return _firestore
        .collection('posts')
        .doc(postId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return false;
          final votes = List<Map<String, dynamic>>.from(doc.data()?['votes'] ?? []);
          return votes.any((vote) => vote['userId'] == user.uid);
        });
  }

  // Enregistre un vote pour un bloc spécifique
  Future<void> vote(String postId, String blocId, String userId) async {
    final postRef = _firestore.collection('posts').doc(postId);
    
    // Utilisation d'une transaction pour assurer la cohérence des données
    await _firestore.runTransaction((transaction) async {
      // 1. Récupère le document ou crée-le s'il n'existe pas
      final postDoc = await transaction.get(postRef);
      
      // Initialise les champs s'ils n'existent pas
      if (!postDoc.exists) {
        throw Exception('Le post n\'existe pas');
      }
      
      // Récupère les votes existants ou initialise un tableau vide
      final votes = List<Map<String, dynamic>>.from(postDoc.data()?['votes'] ?? []);
      
      // Vérifie si l'utilisateur a déjà voté pour ce post
      if (votes.any((vote) => vote['userId'] == userId)) {
        throw Exception('Vous avez déjà voté pour ce post');
      }
      
      // 2. Ajoute le nouveau vote
      votes.add({
        'userId': userId,
        'postId': postId,
        'blocId': blocId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // 3. Met à jour le compteur de votes pour le bloc
      final blocs = List<Map<String, dynamic>>.from(postDoc.data()?['blocs'] ?? []);
      final blocIndex = blocs.indexWhere((bloc) => bloc['id'] == blocId);
      
      if (blocIndex != -1) {
        final currentVotes = (blocs[blocIndex]['votes'] as int?) ?? 0;
        blocs[blocIndex] = {
          ...blocs[blocIndex],
          'votes': currentVotes + 1,
        };
      }
      
      // 4. Met à jour le document avec les nouvelles données
      transaction.update(postRef, {
        'votes': votes,
        'blocs': blocs,
      });
    });
  }

  // Récupère le nombre de votes pour un bloc
  Stream<int> getVoteCount(String postId, String blocId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return 0;
          final blocs = List<Map<String, dynamic>>.from(doc.data()?['blocs'] ?? []);
          final bloc = blocs.firstWhere(
            (bloc) => bloc['id'] == blocId,
            orElse: () => {'votes': 0},
          );
          return (bloc['votes'] as int?) ?? 0;
        });
  }
}
