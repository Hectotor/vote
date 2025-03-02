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

      // Extraire hashtags et mentions
      final hashtags = _extractHashtags(description);
      final mentions = _extractMentions(description);

      // Préparer les données des blocs
      final blocData = await _prepareBlocData(images, imageFilters, textControllers);

      // Créer la publication
      final postRef = await _firestore.collection('posts').add({
        'userId': user.uid,
        'description': description,
        'timestamp': FieldValue.serverTimestamp(),
        'hashtags': hashtags,
        'mentions': mentions,
        'blocs': blocData,
      });

      // Gérer les hashtags
      await _manageHashtags(hashtags, postRef.id);

      // Gérer les mentions
      await _manageMentions(mentions, postRef.id);

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
    List<TextEditingController> textControllers
  ) async {
    final List<Map<String, dynamic>> blocData = [];

    for (int i = 0; i < images.length; i++) {
      final bloc = <String, dynamic>{
        'index': i,
      };

      // Ajouter le texte si présent
      if (textControllers[i].text.isNotEmpty) {
        bloc['text'] = textControllers[i].text;
      }

      // Ajouter l'image si présente
      if (images[i] != null) {
        // Uploader l'image et obtenir l'URL
        final imageUrl = await _uploadImage(images[i]!);
        bloc['imageUrl'] = imageUrl;
        
        // Ajouter les informations du filtre
        bloc['imageFilter'] = {
          'red': imageFilters[i].red,
          'green': imageFilters[i].green,
          'blue': imageFilters[i].blue,
          'opacity': imageFilters[i].opacity,
        };
      }

      blocData.add(bloc);
    }

    return blocData;
  }

  // Méthode pour uploader une image et obtenir son URL
  Future<String> _uploadImage(XFile imageFile) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Utilisateur non connecté');
    }

    final fileName = '${user.uid}_${DateTime.now().millisecondsSinceEpoch}';
    final storageRef = _storage.ref().child('post_images/$fileName');
    
    final uploadTask = await storageRef.putFile(File(imageFile.path));
    final downloadUrl = await uploadTask.ref.getDownloadURL();
    
    return downloadUrl;
  }

  // Gestion des hashtags
  Future<void> _manageHashtags(List<String> hashtags, String postId) async {
    for (String hashtag in hashtags) {
      await _firestore.collection('hashtags').doc(hashtag).set({
        'name': '#$hashtag',
        'postIds': FieldValue.arrayUnion([postId]),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  // Gestion des mentions
  Future<void> _manageMentions(List<String> mentions, String postId) async {
    for (String mention in mentions) {
      await _firestore.collection('mentions').doc(mention).set({
        'name': '@$mention',
        'postIds': FieldValue.arrayUnion([postId]),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  // Ajouter un commentaire
  Future<void> addComment({
    required String postId, 
    required String text,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Utilisateur non connecté');
    }

    await _firestore.collection('comments').add({
      'postId': postId,
      'userId': user.uid,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
      'likes': [],
    });
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
