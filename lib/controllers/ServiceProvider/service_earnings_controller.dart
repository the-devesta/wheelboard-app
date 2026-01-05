import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wheelboard/apihelperclass/api_helper.dart';
import 'package:wheelboard/models/ServiceProvider/service_earnings_model.dart';
import 'package:wheelboard/services/auth_service.dart';
import 'package:wheelboard/utils/constants.dart';
import '../../utils/app_logger.dart';

class ServiceEarningsController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  var isLoading = true.obs;
  var isRecordingPayment = false.obs;
  var dashboardData = Rxn<ServiceEarningsModel>();

  @override
  void onInit() {
    super.onInit();
    fetchEarningsDashboard();
  }

  Future<void> fetchEarningsDashboard() async {
    try {
      isLoading(true);
      final userId = _authService.currentUserId;
      if (userId.isEmpty) {
        AppLogger.d('⚠️ User not logged in or userId is missing');
        isLoading(false);
        return;
      }

      AppLogger.d("💰 Fetching service provider earnings for userId: $userId");

      final response = await HttpHelper.getData(
        endpoint: '${API.serviceEarningsDashboard}?userId=$userId',
        headers: {
          'Authorization': 'Bearer ${_authService.currentToken}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        dashboardData.value = ServiceEarningsModel.fromJson(data);
        AppLogger.d("✅ Earnings dashboard data loaded successfully");
      } else {
        AppLogger.d('❌ Failed to load earnings data: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.d('❌ Error fetching earnings dashboard data: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<bool> recordPayment({
    required String serviceId,
    required double amount,
    required String purpose,
    required String notes,
  }) async {
    try {
      isRecordingPayment(true);
      final userId = _authService.currentUserId;

      final Map<String, dynamic> paymentData = {
        "purposeOfPayment": purpose,
        "paymentAmount": amount,
        "serviceId": serviceId,
        "paymentDate": DateTime.now().toIso8601String(),
        "paymentNotes": notes,
        "userId": userId,
      };

      AppLogger.d("💸 Recording payment: ${jsonEncode(paymentData)}");

      final response = await HttpHelper.postData(
        endpoint: API.createPayment,
        data: paymentData,
        headers: {
          'Authorization': 'Bearer ${_authService.currentToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          "Success",
          "Payment recorded successfully",
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
          snackPosition: SnackPosition.BOTTOM,
        );
        fetchEarningsDashboard(); // Refresh data
        return true;
      } else {
        AppLogger.d('❌ Failed to record payment: ${response.statusCode}');
        Get.snackbar(
          "Error",
          "Failed to record payment",
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      AppLogger.d('❌ Error recording payment: $e');
      Get.snackbar(
        "Error",
        "Something went wrong",
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isRecordingPayment(false);
    }
  }
}
