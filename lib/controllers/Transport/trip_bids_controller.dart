import 'dart:convert';
import 'package:get/get.dart';
import '../../apihelperclass/api_helper.dart';
import '../../utils/constants.dart';
import '../../models/trip_bid_model.dart';
import '../../widgets/custom_snackbar.dart';
import '../../utils/app_logger.dart';

class TripBidsController extends GetxController {
  var isLoading = false.obs;
  var bids = <TripBid>[].obs;

  /// Fetch bids for a specific trip
  Future<void> fetchTripBids(String tripId) async {
    try {
      isLoading.value = true;

      AppLogger.d("💰 Fetching bids for trip: $tripId");

      final response = await HttpHelper.getData(
        endpoint: '${API.getTripBids}$tripId',
        headers: {'Accept': '*/*'},
      );

      AppLogger.d("💰 Trip bids response status: ${response.statusCode}");
      AppLogger.d("💰 Trip bids response body: ${response.body}");

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        bids.value = data.map((e) => TripBid.fromJson(e)).toList();
        AppLogger.d("✅ Fetched ${bids.length} bids for trip");
      } else {
        AppLogger.d("❌ Failed to fetch trip bids: ${response.statusCode}");
        SnackBarHelper.error("Failed to load bids");
      }
    } catch (e) {
      AppLogger.d("❌ Error fetching trip bids: $e");
      SnackBarHelper.error("Failed to load bids: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh bids list
  Future<void> refreshBids(String tripId) async {
    await fetchTripBids(tripId);
  }
}
