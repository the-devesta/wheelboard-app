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
    final response = await HttpHelper.postData(
      endpoint: API.verifyDrivingLicence,
      headers: {'Accept': '*/*', 'Content-Type': 'application/json'},
      data: {'userId': userId, 'dlNumber': dlNumber, 'dob': dob},
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Parse the response
      Map<String, dynamic> responseData = {};
      if (response.body.isNotEmpty) {
        try {
          responseData = Map<String, dynamic>.from(
            jsonDecode(response.body) as Map,
          );
        } catch (e) {
          AppLogger.d('Error parsing response: $e');
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
}
