import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../apihelperclass/api_helper.dart';
import '../../utils/constants.dart';
import '../../utils/session_manager.dart';
import '../../widgets/custom_snackbar.dart';
import '../../utils/app_logger.dart';

class BookingDetailsController extends GetxController {
  final String serviceId;
  final Map<String, dynamic>? initialBookingData;

  BookingDetailsController({required this.serviceId, this.initialBookingData});

  // Observable states
  final isLoading = false.obs;
  final isUpdating = false.obs;
  final bookingData = Rxn<Map<String, dynamic>>();
  final notesController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    AppLogger.d("🔍 BookingDetailsController initialized");
    AppLogger.d("🔍 Received Service ID: $serviceId");

    if (initialBookingData != null) {
      bookingData.value = initialBookingData;
      isLoading.value = false;
      AppLogger.d("✅ Data passed from previous screen. Skipping API fetch.");
    } else {
      fetchBookingDetails();
    }
  }

  @override
  void onClose() {
    notesController.dispose();
    super.onClose();
  }

  /// Fetch booking details from API
  Future<void> fetchBookingDetails() async {
    isLoading.value = true;

    try {
      final sessionManager = SessionManager();
      final token = await sessionManager.getString("authToken");

      AppLogger.d("==========================================");
      AppLogger.d("🔍 FETCHING BOOKING DETAILS");
      AppLogger.d("==========================================");
      AppLogger.d("🔍 Service ID: $serviceId");

      final endpoint = '${API.serviceAssignList}?serviceId=$serviceId';
      AppLogger.d("🔍 Endpoint: $endpoint");

      final response = await HttpHelper.getData(
        endpoint: endpoint,
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
      );

      AppLogger.d("🔍 Response Status Code: ${response.statusCode}");
      AppLogger.d("🔍 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data =
            jsonDecode(response.body) as List<dynamic>? ?? [];

        AppLogger.d("🔍 Parsed Data Count: ${data.length}");

        if (data.isNotEmpty) {
          bookingData.value = data[0] as Map<String, dynamic>;
          AppLogger.d("✅ Successfully fetched booking details");
        } else {
          SnackBarHelper.error("No booking details found");
        }
      } else {
        SnackBarHelper.error("Failed to load booking details");
      }
    } catch (e) {
      AppLogger.e("Error fetching booking details: $e");
      SnackBarHelper.error("Something went wrong: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  /// Start a service
  Future<void> startService(String assignmentId) async {
    if (assignmentId.isEmpty) {
      SnackBarHelper.error("Assignment ID not found");
      return;
    }

    isUpdating.value = true;

    try {
      final sessionManager = SessionManager();
      final token = await sessionManager.getString("authToken");

      final response = await HttpHelper.postData(
        endpoint:
            '${API.updateServiceStatus}?assignmentId=$assignmentId&status=start',
        data: {},
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
          'Accept': '*/*',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        SnackBarHelper.success('Service started successfully');
        // Update local state to reflect the new status
        if (bookingData.value != null) {
          bookingData.update((data) {
            data?['status'] = 'started';
          });
        }
        // Refresh data if we have a valid serviceId
        if (serviceId.isNotEmpty) {
          await fetchBookingDetails();
        }
      } else {
        String errorMessage = "Failed to start service";
        try {
          final body = json.decode(response.body);
          errorMessage = body['message'] ?? body['error'] ?? errorMessage;
        } catch (_) {
          if (response.body.isNotEmpty) {
            errorMessage = response.body;
          }
        }
        SnackBarHelper.error(errorMessage);
      }
    } catch (e) {
      SnackBarHelper.error("Something went wrong: ${e.toString()}");
    } finally {
      isUpdating.value = false;
    }
  }

  /// Complete a service with amount
  Future<void> completeService(String assignmentId, double amount) async {
    if (assignmentId.isEmpty) {
      SnackBarHelper.error("Assignment ID not found");
      return;
    }

    isUpdating.value = true;

    try {
      final sessionManager = SessionManager();
      final token = await sessionManager.getString("authToken");

      // Call complete-service API with assignmentId and amount
      final response = await HttpHelper.postData(
        endpoint:
            '${API.completeService}?assignmentId=$assignmentId&amount=$amount',
        data: {},
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
          'Accept': '*/*',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        SnackBarHelper.success('Service completed successfully');
        // Update local state to reflect the new status
        if (bookingData.value != null) {
          bookingData.update((data) {
            data?['status'] = 'completed';
            data?['amount'] = amount;
          });
        }
        // Refresh data if we have a valid serviceId
        if (serviceId.isNotEmpty) {
          await fetchBookingDetails();
        }
      } else {
        String errorMessage = "Failed to complete service";
        try {
          final body = json.decode(response.body);
          errorMessage = body['message'] ?? body['error'] ?? errorMessage;
        } catch (_) {
          if (response.body.isNotEmpty) {
            errorMessage = response.body;
          }
        }
        SnackBarHelper.error(errorMessage);
      }
    } catch (e) {
      SnackBarHelper.error("Something went wrong: ${e.toString()}");
    } finally {
      isUpdating.value = false;
    }
  }

  /// Cancel a service
  Future<void> cancelService(String assignmentId) async {
    if (assignmentId.isEmpty) {
      SnackBarHelper.error("Assignment ID not found");
      return;
    }

    isUpdating.value = true;

    try {
      final sessionManager = SessionManager();
      final token = await sessionManager.getString("authToken");

      final response = await HttpHelper.postData(
        endpoint: '${API.cancelService}?assignmentId=$assignmentId',
        data: {},
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
          'Accept': '*/*',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        SnackBarHelper.success('Appointment cancelled successfully');
        // Update local state to reflect the new status
        if (bookingData.value != null) {
          bookingData.update((data) {
            data?['status'] = 'cancelled';
          });
        }
        // Refresh data if we have a valid serviceId
        if (serviceId.isNotEmpty) {
          await fetchBookingDetails();
        }
        // Navigate back
        Get.back();
      } else {
        String errorMessage = "Failed to cancel appointment";
        try {
          final body = json.decode(response.body);
          errorMessage = body['message'] ?? body['error'] ?? errorMessage;
        } catch (_) {
          if (response.body.isNotEmpty) {
            errorMessage = response.body;
          }
        }
        SnackBarHelper.error(errorMessage);
      }
    } catch (e) {
      SnackBarHelper.error("Something went wrong: ${e.toString()}");
    } finally {
      isUpdating.value = false;
    }
  }

  /// Get current status
  String get currentStatus =>
      bookingData.value?['status']?.toString().toLowerCase() ?? '';

  /// Check if service is started
  bool get isStarted => currentStatus == 'started' || currentStatus == 'start';

  /// Check if service is completed
  bool get isCompleted => currentStatus == 'completed';

  /// Check if service is cancelled
  bool get isCancelled => currentStatus == 'cancelled';

  /// Get assignment ID
  String get assignmentId => bookingData.value?['assignmentId'] ?? '';

  /// Get contact number
  String get contactNumber =>
      (bookingData.value?['contactNumber'] ??
              bookingData.value?['customerMobile'] ??
              bookingData.value?['mobileNumber'] ??
              '')
          .toString();

  /// Get existing amount
  num get existingAmount {
    final amount = bookingData.value?['amount'];
    if (amount != null && amount is num) {
      return amount;
    }
    return 0;
  }
}
