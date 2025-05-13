import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../SERVICES/auth_redirect_service.dart';

class VoteService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  /// Méthode statique pour gérer le vote avec redirection vers la page de connexion si l'utilisateur n'est pas connecté
  /// Retourne true si l'action a été effectuée, false si l'utilisateur a été redirigé vers la page de connexion
  static Future<bool> voteWithAuthCheck(BuildContext context, String postId, String blocId) async {
    // Utiliser le service d'authentification pour vérifier si l'utilisateur est connecté
    return await AuthRedirectService.executeIfAuthenticated(
      context, 
      () async {
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId == null) return false;
        
        // Vérifier si l'utilisateur a déjà voté
        final voteService = VoteService();
        final hasVoted = await voteService.hasUserVoted(postId);
        
        if (hasVoted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vous avez déjà voté pour ce post'))
          );
          return false;
        }
        
        // Enregistrer le vote
        await voteService.vote(postId, blocId, userId);
        return true;
      }
    ) ?? false;
  }

  // Solution ultra-simplifiée: incrémenter directement le compteur de votes
  Future<void> vote(String postId, String blocId, String userId) async {
    try {
      // Vérifier d'abord si l'utilisateur a déjà voté
      final globalVoteRef = _firestore
          .collection('votesPosts')
          .doc('${userId}_$postId');
      
      final globalVoteDoc = await globalVoteRef.get();
      if (globalVoteDoc.exists) {
        print("L'utilisateur a déjà voté pour ce post");
        return;
      }
      
      // Convertir blocId en index numérique
      final index = int.tryParse(blocId) ?? 0;
      
      // Récupérer le document pour préserver sa structure
      final postRef = _firestore.collection('posts').doc(postId);
      final postDoc = await postRef.get();
      if (!postDoc.exists) {
        print('Le post n\'existe pas');
        return;
      }
      final data = postDoc.data();
      if (data == null) return;
      final blocs = List<Map<String, dynamic>>.from(data['blocs'] ?? []);
      if (index >= blocs.length) return;
      final bloc = Map<String, dynamic>.from(blocs[index]);
      bloc['voteCount'] = (bloc['voteCount'] ?? 0) + 1;
      blocs[index] = bloc;
      // Calculer le voteCount total pour le post
      int totalVoteCount = 0;
      for (final b in blocs) {
        totalVoteCount += (b['voteCount'] ?? 0) as int;
      }
      await postRef.update({
        'blocs': blocs,
        'voteCount': totalVoteCount,
      });
      // Marquer l'utilisateur comme ayant voté dans votesPosts
      await globalVoteRef.set({
        'userId': userId,
        'postId': postId,
        'blocId': blocId,
        'timestamp': FieldValue.serverTimestamp()
      });
      print('Vote enregistré avec succès');
    } catch (e) {
      print('Erreur lors du vote: $e');
    }
  }

  // Vérifier si l'utilisateur a déjà voté
  Future<bool> hasUserVoted(String postId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;
      final doc = await _firestore
          .collection('votesPosts')
          .doc('${user.uid}_$postId')
          .get();
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

  // Récupérer le bloc sur lequel l'utilisateur a voté
  Future<String?> getUserVoteBlocId(String postId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;
      final doc = await _firestore
          .collection('votesPosts')
          .doc('${user.uid}_$postId')
          .get();
      if (!doc.exists) return null;
      return doc.data()?['blocId']?.toString();
    } catch (e) {
      print('Erreur lors de la récupération du vote utilisateur: $e');
      return null;
    }
  }
}
