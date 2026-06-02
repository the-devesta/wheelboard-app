import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../widgets/custom_snackbar.dart';
import '../../utils/app_logger.dart';
import '../../models/service_booking_model.dart';

class BookingDetailsController extends GetxController {
  final String serviceId;
  final ServiceBookingModel? initialBookingData;

  BookingDetailsController({required this.serviceId, this.initialBookingData});

  // Observable states
  final isLoading = false.obs;
  final isUpdating = false.obs;
  final bookingData = Rxn<ServiceBookingModel>();
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
      AppLogger.d("==========================================");
      AppLogger.d("🔍 FETCHING BOOKING DETAILS");
      AppLogger.d("==========================================");
      AppLogger.d("🔍 Service ID: $serviceId");

      final data = await ApiClient.instance.get<List<dynamic>>(
        ApiEndpoints.services.bookingsByService(serviceId),
      );

      AppLogger.d("🔍 Parsed Data Count: ${data.length}");

      if (data.isNotEmpty) {
        bookingData.value = ServiceBookingModel.fromJson(
          data[0] as Map<String, dynamic>,
        );
        AppLogger.d("✅ Successfully fetched booking details");
      } else {
        SnackBarHelper.error("No booking details found");
      }
    } on DioException catch (e) {
      AppLogger.e("Error fetching booking details: $e");
      final msg = e.error is ApiException ? (e.error as ApiException).message : 'Failed to load booking details';
      SnackBarHelper.error(msg);
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
      await ApiClient.instance.patch(
        ApiEndpoints.services.startBooking(assignmentId),
      );

      SnackBarHelper.success('Service started successfully');
      // Update local state to reflect the new status
      if (bookingData.value != null) {
        final updatedData = bookingData.value!.toJson();
        updatedData['status'] = 'started';
        bookingData.value = ServiceBookingModel.fromJson(updatedData);
      }
      // Refresh data if we have a valid serviceId
      if (serviceId.isNotEmpty) {
        await fetchBookingDetails();
      }
    } on DioException catch (e) {
      final msg = e.error is ApiException ? (e.error as ApiException).message : 'Failed to start service';
      SnackBarHelper.error(msg);
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
      await ApiClient.instance.patch(
        ApiEndpoints.services.completeBooking(assignmentId),
        data: {'amount': amount},
      );

      SnackBarHelper.success('Service completed successfully');
      // Update local state to reflect the new status
      if (bookingData.value != null) {
        final updatedData = bookingData.value!.toJson();
        updatedData['status'] = 'completed';
        updatedData['amount'] = amount;
        bookingData.value = ServiceBookingModel.fromJson(updatedData);
      }
      // Refresh data if we have a valid serviceId
      if (serviceId.isNotEmpty) {
        await fetchBookingDetails();
      }
    } on DioException catch (e) {
      final msg = e.error is ApiException ? (e.error as ApiException).message : 'Failed to complete service';
      SnackBarHelper.error(msg);
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
      await ApiClient.instance.patch(
        ApiEndpoints.services.updateBookingStatus(assignmentId),
        data: {'status': 'cancelled'},
      );

      SnackBarHelper.success('Appointment cancelled successfully');
      // Update local state to reflect the new status
      if (bookingData.value != null) {
        final updatedData = bookingData.value!.toJson();
        updatedData['status'] = 'cancelled';
        bookingData.value = ServiceBookingModel.fromJson(updatedData);
      }
      // Refresh data if we have a valid serviceId
      if (serviceId.isNotEmpty) {
        await fetchBookingDetails();
      }
      // Navigate back
      Get.back();
    } on DioException catch (e) {
      final msg = e.error is ApiException ? (e.error as ApiException).message : 'Failed to cancel appointment';
      SnackBarHelper.error(msg);
    } catch (e) {
      SnackBarHelper.error("Something went wrong: ${e.toString()}");
    } finally {
      isUpdating.value = false;
    }
  }

  /// Get current status
  String get currentStatus => bookingData.value?.status.toLowerCase() ?? '';

  /// Check if service is started
  bool get isStarted => currentStatus == 'started' || currentStatus == 'start';

  /// Check if service is completed
  bool get isCompleted => currentStatus == 'completed';

  /// Check if service is cancelled
  bool get isCancelled => currentStatus == 'cancelled';

  /// Get assignment ID
  String get assignmentId => bookingData.value?.assignmentId ?? '';

  /// Get contact number
  String get contactNumber =>
      (bookingData.value?.customerMobile ?? '').toString();

  /// Get existing amount
  num get existingAmount {
    return bookingData.value?.amount ?? 0;
  }
}
