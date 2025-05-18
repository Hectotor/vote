import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchHistoryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Nombre maximum d'entrées d'historique à conserver
  static const int _maxHistoryEntries = 10;

  // Enregistre une recherche dans l'historique
  static Future<void> saveSearch(String query, String type, String itemId, String itemName) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      // L'utilisateur n'est pas connecté, ne pas enregistrer l'historique
      return;
    }

    final String userId = currentUser.uid;
    final Timestamp now = Timestamp.now();

    // Créer l'entrée d'historique
    final Map<String, dynamic> historyEntry = {
      'query': query,
      'type': type, // 'profile', 'hashtag', ou 'mention'
      'itemId': itemId,
      'itemName': itemName,
      'timestamp': now,
    };

    try {
      // Référence à la collection d'historique de l'utilisateur
      final historyRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('search_history');

      // Vérifier si cette recherche existe déjà (pour éviter les doublons)
      final existingQuery = await historyRef
          .where('type', isEqualTo: type)
          .where('itemId', isEqualTo: itemId)
          .get();

      if (existingQuery.docs.isNotEmpty) {
        // Mettre à jour l'entrée existante avec le nouveau timestamp
        await historyRef.doc(existingQuery.docs.first.id).update({
          'timestamp': now,
          'query': query, // Mettre à jour la requête au cas où elle aurait changé
        });
      } else {
        // Ajouter une nouvelle entrée
        await historyRef.add(historyEntry);

        // Récupérer toutes les entrées, triées par date
        final allEntries = await historyRef
            .orderBy('timestamp', descending: true)
            .get();

        // Si le nombre d'entrées dépasse la limite, supprimer les plus anciennes
        if (allEntries.docs.length > _maxHistoryEntries) {
          // Calculer combien d'entrées doivent être supprimées
          final entriesToDelete = allEntries.docs.sublist(_maxHistoryEntries);

          // Supprimer les entrées les plus anciennes
          for (final doc in entriesToDelete) {
            await historyRef.doc(doc.id).delete();
          }
        }
      }
    } catch (e) {
      print('Erreur lors de l\'enregistrement de l\'historique de recherche: $e');
    }
  }

  // Récupère l'historique de recherche de l'utilisateur
  static Stream<QuerySnapshot> getSearchHistory() {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      // Retourner un stream vide si l'utilisateur n'est pas connecté
      return Stream.empty();
    }

    final String userId = currentUser.uid;

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('search_history')
        .orderBy('timestamp', descending: true)
        .limit(_maxHistoryEntries)
        .snapshots();
  }

  // Supprime une entrée spécifique de l'historique
  static Future<void> deleteHistoryEntry(String entryId) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final String userId = currentUser.uid;

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('search_history')
          .doc(entryId)
          .delete();
    } catch (e) {
      print('Erreur lors de la suppression de l\'entrée d\'historique: $e');
    }
  }

  // Efface tout l'historique de recherche
  static Future<void> clearSearchHistory() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final String userId = currentUser.uid;

    try {
      final historySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('search_history')
          .get();

      final batch = _firestore.batch();
      for (final doc in historySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      print('Erreur lors de la suppression de l\'historique de recherche: $e');
    }
  }
}
