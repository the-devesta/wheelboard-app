import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../core/auth/auth_service.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../models/service_booking_model.dart';
import '../../models/service_model.dart';
import '../../services/razorpay_service.dart';
import '../../utils/app_logger.dart';
import '../../widgets/custom_snackbar.dart';
import 'dashboard_controller.dart';
import 'user_profile_controller.dart';

/// Company (consumer) side of the service-booking flow — 1:1 with the web
/// `company/services` + `company/bookings/[id]` pages and `servicesAPI`.
///
/// Parses bookings with the correct backend shape via [ServiceBookingModel]
/// (`id` / `serviceName` / `pricing.amount` / completion + payment flags) — the
/// old `AssignedServiceModel` read legacy keys and produced empty/❌ results.
class CompanyBookingController extends GetxController {
  final isLoading = false.obs;
  final isProcessing = false.obs; // payment / lifecycle action in flight
  final bookings = <ServiceBookingModel>[].obs;
  final selected = Rxn<ServiceBookingModel>();

  RazorpayService? _razorpay;
  String? _payingBookingId;

  @override
  void onInit() {
    super.onInit();
    fetchMyBookings();
  }

  @override
  void onClose() {
    _razorpay?.dispose();
    super.onClose();
  }

  // ── list ───────────────────────────────────────────────────────────────────
  /// GET /services/bookings/my?role=company
  Future<void> fetchMyBookings() async {
    try {
      isLoading.value = true;
      final res = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.services.myBookings,
        queryParameters: {
          'userId': AuthService.to.currentUserId,
          'role': 'company',
        },
      );
      final list = res is List
          ? res
          : (res is Map ? (res['data'] ?? res['bookings'] ?? []) as List : []);
      bookings.assignAll(list
          .whereType<Map>()
          .map((e) => ServiceBookingModel.fromJson(Map<String, dynamic>.from(e)))
          .toList());
    } on DioException catch (e) {
      AppLogger.e('Failed to load bookings: ${_msg(e)}');
      SnackBarHelper.error(_msg(e, fallback: 'Failed to load bookings'));
      bookings.clear();
    } catch (e) {
      AppLogger.e('Failed to load bookings: $e');
      bookings.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// GET /services/bookings/:id
  Future<ServiceBookingModel?> getBookingById(String id) async {
    try {
      final res = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.services.bookingDetails(id),
      );
      final map = res is Map && res['data'] is Map ? res['data'] : res;
      if (map is Map) {
        final b = ServiceBookingModel.fromJson(Map<String, dynamic>.from(map));
        selected.value = b;
        return b;
      }
    } on DioException catch (e) {
      SnackBarHelper.error(_msg(e, fallback: 'Failed to load booking'));
    } catch (e) {
      SnackBarHelper.error('Failed to load booking: $e');
    }
    return null;
  }

  // ── create ──────────────────────────────────────────────────────────────────
  /// POST /services/bookings — same payload the web ServiceAssignmentModal sends.
  /// Returns the new booking id, or null on failure.
  Future<String?> createBooking({
    required ServiceModel service,
    required DateTime scheduledDate,
    String? scheduledTime,
    required String location,
    String paymentMethod = 'Online',
    String? vehicleNumber,
    String? description,
  }) async {
    try {
      isProcessing.value = true;
      final user = AuthService.to.user;
      final profile = user?.profile ?? const <String, dynamic>{};
      final companyId = AuthService.to.currentUserId;
      final companyName = (profile['companyName'] ??
              profile['fullName'] ??
              profile['businessName'] ??
              'Company')
          .toString();
      final companyPhone =
          (profile['phoneNumber'] ?? user?.phoneNumber ?? '').toString();

      final notes = [
        if ((vehicleNumber ?? '').isNotEmpty) 'Vehicle: $vehicleNumber',
        if ((description ?? '').isNotEmpty) description,
      ].join('. ');

      final payload = <String, dynamic>{
        'serviceId': service.serviceId,
        'serviceName': service.serviceTitle,
        'companyId': companyId,
        'companyName': companyName,
        if (companyPhone.isNotEmpty) 'companyPhone': companyPhone,
        'assignedBy': companyId,
        'scheduledDate': _ymd(scheduledDate),
        if ((scheduledTime ?? '').isNotEmpty) 'scheduledTime': scheduledTime,
        'status': 'Assigned',
        'paymentStatus': 'Pending',
        'paymentMethod': paymentMethod,
        'location': location.isNotEmpty ? location : 'N/A',
        'serviceType': service.serviceCategory ?? '',
        'category': service.serviceCategory ?? '',
        'providerId': service.businessId ?? '',
        'pricing': {
          'currency': service.currency ?? 'INR',
          'amount': service.amount ?? 0,
          'type': service.pricingOption,
        },
        'bookedBy': 'Company',
        'bookedByName': companyName,
        if ((vehicleNumber ?? '').isNotEmpty) 'vehicleNumber': vehicleNumber,
        if (notes.isNotEmpty) 'notes': notes,
      };

      final res = await ApiClient.instance.post<dynamic>(
        ApiEndpoints.services.createBooking,
        data: payload,
      );
      final map = res is Map && res['data'] is Map ? res['data'] : res;
      final id = (map is Map ? (map['id'] ?? map['_id']) : null)?.toString();
      SnackBarHelper.success('Service booked successfully!');
      await fetchMyBookings();
      DashboardController.refreshIfActive();
      return id;
    } on DioException catch (e) {
      SnackBarHelper.error(_msg(e, fallback: 'Failed to book service'));
      return null;
    } catch (e) {
      SnackBarHelper.error('Failed to book service: $e');
      return null;
    } finally {
      isProcessing.value = false;
    }
  }

  // ── payment (Razorpay) ──────────────────────────────────────────────────────
  void _ensureRazorpay() {
    _razorpay ??= RazorpayService(
      onPaymentSuccess: _onPaySuccess,
      onPaymentError: _onPayError,
      onExternalWallet: (_) {},
    );
  }

  /// initiate → Razorpay checkout → verify (handled in callbacks).
  Future<void> payBooking(ServiceBookingModel b) async {
    if (b.assignmentId.isEmpty) {
      SnackBarHelper.error('Missing booking reference for payment');
      return;
    }
    if (b.amount <= 0) {
      SnackBarHelper.error('Invalid amount for payment');
      return;
    }
    try {
      isProcessing.value = true;
      final order = await ApiClient.instance.post<Map<String, dynamic>>(
        ApiEndpoints.services.initiateBookingPayment(b.assignmentId),
      );
      final orderId = (order['id'] ?? order['orderId'] ?? '').toString();
      final amountPaise = order['amount'] is num
          ? (order['amount'] as num).toInt()
          : (b.amount * 100).toInt();
      final key = (order['key'] ?? order['razorpayKey'] ?? '').toString();
      final currency = (order['currency'] ?? 'INR').toString();
      if (orderId.isEmpty) {
        isProcessing.value = false;
        SnackBarHelper.error('Could not start payment. Please try again.');
        return;
      }

      String prefillEmail = 'hello@wheelboard.in';
      String prefillContact = '7420861942';
      if (Get.isRegistered<UserProfileController>()) {
        final p = Get.find<UserProfileController>().userProfile.value;
        if (p != null) {
          prefillEmail = p.email ?? prefillEmail;
          prefillContact = p.mobileNo ?? prefillContact;
        }
      }

      _payingBookingId = b.assignmentId;
      _ensureRazorpay();
      await _razorpay!.openCheckout(
        amountInPaise: amountPaise,
        orderId: orderId,
        keyOverride: key,
        currency: currency,
        description: 'Payment for ${b.serviceTitle}',
        prefillEmail: prefillEmail,
        prefillContact: prefillContact,
      );
    } on DioException catch (e) {
      isProcessing.value = false;
      SnackBarHelper.error(_msg(e, fallback: 'Failed to start payment'));
    } catch (e) {
      isProcessing.value = false;
      SnackBarHelper.error('Failed to start payment: $e');
    }
  }

  void _onPaySuccess(PaymentSuccessResponse r) async {
    final id = _payingBookingId;
    if (id == null) {
      isProcessing.value = false;
      return;
    }
    try {
      await ApiClient.instance.post<dynamic>(
        ApiEndpoints.services.verifyBookingPayment(id),
        data: {
          'razorpay_order_id': r.orderId ?? '',
          'razorpay_payment_id': r.paymentId ?? '',
          'razorpay_signature': r.signature ?? '',
        },
      );
      SnackBarHelper.success('Payment successful!');
      await fetchMyBookings();
      DashboardController.refreshIfActive();
      if (selected.value?.assignmentId == id) await getBookingById(id);
    } on DioException catch (e) {
      SnackBarHelper.error(_msg(e, fallback: 'Payment verification failed'));
    } catch (e) {
      SnackBarHelper.error('Payment verification failed: $e');
    } finally {
      _payingBookingId = null;
      isProcessing.value = false;
    }
  }

  void _onPayError(PaymentFailureResponse r) {
    SnackBarHelper.error('Payment failed: ${r.message ?? ''}');
    _payingBookingId = null;
    isProcessing.value = false;
  }

  // ── lifecycle ───────────────────────────────────────────────────────────────
  /// PATCH /services/bookings/:id/confirm-completion (company confirms).
  Future<bool> confirmCompletion(String id) =>
      _patchAction(ApiEndpoints.services.confirmCompletion(id), 'Completion confirmed');

  /// PATCH /services/bookings/:id/status
  Future<bool> cancelBooking(String id) async {
    return _patchAction(
      ApiEndpoints.services.updateBookingStatus(id),
      'Booking cancelled',
      body: {'status': 'Cancelled'},
    );
  }

  /// PATCH /services/bookings/:id/payment-status
  Future<bool> updatePaymentStatus(String id, String status) async {
    return _patchAction(
      ApiEndpoints.services.paymentStatus(id),
      'Payment marked $status',
      body: {
        'userId': AuthService.to.currentUserId,
        'role': 'company',
        'paymentStatus': status,
      },
    );
  }

  Future<bool> _patchAction(String path, String successMsg,
      {Map<String, dynamic>? body}) async {
    try {
      isProcessing.value = true;
      await ApiClient.instance.patch<dynamic>(path, data: body);
      SnackBarHelper.success(successMsg);
      await fetchMyBookings();
      DashboardController.refreshIfActive();
      final id = selected.value?.assignmentId;
      if (id != null && id.isNotEmpty) await getBookingById(id);
      return true;
    } on DioException catch (e) {
      SnackBarHelper.error(_msg(e, fallback: 'Action failed'));
      return false;
    } catch (e) {
      SnackBarHelper.error('Action failed: $e');
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  // ── helpers ──────────────────────────────────────────────────────────────────
  String _ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _msg(DioException e, {String fallback = 'Something went wrong'}) {
    if (e.error is ApiException) return (e.error as ApiException).message;
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      final m = data['message'];
      return m is List ? m.join(', ') : m.toString();
    }
    return fallback;
  }
}
