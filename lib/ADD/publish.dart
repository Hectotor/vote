import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/material.dart' show TextEditingController;

class PublishService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Extraire les hashtags du texte
  List<String> _extractHashtags(String text) {
    final hashtags = RegExp(r'#\w+').allMatches(text).map((m) => m.group(0)!.substring(1)).toList();
    return hashtags;
  }

  // Extraire les mentions du texte
  List<String> _extractMentions(String text) {
    final mentions = RegExp(r'@\w+').allMatches(text).map((m) => m.group(0)!.substring(1)).toList();
    return mentions;
  }

  // Méthode publique pour extraire les mentions
  List<String> extractMentions(String text) {
    return _extractMentions(text);
  }

  // Méthode pour publier du contenu
  Future<bool> publishContent({
    required String description,
    required List<XFile?> images,
    required List<Color> imageFilters,
    required List<TextEditingController> textControllers,
    BuildContext? context,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Obtenir les données de l'utilisateur pour le pseudo
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data() as Map<String, dynamic>;
      final pseudo = userData['pseudo'] ?? '';

      // Extraire hashtags et mentions
      final extractedHashtags = _extractHashtags(description);
      final extractedMentions = _extractMentions(description);

      // Préparer les données des blocs avec l'ID du post
      final blocData = await _prepareBlocData(images, imageFilters, textControllers, null);

      // Créer la publication avec la nouvelle structure
      final postRef = await _firestore.collection('posts').add({
        'userId': user.uid,
        'pseudo': pseudo,
        'text': description,
        'hashtags': extractedHashtags,
        'mentions': extractedMentions,
        'blocs': blocData,
        'blocLayout': _generateBlocLayout(blocData.length),  // Disposition des blocs
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Mettre à jour le document avec son propre ID (pour faciliter les références)
      await postRef.update({'postId': postRef.id});

      // Gérer les hashtags et mentions dans une transaction
      await _firestore.runTransaction((transaction) async {
        // Gérer les hashtags
        for (String hashtag in extractedHashtags) {
          final hashtagDoc = _firestore.collection('hashtags').doc(hashtag);
          transaction.set(hashtagDoc, {
            'name': '#$hashtag',
            'postIds': FieldValue.arrayUnion([postRef.id]),
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }

        // Gérer les mentions
        for (String mention in extractedMentions) {
          final mentionDoc = _firestore.collection('mentions').doc(mention);
          transaction.set(mentionDoc, {
            'name': '@$mention',
            'postIds': FieldValue.arrayUnion([postRef.id]),
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      });

      return true;
    } catch (e) {
      _handlePublishError(context, e);
      return false;
    }
  }

  // Préparer les données des blocs avec upload des images
  Future<List<Map<String, dynamic>>> _prepareBlocData(
    List<XFile?> images, 
    List<Color> imageFilters, 
    List<TextEditingController> textControllers,
    String? postId
  ) async {
    final List<Map<String, dynamic>> blocData = [];

    for (int i = 0; i < images.length; i++) {
      final bloc = <String, dynamic>{
        'index': i,
        'position': i,  // Position initiale dans la grille
      };

      // Ajouter le texte si présent
      if (textControllers[i].text.isNotEmpty) {
        bloc['text'] = textControllers[i].text;
      }

      // Ajouter l'image si présente
      if (images[i] != null) {
        // Uploader l'image et obtenir l'URL
        final postImageUrl = await _uploadImage(images[i]!, postId ?? '');
        bloc['postImageUrl'] = postImageUrl;
        
        // Ajouter les informations du filtre de manière plus simple
        bloc['filterColor'] = imageFilters[i].value.toString();
      }

      blocData.add(bloc);
    }

    return blocData;
  }

  // Méthode pour uploader une image et obtenir son URL
  Future<String> _uploadImage(XFile imageFile, String postId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Utilisateur non connecté');
    }

    final fileName = 'postImageUrl_${DateTime.now().millisecondsSinceEpoch}';
    final storageRef = _storage.ref().child('users/${user.uid}/posts/$postId/$fileName');
    
    final uploadTask = await storageRef.putFile(File(imageFile.path));
    final downloadUrl = await uploadTask.ref.getDownloadURL();
    
    return downloadUrl;
  }

  // Générer la disposition des blocs
  Map<String, dynamic> _generateBlocLayout(int blocCount) {
    // Vous pouvez implémenter différentes mises en page selon le nombre de blocs
    // Cette implémentation simple utilise une grille
    return {
      'type': 'grid',
      'columns': 2,
      'spacing': 4.0,
    };
  }
  
  // Valider la présence d'images dans les blocs 1 et 2
  bool canPublish({
    required List<XFile?> images,
  }) {
    // Compter le nombre d'images non nulles dans les 2 premiers blocs
    final validImages = images.take(2).where((image) => image != null).toList();
    
    print('Validation des images - Nombre total : ${images.length}');
    print('Images non nulles dans les 2 premiers blocs : $validImages');
    
    // Autoriser la publication si au moins 2 images sont présentes
    return validImages.length >= 2;
  }

  // Gestion des erreurs de publication
  void _handlePublishError(BuildContext? context, dynamic error) {
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la publication: ${error.toString()}')),
      );
    }
  }
}
