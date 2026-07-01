import 'dart:io';
import 'package:dio/dio.dart' as dio;

import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/network/api_exception.dart';
import '../utils/app_logger.dart';

/// A stored media object returned by the unified `POST /media` endpoint.
class MediaRef {
  final String url;
  final String? key;
  final String? contentType;
  final String? folder;
  final int? size;

  const MediaRef({
    required this.url,
    this.key,
    this.contentType,
    this.folder,
    this.size,
  });

  factory MediaRef.fromJson(Map<String, dynamic> json) => MediaRef(
        url: json['url']?.toString() ?? '',
        key: json['key']?.toString(),
        contentType: json['contentType']?.toString(),
        folder: json['folder']?.toString(),
        size: (json['size'] as num?)?.toInt(),
      );
}

/// Unified media upload — the single path new app code should use to upload
/// images. Sends real multipart files to `POST /media`; the backend uploads to
/// Firebase and returns hosted URLs (never base64). Mirrors the web `mediaAPI`.
class MediaService {
  /// Upload a single file. Returns the hosted [MediaRef], or null on failure.
  static Future<MediaRef?> upload(File file, {String? folder}) async {
    final results = await uploadMany([file], folder: folder);
    return results.isNotEmpty ? results.first : null;
  }

  /// Maps a file name's extension to the right multipart content-type so the
  /// backend stores the correct type (images as image/*, receipts as PDF).
  static dio.DioMediaType _mediaTypeFor(String name) {
    final ext = name.contains('.') ? name.split('.').last.toLowerCase() : 'jpg';
    switch (ext) {
      case 'png':
        return dio.DioMediaType('image', 'png');
      case 'webp':
        return dio.DioMediaType('image', 'webp');
      case 'gif':
        return dio.DioMediaType('image', 'gif');
      case 'heic':
        return dio.DioMediaType('image', 'heic');
      case 'pdf':
        return dio.DioMediaType('application', 'pdf');
      case 'jpg':
      case 'jpeg':
      default:
        return dio.DioMediaType('image', 'jpeg');
    }
  }

  /// Upload one or more files in a single request.
  static Future<List<MediaRef>> uploadMany(
    List<File> files, {
    String? folder,
  }) async {
    if (files.isEmpty) return const [];
    try {
      final formData = dio.FormData();
      for (final file in files) {
        final name = file.uri.pathSegments.isNotEmpty
            ? file.uri.pathSegments.last
            : 'upload.jpg';
        formData.files.add(MapEntry(
          'files',
          // Send an explicit filename + content-type so the part matches what
          // the web sends (a real File). Without these, the part defaults to
          // application/octet-stream which the storage upload can reject.
          await dio.MultipartFile.fromFile(
            file.path,
            filename: name,
            contentType: _mediaTypeFor(name),
          ),
        ));
      }
      if (folder != null && folder.isNotEmpty) {
        formData.fields.add(MapEntry('folder', folder));
      }

      final res = await ApiClient.instance.upload<Map<String, dynamic>>(
        ApiEndpoints.media.upload,
        formData: formData,
      );

      final list = res['files'];
      if (list is List) {
        return list
            .whereType<Map<String, dynamic>>()
            .map(MediaRef.fromJson)
            .toList();
      }
      return const [];
    } on dio.DioException catch (e) {
      final msg = e.error is ApiException
          ? (e.error as ApiException).message
          : 'Failed to upload media';
      AppLogger.e('📤 Media upload failed: $msg');
      rethrow;
    }
  }
}
