import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        await voteService.vote(postId, int.parse(blocId));
        return true;
      }
    ) ?? false;
  }

  // Empêche l'utilisateur de voter plusieurs fois pour le même post
  Future<void> vote(String postId, int blocId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Utilisateur non connecté");
    final hasVoted = await hasUserVoted(postId);
    if (hasVoted) {
      throw Exception("Vous avez déjà voté pour ce post.");
    }
    // 1. Enregistrer le vote dans votesPosts
    await _firestore.collection('votesPosts').doc('${user.uid}_$postId').set({
      'userId': user.uid,
      'postId': postId,
      'blocId': blocId,
      'timestamp': FieldValue.serverTimestamp()
    });
    // 2. Mettre à jour le bloc correspondant dans posts
    final postRef = _firestore.collection('posts').doc(postId);
    final postSnap = await postRef.get();
    if (!postSnap.exists) return;
    final data = postSnap.data() as Map<String, dynamic>;
    List blocs = data['blocs'] as List;
    if (blocId < 0 || blocId >= blocs.length) return;
    Map bloc = Map<String, dynamic>.from(blocs[blocId]);
    // Mettre à jour voteCount et votes
    bloc['voteCount'] = (bloc['voteCount'] ?? 0) + 1;
    List votes = (bloc['votes'] ?? []).toList();
    if (!votes.contains(user.uid)) {
      votes.add(user.uid);
    }
    bloc['votes'] = votes;
    blocs[blocId] = bloc;
    await postRef.update({'blocs': blocs});
    // Calculer la somme totale des votes
    int totalVotesCount = 0;
    for (var b in blocs) {
      if (b is Map && b['voteCount'] != null) {
        totalVotesCount += (b['voteCount'] as int? ?? 0);
      }
    }
    await postRef.update({'totalVotesCount': totalVotesCount});
    print('Vote enregistré, compteur mis à jour et totalVotesCount actualisé dans posts');
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
