import 'dart:io';

import 'package:http/http.dart' as http;

import '../apihelperclass/api_helper.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

class ProfileService {
  final AuthService _authService = AuthService.to;

  Map<String, String> _defaultHeaders(String userId) {
    final token = _authService.currentToken;
    return {
      'Accept': '*/*',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      if (userId.isNotEmpty) 'UserId': userId,
    };
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
}

