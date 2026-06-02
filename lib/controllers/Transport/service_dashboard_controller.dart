import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:wheelboard/core/auth/auth_service.dart';
import 'package:wheelboard/core/network/api_client.dart';
import 'package:wheelboard/core/network/api_endpoints.dart';
import 'package:wheelboard/core/network/api_exception.dart';
import 'user_profile_controller.dart';
import 'package:wheelboard/models/myassign_sevice_list.dart';
import 'package:wheelboard/utils/app_logger.dart';
import 'package:wheelboard/widgets/custom_snackbar.dart';
import 'package:wheelboard/services/razorpay_service.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:uuid/uuid.dart';

class ServiceDashboardController extends GetxController {
  RxBool isLoading = false.obs;

  RxList<AssignedServiceModel> allServices = <AssignedServiceModel>[].obs;
  RxList<AssignedServiceModel> filteredServices = <AssignedServiceModel>[].obs;

  final searchCtrl = TextEditingController();

  late RazorpayService _razorpayService;
  AssignedServiceModel? _currentProcessingService;

  @override
  void onInit() {
    Future.microtask(() => getServices());
    searchCtrl.addListener(_applySearch);
    _razorpayService = RazorpayService(
      onPaymentSuccess: _onPaymentSuccess,
      onPaymentError: _onPaymentError,
      onExternalWallet: _onExternalWallet,
    );
    super.onInit();
  }

  @override
  void onClose() {
    _razorpayService.dispose();
    super.onClose();
  }

  RxInt expandedIndex = (-1).obs;

  void toggleExpand(int index) {
    expandedIndex.value = expandedIndex.value == index ? -1 : index;
  }

  Future<void> getServices() async {
    try {
      isLoading.value = true;
      final userId = AuthService.to.currentUserId;

      final data = await ApiClient.instance.get<List<dynamic>>(
        ApiEndpoints.services.myBookings,
        queryParameters: {'userId': userId},
      );

      allServices.assignAll(
        data.map((e) => AssignedServiceModel.fromJson(e)).toList(),
      );

      filteredServices.assignAll(allServices);
    } on DioException catch (e) {
      final msg = e.error is ApiException ? (e.error as ApiException).message : 'Failed to load services';
      AppLogger.e('Error fetching services: $msg');
    } catch (e) {
      AppLogger.e('Error fetching services: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _applySearch() {
    final q = searchCtrl.text.toLowerCase().trim();

    if (q.isEmpty) {
      filteredServices.assignAll(allServices);
    } else {
      filteredServices.assignAll(
        allServices.where((service) {
          return service.serviceTitle.toLowerCase().contains(q) ||
              service.description.toLowerCase().contains(q);
        }).toList(),
      );
    }
  }

  Future<bool> deleteService(String assignmentId) async {
    try {
      isLoading.value = true;

      await ApiClient.instance.patch(
        ApiEndpoints.services.updateBookingStatus(assignmentId),
        data: {'status': 'cancelled'},
      );

      SnackBarHelper.success("Service deleted successfully!");
      getServices();
      return true;
    } on DioException catch (e) {
      AppLogger.d("❌ Error deleting service: $e");
      final msg = e.error is ApiException ? (e.error as ApiException).message : 'Failed to delete service';
      SnackBarHelper.error(msg);
      return false;
    } catch (e) {
      AppLogger.d("❌ Error deleting service: $e");
      SnackBarHelper.error("Failed to delete service");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> initiatePayment(AssignedServiceModel service) async {
    try {
      if (service.paymentAmount <= 0) {
        SnackBarHelper.error("Invalid amount for payment");
        return;
      }
      _currentProcessingService = service;

      String prefillEmail = "hello@wheelboard.in";
      String prefillContact = "7420861942";

      try {
        if (Get.isRegistered<UserProfileController>()) {
          final profile = Get.find<UserProfileController>().userProfile.value;
          if (profile != null) {
            prefillEmail = profile.email ?? profile.mobileNo ?? prefillEmail;
            prefillContact = profile.mobileNo ?? prefillContact;
          }
        }
      } catch (e) {
        AppLogger.d("Could not fetch user profile for payment prefill: $e");
      }

      await _razorpayService.openCheckout(
        amountInPaise: (service.paymentAmount * 100).toInt(),
        orderId: "",
        description: "Payment for ${service.serviceTitle}",
        prefillEmail: prefillEmail,
        prefillContact: prefillContact,
      );
    } catch (e) {
      AppLogger.d("Error initiating payment: $e");
      SnackBarHelper.error("Failed to start payment: $e");
    }
  }

  void _onPaymentSuccess(PaymentSuccessResponse response) {
    if (_currentProcessingService != null) {
      _processPaymentCompletion(_currentProcessingService!, response);
    }
  }

  void _onPaymentError(PaymentFailureResponse response) {
    SnackBarHelper.error("Payment Failed: ${response.message}");
    AppLogger.d("Payment Error: ${response.code} - ${response.message}");
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    SnackBarHelper.success("External Wallet Selected: ${response.walletName}");
  }

  Future<void> _processPaymentCompletion(
    AssignedServiceModel service,
    PaymentSuccessResponse paymentResponse,
  ) async {
    try {
      isLoading.value = true;
      final userId = AuthService.to.currentUserId;

      final paymentId = const Uuid().v4();
      final now = DateTime.now().toIso8601String();

      final payload = {
        "paymentId": paymentId,
        "purposeOfPayment": "Service Completion: ${service.category}",
        "paymentAmount": service.paymentAmount,
        "serviceId": service.serviceId,
        "paymentDate": now,
        "paymentNotes": service.description,
        "userId": userId.isNotEmpty ? userId : service.assignedToUserId,
        "paymentStatus": "Success",
        "paymentMode": "Razorpay",
        "orderId": paymentResponse.orderId ?? "",
        "razorPaymentId": paymentResponse.paymentId ?? "",
        "signature": paymentResponse.signature ?? "",
        "createdDate": now,
        "assignmentId": service.assignmentId,
      };

      await ApiClient.instance.post(
        ApiEndpoints.services.verifyBookingPayment(service.assignmentId),
        data: payload,
      );

      SnackBarHelper.success("Payment Completed Successfully!");
      getServices();
    } on DioException catch (e) {
      AppLogger.d("Error completing payment on backend: $e");
      SnackBarHelper.error("Payment recorded failed at backend.");
    } catch (e) {
      AppLogger.d("Error completing payment on backend: $e");
      SnackBarHelper.error("Error completing payment.");
    } finally {
      isLoading.value = false;
      _currentProcessingService = null;
    }
  }
}
