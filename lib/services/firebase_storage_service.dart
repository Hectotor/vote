import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(XFile image, String userId, String postId) async {
    Reference ref = _storage.ref().child(
        'users/$userId/posts/$postId/${DateTime.now().millisecondsSinceEpoch}');
    await ref.putFile(File(image.path));
    return await ref.getDownloadURL();
  }
}
