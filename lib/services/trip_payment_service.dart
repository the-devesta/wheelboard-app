import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/network/api_exception.dart';
import '../models/trip_confirmation_model.dart';
import '../utils/app_logger.dart';

/// Result of `POST /payment/initiate`.
///
/// Mirrors web `PaymentInitiateResponse`:
/// `{ paymentId, orderId, amount, currency, razorpayKey }`.
class PaymentInitiateResult {
  PaymentInitiateResult({
    required this.orderId,
    required this.amountInPaise,
    required this.razorpayKey,
    required this.currency,
    this.paymentId,
    this.raw,
  });

  final String orderId;
  final int amountInPaise;
  final String razorpayKey;
  final String currency;
  final String? paymentId;
  final Map<String, dynamic>? raw;
}

/// Result of `POST /payment/verify`.
///
/// Mirrors web `PaymentVerifyResponse`:
/// `{ success, message, tripId, driverId, paymentId, otp? }`.
class PaymentVerifyResult {
  PaymentVerifyResult({
    required this.success,
    this.message,
    this.otp,
    this.paymentId,
    this.raw,
  });

  final bool success;
  final String? message;
  final String? otp;
  final String? paymentId;
  final Map<String, dynamic>? raw;
}

class TripPaymentService {
  /// Initiate a trip-assignment payment and create a Razorpay order.
  ///
  /// Matches web `paymentAPI.initiatePayment()`:
  /// `POST /payment/initiate { tripId, bidId, paymentOption, paymentMethod, amount }`.
  Future<PaymentInitiateResult> initiatePayment({
    required String tripId,
    required String bidId,
    required String paymentOption, // 'platform' | 'total'
    required double amount,
    String paymentMethod = 'card',
  }) async {
    try {
      final raw = await ApiClient.instance.post<dynamic>(
        ApiEndpoints.trips.createOrder, // /payment/initiate
        data: {
          'tripId': tripId,
          'bidId': bidId,
          'paymentOption': paymentOption,
          'paymentMethod': paymentMethod,
          'amount': _round(amount),
        },
      );

      final data = _extractData(raw);

      final orderId = _stringField(data, [
        'orderId', 'order_id', 'razorpayOrderId', 'razorpay_order_id', 'id',
      ]);
      final razorpayKey = _stringField(data, [
        'razorpayKey', 'razorpayKeyId', 'key', 'keyId', 'key_id',
      ]);
      final currency = _stringField(data, ['currency']) ?? 'INR';
      final paymentId = _stringField(data, ['paymentId', 'payment_id']);

      if (orderId == null || orderId.isEmpty) {
        throw Exception('Payment could not be started: missing order id.');
      }

      // Server returns amount in rupees → convert to paise (web parity).
      final serverAmount = data['amount'];
      int paise;
      if (serverAmount != null) {
        final parsed = double.tryParse(serverAmount.toString()) ?? amount;
        // If it already looks like paise (≈ amount*100), keep it; else *100.
        if (parsed >= (amount * 100) - 5 && parsed <= (amount * 100) + 5) {
          paise = parsed.round();
        } else {
          paise = (parsed * 100).round();
        }
      } else {
        paise = (amount * 100).round();
      }

      AppLogger.d(
          '[Payment] initiated order=$orderId paise=$paise key=${razorpayKey != null}');

      return PaymentInitiateResult(
        orderId: orderId,
        amountInPaise: paise,
        razorpayKey: razorpayKey ?? '',
        currency: currency,
        paymentId: paymentId,
        raw: data,
      );
    } on DioException catch (e) {
      final msg = e.error is ApiException
          ? (e.error as ApiException).message
          : 'Unable to start payment (${e.response?.statusCode ?? "network error"})';
      throw Exception(msg);
    }
  }

  /// Verify the Razorpay payment and assign the trip.
  ///
  /// Matches web `paymentAPI.verifyPayment()`:
  /// `POST /payment/verify { paymentId, tripId, bidId, signature, orderId }`.
  Future<PaymentVerifyResult> verifyPayment({
    required String paymentId,
    required String tripId,
    required String bidId,
    required String orderId,
    String? signature,
  }) async {
    try {
      final raw = await ApiClient.instance.post<dynamic>(
        ApiEndpoints.trips.verifyPayment, // /payment/verify
        data: {
          'paymentId': paymentId,
          'tripId': tripId,
          'bidId': bidId,
          'orderId': orderId,
          if (signature != null && signature.isNotEmpty) 'signature': signature,
        },
      );

      final data = _extractData(raw);
      final success = data['success'] == null ? true : data['success'] == true;
      if (!success) {
        throw Exception(
            (data['message'] ?? 'Payment verification failed').toString());
      }

      return PaymentVerifyResult(
        success: true,
        message: data['message']?.toString(),
        otp: data['otp']?.toString(),
        paymentId: (data['paymentId'] ?? paymentId).toString(),
        raw: data,
      );
    } on DioException catch (e) {
      final msg = e.error is ApiException
          ? (e.error as ApiException).message
          : 'Payment verification failed (${e.response?.statusCode ?? "network error"})';
      throw Exception(msg);
    }
  }

  /// Fetch trip confirmation details after a successful payment.
  Future<TripConfirmationModel> getTripConfirmation(String tripId) async {
    try {
      final data = await ApiClient.instance.get<Map<String, dynamic>>(
        ApiEndpoints.trips.confirmation(tripId),
      );
      return TripConfirmationModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(
          'Failed to fetch trip confirmation (${e.response?.statusCode ?? "network error"})');
    }
  }

  // ── helpers ──
  Map<String, dynamic> _extractData(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data is Map<String, dynamic>) return data;
      return payload;
    }
    return <String, dynamic>{};
  }

  String? _stringField(Map<String, dynamic> data, List<String> keys) {
    for (final k in keys) {
      final v = data[k];
      if (v is String && v.trim().isNotEmpty) {
        final s = v.trim();
        if (s.toLowerCase() != 'undefined' && s.toLowerCase() != 'null') {
          return s;
        }
      }
    }
    return null;
  }

  double _round(double v) =>
      v.isFinite ? double.parse(v.toStringAsFixed(2)) : 0.0;
}
