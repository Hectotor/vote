import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/material.dart' show TextEditingController;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

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

      // Créer la publication avec la nouvelle structure
      final postRef = await _firestore.collection('posts').add({
        'userId': user.uid,
        'pseudo': pseudo,
        'text': description,
        'hashtags': extractedHashtags,
        'mentions': extractedMentions,
        'blocs': [],
        'blocLayout': _generateBlocLayout(0),  // Disposition des blocs
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Mettre à jour le document avec son propre ID (pour faciliter les références)
      await postRef.update({'postId': postRef.id});

      // Préparer les données des blocs avec l'ID du post
      final blocData = await _prepareBlocData(images, imageFilters, textControllers, postRef.id);

      // Filtrer les blocs pour ne garder que ceux qui ont une image
      final blocsWithImages = blocData.where((bloc) => bloc['postImageUrl'] != null).toList();

      // Mettre à jour le document avec les blocs qui ont des images
      await postRef.update({
        'blocs': blocsWithImages,
        'blocLayout': _generateBlocLayout(blocsWithImages.length)  // Mettre à jour la disposition
      });

      // Gérer les hashtags et mentions dans une transaction
      await _firestore.runTransaction((transaction) async {
        // Gérer les hashtags
        for (String hashtag in extractedHashtags) {
          final hashtagDoc = _firestore.collection('hashtags').doc(hashtag);
          transaction.set(hashtagDoc, {
            'name': '#$hashtag',
            'postIds': FieldValue.arrayUnion([postRef.id]),
          }, SetOptions(merge: true));
        }

        // Gérer les mentions
        for (String mention in extractedMentions) {
          final mentionDoc = _firestore.collection('mentions').doc(mention);
          transaction.set(mentionDoc, {
            'name': '@$mention',
            'postIds': FieldValue.arrayUnion([postRef.id]),
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
    print('Starting to prepare bloc data for ${images.length} images');

    for (int i = 0; i < images.length; i++) {
      final bloc = <String, dynamic>{};

      if (textControllers[i].text.isNotEmpty) {
        bloc['text'] = textControllers[i].text;
      }

      if (images[i] != null) {
        try {
          print('Starting upload for image $i');
          final imageUrl = await _uploadImage(images[i]!, postId ?? '');
          bloc['postImageUrl'] = imageUrl;
          bloc['filterColor'] = imageFilters[i].value.toString();
          print('Successfully uploaded image $i: $imageUrl');
        } catch (e) {
          print('Error uploading image $i: $e');
          // Si une image échoue, on annule tout
          blocData.clear();
          throw Exception('Échec de l\'upload d\'une image: $e');
        }
      }

      blocData.add(bloc);
    }

    print('Successfully prepared bloc data with ${blocData.length} blocs');
    return blocData;
  }

  // Méthode pour compresser une image
  Future<File> _compressImage(File file) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = path.join(dir.path, '${path.basename(file.path)}_compressed.jpg');
      
      print('Compressing image: ${file.path}');
      print('Original size: ${await file.length()} bytes');
      
      final result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        targetPath,
        quality: 70,
        format: CompressFormat.jpeg,
      );
      
      if (result == null) {
        print('Compression failed, using original file');
        return file;  // Retourne le fichier original en cas d'échec de compression
      }
      
      print('Compressed size: ${await result.length()} bytes');
      return File(result.path);  // Conversion explicite en File
    } catch (e) {
      print('Error during compression: $e');
      return file;  // Retourne le fichier original en cas d'erreur
    }
  }

  // Méthode pour uploader une image
  Future<String> _uploadImage(XFile imageFile, String? postId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Utilisateur non connecté');
    }

    if (postId == null) {
      throw Exception('Post ID is required for image upload');
    }

    print('User ID: ${user.uid}');
    print('Post ID: $postId');

    final fileName = 'postImageUrl_${DateTime.now().millisecondsSinceEpoch}';
    final storageRef = _storage.ref().child('users/${user.uid}/posts/$postId/${fileName}');
    
    print('Storage path: ${storageRef.fullPath}');
    
    // Compresser l'image avant l'upload
    final compressedFile = await _compressImage(File(imageFile.path));
    
    final uploadTask = await storageRef.putFile(compressedFile);
    final downloadUrl = await uploadTask.ref.getDownloadURL();
    
    print('Upload successful. Download URL: $downloadUrl');
    
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
