
import 'package:cloud_firestore/cloud_firestore.dart';

class ShowSuggestions {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Récupère les suggestions basées sur le dernier mot du texte
  /// Si le mot commence par #, recherche des hashtags
  /// Si le mot commence par @, recherche des mentions
  Future<List<String>> getSuggestions(String lastWord) async {
    if (lastWord.isEmpty) {
      return [];
    }

    if (lastWord.startsWith('#')) {
      final query = lastWord.substring(1).toLowerCase();
      if (query.isEmpty) {
        return [];
      }

      // Chercher dans Firebase
      final snapshot = await _firestore
          .collection('hashtags')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '${query}z')
          .limit(5)
          .get();

      // Ajouter le # devant chaque suggestion
      return snapshot.docs.map((doc) {
        final name = doc.data()['name'] as String;
        return name.startsWith('#') ? name : '#$name';
      }).toList();
    } else if (lastWord.startsWith('@')) {
      final query = lastWord.substring(1).toLowerCase();
      if (query.isEmpty) {
        return [];
      }

      // Chercher dans Firebase
      final snapshot = await _firestore
          .collection('mentions')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '${query}z')
          .limit(5)
          .get();

      // Ajouter le @ devant chaque suggestion
      return snapshot.docs.map((doc) {
        final name = doc.data()['name'] as String;
        return name.startsWith('@') ? name : '@$name';
      }).toList();
    }
    
    return [];
  }
  
  /// Extrait le dernier mot du texte avant la position du curseur
  String getLastWord(String text, int position) {
    if (position == 0) return '';
    
    final textBeforeCursor = text.substring(0, position);
    final words = textBeforeCursor.split(' ');
    return words.last;
  }
}
