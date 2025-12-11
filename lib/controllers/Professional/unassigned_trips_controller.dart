import 'dart:convert';
import 'package:get/get.dart';
import '../../apihelperclass/api_helper.dart';
import '../../utils/constants.dart';
import '../../models/unassigned_trip_model.dart';
import '../../utils/session_manager.dart';
import '../../widgets/custom_snackbar.dart';
import '../../utils/kyc_helper.dart';

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

      print("🚚 Fetching unassigned trips...");

      final response = await HttpHelper.getData(
        endpoint: API.getUnassignedTripList,
        headers: {'Accept': '*/*'},
      );

      print("🚚 Unassigned trips response status: ${response.statusCode}");
      print("🚚 Unassigned trips response body: ${response.body}");

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        unassignedTrips.value = data
            .map((e) => UnassignedTrip.fromJson(e))
            .toList();
        print("✅ Fetched ${unassignedTrips.length} unassigned trips");
      } else {
        print("❌ Failed to fetch unassigned trips: ${response.statusCode}");
        SnackBarHelper.error("Failed to load trips");
      }
    } catch (e) {
      print("❌ Error fetching unassigned trips: $e");
      SnackBarHelper.error("Failed to load trips: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch trip details by tripId
  Future<void> fetchTripDetails(String tripId) async {
    try {
      isDetailsLoading.value = true;

      print("🚚 Fetching trip details for: $tripId");

      final response = await HttpHelper.getData(
        endpoint: '${API.getUnassignedTripDetails}$tripId',
        headers: {'Accept': '*/*'},
      );

      print("🚚 Trip details response status: ${response.statusCode}");
      print("🚚 Trip details response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        tripDetails.value = UnassignedTripDetails.fromJson(data);
        print("✅ Fetched trip details");
      } else {
        print("❌ Failed to fetch trip details: ${response.statusCode}");
        SnackBarHelper.error("Failed to load trip details");
      }
    } catch (e) {
      print("❌ Error fetching trip details: $e");
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

      print("💰 Submitting bid for trip: $tripId");

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

      print("💰 Submit bid response status: ${response.statusCode}");
      print("💰 Submit bid response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Bid submitted successfully");
        SnackBarHelper.success("Bid submitted successfully");
        return true;
      } else {
        print("❌ Failed to submit bid: ${response.statusCode}");
        SnackBarHelper.error("Failed to submit bid");
        return false;
      }
    } catch (e) {
      print("❌ Error submitting bid: $e");
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
