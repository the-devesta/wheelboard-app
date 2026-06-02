import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wheelboard/models/assigned_trip_model.dart';
import 'package:wheelboard/core/network/api_client.dart';
import 'package:wheelboard/core/network/api_endpoints.dart';
import 'package:wheelboard/core/network/api_exception.dart';
import 'package:wheelboard/core/auth/auth_service.dart';
import 'package:wheelboard/utils/location_service.dart';
import '../../utils/app_logger.dart';

class AssignedTripController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  var assignedTrips = <AssignedTrip>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAssignedTrips();
  }

  Future<void> fetchAssignedTrips() async {
    try {
      isLoading(true);
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
    } catch (e) {
      AppLogger.d('❌ Error fetching assigned trips: $e');
      assignedTrips.value = [];
    } finally {
      isLoading(false);
    }
  }
}
