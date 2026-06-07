import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/network/api_exception.dart';
import '../models/lr_model.dart';

/// Lorry Receipt (LR) API client.
///
/// Mirrors the wheelboard-fe `tripsApi` LR methods, but corrected against the
/// authoritative backend controller (`modules/trips/lr/lr.controller.ts`):
///   POST   /trips/:id/lr/generate    (fleet owner, draft trip)
///   PATCH  /trips/:id/lr             (fleet owner, after rejection)
///   GET    /trips/:id/lr
///   POST   /trips/:id/lr/confirm     { verificationType:'checkbox', confirmed:true }
///   POST   /trips/:id/lr/request-otp (driverId from token)
///   POST   /trips/:id/lr/verify-otp  { otpCode }
///   POST   /trips/:id/lr/reject      { reason, notes? }
class LrService {
  /// Fetch the LR for a trip. Throws [LrNotFound] when the LR has not been
  /// generated yet (so callers can distinguish "no LR" from a real error).
  Future<LrDetails> getLR(String tripId) async {
    try {
      final raw = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.trips.lrDetails(tripId),
      );
      if (raw is Map<String, dynamic>) return LrDetails.fromJson(raw);
      throw Exception('Unexpected response while fetching LR.');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw LrNotFound();
      }
      throw Exception(_msg(e, 'Failed to load LR details'));
    }
  }

  /// Generate a new LR for a draft trip (fleet owner).
  Future<void> generateLR(String tripId, GenerateLrPayload payload) async {
    try {
      await ApiClient.instance.post<dynamic>(
        ApiEndpoints.trips.lrGenerate(tripId),
        data: payload.toJson(),
      );
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Failed to generate LR'));
    }
  }

  /// Update an LR that the driver rejected (fleet owner) and resend.
  Future<void> updateLR(String tripId, GenerateLrPayload payload) async {
    try {
      await ApiClient.instance.patch<dynamic>(
        ApiEndpoints.trips.lrUpdate(tripId),
        data: payload.toJson(),
      );
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Failed to update LR'));
    }
  }

  /// Confirm the LR with the simple checkbox method (driver).
  Future<void> confirmCheckbox(String tripId) async {
    try {
      await ApiClient.instance.post<dynamic>(
        ApiEndpoints.trips.lrConfirm(tripId),
        data: {'verificationType': 'checkbox', 'confirmed': true},
      );
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Failed to confirm LR'));
    }
  }

  /// Request an OTP for LR confirmation (driver). Returns the OTP echoed by the
  /// backend (used for development/demo display) when present.
  Future<String?> requestOtp(String tripId) async {
    try {
      final raw = await ApiClient.instance.post<dynamic>(
        ApiEndpoints.trips.lrRequestOtp(tripId),
      );
      if (raw is Map) {
        final root = raw['data'] is Map ? raw['data'] : raw;
        return root['otp']?.toString();
      }
      return null;
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Failed to send OTP'));
    }
  }

  /// Verify the OTP and confirm the LR (driver).
  Future<void> verifyOtp(String tripId, String otpCode) async {
    try {
      await ApiClient.instance.post<dynamic>(
        ApiEndpoints.trips.lrVerifyOtp(tripId),
        data: {'otpCode': otpCode},
      );
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Failed to verify OTP'));
    }
  }

  /// Reject the LR with a reason (driver).
  Future<void> reject(String tripId, String reason, {String? notes}) async {
    try {
      await ApiClient.instance.post<dynamic>(
        ApiEndpoints.trips.lrReject(tripId),
        data: {
          'reason': reason,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
      );
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Failed to reject LR'));
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

/// Thrown by [LrService.getLR] when no LR has been generated for the trip yet.
class LrNotFound implements Exception {
  @override
  String toString() => 'LR not generated for this trip';
}
