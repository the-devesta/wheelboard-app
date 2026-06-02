import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../models/trip_bid_model.dart';
import '../../utils/app_logger.dart';
import '../../utils/bidder_enrichment.dart';

/// Loads a trip + its embedded bids for the assignment / payment screen.
///
/// Mirrors `wheelboard-fe /company/trips/assignment/page.tsx` which calls
/// `getTripById(tripId)` and finds the chosen bid inside `trip.bids`.
class AssignTripController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final bids = <TripBid>[].obs;

  // Trip context for the assignment summary
  final from = ''.obs;
  final to = ''.obs;
  final pickupDate = Rxn<DateTime>();
  final pickupTime = ''.obs;
  final vehicleName = ''.obs;
  final tripCode = ''.obs;
  final specialInstructions = ''.obs;

  Future<void> fetchAssignTrip(String tripId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      AppLogger.d("💰 Fetching trip for assignment: $tripId");

      final raw = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.trips.details(tripId),
      );

      final Map<String, dynamic> trip =
          raw is Map<String, dynamic> ? raw : <String, dynamic>{};

      // Route
      final route = trip['route'] as Map<String, dynamic>? ?? {};
      from.value = (route['startLocation']?['address'] ?? '').toString();
      to.value = (route['endLocation']?['address'] ?? '').toString();

      // Timeline
      final timeline = trip['timeline'] as Map<String, dynamic>? ?? {};
      final start =
          timeline['scheduledStartTime'] ?? trip['pickupDate'];
      if (start != null) {
        final dt = DateTime.tryParse(start.toString());
        pickupDate.value = dt;
        if (dt != null) {
          final local = dt.toLocal();
          pickupTime.value =
              '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
        }
      }

      // Vehicle (may be populated object or id)
      final v = trip['vehicleId'];
      if (v is Map) {
        vehicleName.value =
            (v['name'] ?? v['model'] ?? v['registrationNumber'] ?? '')
                .toString();
      }

      tripCode.value =
          (trip['tripId'] ?? trip['_id'] ?? tripId).toString();
      specialInstructions.value =
          (trip['specialInstructions'] ?? '').toString();

      // Bids
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
      bids.value = parsed;
      AppLogger.d("✅ Assignment: ${bids.length} bids loaded");

      // Enrich any bidder whose profile wasn't populated in the trip document.
      final enriched = await enrichBidders(parsed);
      bids.value = enriched;
    } on DioException catch (e) {
      final msg = e.error is ApiException
          ? (e.error as ApiException).message
          : 'Failed to load assignment details (${e.response?.statusCode})';
      errorMessage.value = msg;
      AppLogger.e("❌ Error fetching assignment: $msg");
    } catch (e) {
      errorMessage.value = 'Failed to load assignment details';
      AppLogger.e("❌ Error fetching assignment: $e");
    } finally {
      isLoading.value = false;
    }
  }

  TripBid? getBidById(String? bidId) {
    if (bidId == null || bidId.isEmpty) {
      return bids.isNotEmpty ? bids.first : null;
    }
    try {
      return bids.firstWhere((b) => b.bidId == bidId);
    } catch (_) {
      return bids.isNotEmpty ? bids.first : null;
    }
  }
}
