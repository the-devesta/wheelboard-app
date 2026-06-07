import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/network/api_exception.dart';
import '../models/kyc_model.dart';

/// KYC API client — mirrors wheelboard-fe `kycApi.ts` against the backend
/// `src/kyc/kyc.controller.ts`. The backend resolves `professionalType` from
/// the authenticated user's role, so this single service serves all roles
/// (driver / transport / service provider).
class KycService {
  /// GET /kyc/my-kyc — returns (auto-creating if needed) the caller's KYC.
  Future<Kyc> getMyKyc() async {
    try {
      final raw = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.kyc.myKyc,
      );
      if (raw is Map<String, dynamic>) return Kyc.fromJson(raw);
      throw Exception('Unexpected response while loading KYC.');
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Failed to load KYC'));
    }
  }

  /// GET /kyc/required-documents?professionalType=
  Future<RequiredDocuments> getRequiredDocuments(String professionalType) async {
    try {
      final raw = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.kyc.requiredDocuments,
        queryParameters: {'professionalType': professionalType},
      );
      if (raw is Map<String, dynamic>) return RequiredDocuments.fromJson(raw);
      return const RequiredDocuments(mandatory: [], optional: []);
    } on DioException {
      return const RequiredDocuments(mandatory: [], optional: []);
    }
  }

  /// GET /kyc/completeness
  Future<KycCompleteness?> checkCompleteness() async {
    try {
      final raw = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.kyc.completeness,
      );
      if (raw is Map<String, dynamic>) return KycCompleteness.fromJson(raw);
      return null;
    } on DioException {
      return null;
    }
  }

  /// POST /kyc/verify/pan  { panNumber }
  /// Backend records the PAN as PENDING (manual review) — returns verified=false.
  Future<KycVerifyResult> verifyPan(String panNumber) async {
    try {
      final raw = await ApiClient.instance.post<dynamic>(
        ApiEndpoints.kyc.verifyPan,
        data: {'panNumber': panNumber},
      );
      if (raw is Map<String, dynamic>) return KycVerifyResult.fromJson(raw);
      return const KycVerifyResult(verified: false);
    } on DioException catch (e) {
      throw Exception(_msg(e, 'PAN verification failed'));
    }
  }

  /// POST /kyc/verify/driving-license  { dlNumber, dateOfBirth: YYYY-MM-DD }
  /// Verified instantly against the government database (or throws on failure).
  Future<KycVerifyResult> verifyDl(String dlNumber, String dateOfBirth) async {
    try {
      final raw = await ApiClient.instance.post<dynamic>(
        ApiEndpoints.kyc.verifyDrivingLicense,
        data: {'dlNumber': dlNumber, 'dateOfBirth': dateOfBirth},
      );
      if (raw is Map<String, dynamic>) return KycVerifyResult.fromJson(raw);
      return const KycVerifyResult(verified: false);
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Driving License verification failed'));
    }
  }

  /// POST /kyc/upload/document
  Future<Kyc> uploadDocument({
    required String documentType,
    required String documentNumber,
    String? documentName,
    String? fileUrl,
    bool? autoVerify,
  }) async {
    try {
      final raw = await ApiClient.instance.post<dynamic>(
        ApiEndpoints.kyc.uploadDocument,
        data: {
          'documentType': documentType,
          'documentNumber': documentNumber,
          if (documentName != null && documentName.isNotEmpty)
            'documentName': documentName,
          if (fileUrl != null && fileUrl.isNotEmpty) 'fileUrl': fileUrl,
          if (autoVerify != null) 'autoVerify': autoVerify,
        },
      );
      if (raw is Map<String, dynamic>) return Kyc.fromJson(raw);
      throw Exception('Unexpected response while uploading document.');
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Failed to upload document'));
    }
  }

  String _msg(DioException e, String fallback) {
    if (e.error is ApiException) return (e.error as ApiException).message;
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      final m = data['message'];
      return m is List ? m.join(', ') : m.toString();
    }
    return '$fallback (${e.response?.statusCode ?? 'network error'})';
  }
}
