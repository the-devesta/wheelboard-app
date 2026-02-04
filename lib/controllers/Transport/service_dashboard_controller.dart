import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:wheelboard/apihelperclass/api_helper.dart';
import 'user_profile_controller.dart';
import 'package:wheelboard/models/dashboard_model.dart';
import 'package:wheelboard/models/myassign_sevice_list.dart';
import 'package:wheelboard/services/auth_service.dart';
import 'package:wheelboard/utils/app_logger.dart';
import 'package:wheelboard/utils/constants.dart';
import 'package:wheelboard/utils/error_handler.dart';
import 'package:wheelboard/widgets/custom_snackbar.dart';
import 'package:wheelboard/services/razorpay_service.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:wheelboard/utils/session_manager.dart';

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
      final response = await HttpHelper.getData(
        endpoint:
            '${API.getAssingServiceList}${Get.find<AuthService>().userId}',
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        debugPrint('data====>>>${response.body}');
        final List data = jsonDecode(response.body);

        allServices.assignAll(
          data.map((e) => AssignedServiceModel.fromJson(e)).toList(),
        );

        filteredServices.assignAll(allServices);
      }

      isLoading.value = false;
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
      final endpoint = '${API.deleteService}/$assignmentId/delete';

      final response = await HttpHelper.postData(
        endpoint: endpoint,
        data: {},
        headers: {'Accept': '*/*', 'Content-Type': 'application/json'},
      );

      AppLogger.d("🗑️ Delete response status: ${response.statusCode}");
      AppLogger.d("🗑️ Delete response body: ${response.body}");

      if (response.statusCode == 200) {
        SnackBarHelper.success("Service deleted successfully!");
        getServices();
        return true;
      }

      final errorMessage = ErrorHandler.parseError(
        response.body,
        statusCode: response.statusCode,
      );

      SnackBarHelper.error(errorMessage);
      return false;
    } catch (e) {
      AppLogger.d("❌ Error deleting service: $e");
      final errorMessage = ErrorHandler.handleNetworkError(e);
      SnackBarHelper.error(errorMessage);
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
      // Generate a temporary order ID or use assignment ID

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
      final sessionManager = SessionManager();
      final userId = await sessionManager.getString(
        "userId",
      ); // or service.assignedToUserId

      final paymentId = const Uuid().v4();
      final now = DateTime.now().toIso8601String();

      final payload = {
        "paymentId": paymentId,
        "purposeOfPayment": "Service Completion: ${service.category}",
        "paymentAmount": service.paymentAmount,
        "serviceId": service.serviceId,
        "paymentDate": now,
        "paymentNotes": service.description,
        "userId": userId ?? service.assignedToUserId,
        "paymentStatus": "Success",
        "paymentMode": "Razorpay",
        "orderId": paymentResponse.orderId ?? "",
        "razorPaymentId": paymentResponse.paymentId ?? "",
        "signature": paymentResponse.signature ?? "",
        "createdDate": now,
        "assignmentId": service.assignmentId,
      };

      final response = await HttpHelper.postData(
        endpoint:
            '${API.completePayment}', // Need to ensure this API constant exists
        data: payload,
        headers: {'Accept': '*/*', 'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        SnackBarHelper.success("Payment Completed Successfully!");
        // Refresh list
        getServices();
        // User requested: "GO TO ROUTE /ServiceDashboardScreen"
        // Since we are already here, refreshing is fine. Or we can reload.
      } else {
        SnackBarHelper.error("Payment recorded failed at backend.");
        AppLogger.d("Backend api fail: ${response.body}");
      }
    } catch (e) {
      AppLogger.d("Error completing payment on backend: $e");
      SnackBarHelper.error("Error completing payment.");
    } finally {
      isLoading.value = false;
      _currentProcessingService = null;
    }
  }
}
