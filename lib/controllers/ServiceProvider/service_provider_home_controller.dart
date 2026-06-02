import 'package:get/get.dart';
import 'package:dio/dio.dart';

import '../../core/auth/auth_service.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../models/service_model.dart';
import '../../utils/app_logger.dart';
import '../../widgets/custom_snackbar.dart';
import '../../models/service_booking_model.dart';

/// Controller for ServiceProvider Home, BookingList, MyListings screens
class ServiceProviderHomeController extends GetxController {
  final isLoadingServices = false.obs;
  final isLoadingBookings = false.obs;
  final isLoadingServiceDetails = false.obs;

  final services = <ServiceModel>[].obs;
  final serviceImages = <String, String>{}.obs;
  final allServiceIds = <String>[].obs;

  final allBookings = <ServiceBookingModel>[].obs;
  final filteredBookings = <ServiceBookingModel>[].obs;
  final selectedStatus = 'All'.obs;
  final totalLeads = 0.obs;

  final serviceDetails = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    Future.microtask(() => fetchMyServices());
  }

  Future<void> fetchMyServices() async {
    isLoadingServices.value = true;

    try {
      final userId = AuthService.to.currentUserId;
      if (userId.isEmpty) return;

      final data = await ApiClient.instance.get<List<dynamic>>(
        ApiEndpoints.services.list,
        queryParameters: {'userId': userId},
      );

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
          pricingOption: json['isFlatPrice'] == true ? 'Flat Price' : 'Per Hour',
          amount: json['price'],
          businessHoursFrom: json['businessFrom'],
          businessHoursTo: json['businessTo'],
          daysOpen: json['daysOpen'],
        );
      }).toList();

      for (int i = 0; i < data.length && i < services.length; i++) {
        final json = data[i] as Map<String, dynamic>;
        final images = json['images'] as List<dynamic>? ?? [];
        if (images.isNotEmpty) {
          serviceImages[services[i].serviceId] = images[0].toString();
        }
      }

      allServiceIds.value = services.map((s) => s.serviceId).toList();

      if (services.isNotEmpty) {
        fetchTotalLeads();
      }
    } on DioException catch (e) {
      final msg = e.error is ApiException ? (e.error as ApiException).message : 'Failed to load services';
      AppLogger.d('Error fetching services: $msg');
    } catch (e) {
      AppLogger.d('Error fetching services: $e');
    } finally {
      isLoadingServices.value = false;
    }
  }

  Future<void> fetchTotalLeads() async {
    try {
      int total = 0;
      for (var service in services) {
        try {
          final data = await ApiClient.instance.get<List<dynamic>>(
            ApiEndpoints.services.bookingsByService(service.serviceId),
          );
          total += data.length;
        } catch (e) {
          // continue to next service
        }
      }
      totalLeads.value = total;
    } catch (e) {
      AppLogger.d('Error fetching total leads: $e');
    }
  }

  Future<void> fetchBookings(List<String> serviceIds) async {
    isLoadingBookings.value = true;

    try {
      List<ServiceBookingModel> collectedBookings = [];

      for (String serviceId in serviceIds) {
        if (serviceId.isEmpty) continue;
        try {
          final data = await ApiClient.instance.get<List<dynamic>>(
            ApiEndpoints.services.bookingsByService(serviceId),
          );
          collectedBookings.addAll(
            data.map((e) => ServiceBookingModel.fromJson(e as Map<String, dynamic>)).toList(),
          );
        } catch (e) {
          // continue fetching others
        }
      }

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

  void applyBookingFilter() {
    if (selectedStatus.value == 'All') {
      filteredBookings.value = List.from(allBookings);
    } else {
      filteredBookings.value = allBookings.where((booking) {
        return booking.status.toLowerCase() == selectedStatus.value.toLowerCase();
      }).toList();
    }
  }

  void setStatusFilter(String status) {
    selectedStatus.value = status;
    applyBookingFilter();
  }

  Future<void> togglePublishStatus(String serviceId) async {
    final currentService = services.firstWhere(
      (s) => s.serviceId == serviceId,
      orElse: () => services.first,
    );
    final willBePublished = !currentService.isAvailable;

    isLoadingServices.value = true;

    try {
      final endpoint = willBePublished
          ? ApiEndpoints.services.publish(serviceId)
          : ApiEndpoints.services.unpublish(serviceId);

      await ApiClient.instance.post(endpoint);

      final statusText = willBePublished ? "Published" : "Unpublished";
      SnackBarHelper.success("Service $statusText successfully");
      await fetchMyServices();
    } on DioException catch (e) {
      final msg = e.error is ApiException ? (e.error as ApiException).message : 'Failed to update status';
      SnackBarHelper.error(msg);
    } catch (e) {
      SnackBarHelper.error("An error occurred: $e");
    } finally {
      isLoadingServices.value = false;
    }
  }

  Future<void> fetchServiceDetails(String serviceId) async {
    isLoadingServiceDetails.value = true;

    try {
      final rawData = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.services.details(serviceId),
      );

      if (rawData is Map<String, dynamic>) {
        if (rawData['success'] == true && rawData['data'] != null) {
          serviceDetails.value = rawData['data'] as Map<String, dynamic>;
        } else {
          serviceDetails.value = rawData;
        }
      } else if (rawData is List && rawData.isNotEmpty) {
        serviceDetails.value = rawData[0] as Map<String, dynamic>;
      }
    } on DioException catch (e) {
      final msg = e.error is ApiException ? (e.error as ApiException).message : 'Failed to load service details';
      AppLogger.d("Error fetching service details: $msg");
      SnackBarHelper.error(msg);
    } catch (e) {
      AppLogger.d("Error fetching service details: $e");
      SnackBarHelper.error("Something went wrong");
    } finally {
      isLoadingServiceDetails.value = false;
    }
  }

  String getServiceImage(String serviceId) {
    return serviceImages[serviceId] ?? '';
  }
}
