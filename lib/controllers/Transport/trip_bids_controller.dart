import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../models/trip_bid_model.dart';
import '../../widgets/custom_snackbar.dart';
import '../../utils/app_logger.dart';
import '../../utils/bidder_enrichment.dart';

/// Loads the bids embedded inside a trip document.
///
/// Mirrors `wheelboard-fe useTripById()` which calls `GET /trips/:tripId`
/// and reads the embedded `bids` array — there is NO `/trips/:tripId/bids`
/// endpoint on the backend (that returns 404).
class TripBidsController extends GetxController {
  final isLoading = false.obs;
  final bids = <TripBid>[].obs;
  final errorMessage = ''.obs;

  // Trip context (for the bids-screen header)
  final tripFrom = ''.obs;
  final tripTo = ''.obs;

  Future<void> fetchTripBids(String tripId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      AppLogger.d("💰 Fetching trip (with bids): $tripId");

      final raw = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.trips.details(tripId),
      );

      final Map<String, dynamic> trip =
          raw is Map<String, dynamic> ? raw : <String, dynamic>{};

      // Route context
      final route = trip['route'] as Map<String, dynamic>? ?? {};
      tripFrom.value =
          (route['startLocation']?['address'] ?? '').toString();
      tripTo.value = (route['endLocation']?['address'] ?? '').toString();

      // Embedded bids
      final bidList = trip['bids'] as List<dynamic>? ?? [];
      final parsed = bidList
          .asMap()
          .entries
          .where((e) => e.value is Map)
          .map((e) => TripBid.fromBackendBid(
                Map<String, dynamic>.from(e.value as Map),
                tripId: tripId,
                index: e.key,
              ))
          .toList();

      // Show parsed bids immediately, then enrich missing bidder profiles
      // (mirrors web useTripById which fetches public profiles separately).
      bids.value = parsed;
      AppLogger.d("✅ Loaded ${bids.length} bids for trip $tripId");

      final enriched = await enrichBidders(parsed);
      bids.value = enriched;
    } on DioException catch (e) {
      final msg = e.error is ApiException
          ? (e.error as ApiException).message
          : 'Failed to load bids (${e.response?.statusCode})';
      errorMessage.value = msg;
      AppLogger.e("❌ Error fetching bids: $msg");
      SnackBarHelper.error(msg);
    } catch (e) {
      errorMessage.value = 'Failed to load bids';
      AppLogger.e("❌ Error fetching bids: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshBids(String tripId) => fetchTripBids(tripId);
}
