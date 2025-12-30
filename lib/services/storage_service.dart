import 'dart:io';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  // final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  Future<String> uploadImage(File file, String userId) async {
    try {
      // FREE TIER WORKAROUND:
      // Firebase Storage requires "Blaze" plan for some regions/accounts.
      // To avoid credit card requirement for this demo, we will save the LOCAL path.
      // NOTE: This image will ONLY be visible on the device that took the photo.
      return file.path; 

      /* 
      // Original Cloud Upload Logic (Requires Billing)
      String fileName = _uuid.v4();
      Reference ref = _storage.ref().child('activity_photos').child(userId).child('$fileName.jpg');
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
      */
    } catch (e) {
      print("Error uploading image: $e");
      // Even if error, return path so user sees something
      return file.path;
    }
  }
}
