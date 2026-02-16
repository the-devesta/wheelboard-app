import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
// import '../controllers/apihelperclass/...';
import '../utils/constants.dart';
import '../utils/app_logger.dart';
import 'package:intl/intl.dart';

class HttpHelper {
  static String get baseUrl => ApiConstants.baseUrl;

  static Future<http.Response> getData({
    required String endpoint,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
  }) async {
    Uri uri = Uri.parse(
      baseUrl + endpoint,
    ).replace(queryParameters: queryParams);
    debugPrint('requested urlll===> $uri');
    return await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 30));
  }

  static Future<http.Response> postData({
    required String endpoint,
    required Map<String, dynamic> data,
    Map<String, String>? headers,
  }) async {
    Uri uri = Uri.parse(baseUrl + endpoint);

    // Debug logging for release mode
    AppLogger.d("🌐 API Request:");
    AppLogger.d("🌐 URL: $uri");
    AppLogger.d(
      "🌐 Headers: ${headers ?? {'Content-Type': 'application/json'}}",
    );
    AppLogger.d("🌐 Data: ${jsonEncode(data)}");

    try {
      final response = await http
          .post(
            uri,
            headers: headers ?? {'Content-Type': 'application/json'},
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 30));

      AppLogger.d("🌐 Response Status: ${response.statusCode}");
      AppLogger.d("🌐 Response Body: ${response.body}");

      // Check for specific error cases
      if (response.statusCode == 0) {
        throw Exception(
          "Network connection failed. Please check your internet connection.",
        );
      }

      return response;
    } catch (e) {
      AppLogger.d("🌐 API Error: $e");
      if (e.toString().contains('HandshakeException') ||
          e.toString().contains('CertificateException')) {
        throw Exception(
          "SSL Certificate error. Please check your network configuration.",
        );
      } else if (e.toString().contains('SocketException')) {
        throw Exception(
          "Network connection failed. Please check your internet connection.",
        );
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
    return await http
        .put(
          uri,
          headers: headers ?? {'Content-Type': 'application/json'},
          body: jsonEncode(data),
        )
        .timeout(const Duration(seconds: 30));
  }

  static Future<http.Response> deleteData({
    required String endpoint,
    Map<String, String>? headers,
  }) async {
    Uri uri = Uri.parse(baseUrl + endpoint);
    return await http
        .delete(uri, headers: headers)
        .timeout(const Duration(seconds: 30));
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
      AppLogger.d(
        "📂 Attached File: $fileName as $fieldKey with Content-Type: ${mediaType?.toString() ?? 'unknown'}",
      );
    }

    // 🔍 Debug logging
    AppLogger.d("==================================");
    AppLogger.d("📡 Sending Multipart Request");
    AppLogger.d("👉 Method: ${request.method}");
    AppLogger.d("👉 URL: $uri");
    AppLogger.d("👉 Headers: ${request.headers}");
    AppLogger.d("👉 Fields: ${request.fields}");
    AppLogger.d("👉 Files attached: ${files.length}");
    AppLogger.d("==================================");

    // Send request
    return await request.send().timeout(const Duration(seconds: 60));
  }

  /// Get vehicle details by vehicle number
  static Future<http.Response> getVehicleDetails({
    required String vehicleNumber,
    Map<String, String>? headers,
  }) async {
    Uri uri = Uri.parse(baseUrl + API.getVehicleDetails);

    final requestBody = {"vehicleNumber": vehicleNumber};

    AppLogger.d("🚗 Vehicle API Request:");
    AppLogger.d("🚗 URL: $uri");
    AppLogger.d("🚗 Body: ${jsonEncode(requestBody)}");
    AppLogger.d(
      "🚗 Headers: ${headers ?? {'Content-Type': 'application/json'}}",
    );

    return await http
        .post(
          uri,
          headers: headers ?? {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        )
        .timeout(const Duration(seconds: 30));
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

  /// Get driver details by driver ID
  static Future<http.Response> getDriverDetails({
    required String driverId,
    Map<String, String>? headers,
  }) async {
    // Remove trailing slash from baseUrl if present, then add endpoint
    final cleanBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    Uri uri = Uri.parse(
      '$cleanBaseUrl/api/Transport/drivers-details/$driverId',
    );

    AppLogger.d("👤 Driver Details API Request:");
    AppLogger.d("👤 URL: $uri");
    AppLogger.d("👤 Headers: ${headers ?? {'accept': '*/*'}}");

    return await http.get(uri, headers: headers ?? {'accept': '*/*'});
  }

  /// Get professional driver details by driver ID
  static Future<http.Response> getProfessionalDetails({
    required String driverId,
    Map<String, String>? headers,
  }) async {
    final cleanBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    Uri uri = Uri.parse(
      '$cleanBaseUrl/api/Transport/professional-details/$driverId',
    );

    AppLogger.d("👤 Professional Driver Details API Request:");
    AppLogger.d("👤 URL: $uri");
    AppLogger.d("👤 Headers: ${headers ?? {'accept': '*/*'}}");

    return await http.get(uri, headers: headers ?? {'accept': '*/*'});
  }

  //date format common fucntion
  static String formatDate(
    dynamic date, {
    String format = 'dd MMM yyyy, hh:mm a',
  }) {
    if (date == null) return '';

    try {
      DateTime dateTime;

      if (date is DateTime) {
        dateTime = date;
      } else if (date is String) {
        dateTime = DateTime.parse(date).toLocal();
      } else {
        return '';
      }

      return DateFormat(format).format(dateTime);
    } catch (e) {
      return '';
    }
  }

  static Future<http.Response> startTrip(
    String tripId, {
    Map<String, String>? headers,
  }) async {
    return await postData(
      endpoint: API.startTrip,
      data: {'tripId': tripId},
      headers: headers,
    );
  }

  static Future<http.Response> endTrip(
    String tripId, {
    Map<String, String>? headers,
  }) async {
    return await postData(
      endpoint: API.endTrip,
      data: {'tripId': tripId},
      headers: headers,
    );
  }

  static String formatAmount(num? amount, {String symbol = '₹'}) {
    if (amount == null) return '${symbol}0';

    final formatter = NumberFormat('#,##0', 'en_IN');
    return '$symbol${formatter.format(amount)}';
  }

  static Future<http.Response> postWithQuery({
    required String endpoint,
    required Map<String, dynamic> queryParams,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse(baseUrl + endpoint).replace(
      queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())),
    );

    AppLogger.d("🌐 POST With Query");
    AppLogger.d("🌐 URL: $uri");
    AppLogger.d("🌐 Headers: ${headers ?? {'accept': '*/*'}}");

    return await http.post(uri, headers: headers ?? {'accept': '*/*'});
  }
}
