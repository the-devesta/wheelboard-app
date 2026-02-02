import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../apihelperclass/api_helper.dart';
import '../utils/constants.dart';
import '../utils/app_logger.dart';

class ProfileService {
  Map<String, String> _defaultHeaders(String userId) {
    // APIS are authenticated via UserId in header, not bearer token
    return {'Accept': '*/*', if (userId.isNotEmpty) 'UserId': userId};
  }

  Future<bool> updateTransportProfile({
    required String userId,
    required String companyName,
    required String fullName,
    required String email,
    required String location,
    required String fleetSize,
    required String gstNumber,
    File? companyLogo,
  }) async {
    final response = await HttpHelper.uploadMultipart(
      endpoint: API.updateTransportProfile,
      fields: {
        'UserId': userId,
        'CompanyName': companyName,
        'FullName': fullName,
        'Email': email,
        'Location': location,
        'FleetSize': fleetSize,
        'GSTNumber': gstNumber,
      },
      files: companyLogo != null ? [companyLogo] : [],
      fieldKey: 'CompanyLogo',
      headers: _defaultHeaders(userId),
    );

    final resolved = await http.Response.fromStream(response);
    final isSuccess = resolved.statusCode >= 200 && resolved.statusCode < 300;

    if (!isSuccess) {
      throw Exception(
        'Failed to update transport profile (${resolved.statusCode}): ${resolved.body}',
      );
    }

    return true;
  }

  Future<bool> updateProfessionalProfile({
    required String userId,
    required String fullName,
    required String fathersName,
    required String yearsOfExperience,
    required String birthDateIso,
    required String state,
    required String city,
    File? driverImage,
  }) async {
    final response = await HttpHelper.uploadMultipart(
      endpoint: API.updateProfessionalProfile,
      fields: {
        'UserId': userId,
        'FullName': fullName,
        'FathersName': fathersName,
        'YearsOfExperience': yearsOfExperience,
        'BirthDate': birthDateIso,
        'State': state,
        'City': city,
      },
      files: driverImage != null ? [driverImage] : [],
      fieldKey: 'DriverImage',
      headers: _defaultHeaders(userId),
    );

    final resolved = await http.Response.fromStream(response);
    final isSuccess = resolved.statusCode >= 200 && resolved.statusCode < 300;

    if (!isSuccess) {
      throw Exception(
        'Failed to update professional profile (${resolved.statusCode}): ${resolved.body}',
      );
    }

    return true;
  }

  /// Verify Driving License KYC
  /// This API is called when user wants to verify their driving license
  /// Required for professional users with type Driver
  Future<Map<String, dynamic>> verifyDrivingLicence({
    required String userId,
    required String dlNumber,
    required String dob,
  }) async {
    AppLogger.d('🔐 [ProfileService] Verify DL Request:');
    AppLogger.d('🔐 [ProfileService] - userId: $userId');
    AppLogger.d('🔐 [ProfileService] - dlNumber: $dlNumber');
    AppLogger.d('🔐 [ProfileService] - dob: $dob');

    final response = await HttpHelper.postData(
      endpoint: API.verifyDrivingLicence,
      headers: {'Accept': '*/*', 'Content-Type': 'application/json'},
      data: {'userId': userId, 'dlNumber': dlNumber, 'dob': dob},
    );

    AppLogger.d('🔐 [ProfileService] Response Status: ${response.statusCode}');
    AppLogger.d('🔐 [ProfileService] Response Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Parse the response
      Map<String, dynamic> responseData = {};
      if (response.body.isNotEmpty) {
        try {
          responseData = Map<String, dynamic>.from(
            jsonDecode(response.body) as Map,
          );
          AppLogger.d(
            '🔐 [ProfileService] Parsed Response Data: $responseData',
          );

          // Check if response contains KYC status
          if (responseData.containsKey('isKYCCompleted')) {
            AppLogger.d(
              '🔐 [ProfileService] Response contains isKYCCompleted: ${responseData['isKYCCompleted']}',
            );
          }
          if (responseData.containsKey('result') &&
              responseData['result'] is Map) {
            final result = responseData['result'] as Map<String, dynamic>;
            if (result.containsKey('isKYCCompleted')) {
              AppLogger.d(
                '🔐 [ProfileService] Result contains isKYCCompleted: ${result['isKYCCompleted']}',
              );
            }
          }
        } catch (e) {
          AppLogger.d('🔐 [ProfileService] Error parsing response: $e');
        }
      }

      return {
        'success': true,
        'message': 'Driving License verified successfully',
        'data': responseData,
      };
    } else {
      throw Exception(
        'Failed to verify driving license (${response.statusCode}): ${response.body}',
      );
    }
  }

  /// Verify PAN Card KYC
  /// This API is called when user wants to verify their PAN card
  /// Required for professional users with type Technical or Helper
  Future<Map<String, dynamic>> verifyPanKYC({
    required String userId,
    required String panNumber,
  }) async {
    AppLogger.d('🔐 [ProfileService] Verify PAN Request:');
    AppLogger.d('🔐 [ProfileService] - userId: $userId');
    AppLogger.d('🔐 [ProfileService] - panNumber: $panNumber');

    final response = await HttpHelper.postData(
      endpoint: API.verifyPanKYC,
      headers: {'Accept': '*/*', 'Content-Type': 'application/json'},
      data: {'panNumber': panNumber, 'userId': userId},
    );

    AppLogger.d(
      '🔐 [ProfileService] PAN Response Status: ${response.statusCode}',
    );
    AppLogger.d('🔐 [ProfileService] PAN Response Body: ${response.body}');

    // Parse response body
    Map<String, dynamic> responseData = {};
    if (response.body.isNotEmpty) {
      try {
        responseData = Map<String, dynamic>.from(
          jsonDecode(response.body) as Map,
        );
        AppLogger.d(
          '🔐 [ProfileService] Parsed PAN Response Data: $responseData',
        );

        // Check if response contains KYC status
        if (responseData.containsKey('isKYCCompleted')) {
          AppLogger.d(
            '🔐 [ProfileService] PAN Response contains isKYCCompleted: ${responseData['isKYCCompleted']}',
          );
        }
        if (responseData.containsKey('result') &&
            responseData['result'] is Map) {
          final result = responseData['result'] as Map<String, dynamic>;
          if (result.containsKey('isKYCCompleted')) {
            AppLogger.d(
              '🔐 [ProfileService] PAN Result contains isKYCCompleted: ${result['isKYCCompleted']}',
            );
          }
        }
      } catch (e) {
        AppLogger.d('🔐 [ProfileService] Error parsing PAN response: $e');
      }
    }

    // Check API response code (inside body) or HTTP status
    final apiCode = responseData['code'];
    final message = responseData['message'] ?? '';

    // Success if HTTP 200 OR if code in body is 200
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Even if HTTP is 200, check if API returned error code
      if (apiCode != null && apiCode != 200) {
        throw Exception(
          message.isNotEmpty ? message : 'PAN verification failed',
        );
      }

      return {
        'success': true,
        'message': message.isNotEmpty
            ? message
            : 'PAN Card verified successfully',
        'data': responseData['result'] ?? responseData,
      };
    } else {
      // Handle error response
      final errorMessage = message.isNotEmpty
          ? message
          : 'Failed to verify PAN card (${response.statusCode})';
      throw Exception(errorMessage);
    }
  }
}
