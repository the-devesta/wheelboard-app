import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // Required for MediaType
import 'package:mime/mime.dart'; // Optional: to detect MIME types
// import '../controllers/apihelperclass/...';
import '../utils/constants.dart';

class HttpHelper {
  static String get baseUrl => ApiConstants.baseUrl;

  static Future<http.Response> getData({
    required String endpoint,
    Map<String, String>? headers,
    Map<String, String>? queryParams,
  }) async {
    Uri uri = Uri.parse(
      baseUrl + endpoint,
    ).replace(queryParameters: queryParams);
    return await http.get(uri, headers: headers);
  }

  static Future<http.Response> postData({
    required String endpoint,
    required Map<String, dynamic> data,
    Map<String, String>? headers,
  }) async {
    Uri uri = Uri.parse(baseUrl + endpoint);
    return await http.post(
      uri,
      headers: headers ?? {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
  }

  static Future<http.Response> putData({
    required String endpoint,
    required Map<String, dynamic> data,
    Map<String, String>? headers,
  }) async {
    Uri uri = Uri.parse(baseUrl + endpoint);
    return await http.put(
      uri,
      headers: headers ?? {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
  }

  static Future<http.Response> deleteData({
    required String endpoint,
    Map<String, String>? headers,
  }) async {
    Uri uri = Uri.parse(baseUrl + endpoint);
    return await http.delete(uri, headers: headers);
  }

  /// ✅ Multipart upload (e.g., image, video, document, etc.)
  static Future<http.StreamedResponse> uploadMultipart({
    required String endpoint,
    required Map<String, String> fields,
    required List<File> files,
    Map<String, String>? headers,
    String method = 'POST', // Also supports 'PUT'
    String fieldKey = 'file', // Field name for the file(s)
  }) async {
    Uri uri = Uri.parse(baseUrl + endpoint);
    var request = http.MultipartRequest(method, uri);

    // Add headers
    if (headers != null) {
      request.headers.addAll(headers);
    }

    // Add form fields
    request.fields.addAll(fields);

    // Add files
    for (File file in files) {
      final mimeType =
          lookupMimeType(file.path)?.split('/') ??
          ['application', 'octet-stream'];

      request.files.add(
        await http.MultipartFile.fromPath(
          fieldKey,
          file.path,
          contentType: MediaType(mimeType[0], mimeType[1]),
        ),
      );
    }

    return await request.send();
  }
}
