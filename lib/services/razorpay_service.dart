import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../utils/app_logger.dart';

typedef PaymentSuccessHandler = void Function(PaymentSuccessResponse response);
typedef PaymentErrorHandler = void Function(PaymentFailureResponse response);
typedef ExternalWalletHandler = void Function(ExternalWalletResponse response);

class RazorpayService {
  RazorpayService({
    required PaymentSuccessHandler onPaymentSuccess,
    required PaymentErrorHandler onPaymentError,
    required ExternalWalletHandler onExternalWallet,
  }) {
    _log('Initializing Razorpay SDK');
    _razorpay = Razorpay()
      ..on(Razorpay.EVENT_PAYMENT_SUCCESS, onPaymentSuccess)
      ..on(Razorpay.EVENT_PAYMENT_ERROR, onPaymentError)
      ..on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);
  }

  static const String _keyId = 'rzp_test_P3ApmD21Le7iZa';

  Razorpay? _razorpay;

  Future<void> openCheckout({
    required int amountInPaise,
    required String orderId,
    required String description,
    String? keyOverride,
    String? receipt,
    String currency = 'INR',
    String customerName = 'WheelBoard',
    String prefillContact = '9999999999',
    String prefillEmail = 'payments@wheelboard.app',
    String? image,
    Map<String, dynamic>? notes,
  }) async {
    if (amountInPaise <= 0) {
      throw Exception('Payment amount must be greater than zero');
    }
    _log(
      'Opening Razorpay order | orderId=$orderId amountPaise=$amountInPaise',
      extra: {
        'currency': currency,
        'notes': notes ?? {},
        if (receipt != null) 'receipt': receipt,
      },
    );

    final options = <String, dynamic>{
      'key': keyOverride != null && keyOverride.isNotEmpty
          ? keyOverride
          : _keyId,
      'amount': amountInPaise,
      'currency': currency,
      'name': customerName,
      'description': description,
      'order_id': orderId,
      'timeout': 120,
      'prefill': {'contact': prefillContact, 'email': prefillEmail},
      'notes': notes ?? {},
      'theme': {'color': '#F36969'},
      'image':
          image ?? 'https://wheelboardapi.addonshareware.com/images/logo.png',
    };

    if (_razorpay == null) {
      _log('Razorpay instance is null just before opening checkout');
      throw Exception('Razorpay is not initialized');
    }

    try {
      _log('Opening Razorpay checkout sheet', extra: options);
      _razorpay!.open(options);
    } on PlatformException catch (e, stackTrace) {
      _log(
        'PlatformException while opening Razorpay checkout',
        error: e,
        stackTrace: stackTrace,
      );
      final reason = e.message?.isNotEmpty == true ? e.message : e.code;
      throw Exception('Unable to launch Razorpay: $reason');
    } catch (e, stackTrace) {
      _log(
        'Unknown exception while opening Razorpay checkout',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  void dispose() {
    _log('Disposing Razorpay SDK');
    _razorpay?.clear();
    _razorpay = null;
  }

  void _log(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Object? extra,
  }) {
    final buffer = StringBuffer('[RazorpayService] $message');
    if (error != null) {
      buffer.write(' | error: $error');
    }
    if (extra != null) {
      buffer.write(' | extra: ${_safeJson(extra)}');
    }

    if (kDebugMode) {
      AppLogger.d(buffer.toString());
      if (stackTrace != null) {
        AppLogger.d(stackTrace.toString());
      }
    } else {
      developer.log(
        buffer.toString(),
        name: 'wheelboard.razorpay',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  String _safeJson(Object object) {
    try {
      return jsonEncode(object);
    } catch (_) {
      return object.toString();
    }
  }
}
