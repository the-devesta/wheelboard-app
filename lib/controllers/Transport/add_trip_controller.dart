import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import '../../models/get_driver_model.dart';
import '../../models/get_vehicle_model.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../utils/navigation_helper.dart';
import '../../models/add_new_trip_model.dart';
import '../../widgets/custom_snackbar.dart';
import '../../utils/app_logger.dart';

/// Canonical trip-status bucketing — an EXACT mirror of the web company Trips
/// page `mapTripStatus` (wheelboard-fe/src/app/company/trips/page.tsx). Keeping
/// this identical guarantees the mobile tabs/counts always match the web
/// company screen (1 Upcoming / 4 In-Process / 1 Completed, etc.).
///
/// Returns one of: 'upcoming' | 'in-process' | 'completed'.
String tripStatusBucket(String rawStatus) {
  switch (rawStatus.toLowerCase().trim()) {
    // Completed: finished, POD collected/verified, or in the payment phase.
    case 'completed':
    case 'pod-collected':
    case 'pod-verified':
    case 'payment-pending':
    case 'payment-initiated':
    case 'payment-awaiting-confirmation':
    case 'payment-confirmed':
      return 'completed';

    // In-Process: trip is actively being executed (incl. awaiting LR confirm).
    case 'in-progress':
    case 'awaiting-pod':
    case 'pending-lr-confirmation':
    case 'en-route-to-pickup':
    case 'arrived-at-pickup':
      return 'in-process';

    // Upcoming: draft | scheduled | cancelled | created |
    // awaiting-lr-confirmation | lr-confirmed | arrived | anything unknown.
    // (Matches the web `default → 'Upcoming'`.)
    default:
      return 'upcoming';
  }
}

class TripController extends GetxController {
  var drivers = <Driver>[].obs;
  var vehicles = <Vehicle>[].obs;
  var trips = <Trip>[].obs;

  var selectedDriver = RxnString();
  var selectedVehicle = RxnString();

  var isLoading = false.obs;
  var isVehicleLoading = false.obs;
  var isTripsLoading = false.obs;

  Future<void> fetchDrivers(String userId) async {
    try {
      isLoading.value = true;

      final data = await ApiClient.instance.get<List<dynamic>>(
        ApiEndpoints.fleet.drivers,
        queryParameters: {'userId': userId},
      );

      drivers.value = data.map((e) => Driver.fromJson(e)).toList();

      if (drivers.isNotEmpty && selectedDriver.value == null) {
        selectedDriver.value = drivers.first.driverId;
      }
    } on dio.DioException catch (e) {
      final msg = e.error is ApiException
          ? (e.error as ApiException).message
          : 'Failed to load drivers';
      SnackBarHelper.error(msg);
    } catch (e) {
      SnackBarHelper.error("Exception: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchVehicles(String userId) async {
    try {
      isVehicleLoading.value = true;

      final data = await ApiClient.instance.get<List<dynamic>>(
        ApiEndpoints.fleet.vehicles,
        queryParameters: {'userId': userId},
      );

      vehicles.value = data.map((e) => Vehicle.fromJson(e)).toList();
    } on dio.DioException catch (e) {
      final msg = e.error is ApiException
          ? (e.error as ApiException).message
          : 'Failed to load vehicles';
      SnackBarHelper.error(msg);
    } catch (e) {
      SnackBarHelper.error("Exception: $e");
    } finally {
      isVehicleLoading.value = false;
    }
  }

  Future<void> addTrip(Trip trip) async {
    try {
      isLoading.value = true;

      if (trip.vehicleId.isEmpty) {
        SnackBarHelper.error("Please select a vehicle");
        return;
      }
      if (trip.pickupLocation.isEmpty) {
        SnackBarHelper.error("Please enter pickup location");
        return;
      }
      if (trip.deliveryLocation.isEmpty) {
        SnackBarHelper.error("Please enter delivery location");
        return;
      }
      if (trip.pickupDate == null) {
        SnackBarHelper.error("Please select pickup date");
        return;
      }
      if (trip.pickupTime.isEmpty) {
        SnackBarHelper.error("Please select pickup time");
        return;
      }

      // Combine date + time into scheduledStartTime
      DateTime scheduledStart = trip.pickupDate!;
      if (trip.pickupTime.isNotEmpty) {
        final parts = trip.pickupTime.split(':');
        final hour = int.tryParse(parts[0]) ?? 0;
        final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
        scheduledStart = DateTime(
          scheduledStart.year, scheduledStart.month, scheduledStart.day,
          hour, minute,
        );
      }
      final scheduledEnd = scheduledStart.add(const Duration(hours: 8));

      final body = <String, dynamic>{
        "vehicleId": trip.vehicleId,
        "scheduledStartTime": scheduledStart.toUtc().toIso8601String(),
        "scheduledEndTime": scheduledEnd.toUtc().toIso8601String(),
        "route": {
          "startLocation": {
            "address": trip.pickupLocation,
            "coordinates": [trip.pickupLng ?? 0.0, trip.pickupLat ?? 0.0],
          },
          "endLocation": {
            "address": trip.deliveryLocation,
            "coordinates": [trip.longitude ?? 0.0, trip.latitude ?? 0.0],
          },
        },
        "tripType": trip.isScheduledTrip ? "scheduled" : "created",
        if (trip.payRange.trim().isNotEmpty) "expectedPay": trip.payRange.trim(),
        if (trip.isScheduledTrip && trip.driverId.trim().isNotEmpty)
          "driverId": trip.driverId.trim(),
      };

      AppLogger.d("📤 Creating trip: ${ApiEndpoints.trips.create}");

      await ApiClient.instance.post(
        ApiEndpoints.trips.create,
        data: body,
      );

      AppLogger.d("✅ Trip created successfully");
      SnackBarHelper.success("Trip added successfully!");

      Future.delayed(const Duration(milliseconds: 500), () {
        NavigationHelper.navigateToMainWrapper();
      });
    } on dio.DioException catch (e) {
      final msg = e.error is ApiException
          ? (e.error as ApiException).message
          : "Failed to create trip (${e.response?.statusCode})";
      SnackBarHelper.error(msg);
    } catch (e) {
      SnackBarHelper.error("Exception: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateTrip(Trip trip) async {
    try {
      isLoading.value = true;

      if (trip.tripId.isEmpty && trip.id.isEmpty) {
        SnackBarHelper.error("Trip ID is missing. Cannot update trip.");
        return;
      }
      if (trip.vehicleId.isEmpty) {
        SnackBarHelper.error("Please select a vehicle");
        return;
      }
      if (trip.pickupLocation.isEmpty) {
        SnackBarHelper.error("Please enter pickup location");
        return;
      }
      if (trip.deliveryLocation.isEmpty) {
        SnackBarHelper.error("Please enter delivery location");
        return;
      }
      if (trip.pickupDate == null) {
        SnackBarHelper.error("Please select pickup date");
        return;
      }
      if (trip.pickupTime.isEmpty) {
        SnackBarHelper.error("Please select pickup time");
        return;
      }

      // Combine date + time into scheduledStartTime
      DateTime scheduledStart = trip.pickupDate!;
      if (trip.pickupTime.isNotEmpty) {
        final parts = trip.pickupTime.split(':');
        final hour = int.tryParse(parts[0]) ?? 0;
        final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
        scheduledStart = DateTime(
          scheduledStart.year, scheduledStart.month, scheduledStart.day,
          hour, minute,
        );
      }
      final scheduledEnd = scheduledStart.add(const Duration(hours: 8));

      final body = <String, dynamic>{
        "vehicleId": trip.vehicleId,
        "scheduledStartTime": scheduledStart.toUtc().toIso8601String(),
        "scheduledEndTime": scheduledEnd.toUtc().toIso8601String(),
        "route": {
          "startLocation": {
            "address": trip.pickupLocation,
            "coordinates": [trip.pickupLng ?? 0.0, trip.pickupLat ?? 0.0],
          },
          "endLocation": {
            "address": trip.deliveryLocation,
            "coordinates": [trip.longitude ?? 0.0, trip.latitude ?? 0.0],
          },
        },
        if (trip.driverId.trim().isNotEmpty) ...{
          "driverId": trip.driverId.trim(),
          "driverModel": "Driver",
        },
      };

      final idToUse = trip.id.isNotEmpty ? trip.id : trip.tripId;
      await ApiClient.instance.patch(
        ApiEndpoints.trips.update(idToUse),
        data: body,
      );

      AppLogger.d("✅ Trip updated successfully");
      SnackBarHelper.success("Trip updated successfully!");

      // Refresh the list so the trips screen reflects the changes
      // (fetchTrips authenticates via token; userId is only for logging).
      await fetchTrips(trip.userId);

      Get.back(result: true);
    } on dio.DioException catch (e) {
      final msg = e.error is ApiException
          ? (e.error as ApiException).message
          : "Failed to update trip (${e.response?.statusCode})";
      SnackBarHelper.error(msg);
    } catch (e) {
      SnackBarHelper.error("Exception: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchTrips(String userId) async {
    try {
      isTripsLoading.value = true;
      AppLogger.d("🚚 Fetching trips (userId=$userId)");

      // Use dynamic so we can handle both array and object responses
      final raw = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.trips.list,
      );

      AppLogger.d("🚚 Raw trips response type: ${raw.runtimeType}");

      List<dynamic> tripsList = [];

      if (raw is List) {
        // Backend returned array directly
        tripsList = raw;
      } else if (raw is Map<String, dynamic>) {
        // Backend returned { trips: [...] }  or  { data: [...] }  etc.
        if (raw['trips'] is List) {
          tripsList = raw['trips'] as List<dynamic>;
        } else if (raw['data'] is List) {
          tripsList = raw['data'] as List<dynamic>;
        } else if (raw['result'] is List) {
          tripsList = raw['result'] as List<dynamic>;
        }
      }

      AppLogger.d("🚚 Parsed ${tripsList.length} trips");

      trips.value = tripsList
          .whereType<Map<String, dynamic>>()
          .map((e) => Trip.fromJson(e))
          .toList();

      AppLogger.d("========== TRIP DEBUG ==========");
      AppLogger.d("API raw response length: ${tripsList.length}");
      AppLogger.d("Parsed trips length: ${trips.length}");
      for (final t in trips) {
        AppLogger.d("Trip ID: ${t.tripId} | DB ID: ${t.id} | Status: ${t.tripStatus}");
      }
      AppLogger.d("================================");

      AppLogger.d("✅ Fetched ${trips.length} trips");
    } on dio.DioException catch (e) {
      final msg = e.error is ApiException
          ? (e.error as ApiException).message
          : 'Failed to load trips (${e.response?.statusCode})';
      AppLogger.e("❌ DioException fetching trips: $msg");
      SnackBarHelper.error(msg);
    } catch (e) {
      AppLogger.e("❌ Unexpected error fetching trips: $e");
    } finally {
      isTripsLoading.value = false;
    }
  }

  List<Trip> getTripsByStatus(String status) {
    // Normalize the requested tab to the canonical bucket name, then filter
    // using the shared web-parity [tripStatusBucket] mapping so the mobile
    // tabs are always in lock-step with the web company Trips screen.
    final normalized = status.toLowerCase().trim();
    final target = (normalized == 'in-process' || normalized == 'in process')
        ? 'in-process'
        : normalized == 'completed'
            ? 'completed'
            : 'upcoming';
    return trips
        .where((trip) => tripStatusBucket(trip.tripStatus) == target)
        .toList();
  }

  Future<void> refreshTrips(String userId) async => fetchTrips(userId);

  /// Resolve a user-facing message from a Dio error. The auth interceptor does
  /// not wrap errors as [ApiException], so we read the backend body directly
  /// (e.g. "Cannot delete a trip that is currently in-process") instead of a
  /// generic fallback — this is what surfaces the real reason in the UI.
  String _dioMessage(dio.DioException e, String fallback) {
    if (e.error is ApiException) return (e.error as ApiException).message;
    final data = e.response?.data;
    final code = e.response?.statusCode ?? 0;
    if (data != null) return ApiException.toFriendlyMessage(data, code);
    return fallback;
  }

  Future<String?> deleteTrip(String tripId, String userId) async {
    try {
      isLoading.value = true;
      AppLogger.d('📡 Deleting trip: $tripId');

      await ApiClient.instance.delete(
        ApiEndpoints.trips.delete(tripId),
      );

      await fetchTrips(userId);
      return null;
    } on dio.DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // If it's 404, it might have been already deleted (e.g. from web UI).
        // Refresh the list so it disappears from the app UI.
        await fetchTrips(userId);
        return null; // Consider it a success since it's gone
      }
      return _dioMessage(e, 'Failed to delete trip');
    } catch (e) {
      return 'Error deleting trip';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> completeTrip(String tripId, String userId) async {
    try {
      isLoading.value = true;
      AppLogger.d('📡 Completing trip: $tripId');

      await ApiClient.instance.post(
        ApiEndpoints.trips.arrive(tripId),
      );

      SnackBarHelper.success('Trip completed successfully!');
      await fetchTrips(userId);
      return true;
    } on dio.DioException catch (e) {
      final msg = e.error is ApiException
          ? (e.error as ApiException).message
          : 'Failed to complete trip';
      SnackBarHelper.error(msg);
      return false;
    } catch (e) {
      SnackBarHelper.error('Error ending trip');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
