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
        final decoded = json.decode(response.body);

        if (decoded is List) {
          unassignedTrips.value = decoded
              .map((e) => UnassignedTrip.fromJson(e))
              .toList();
          AppLogger.d("✅ Fetched ${unassignedTrips.length} unassigned trips");
        } else {
          // If it's a Map (e.g., {"message": "No unassigned trips found."})
          unassignedTrips.value = [];
          if (decoded is Map && decoded.containsKey('message')) {
            AppLogger.d("ℹ️ API Message: ${decoded['message']}");
          }
        }
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

      final requestData = {
        'createdBy': userId,
        'partnerId': partnerId ?? 0,
        'tripId': tripId,
        'userId': userId,
        'bidAmount': bidAmount,
        'bidDescription': bidDescription,
      };

      AppLogger.d(
        "═══════════════════════════════════════════════════════════",
      );
      AppLogger.d("💰 BID SUBMISSION REQUEST");
      AppLogger.d(
        "═══════════════════════════════════════════════════════════",
      );
      AppLogger.d("📍 Trip ID: $tripId");
      AppLogger.d("👤 User ID: $userId");
      AppLogger.d("💵 Bid Amount: ₹$bidAmount");
      AppLogger.d("📝 Description: $bidDescription");
      AppLogger.d("📤 Full Request Data: ${json.encode(requestData)}");
      AppLogger.d(
        "═══════════════════════════════════════════════════════════",
      );

      final response = await HttpHelper.postData(
        endpoint: API.submitBid,
        data: requestData,
        headers: {'Accept': '*/*', 'Content-Type': 'application/json'},
      );

      AppLogger.d(
        "═══════════════════════════════════════════════════════════",
      );
      AppLogger.d("💰 BID SUBMISSION RESPONSE");
      AppLogger.d(
        "═══════════════════════════════════════════════════════════",
      );
      AppLogger.d("📊 Status Code: ${response.statusCode}");
      AppLogger.d("📥 Response Body: ${response.body}");
      AppLogger.d(
        "═══════════════════════════════════════════════════════════",
      );

      // Parse the response body to get the server message
      String serverMessage = "";
      bool isDuplicateBid = false;
      bool isServerStatusFalse = false;

      try {
        final responseData = json.decode(response.body);
        if (responseData is Map) {
          // Check for status field in response body
          if (responseData.containsKey('status')) {
            final status = responseData['status'];
            if (status == false || status == 'false' || status == 0) {
              isServerStatusFalse = true;
              AppLogger.d("⚠️ SERVER RETURNED status: false");
            }
          }

          // Check for various possible message fields
          serverMessage =
              responseData['message'] ??
              responseData['Message'] ??
              responseData['error'] ??
              responseData['Error'] ??
              responseData['msg'] ??
              "";

          // Check if it's a duplicate bid - common patterns
          final responseLower = response.body.toLowerCase();
          if (responseLower.contains('already') ||
              responseLower.contains('duplicate') ||
              responseLower.contains('exist') ||
              responseLower.contains('placed a bid')) {
            isDuplicateBid = true;
            AppLogger.d("⚠️ DUPLICATE BID DETECTED!");
          }
        }
      } catch (parseError) {
        AppLogger.d("⚠️ Could not parse response as JSON: $parseError");
        serverMessage = response.body;
      }

      // Check if server returned status: false (even with HTTP 200)
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (isServerStatusFalse || isDuplicateBid) {
          // Server returned 200 but status is false - this is an error case
          AppLogger.d("❌ SERVER RETURNED SUCCESS CODE BUT status: false");
          AppLogger.d("📄 Server Message: $serverMessage");
          AppLogger.d(
            "═══════════════════════════════════════════════════════════",
          );

          if (isDuplicateBid) {
            SnackBarHelper.warning(
              serverMessage.isNotEmpty
                  ? serverMessage
                  : "Aapne is trip ke liye pehle se bid submit ki hai!",
            );
          } else {
            SnackBarHelper.error(
              serverMessage.isNotEmpty
                  ? serverMessage
                  : "Bid submit nahi ho paayi. Please try again.",
            );
          }
          return false;
        }

        // Actual success case
        AppLogger.d("✅ BID SUBMITTED SUCCESSFULLY!");
        AppLogger.d(
          "═══════════════════════════════════════════════════════════",
        );
        SnackBarHelper.success(
          serverMessage.isNotEmpty
              ? serverMessage
              : "Bid submitted successfully",
        );
        return true;
      } else if (response.statusCode == 409 || isDuplicateBid) {
        // 409 Conflict typically means duplicate
        AppLogger.d(
          "⚠️ DUPLICATE BID - User already submitted bid for this trip",
        );
        AppLogger.d(
          "═══════════════════════════════════════════════════════════",
        );
        SnackBarHelper.warning(
          serverMessage.isNotEmpty
              ? serverMessage
              : "Aapne is trip ke liye pehle se bid submit ki hai!",
        );
        return false;
      } else if (response.statusCode == 400) {
        AppLogger.d("❌ BAD REQUEST: $serverMessage");
        AppLogger.d(
          "═══════════════════════════════════════════════════════════",
        );
        SnackBarHelper.error(
          serverMessage.isNotEmpty
              ? serverMessage
              : "Invalid bid request. Please check your input.",
        );
        return false;
      } else {
        AppLogger.d("❌ FAILED TO SUBMIT BID");
        AppLogger.d("📊 Status: ${response.statusCode}");
        AppLogger.d("📄 Server Message: $serverMessage");
        AppLogger.d(
          "═══════════════════════════════════════════════════════════",
        );
        SnackBarHelper.error(
          serverMessage.isNotEmpty
              ? serverMessage
              : "Failed to submit bid (Error: ${response.statusCode})",
        );
        return false;
      }
    } catch (e) {
      AppLogger.d(
        "═══════════════════════════════════════════════════════════",
      );
      AppLogger.d("❌ EXCEPTION DURING BID SUBMISSION");
      AppLogger.d("Error: $e");
      AppLogger.d(
        "═══════════════════════════════════════════════════════════",
      );
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
