import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../apihelperclass/api_helper.dart';
import '../../models/service_model.dart';
import '../../utils/constants.dart';
import '../../utils/session_manager.dart';
import '../../utils/app_logger.dart';
import '../../widgets/custom_snackbar.dart';
import '../../models/service_booking_model.dart';

/// Controller for ServiceProvider Home, BookingList, MyListings screens
class ServiceProviderHomeController extends GetxController {
  // Observable states
  final isLoadingServices = false.obs;
  final isLoadingBookings = false.obs;
  final isLoadingServiceDetails = false.obs;

  // Services data
  final services = <ServiceModel>[].obs;
  final serviceImages = <String, String>{}.obs;
  final allServiceIds = <String>[].obs;

  // Bookings data
  final allBookings = <ServiceBookingModel>[].obs;
  final filteredBookings = <ServiceBookingModel>[].obs;
  final selectedStatus = 'All'.obs;
  final totalLeads = 0.obs;

  // Service details
  final serviceDetails = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    Future.microtask(() => fetchMyServices());
  }

  /// Fetch all services for the current user
  Future<void> fetchMyServices() async {
    isLoadingServices.value = true;

    try {
      final sessionManager = SessionManager();
      final userId = await sessionManager.getString("userId");
      final token = await sessionManager.getString("authToken");

      if (userId == null || userId.isEmpty) {
        return;
      }

      final response = await HttpHelper.getData(
        endpoint: '${API.serviceListByUser}$userId',
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data =
            jsonDecode(response.body) as List<dynamic>? ?? [];

        services.value = data.map((e) {
          final json = e as Map<String, dynamic>;
          return ServiceModel(
            serviceId: json['serviceId'] ?? '',
            serviceTitle: json['title'] ?? json['serviceTitle'] ?? '',
            city: json['city'] ?? '',
            fullAddress: json['fullAddress'] ?? '',
            isAvailable: json['isVisible'] ?? false,
            businessName: json['businessName'] ?? '',
            businessType: json['businessType'] ?? '',
            serviceCategory: json['serviceCategory'],
            contactNumber: json['contactNumber'],
            whatsappNumber: json['whatsappNumber'],
            description: json['description'],
            pricingOption: json['isFlatPrice'] == true
                ? 'Flat Price'
                : 'Per Hour',
            amount: json['price'],
            businessHoursFrom: json['businessFrom'],
            businessHoursTo: json['businessTo'],
            daysOpen: json['daysOpen'],
          );
        }).toList();

        // Store images separately for each service
        for (int i = 0; i < data.length && i < services.length; i++) {
          final json = data[i] as Map<String, dynamic>;
          final images = json['images'] as List<dynamic>? ?? [];
          if (images.isNotEmpty) {
            serviceImages[services[i].serviceId] = images[0].toString();
          }
        }

        // Update service IDs list
        allServiceIds.value = services.map((s) => s.serviceId).toList();

        // Fetch total leads after services are loaded
        if (services.isNotEmpty) {
          fetchTotalLeads();
        }
      }
    } catch (e) {
      AppLogger.d('Error fetching services: $e');
    } finally {
      isLoadingServices.value = false;
    }
  }

  /// Fetch total leads count for all services
  Future<void> fetchTotalLeads() async {
    try {
      final sessionManager = SessionManager();
      final token = await sessionManager.getString("authToken");

      int total = 0;
      for (var service in services) {
        final endpoint =
            '${API.serviceAssignList}?serviceId=${service.serviceId}';
        final response = await HttpHelper.getData(
          endpoint: endpoint,
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
            'Accept': '*/*',
          },
        );

        if (response.statusCode == 200) {
          final List<dynamic> data =
              jsonDecode(response.body) as List<dynamic>? ?? [];
          total += data.length;
        }
      }

      totalLeads.value = total;
    } catch (e) {
      AppLogger.d('Error fetching total leads: $e');
    }
  }

  /// Fetch bookings for multiple service IDs
  Future<void> fetchBookings(List<String> serviceIds) async {
    isLoadingBookings.value = true;

    try {
      final sessionManager = SessionManager();
      final token = await sessionManager.getString("authToken");

      List<ServiceBookingModel> collectedBookings = [];

      for (String serviceId in serviceIds) {
        if (serviceId.isEmpty) continue;

        final endpoint = '${API.serviceAssignList}?serviceId=$serviceId';
        final response = await HttpHelper.getData(
          endpoint: endpoint,
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
            'Accept': '*/*',
          },
        );

        if (response.statusCode == 200) {
          final List<dynamic> data =
              jsonDecode(response.body) as List<dynamic>? ?? [];
          collectedBookings.addAll(
            data
                .map(
                  (e) =>
                      ServiceBookingModel.fromJson(e as Map<String, dynamic>),
                )
                .toList(),
          );
        }
      }

      // Sort by date (descending)
      collectedBookings.sort((a, b) {
        final dateA = DateTime.tryParse(a.scheduledDate) ?? DateTime(0);
        final dateB = DateTime.tryParse(b.scheduledDate) ?? DateTime(0);
        return dateB.compareTo(dateA);
      });

      allBookings.value = collectedBookings;
      applyBookingFilter();
    } catch (e) {
      AppLogger.d("Error fetching bookings: $e");
    } finally {
      isLoadingBookings.value = false;
    }
  }

  /// Apply status filter to bookings
  void applyBookingFilter() {
    if (selectedStatus.value == 'All') {
      filteredBookings.value = List.from(allBookings);
    } else {
      filteredBookings.value = allBookings.where((booking) {
        final status = booking.status.toLowerCase();
        return status == selectedStatus.value.toLowerCase();
      }).toList();
    }
  }

  /// Set booking status filter
  void setStatusFilter(String status) {
    selectedStatus.value = status;
    applyBookingFilter();
  }

  /// Toggle publish/unpublish status for a service
  Future<void> togglePublishStatus(String serviceId) async {
    // Find current service to determine anticipated new state
    final currentService = services.firstWhere(
      (s) => s.serviceId == serviceId,
      orElse: () => services.first,
    );
    final willBePublished = !currentService.isAvailable;

    isLoadingServices.value = true;

    try {
      final sessionManager = SessionManager();
      final userId = await sessionManager.getString("userId");
      if (userId == null || userId.isEmpty) {
        return;
      }

      final response = await HttpHelper.postData(
        endpoint:
            '${API.serviceTogglePublishUnpublish}?serviceId=$serviceId&userId=$userId',
        data: {},
      );

      if (response.statusCode == 200) {
        final statusText = willBePublished ? "Published" : "Unpublished";
        Get.snackbar(
          "Success",
          "Service $statusText successfully",
          backgroundColor: willBePublished ? Colors.green : Colors.orange,
          colorText: Colors.white,
        );
        await fetchMyServices(); // Refresh list to get new status
      } else {
        Get.snackbar(
          "Error",
          "Failed to update status",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "An error occurred: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingServices.value = false;
    }
  }

  /// Fetch service details by ID
  Future<void> fetchServiceDetails(String serviceId) async {
    isLoadingServiceDetails.value = true;

    try {
      final sessionManager = SessionManager();
      final token = await sessionManager.getString("authToken");

      final response = await HttpHelper.getData(
        endpoint: '${API.serviceDetail}$serviceId',
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
          'Accept': '*/*',
        },
      );

      if (response.statusCode == 200) {
        final dynamic rawData = jsonDecode(response.body);

        if (rawData is Map<String, dynamic>) {
          // Check if response has success/data wrapper
          if (rawData['success'] == true && rawData['data'] != null) {
            serviceDetails.value = rawData['data'] as Map<String, dynamic>;
          } else {
            // Use raw data directly
            serviceDetails.value = rawData;
          }
        } else if (rawData is List && rawData.isNotEmpty) {
          serviceDetails.value = rawData[0] as Map<String, dynamic>;
        }
      } else {
        SnackBarHelper.error("Failed to load service details");
      }
    } catch (e) {
      AppLogger.d("Error fetching service details: $e");
      SnackBarHelper.error("Something went wrong");
    } finally {
      isLoadingServiceDetails.value = false;
    }
  }

  /// Get image URL for a service
  String getServiceImage(String serviceId) {
    return serviceImages[serviceId] ?? '';
  }
}
