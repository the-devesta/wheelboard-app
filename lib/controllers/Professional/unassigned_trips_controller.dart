import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../models/unassigned_trip_model.dart';
import '../../widgets/custom_snackbar.dart';
import 'package:wheelboard/core/auth/auth_service.dart';
import '../../utils/kyc_helper.dart';
import '../../utils/app_logger.dart';

class UnassignedTripsController extends GetxController {
  var isLoading = false.obs;
  var unassignedTrips = <UnassignedTrip>[].obs;
  var tripDetails = Rxn<UnassignedTripDetails>();
  var isDetailsLoading = false.obs;
  var isSubmittingBid = false.obs;

  // Search functionality
  var searchQuery = ''.obs;

  List<UnassignedTrip> get filteredTrips {
    if (searchQuery.value.isEmpty) {
      return unassignedTrips;
    }
    final query = searchQuery.value.toLowerCase();
    return unassignedTrips.where((trip) {
      final destination = trip.destination.toLowerCase();
      final pickup = trip.pickupLocation.toLowerCase();
      final tripType = trip.tripType.toLowerCase();
      final payRange = trip.payRange.toString().toLowerCase();

      return destination.contains(query) ||
          pickup.contains(query) ||
          tripType.contains(query) ||
          payRange.contains(query);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchUnassignedTrips();
  }

  /// Fetch unassigned trips list
  Future<void> fetchUnassignedTrips() async {
    try {
      isLoading.value = true;
      AppLogger.d("🚚 Fetching unassigned trips...");

      // Backend returns { trips: [...], pagination: {...} }
      final data = await ApiClient.instance.get<Map<String, dynamic>>(
        ApiEndpoints.trips.unassignedList,
        queryParameters: {'tripType': 'created'},
      );

      final tripsList = data['trips'] as List<dynamic>? ?? [];
      unassignedTrips.value = tripsList
          .map((e) => UnassignedTrip.fromJson(e as Map<String, dynamic>))
          .toList();
      AppLogger.d("✅ Fetched ${unassignedTrips.length} unassigned trips");
    } on DioException catch (e) {
      final msg = e.error is ApiException ? (e.error as ApiException).message : 'Failed to load trips';
      AppLogger.e("❌ Error fetching unassigned trips: $e");
      SnackBarHelper.error(msg);
      unassignedTrips.value = [];
    } catch (e) {
      AppLogger.e("❌ Error fetching unassigned trips: $e");
      SnackBarHelper.error("Failed to load trips: $e");
      unassignedTrips.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch trip details by tripId
  Future<void> fetchTripDetails(String tripId) async {
    try {
      isDetailsLoading.value = true;
      AppLogger.d("🚚 Fetching trip details for: $tripId");

      final data = await ApiClient.instance.get<Map<String, dynamic>>(
        ApiEndpoints.trips.unassignedDetails(tripId),
      );

      tripDetails.value = UnassignedTripDetails.fromJson(data);
      AppLogger.d("✅ Fetched trip details");
    } on DioException catch (e) {
      final msg = e.error is ApiException ? (e.error as ApiException).message : 'Failed to load trip details';
      AppLogger.e("❌ Error fetching trip details: $e");
      SnackBarHelper.error(msg);
    } catch (e) {
      AppLogger.e("❌ Error fetching trip details: $e");
      SnackBarHelper.error("Failed to load trip details: $e");
    } finally {
      isDetailsLoading.value = false;
    }
  }

  /// Submit bid for a trip
  Future<bool> submitBid({
    required String tripId,
    required double bidAmount,
    required String bidDescription,
    int? partnerId,
  }) async {
    try {
      isSubmittingBid.value = true;

      final userId = AuthService.to.currentUserId;

      if (userId.isEmpty) {
        SnackBarHelper.error("User not logged in");
        return false;
      }

      // Check KYC status before submitting bid
      if (!KYCHelper.checkAndShowKYCDialog()) {
        return false;
      }

      final requestData = <String, dynamic>{
        'amount': bidAmount,
        if (bidDescription.trim().isNotEmpty) 'notes': bidDescription.trim(),
      };

      AppLogger.d("💰 BID SUBMISSION REQUEST");
      AppLogger.d("📤 Data: $requestData");

      final response = await ApiClient.instance.post<dynamic>(
        ApiEndpoints.trips.submitBid(tripId),
        data: requestData,
      );

      // Handle weird 200 OK responses with status: false
      if (response is Map) {
        final status = response['status'];
        final message = response['message'] ?? response['msg'] ?? response['error'] ?? '';

        if (status == false || status == 'false' || status == 0) {
          final isDuplicate = message.toString().toLowerCase().contains('already') ||
                              message.toString().toLowerCase().contains('duplicate');

          if (isDuplicate) {
            SnackBarHelper.warning(message.isNotEmpty ? message : "Aapne is trip ke liye pehle se bid submit ki hai!");
          } else {
            SnackBarHelper.error(message.isNotEmpty ? message : "Bid submit nahi ho paayi. Please try again.");
          }
          return false;
        }

        AppLogger.d("✅ BID SUBMITTED SUCCESSFULLY!");
        SnackBarHelper.success(message.isNotEmpty ? message : "Bid submitted successfully");
        return true;
      }

      AppLogger.d("✅ BID SUBMITTED SUCCESSFULLY!");
      SnackBarHelper.success("Bid submitted successfully");
      return true;
    } on DioException catch (e) {
      final msg = e.error is ApiException ? (e.error as ApiException).message : 'Failed to submit bid';
      final isDuplicate = msg.toLowerCase().contains('already') || msg.toLowerCase().contains('duplicate');
      
      if (e.response?.statusCode == 409 || isDuplicate) {
        SnackBarHelper.warning("Aapne is trip ke liye pehle se bid submit ki hai!");
      } else {
        SnackBarHelper.error(msg);
      }
      return false;
    } catch (e) {
      AppLogger.e("❌ EXCEPTION DURING BID SUBMISSION: $e");
      SnackBarHelper.error("Failed to submit bid: $e");
      return false;
    } finally {
      isSubmittingBid.value = false;
    }
  }

  /// Refresh trips list
  Future<void> refreshTrips() async {
    await fetchUnassignedTrips();
  }
}
