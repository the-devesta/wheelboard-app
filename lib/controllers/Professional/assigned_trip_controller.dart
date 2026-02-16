import 'package:get/get.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:wheelboard/models/assigned_trip_model.dart';
import 'package:wheelboard/apihelperclass/api_helper.dart';
import 'package:wheelboard/services/auth_service.dart';
import 'package:wheelboard/utils/constants.dart';
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
      final token = _authService.currentToken;

      AppLogger.d('═══════════════════════════════════════════');
      AppLogger.d('🚗 ASSIGNED TRIPS FETCH DEBUG');
      AppLogger.d('═══════════════════════════════════════════');
      AppLogger.d('🚗 UserId: "$userId"');
      AppLogger.d('🚗 Token exists: ${token.isNotEmpty}');
      AppLogger.d('🚗 BaseUrl: ${ApiConstants.baseUrl}');

      if (userId.isEmpty) {
        AppLogger.d('⚠️ User not logged in or userId is missing');
        assignedTrips.value = [];
        isLoading(false);
        return;
      }

      AppLogger.d("🚗 Fetching assigned trips for userId: $userId");

      final fullUrl = '${API.getTripListByDriver}$userId';
      final completeUrl = '${ApiConstants.baseUrl}$fullUrl';
      AppLogger.d("🚗 FULL URL: $completeUrl");

      final response = await HttpHelper.getData(
        endpoint: fullUrl,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      AppLogger.d("🚗 Assigned trips response status: ${response.statusCode}");
      AppLogger.d("🚗 Assigned trips response body: ${response.body}");

      // Check if response is HTML (error page)
      if (response.body.trim().startsWith('<!DOCTYPE') ||
          response.body.trim().startsWith('<html')) {
        AppLogger.d(
          "❌ Server returned HTML instead of JSON - API endpoint may be incorrect",
        );
        assignedTrips.value = [];
        isLoading(false);
        return;
      }

      if (response.statusCode == 200) {
        AppLogger.d("🚗 RAW TRIP DATA: ${response.body}");
        try {
          final List<dynamic> tripData = jsonDecode(response.body);
          if (tripData.isEmpty) {
            AppLogger.d('ℹ️ No assigned trips found for this user');
            assignedTrips.value = [];
          } else {
            final List<AssignedTrip> trips = tripData
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
              if (a.calculatedDistance == null && b.calculatedDistance == null)
                return 0;
              if (a.calculatedDistance == null) return 1;
              if (b.calculatedDistance == null) return -1;
              return a.calculatedDistance!.compareTo(b.calculatedDistance!);
            });

            assignedTrips.value = trips;
            AppLogger.d(
              "✅ Fetched and sorted ${assignedTrips.length} assigned trips",
            );

            // Debug: Log each trip's status and distance
            AppLogger.d("═══════════════════════════════════════════");
            AppLogger.d("🚗 TRIP STATUSES DEBUG:");
            for (var trip in assignedTrips) {
              AppLogger.d(
                "  📍 Trip: ${trip.tripCode} | Status: '${trip.tripStatus}' | Distance: ${trip.calculatedDistance?.toStringAsFixed(2)} km | ETA: ${trip.estimatedEta}",
              );
            }
            AppLogger.d("═══════════════════════════════════════════");
          }
        } catch (parseError) {
          AppLogger.d('❌ Error parsing assigned trips: $parseError');
          // Check if it's an error message
          try {
            final errorData = jsonDecode(response.body);
            final errorMessage =
                errorData['message'] ??
                errorData['error'] ??
                'No bids found for this trip';
            AppLogger.d('ℹ️ $errorMessage');
          } catch (e) {
            AppLogger.d('❌ Failed to parse error message');
          }
          assignedTrips.value = [];
        }
      } else {
        AppLogger.d('❌ Failed to load assigned trips: ${response.statusCode}');
        // Try to parse error message
        try {
          final errorData = jsonDecode(response.body);
          final errorMessage =
              errorData['message'] ??
              errorData['error'] ??
              'Failed to load assigned trips';
          AppLogger.d('ℹ️ $errorMessage');
        } catch (e) {
          AppLogger.d('❌ Response body: ${response.body}');
        }
        assignedTrips.value = [];
      }
    } catch (e) {
      AppLogger.d('❌ Error fetching assigned trips: $e');
      assignedTrips.value = [];
    } finally {
      isLoading(false);
    }
  }
}
