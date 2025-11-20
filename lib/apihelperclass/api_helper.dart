import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
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
    
    // Debug logging for release mode
    print("🌐 API Request:");
    print("🌐 URL: $uri");
    print("🌐 Headers: ${headers ?? {'Content-Type': 'application/json'}}");
    print("🌐 Data: ${jsonEncode(data)}");
    
    try {
      final response = await http.post(
        uri,
        headers: headers ?? {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      
      print("🌐 Response Status: ${response.statusCode}");
      print("🌐 Response Body: ${response.body}");
      
      // Check for specific error cases
      if (response.statusCode == 0) {
        throw Exception("Network connection failed. Please check your internet connection.");
      }
      
      return response;
    } catch (e) {
      print("🌐 API Error: $e");
      if (e.toString().contains('HandshakeException') || 
          e.toString().contains('CertificateException')) {
        throw Exception("SSL Certificate error. Please check your network configuration.");
      } else if (e.toString().contains('SocketException')) {
        throw Exception("Network connection failed. Please check your internet connection.");
      }
      rethrow;
    }
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
    String method = "POST",
  }) async {
    final uri = Uri.parse(baseUrl + endpoint);

    final request = http.MultipartRequest(method, uri);

    // Let the http client set the multipart content type, but add other headers
    if (headers != null) {
      final cleanHeaders = Map<String, String>.from(headers);
      cleanHeaders.remove('Content-Type');
      request.headers.addAll(cleanHeaders);
    }

    // ✅ Add fields (skip nulls)
    fields.forEach((key, value) {
      if (value != null) {
        request.fields[key] = value;
      }
    });

    // ✅ Add files - send all files with the same field name (standard multipart behavior)
    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      final fileName = file.path.split("/").last;
      final mimeType = lookupMimeType(file.path);
      final mediaType = mimeType != null ? MediaType.parse(mimeType) : null;

      // Use the same field name for all files (most APIs expect this)
      // The server should handle multiple files with the same field name
      final multipartFile = await http.MultipartFile.fromPath(
        fieldKey,
        file.path,
        filename: fileName,
        contentType: mediaType,
      );

      request.files.add(multipartFile);
      print(
          "📂 Attached File: $fileName as $fieldKey with Content-Type: ${mediaType?.toString() ?? 'unknown'}");
    }

    // 🔍 Debug logging
    print("==================================");
    print("📡 Sending Multipart Request");
    print("👉 Method: ${request.method}");
    print("👉 URL: $uri");
    print("👉 Headers: ${request.headers}");
    print("👉 Fields: ${request.fields}");
    print("👉 Files attached: ${files.length}");
    print("==================================");

    // Send request
    return await request.send();
  }

  /// Get vehicle details by vehicle number
  static Future<http.Response> getVehicleDetails({
    required String vehicleNumber,
    Map<String, String>? headers,
  }) async {
    Uri uri = Uri.parse(baseUrl + API.getVehicleDetails);
    
    final requestBody = {"vehicleNumber": vehicleNumber};
    
    print("🚗 Vehicle API Request:");
    print("🚗 URL: $uri");
    print("🚗 Body: ${jsonEncode(requestBody)}");
    print("🚗 Headers: ${headers ?? {'Content-Type': 'application/json'}}");
    
    return await http.post(
      uri,
      headers: headers ?? {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );
  }

  /// Get driver license details by license number and DOB
  static Future<http.Response> getLicenseDetails({
    required String number,
    required String dob,
    Map<String, String>? headers,
  }) async {
    Uri uri = Uri.parse(baseUrl + API.getLicenseDetails);
    return await http.post(
      uri,
      headers: headers ?? {'Content-Type': 'application/json'},
      body: jsonEncode({"number": number, "dob": dob}),
    );
  }
}
