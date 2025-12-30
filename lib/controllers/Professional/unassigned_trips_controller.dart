import 'dart:convert';
import 'package:get/get.dart';
import '../../apihelperclass/api_helper.dart';
import '../../utils/constants.dart';
import '../../models/unassigned_trip_model.dart';
import '../../utils/session_manager.dart';
import '../../widgets/custom_snackbar.dart';
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

      final response = await HttpHelper.getData(
        endpoint: API.getUnassignedTripList,
        headers: {'Accept': '*/*'},
      );

      AppLogger.d(
        "🚚 Unassigned trips response status: ${response.statusCode}",
      );
      AppLogger.d("🚚 Unassigned trips response body: ${response.body}");

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        unassignedTrips.value = data
            .map((e) => UnassignedTrip.fromJson(e))
            .toList();
        AppLogger.d("✅ Fetched ${unassignedTrips.length} unassigned trips");
      } else {
        AppLogger.d(
          "❌ Failed to fetch unassigned trips: ${response.statusCode}",
        );
        SnackBarHelper.error("Failed to load trips");
      }
    } catch (e) {
      AppLogger.d("❌ Error fetching unassigned trips: $e");
      SnackBarHelper.error("Failed to load trips: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch trip details by tripId
  Future<void> fetchTripDetails(String tripId) async {
    try {
      isDetailsLoading.value = true;

      AppLogger.d("🚚 Fetching trip details for: $tripId");

      final response = await HttpHelper.getData(
        endpoint: '${API.getUnassignedTripDetails}$tripId',
        headers: {'Accept': '*/*'},
      );

      AppLogger.d("🚚 Trip details response status: ${response.statusCode}");
      AppLogger.d("🚚 Trip details response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        tripDetails.value = UnassignedTripDetails.fromJson(data);
        AppLogger.d("✅ Fetched trip details");
      } else {
        AppLogger.d("❌ Failed to fetch trip details: ${response.statusCode}");
        SnackBarHelper.error("Failed to load trip details");
      }
    } catch (e) {
      AppLogger.d("❌ Error fetching trip details: $e");
      SnackBarHelper.error("Failed to load trip details: ${e.toString()}");
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

      final sessionManager = SessionManager();
      final userId = await sessionManager.getString("userId");

      if (userId == null || userId.isEmpty) {
        SnackBarHelper.error("User not logged in");
        return false;
      }

      // Check KYC status before submitting bid
      if (!KYCHelper.checkAndShowKYCDialog()) {
        return false;
      }

      AppLogger.d("💰 Submitting bid for trip: $tripId");

      final response = await HttpHelper.postData(
        endpoint: API.submitBid,
        data: {
          'createdBy': userId,
          'partnerId': partnerId ?? 0,
          'tripId': tripId,
          'userId': userId,
          'bidAmount': bidAmount,
          'bidDescription': bidDescription,
        },
        headers: {'Accept': '*/*', 'Content-Type': 'application/json'},
      );

      AppLogger.d("💰 Submit bid response status: ${response.statusCode}");
      AppLogger.d("💰 Submit bid response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.d("✅ Bid submitted successfully");
        SnackBarHelper.success("Bid submitted successfully");
        return true;
      } else {
        AppLogger.d("❌ Failed to submit bid: ${response.statusCode}");
        SnackBarHelper.error("Failed to submit bid");
        return false;
      }
    } catch (e) {
      AppLogger.d("❌ Error submitting bid: $e");
      SnackBarHelper.error("Failed to submit bid: ${e.toString()}");
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
