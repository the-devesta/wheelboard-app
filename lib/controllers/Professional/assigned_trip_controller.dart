import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wheelboard/models/assigned_trip_model.dart';
import 'package:wheelboard/core/network/api_client.dart';
import 'package:wheelboard/core/network/api_endpoints.dart';
import 'package:wheelboard/core/network/api_exception.dart';
import 'package:wheelboard/core/auth/auth_service.dart';
import 'package:wheelboard/utils/location_service.dart';
import 'package:wheelboard/utils/trip_status.dart';
import '../../utils/app_logger.dart';

class AssignedTripController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  var assignedTrips = <AssignedTrip>[].obs;
  var isLoading = true.obs;

  /// Whether the last fetch failed (drives the retry/error state in the UI).
  final hasError = false.obs;
  final errorMessage = ''.obs;

  /// Local UI filter for the My Trips list, mirroring the web filter tabs:
  /// 'All' | 'Assigned' | 'In-Process' | 'Completed'.
  final selectedFilter = 'All'.obs;

  // ── derived classification (single source of truth via TripStatusMapper) ──
  TripBucket bucketOf(AssignedTrip t) => TripStatusMapper.bucketOf(t.tripStatus);

  bool isAssignedTrip(AssignedTrip t) =>
      TripStatusMapper.isAssigned(t.tripStatus, t.driverId);

  /// Driver earnings for a trip — mirrors web `financial.driverEarnings || price`
  /// using the fields available on [AssignedTrip].
  double earningsOf(AssignedTrip t) {
    if ((t.amountToDriver ?? 0) > 0) return t.amountToDriver!;
    if ((t.bidAmount ?? 0) > 0) return t.bidAmount!;
    if ((t.totalTripCost ?? 0) > 0) return t.totalTripCost!;
    return _parseAmount(t.payRange) ?? 0;
  }

  double? _parseAmount(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final match = RegExp(r'[\d.]+').firstMatch(raw.replaceAll(',', ''));
    return match == null ? null : double.tryParse(match.group(0)!);
  }

  // ── stats (mirror web `deriveStatsFromTrips`) ─────────────────────────────
  int get completedCount =>
      assignedTrips.where((t) => bucketOf(t) == TripBucket.completed).length;

  int get inProcessCount =>
      assignedTrips.where((t) => bucketOf(t) == TripBucket.inProcess).length;

  int get assignedCount => assignedTrips
      .where((t) => isAssignedTrip(t) && bucketOf(t) == TripBucket.upcoming)
      .length;

  int get upcomingCount =>
      assignedTrips.where((t) => bucketOf(t) == TripBucket.upcoming).length;

  int get activeAndAssignedCount => inProcessCount + assignedCount;

  double get totalEarnings => assignedTrips
      .where((t) => bucketOf(t) == TripBucket.completed)
      .fold(0.0, (sum, t) => sum + earningsOf(t));

  double get estimatedEarnings => assignedTrips.where((t) {
        final b = bucketOf(t);
        return b == TripBucket.upcoming || b == TripBucket.inProcess;
      }).fold(0.0, (sum, t) => sum + earningsOf(t));

  /// Default rating until a profile/stats endpoint supplies a real one — matches
  /// the web default of 4.8.
  double get rating => 4.8;

  /// Trips visible for the active filter (mirror web `filteredTrips`).
  List<AssignedTrip> get visibleTrips {
    bool matches(AssignedTrip t) {
      final b = bucketOf(t);
      final isAssigned = isAssignedTrip(t) && b == TripBucket.upcoming;
      final isInProcess = b == TripBucket.inProcess;
      final isCompleted = b == TripBucket.completed;
      switch (selectedFilter.value) {
        case 'Assigned':
          return isAssigned;
        case 'In-Process':
          return isInProcess;
        case 'Completed':
          return isCompleted;
        case 'All':
        default:
          return isAssigned || isInProcess || isCompleted;
      }
    }

    return assignedTrips.where(matches).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchAssignedTrips();
  }

  Future<void> fetchAssignedTrips() async {
    try {
      isLoading(true);
      hasError(false);
      errorMessage('');
      final userId = _authService.currentUserId;

      // If userId is empty the token may not be loaded yet — still attempt
      // the API call because the Bearer token is injected by the interceptor.
      // An empty userId only means the reactive state isn't populated yet.
      if (userId.isEmpty) {
        AppLogger.d('⚠️ userId empty — attempting fetch anyway via token');
      }

      AppLogger.d("🚗 Fetching assigned trips (userId=$userId)");

      // Use dynamic to handle both array and object response shapes
      final raw = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.trips.list,
      );

      AppLogger.d("🚗 Raw response type: ${raw.runtimeType}");

      List<dynamic> tripData = [];
      if (raw is List) {
        tripData = raw;
      } else if (raw is Map<String, dynamic>) {
        tripData = (raw['trips'] ?? raw['data'] ?? raw['result'] ?? []) as List<dynamic>;
      }

      AppLogger.d("🚗 Parsed ${tripData.length} trips");

      if (tripData.isEmpty) {
        AppLogger.d('ℹ️ No assigned trips found for this user');
        assignedTrips.value = [];
      } else {
        final List<AssignedTrip> trips = tripData
            .whereType<Map<String, dynamic>>()
            .map((data) => AssignedTrip.fromJson(data))
            .toList();

        // Calculate distance from current location
        Position? currentPos = await LocationService.getCurrentPosition();
        if (currentPos != null) {
          AppLogger.d(
            "📍 My Current Position: ${currentPos.latitude}, ${currentPos.longitude}",
          );
          for (var trip in trips) {
            if (trip.latitude != null && trip.longitude != null) {
              double distanceInMeters = Geolocator.distanceBetween(
                currentPos.latitude,
                currentPos.longitude,
                trip.latitude!,
                trip.longitude!,
              );
              trip.calculatedDistance = distanceInMeters / 1000; // km

              // Estimate ETA (average speed 40km/h)
              double hours = trip.calculatedDistance! / 40;
              int minutes = (hours * 60).round();
              if (minutes < 60) {
                trip.estimatedEta = "$minutes mins";
              } else {
                int h = minutes ~/ 60;
                int m = minutes % 60;
                trip.estimatedEta = "${h}h ${m}m";
              }
            }
          }
        }

        // Sort trips by distance (nearest first)
        trips.sort((a, b) {
          if (a.calculatedDistance == null && b.calculatedDistance == null) {
            return 0;
          }
          if (a.calculatedDistance == null) return 1;
          if (b.calculatedDistance == null) return -1;
          return a.calculatedDistance!.compareTo(b.calculatedDistance!);
        });

        assignedTrips.value = trips;
        AppLogger.d(
          "✅ Fetched and sorted ${assignedTrips.length} assigned trips",
        );
      }
    } on DioException catch (e) {
      final apiError = e.error;
      final msg = apiError is ApiException ? apiError.message : 'Failed to load assigned trips';
      AppLogger.d('❌ Error fetching assigned trips: $msg');
      assignedTrips.value = [];
      hasError(true);
      errorMessage(msg);
    } catch (e) {
      AppLogger.d('❌ Error fetching assigned trips: $e');
      assignedTrips.value = [];
      hasError(true);
      errorMessage('Something went wrong while loading your trips.');
    } finally {
      isLoading(false);
    }
  }
}
