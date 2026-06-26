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
import '../../models/lead_model.dart';
import '../../services/lead_service.dart';

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
  // Real lead-CRM stats (total/converted/conversion rate) for the dashboard.
  final leadStats = Rxn<LeadStats>();
  final LeadService _leadService = LeadService();

  final serviceDetails = Rxn<Map<String, dynamic>>();

  /// Total bookings received by this provider — drives the Home "Bookings" stat.
  int get totalBookings => allBookings.length;

  @override
  void onInit() {
    super.onInit();
    Future.microtask(() {
      fetchMyServices();
      // Bookings are resolved from the JWT (provider id), so they can load in
      // parallel with services — needed for the Home "Bookings" count card.
      fetchBookings();
    });
  }

  Future<void> fetchMyServices() async {
    isLoadingServices.value = true;

    try {
      final userId = AuthService.to.currentUserId;
      if (userId.isEmpty) return;

      // The backend `GET /services` filters on `businessId` (mapped to the
      // owning user) — the SAME param the web sends. Sending `userId` was
      // ignored, so the listing showed the wrong/all services.
      final data = await ApiClient.instance.get<List<dynamic>>(
        ApiEndpoints.services.list,
        queryParameters: {'businessId': userId},
      );

      // Parse with the canonical `ServiceModel.fromJson` (reads the real backend
      // keys: id/title/pricing/availability/contactInfo/images/status) instead
      // of the previous hand-rolled map that read legacy keys.
      services.value = data
          .whereType<Map<String, dynamic>>()
          .map(ServiceModel.fromJson)
          .toList();

      serviceImages.clear();
      for (final service in services) {
        if (service.images.isNotEmpty) {
          serviceImages[service.serviceId] = service.images.first;
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

  /// Real lead-CRM stats from `/leads/provider/:id/stats` (mirrors web), instead
  /// of the old proxy that counted bookings per service via N+1 requests.
  Future<void> fetchTotalLeads() async {
    try {
      final providerId = AuthService.to.currentUserId;
      if (providerId.isEmpty) return;
      final stats = await _leadService.getStats(providerId);
      leadStats.value = stats;
      totalLeads.value = stats.total;
    } catch (e) {
      AppLogger.d('Error fetching lead stats: $e');
    }
  }

  /// All bookings for the provider in a single request via
  /// `/services/bookings/provider/:id` (the backend resolves the provider from
  /// the JWT). Replaces the previous N+1 per-service fetch, which also missed
  /// bookings whose providerId had been backfilled. The optional [serviceIds]
  /// arg is kept for call-site compatibility but no longer used.
  Future<void> fetchBookings([List<String>? serviceIds]) async {
    isLoadingBookings.value = true;

    try {
      final providerId = AuthService.to.currentUserId;
      if (providerId.isEmpty) {
        allBookings.clear();
        applyBookingFilter();
        return;
      }

      final data = await ApiClient.instance.get<List<dynamic>>(
        ApiEndpoints.services.providerBookings(providerId),
      );

      final collectedBookings = data
          .whereType<Map<String, dynamic>>()
          .map(ServiceBookingModel.fromJson)
          .toList();

      collectedBookings.sort((a, b) {
        final dateA = DateTime.tryParse(a.scheduledDate) ?? DateTime(0);
        final dateB = DateTime.tryParse(b.scheduledDate) ?? DateTime(0);
        return dateB.compareTo(dateA);
      });

      allBookings.value = collectedBookings;
      applyBookingFilter();
    } on DioException catch (e) {
      final msg = e.error is ApiException ? (e.error as ApiException).message : 'Failed to load bookings';
      AppLogger.d("Error fetching bookings: $msg");
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
