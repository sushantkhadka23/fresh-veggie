import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

class StorageServices {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  //adding profile picture of user
  Future<String> uploadProfilePicture({
    required File file,
    required String uid,
  }) async {
    try {
      String fileName = p.basename(file.path);
      String ext = p.extension(fileName);

      // Create a reference with the original filename and extension
      Reference ref =
          _storage.ref().child('profile_pictures').child('$uid$ext');

      // Upload file to Firebase Storage
      UploadTask uploadTask = ref.putFile(file);
      // Wait for upload to complete
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile picture: $e');
    }
  }

  //adding product's picture to storage
  Future<String> uploadProductPicture({
    required File file,
    required String productId,
  }) async {
    try {
      String fileName = p.basename(file.path);
      String ext = p.extension(fileName);

      // Create a reference with the original filename and extension
      Reference ref =
          _storage.ref().child('product_picture').child('$productId$ext');
      // Upload file to Firebase Storage
      UploadTask uploadTask = ref.putFile(file);
      // Wait for upload to complete
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile picture: $e');
    }
  }
}
