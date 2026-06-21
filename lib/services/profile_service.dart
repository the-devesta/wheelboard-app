import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart' as dio;

import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/network/api_exception.dart';
import '../utils/app_logger.dart';

/// Profile service — 1:1 with wheelboard-fe `userAPI.updateProfile`.
///
/// The web (and the backend) use a SINGLE generic endpoint for every role:
///   `PUT /users/profile`  body: { profile, profileImage(base64), email }
/// The backend merges `profile` into the user's stored profile object, so each
/// role just sends its own relevant fields. (The old multipart routes
/// `/users/profile/professional` & `/users/profile/transport` are PUT-only and
/// were 404ing because the app sent POST — they are no longer used.)
class ProfileService {
  /// PUT /users/profile — update the current user's profile.
  Future<bool> updateProfile({
    required Map<String, dynamic> profile,
    String? profileImageBase64,
    String? email,
  }) async {
    try {
      // Drop null/empty values so we never overwrite stored data with blanks.
      final cleaned = <String, dynamic>{};
      profile.forEach((k, v) {
        if (v == null) return;
        if (v is String && v.trim().isEmpty) return;
        cleaned[k] = v;
      });

      await ApiClient.instance.put<dynamic>(
        ApiEndpoints.users.updateProfile, // PUT /users/profile
        data: {
          'profile': cleaned,
          if (profileImageBase64 != null && profileImageBase64.isNotEmpty)
            'profileImage': profileImageBase64,
          if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
        },
      );
      return true;
    } on dio.DioException catch (e) {
      throw Exception(_msg(e, 'Failed to update profile'));
    }
  }

  /// Read an image file as a base64 data-URL — the same shape the web sends for
  /// `profileImage` (the backend mirrors it to avatar / profileImage / logo).
  static Future<String> fileToBase64DataUrl(File file) async {
    final bytes = await file.readAsBytes();
    final p = file.path.toLowerCase();
    final mime = p.endsWith('.png')
        ? 'image/png'
        : p.endsWith('.webp')
            ? 'image/webp'
            : (p.endsWith('.heic') ? 'image/heic' : 'image/jpeg');
    return 'data:$mime;base64,${base64Encode(bytes)}';
  }

  /// Verify Driving License KYC.
  Future<Map<String, dynamic>> verifyDrivingLicence({
    required String userId,
    required String dlNumber,
    required String dob,
  }) async {
    AppLogger.d('🔐 [ProfileService] Verify DL: userId=$userId dl=$dlNumber');
    try {
      final responseData = await ApiClient.instance.post<dynamic>(
        ApiEndpoints.kyc.verifyDrivingLicense,
        data: {'userId': userId, 'dlNumber': dlNumber, 'dob': dob},
      );

      final resultData = responseData is Map<String, dynamic>
          ? responseData
          : <String, dynamic>{};

      return {
        'success': true,
        'message': 'Driving License verified successfully',
        'data': resultData,
      };
    } on dio.DioException catch (e) {
      throw Exception(
        'Failed to verify driving license (${e.response?.statusCode}): ${e.response?.data}',
      );
    }
  }

  /// Verify PAN Card KYC.
  Future<Map<String, dynamic>> verifyPanKYC({
    required String userId,
    required String panNumber,
  }) async {
    AppLogger.d('🔐 [ProfileService] Verify PAN: userId=$userId pan=$panNumber');
    try {
      final responseData = await ApiClient.instance.post<dynamic>(
        ApiEndpoints.kyc.verifyPan,
        data: {'panNumber': panNumber, 'userId': userId},
      );

      final resultData = responseData is Map<String, dynamic>
          ? responseData
          : <String, dynamic>{};
      final apiCode = resultData['code'];
      final message = (resultData['message'] ?? '').toString();

      if (apiCode != null && apiCode != 200) {
        throw Exception(
            message.isNotEmpty ? message : 'PAN verification failed');
      }

      return {
        'success': true,
        'message':
            message.isNotEmpty ? message : 'PAN Card verified successfully',
        'data': resultData['result'] ?? resultData,
      };
    } on dio.DioException catch (e) {
      final message =
          e.response?.data is Map ? (e.response?.data['message'] ?? '') : '';
      final errorMessage = message.toString().isNotEmpty
          ? message.toString()
          : 'Failed to verify PAN card (${e.response?.statusCode})';
      throw Exception(errorMessage);
    }
  }

  String _msg(dio.DioException e, String fallback) {
    if (e.error is ApiException) return (e.error as ApiException).message;
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      final m = data['message'];
      return m is List ? m.join(', ') : m.toString();
    }
    return '$fallback (${e.response?.statusCode ?? 'network error'})';
  }
}
