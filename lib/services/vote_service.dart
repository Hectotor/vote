import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Solution ultra-simplifiée: incrémenter directement le compteur de votes
  Future<void> vote(String postId, String blocId, String userId) async {
    try {
      // Vérifier d'abord si l'utilisateur a déjà voté
      final userVoteDoc = await _firestore.collection('userVotes').doc('$userId-$postId').get();
      if (userVoteDoc.exists) {
        print('L\'utilisateur a déjà voté pour ce post');
        return;
      }
      
      // Convertir blocId en index numérique
      final index = int.tryParse(blocId) ?? 0;
      
      // Récupérer le document pour préserver sa structure
      final doc = await _firestore.collection('posts').doc(postId).get();
      if (!doc.exists) {
        print('Post non trouvé');
        return;
      }
      
      final data = doc.data();
      if (data == null) {
        print('Données du post vides');
        return;
      }
      
      // Récupérer les blocs
      final List<dynamic> blocs = List.from(data['blocs'] ?? []);
      if (index >= blocs.length) {
        print('Index de bloc invalide');
        return;
      }
      
      // Mettre à jour le compteur de votes du bloc et le tableau votes
      final Map<String, dynamic> bloc = Map<String, dynamic>.from(blocs[index]);
      
      // Initialiser le tableau votes s'il n'existe pas
      if (bloc['votes'] == null) {
        bloc['votes'] = [];
      } else if (bloc['votes'] is! List) {
        bloc['votes'] = [];
      }
      
      // S'assurer que l'utilisateur n'est pas déjà dans le tableau
      if (!bloc['votes'].contains(userId)) {
        bloc['votes'].add(userId);
      }
      
      // Mettre à jour le voteCount pour qu'il corresponde à la longueur du tableau votes
      bloc['voteCount'] = (bloc['votes'] as List).length;
      
      // Mettre à jour le bloc dans la liste
      blocs[index] = bloc;
      
      // Mettre à jour le document avec la structure préservée
      await _firestore.collection('posts').doc(postId).update({
        'blocs': blocs
      });
      
      // Marquer l'utilisateur comme ayant voté
      await _firestore.collection('userVotes').doc('$userId-$postId').set({
        'userId': userId,
        'postId': postId,
        'blocId': blocId, // Stocker aussi l'ID du bloc voté
        'timestamp': FieldValue.serverTimestamp()
      });
      
      print('Vote enregistré avec succès');
    } catch (e) {
      print('Erreur lors du vote: $e');
    }
  }

  // Vérifier si l'utilisateur a déjà voté en utilisant une collection séparée
  Future<bool> hasUserVoted(String postId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;
      
      final doc = await _firestore.collection('userVotes').doc('${user.uid}-$postId').get();
      return doc.exists;
    } catch (e) {
      print('Erreur lors de la vérification du vote: $e');
      return false;
    }
  }

  // Obtenir le nombre de votes pour un bloc spécifique
  Future<int> getVoteCount(String postId, String blocId) async {
    try {
      final index = int.tryParse(blocId) ?? 0;
      
      final doc = await _firestore.collection('posts').doc(postId).get();
      if (!doc.exists) return 0;
      
      final data = doc.data();
      if (data == null) return 0;
      
      final blocs = data['blocs'];
      if (blocs == null || !(blocs is List) || index >= blocs.length) return 0;
      
      final bloc = blocs[index];
      if (bloc == null || !(bloc is Map)) return 0;
      
      return (bloc['voteCount'] as num?)?.toInt() ?? 0;
    } catch (e) {
      print('Erreur lors du comptage des votes: $e');
      return 0;
    }
  }

  // Obtenir tous les compteurs de votes pour un post
  Future<Map<String, int>> getAllVoteCounts(String postId) async {
    try {
      final doc = await _firestore.collection('posts').doc(postId).get();
      if (!doc.exists) return {};
      
      final data = doc.data();
      if (data == null) return {};
      
      final blocs = data['blocs'];
      if (blocs == null || !(blocs is List)) return {};
      
      final Map<String, int> voteCounts = {};
      
      for (var i = 0; i < blocs.length; i++) {
        final bloc = blocs[i];
        if (bloc == null || !(bloc is Map)) {
          voteCounts[i.toString()] = 0;
          continue;
        }
        
        voteCounts[i.toString()] = (bloc['voteCount'] as num?)?.toInt() ?? 0;
      }
      
      return voteCounts;
    } catch (e) {
      print('Erreur lors de la récupération des votes: $e');
      return {};
    }
  }

  // Obtenir un Stream des votes en temps réel
  Stream<Map<String, int>> watchVotes(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return {};
      
      final data = doc.data();
      if (data == null) return {};
      
      final blocs = data['blocs'];
      if (blocs == null || !(blocs is List)) return {};
      
      final Map<String, int> voteCounts = {};
      
      for (var i = 0; i < blocs.length; i++) {
        final bloc = blocs[i];
        if (bloc == null || !(bloc is Map)) {
          voteCounts[i.toString()] = 0;
          continue;
        }
        
        voteCounts[i.toString()] = (bloc['voteCount'] as num?)?.toInt() ?? 0;
      }
      
      return voteCounts;
    });
  }
}
