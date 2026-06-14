import 'dart:async';

import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../models/service_payload.dart';
import '../../services/razorpay_service.dart';
import '../../utils/app_logger.dart';
import '../../widgets/custom_snackbar.dart';

/// Owns the service-listing CRUD for the Service Provider (business) persona.
///
/// All requests use the SAME JSON contract as the wheelboard-fe web app
/// (`CreateServiceDto`): `POST /services` / `PATCH /services/:id` with a JSON
/// body, images embedded as base64 data-URLs. (The old PascalCase multipart
/// payload — `ServiceTitle`/`IsFlatPrice`/`Images` — did NOT match the backend
/// DTO.)
///
/// Account + business-profile registration lives in `SpRegisterController`.
class ServiceProviderController extends GetxController {
  var isLoading = false.obs;

  /// Create a new service.
  ///
  /// Free-tier providers must pay a one-time listing fee first: the backend
  /// returns HTTP 402 PAYMENT_REQUIRED with a Razorpay order in
  /// `data: { amount, currency, orderId, razorpayKey }`. We complete that order
  /// and resubmit the create with the verified `listingPayment`. Subscribed
  /// providers never hit the 402 and create directly.
  Future<Map<String, dynamic>?> addService(ServicePayload payload) async {
    if (isLoading.value) return null;
    isLoading.value = true;

    try {
      final data = await _postService(payload);
      SnackBarHelper.success('Service added successfully!');
      isLoading.value = false;
      return {'success': true, 'data': data};
    } on dio.DioException catch (e) {
      if (e.response?.statusCode == 402) {
        // Listing fee required — branch into the Razorpay flow (keeps the
        // loading state until it resolves).
        return _payListingFeeThenCreate(payload, e.response?.data);
      }
      isLoading.value = false;
      final msg = e.error is ApiException
          ? (e.error as ApiException).message
          : 'Failed to add service';
      SnackBarHelper.error(msg);
      return {'success': false, 'error': msg};
    } catch (e) {
      isLoading.value = false;
      SnackBarHelper.error(e.toString());
      return {'success': false, 'error': e.toString()};
    }
  }

  /// POST /services with the JSON [CreateServiceDto] body.
  Future<dynamic> _postService(ServicePayload payload) async {
    final body = await payload.toJson();
    return ApiClient.instance.post<dynamic>(
      ApiEndpoints.services.create,
      data: body,
    );
  }

  /// Completes the Razorpay listing-fee order from a 402 response, then
  /// resubmits the create with the verified `listingPayment` fields.
  Future<Map<String, dynamic>?> _payListingFeeThenCreate(
    ServicePayload payload,
    dynamic responseBody,
  ) async {
    final fee = (responseBody is Map && responseBody['data'] is Map)
        ? Map<String, dynamic>.from(responseBody['data'] as Map)
        : (responseBody is Map
            ? Map<String, dynamic>.from(responseBody)
            : <String, dynamic>{});

    final orderId = (fee['orderId'] ?? '').toString();
    final amountRupees = fee['amount'] is num
        ? (fee['amount'] as num).toDouble()
        : double.tryParse('${fee['amount']}') ?? 0;
    final key = (fee['razorpayKey'] ?? '').toString();
    final currency = (fee['currency'] ?? 'INR').toString();

    if (orderId.isEmpty || amountRupees <= 0) {
      isLoading.value = false;
      SnackBarHelper.error('Could not start the listing-fee payment.');
      return {'success': false, 'error': 'invalid_listing_fee'};
    }

    final completer = Completer<PaymentSuccessResponse?>();
    final razorpay = RazorpayService(
      onPaymentSuccess: (r) {
        if (!completer.isCompleted) completer.complete(r);
      },
      onPaymentError: (r) {
        if (!completer.isCompleted) completer.complete(null);
        SnackBarHelper.error(
            'Listing fee payment failed: ${r.message ?? 'cancelled'}');
      },
      onExternalWallet: (_) {},
    );

    try {
      await razorpay.openCheckout(
        amountInPaise: (amountRupees * 100).toInt(),
        orderId: orderId,
        keyOverride: key,
        currency: currency,
        description: 'Service listing fee',
      );

      final result = await completer.future;
      if (result == null) {
        isLoading.value = false;
        return {'success': false, 'error': 'payment_cancelled'};
      }

      final paid = payload.withListingPayment(
        orderId: result.orderId ?? orderId,
        paymentId: result.paymentId ?? '',
        signature: result.signature ?? '',
      );
      final data = await _postService(paid);

      SnackBarHelper.success('Service added successfully!');
      isLoading.value = false;
      return {'success': true, 'data': data};
    } on dio.DioException catch (e) {
      isLoading.value = false;
      final msg = e.error is ApiException
          ? (e.error as ApiException).message
          : 'Failed to add service';
      SnackBarHelper.error(msg);
      return {'success': false, 'error': msg};
    } catch (e) {
      isLoading.value = false;
      SnackBarHelper.error(e.toString());
      return {'success': false, 'error': e.toString()};
    } finally {
      razorpay.dispose();
    }
  }

  /// Update an existing service (PATCH /services/:id, JSON body).
  Future<Map<String, dynamic>?> updateService(
    String serviceId,
    ServicePayload payload,
  ) async {
    if (isLoading.value) return null;

    try {
      isLoading.value = true;
      final body = await payload.toJson();

      final data = await ApiClient.instance.patch<dynamic>(
        ApiEndpoints.services.update(serviceId),
        data: body,
      );

      SnackBarHelper.success('Service updated successfully!');
      return {'success': true, 'data': data};
    } on dio.DioException catch (e) {
      final msg = e.error is ApiException
          ? (e.error as ApiException).message
          : 'Failed to update service';
      SnackBarHelper.error(msg);
      return {'success': false, 'error': msg};
    } catch (e) {
      SnackBarHelper.error(e.toString());
      return {'success': false, 'error': e.toString()};
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete a service (DELETE /services/:id).
  Future<bool> deleteService(String serviceId, [String? userId]) async {
    if (isLoading.value) return false;

    try {
      isLoading.value = true;
      AppLogger.d('🗑️ Deleting service: $serviceId');

      await ApiClient.instance.delete(ApiEndpoints.services.delete(serviceId));

      SnackBarHelper.success('Service deleted successfully!');
      return true;
    } on dio.DioException catch (e) {
      final msg = e.error is ApiException
          ? (e.error as ApiException).message
          : 'Failed to delete service';
      SnackBarHelper.error(msg);
      return false;
    } catch (e) {
      AppLogger.d('❌ Error deleting service: $e');
      SnackBarHelper.error('Failed to delete service: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
