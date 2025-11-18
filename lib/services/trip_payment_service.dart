import 'dart:convert';

import '../apihelperclass/api_helper.dart';
import '../models/trip_confirmation_model.dart';
import '../utils/constants.dart';

class TripOrderResponse {
  TripOrderResponse({
    required this.orderId,
    required this.amountInPaise,
    required this.keyId,
    this.receipt,
    this.raw,
  });

  final String orderId;
  final int amountInPaise;
  final String keyId;
  final String? receipt;
  final Map<String, dynamic>? raw;
}

class TripPaymentVerificationPayload {
  TripPaymentVerificationPayload({
    required this.tripId,
    required this.bidId,
    required this.userId,
    required this.amount,
    required this.platformFee,
    required this.totalAmount,
    required this.orderId,
    this.paymentId,
    this.signature,
  });

  final String tripId;
  final String bidId;
  final String userId;
  final double amount;
  final double platformFee;
  final double totalAmount;
  final String orderId;
  final String? paymentId;
  final String? signature;

  TripPaymentVerificationPayload copyWith({
    String? orderId,
    String? paymentId,
    String? signature,
  }) {
    return TripPaymentVerificationPayload(
      tripId: tripId,
      bidId: bidId,
      userId: userId,
      amount: amount,
      platformFee: platformFee,
      totalAmount: totalAmount,
      orderId: orderId ?? this.orderId,
      paymentId: paymentId ?? this.paymentId,
      signature: signature ?? this.signature,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tripId': tripId,
      'bidId': bidId,
      'userId': userId,
      'amount': _roundCurrency(amount),
      'platformFee': _roundCurrency(platformFee),
      'totalAmount': _roundCurrency(totalAmount),
      'orderId': orderId,
      'paymentId': paymentId,
      'signature': signature,
    };
  }

  int _roundCurrency(double value) {
    if (!value.isFinite) return 0;
    return value.round();
  }
}

class TripPaymentService {
  Future<TripOrderResponse> createOrder({
    required double totalAmount,
  }) async {
    final response = await HttpHelper.postData(
      endpoint: API.createTripOrder,
      data: {'totalAmount': _currencyToInt(totalAmount)},
      headers: const {
        'accept': '*/*',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Unable to create payment order (${response.statusCode})',
      );
    }

    final Map<String, dynamic> payload =
        jsonDecode(response.body) as Map<String, dynamic>;
    final data = _extractData(payload);
    final orderId = _stringField(data, ['orderId', 'order_id', 'id']);
    final keyId = _stringField(data, ['key', 'keyId', 'key_id']);
    final amountPaise = _amountToPaise(data['amount'] ?? totalAmount);
    final receipt = _stringField(data, ['receipt'], allowNull: true);

    if (orderId == null || orderId.isEmpty) {
      throw Exception('Server did not return a valid order id');
    }

    return TripOrderResponse(
      orderId: orderId,
      amountInPaise: amountPaise,
      keyId: keyId ?? '',
      receipt: receipt,
      raw: data,
    );
  }

  Future<void> verifyPayment(
    TripPaymentVerificationPayload payload,
  ) async {
    final response = await HttpHelper.postData(
      endpoint: API.verifyTripPayment,
      data: payload.toJson(),
      headers: const {
        'accept': '*/*',
        'Content-Type': 'application/json',
      },
    );

    final bodyText = response.body;

    if (response.statusCode != 200) {
      final message =
          bodyText.isNotEmpty ? bodyText : 'Payment verification failed';
      throw Exception(
        'Payment verification failed (${response.statusCode}): $message',
      );
    }

    if (bodyText.isNotEmpty) {
      try {
        final Map<String, dynamic> body =
            jsonDecode(bodyText) as Map<String, dynamic>;
        if (body.containsKey('success') && body['success'] == false) {
          throw Exception(body['message'] ?? 'Payment verification failed');
        }
      } catch (_) {
        // Non-JSON body, ignore.
      }
    }
  }

  Map<String, dynamic> _extractData(Map<String, dynamic> payload) {
    final data = payload['data'];
    if (data is Map<String, dynamic>) return data;
    return payload;
  }

  String? _stringField(
    Map<String, dynamic> data,
    List<String> keys, {
    bool allowNull = false,
  }) {
    for (final key in keys) {
      final value = data[key];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }

  int _amountToPaise(dynamic amount) {
    double value;
    if (amount is int) {
      value = amount.toDouble();
    } else if (amount is double) {
      value = amount;
    } else {
      value = double.tryParse(amount.toString()) ?? 0;
    }
    if (value == 0) {
      throw Exception('Server returned invalid amount for order');
    }
    return (value * 100).round();
  }

  int _currencyToInt(double value) => value.round();

  /// Fetch trip confirmation details after payment
  Future<TripConfirmationModel> getTripConfirmation(String tripId) async {
    final response = await HttpHelper.getData(
      endpoint: '${API.getTripConfirmation}$tripId',
      headers: const {
        'accept': '*/*',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to fetch trip confirmation (${response.statusCode})',
      );
    }

    final Map<String, dynamic> body = jsonDecode(response.body) as Map<String, dynamic>;
    return TripConfirmationModel.fromJson(body);
  }
}

