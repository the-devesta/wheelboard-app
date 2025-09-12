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

  static Future<http.StreamedResponse> uploadMultipart({
    required String endpoint,
    required Map<String, String?> fields,
    required List<File> files,
    required String fieldKey,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse(baseUrl + endpoint);

    final request = http.MultipartRequest("POST", uri);

    // ✅ Add headers (Content-Type will be auto-set by MultipartRequest)
    if (headers != null) {
      request.headers.addAll(headers);
    }

    // ✅ Add fields (skip nulls)
    fields.forEach((key, value) {
      if (value != null) {
        request.fields[key] = value;
      }
    });

    // ✅ Add files
    for (final file in files) {
      final fileName = file.path.split("/").last;
      request.files.add(await http.MultipartFile.fromPath(fieldKey, file.path));

      // Debug log for each file
      // print("📂 Attached File: $fileName");
    }

    // 🔍 Debug logging
    print("==================================");
    print("📡 Sending Multipart Request");
    print("👉 URL: $uri");
    print("👉 Headers: ${request.headers}");
    print("👉 Fields: ${request.fields}");
    print("👉 Files attached: ${files.length}");
    print("==================================");

    // Send request
    return await request.send();
  }
}
