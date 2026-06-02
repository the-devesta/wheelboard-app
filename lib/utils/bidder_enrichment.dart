import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/trip_bid_model.dart';
import 'app_logger.dart';

/// Enriches bids whose bidder profile wasn't populated in the trip document.
///
/// Mirrors `wheelboard-fe useTripById()` which, for every bid with a missing /
/// "Unknown" bidder name, fetches `GET /users/:bidderId/public-profile` and
/// merges the profile back into the bid.
///
/// Profiles are fetched once per unique bidder id, in parallel.
Future<List<TripBid>> enrichBidders(List<TripBid> bids) async {
  if (bids.isEmpty) return bids;

  // Unique bidder ids that need a profile fetch.
  final ids = <String>{
    for (final b in bids)
      if (b.needsEnrichment) b.bidderId,
  };
  if (ids.isEmpty) return bids;

  AppLogger.d('🔎 Enriching ${ids.length} bidder profile(s)');

  final profileMap = <String, dynamic>{};
  await Future.wait(ids.map((id) async {
    try {
      final res = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.users.publicProfile(id),
      );
      profileMap[id] = res;
    } catch (e) {
      AppLogger.d('⚠️ Could not fetch profile for $id: $e');
    }
  }));

  if (profileMap.isEmpty) return bids;

  return bids.map((b) {
    final profile = profileMap[b.bidderId];
    return profile != null ? b.mergeProfile(profile) : b;
  }).toList();
}
