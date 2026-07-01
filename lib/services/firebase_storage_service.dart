import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

/// Uploads files directly to Firebase Storage from the app.
///
/// This avoids routing uploads through the backend (which requires
/// FIREBASE_SERVICE_ACCOUNT_JSON env var on the server). The app's
/// google-services.json already has Firebase Storage configured.
class FirebaseStorageService {
  static FirebaseStorage get _storage => FirebaseStorage.instance;

  static Future<String> _upload(File file, String path) async {
    final ref = _storage.ref().child(path);
    final task = await ref.putFile(file);
    return await task.ref.getDownloadURL();
  }

  static String _ext(File file) {
    final raw = file.path.split('.').last.split('?').first.toLowerCase();
    const allowed = ['jpg', 'jpeg', 'png', 'webp', 'heic'];
    return allowed.contains(raw) ? raw : 'jpg';
  }

  /// Upload a profile/logo image. Returns the Firebase download URL.
  static Future<String> uploadProfileImage(File file) {
    final path = 'profiles/${DateTime.now().millisecondsSinceEpoch}.${_ext(file)}';
    return _upload(file, path);
  }

  /// Upload multiple POD delivery photos. Returns list of download URLs.
  static Future<List<String>> uploadPodPhotos(
    List<File> files,
    String tripId,
  ) async {
    final urls = <String>[];
    for (int i = 0; i < files.length; i++) {
      final path =
          'pod/$tripId/${DateTime.now().millisecondsSinceEpoch}_$i.${_ext(files[i])}';
      urls.add(await _upload(files[i], path));
    }
    return urls;
  }
}
