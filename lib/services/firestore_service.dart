import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'firebase_storage_service.dart';
import 'dart:ui';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorageService _storageService = FirebaseStorageService();

  Future<void> createPost({
    required String userId,
    required String title,
    required List<XFile?> images,
    required List<Map<String, dynamic>> texts,
    required List<Color> filters,
    required String description,
    required List<String> hashtags,
    DateTime? endVoteDate,
  }) async {
    final docRef = _firestore.collection('users/$userId/posts').doc();
    final postId = docRef.id;

    // Traiter les images
    List<String> imageUrls = [];
    for (var image in images) {
      if (image != null) {
        String url = await _storageService.uploadImage(image, userId, postId);
        imageUrls.add(url);
      }
    }

    // Créer le document
    await docRef.set({
      'title': title,
      'createdAt': FieldValue.serverTimestamp(),
      'endVoteAt': endVoteDate,
      'description': description,
      'hashtags': hashtags,
      'blocks': List.generate(
        images.length,
        (index) => {
          'order': index,
          'imageUrl': imageUrls.length > index ? imageUrls[index] : null,
          'filter': filters[index].value,
          'text': texts[index],
        },
      ),
    });
  }
}
