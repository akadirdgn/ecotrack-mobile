import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  Future<String> uploadImage(File file, String userId) async {
    try {
      String fileName = _uuid.v4();
      // Create a reference to the location you want to upload to in firebase
      Reference ref = _storage.ref().child('activity_photos').child(userId).child('$fileName.jpg');

      // Upload the file to firebase
      UploadTask uploadTask = ref.putFile(file);

      // Waits till the file is uploaded then stores the download url
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      throw Exception("Resim yüklenemedi: $e");
    }
  }
}
