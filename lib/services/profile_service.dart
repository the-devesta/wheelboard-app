import 'dart:io';
import 'package:dio/dio.dart' as dio;

import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../utils/app_logger.dart';

class ProfileService {
  Future<bool> updateTransportProfile({
    required String userId,
    required String companyName,
    required String fullName,
    required String email,
    required String location,
    required String fleetSize,
    required String gstNumber,
    String? phoneNumber,
    String? whatsappNumber,
    String? description,
    String? website,
    File? companyLogo,
  }) async {
    final formData = dio.FormData.fromMap({
      'UserId': userId,
      'CompanyName': companyName,
      'FullName': fullName,
      'Email': email,
      'Location': location,
      'FleetSize': fleetSize,
      'GSTNumber': gstNumber,
      if (phoneNumber != null && phoneNumber.isNotEmpty)
        'PhoneNumber': phoneNumber,
      if (whatsappNumber != null && whatsappNumber.isNotEmpty)
        'WhatsappNumber': whatsappNumber,
      if (description != null && description.isNotEmpty)
        'Description': description,
      if (website != null && website.isNotEmpty) 'Website': website,
    });

    if (companyLogo != null) {
      formData.files.add(MapEntry(
        'CompanyLogo',
        await dio.MultipartFile.fromFile(companyLogo.path),
      ));
    }

    try {
      await ApiClient.instance.upload<dynamic>(
        ApiEndpoints.users.updateTransportProfile,
        formData: formData,

      );
      return true;
    } on dio.DioException catch (e) {
      throw Exception(
        'Failed to update transport profile (${e.response?.statusCode}): ${e.response?.data}',
      );
    }
  }

  Future<bool> updateProfessionalProfile({
    required String userId,
    required String fullName,
    required String fathersName,
    required String yearsOfExperience,
    required String birthDateIso,
    required String state,
    required String city,
    String? phoneNumber,
    String? whatsappNumber,
    String? description,
    File? driverImage,
  }) async {
    final formData = dio.FormData.fromMap({
      'UserId': userId,
      'FullName': fullName,
      'FathersName': fathersName,
      'YearsOfExperience': yearsOfExperience,
      'BirthDate': birthDateIso,
      'State': state,
      'City': city,
      if (phoneNumber != null && phoneNumber.isNotEmpty)
        'PhoneNumber': phoneNumber,
      if (whatsappNumber != null && whatsappNumber.isNotEmpty)
        'WhatsappNumber': whatsappNumber,
      if (description != null && description.isNotEmpty)
        'Description': description,
    });

    if (driverImage != null) {
      formData.files.add(MapEntry(
        'DriverImage',
        await dio.MultipartFile.fromFile(driverImage.path),
      ));
    }

    try {
      await ApiClient.instance.upload<dynamic>(
        ApiEndpoints.users.updateProfessionalProfile,
        formData: formData,

      );
      return true;
    } on dio.DioException catch (e) {
      throw Exception(
        'Failed to update professional profile (${e.response?.statusCode}): ${e.response?.data}',
      );
    }
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

    try {
      final responseData = await ApiClient.instance.post<dynamic>(
        ApiEndpoints.kyc.verifyDrivingLicense,
        data: {'userId': userId, 'dlNumber': dlNumber, 'dob': dob},
      );

      Map<String, dynamic> resultData = {};
      if (responseData is Map<String, dynamic>) {
        resultData = responseData;
        AppLogger.d('🔐 [ProfileService] Parsed Response Data: $resultData');
      }

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

    try {
      final responseData = await ApiClient.instance.post<dynamic>(
        ApiEndpoints.kyc.verifyPan,
        data: {'panNumber': panNumber, 'userId': userId},
      );

      Map<String, dynamic> resultData = {};
      if (responseData is Map<String, dynamic>) {
        resultData = responseData;
        AppLogger.d('🔐 [ProfileService] Parsed PAN Response Data: $resultData');
      }

      final apiCode = resultData['code'];
      final message = resultData['message'] ?? '';

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
        'data': resultData['result'] ?? resultData,
      };
    } on dio.DioException catch (e) {
      final message = e.response?.data is Map ? e.response?.data['message'] ?? '' : '';
      final errorMessage = message.toString().isNotEmpty
          ? message.toString()
          : 'Failed to verify PAN card (${e.response?.statusCode})';
      throw Exception(errorMessage);
    }
  }
}
