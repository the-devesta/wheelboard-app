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
    return trips.where((trip) {
      final s = trip.tripStatus.toLowerCase().trim();
      switch (status.toLowerCase()) {
        // ── Upcoming: anything not yet started ──────────────────────────────
        // Mirrors web mapBackendStatus():
        //   draft | scheduled | pending-lr-confirmation |
        //   awaiting-lr-confirmation | lr-confirmed → 'Upcoming'
        case 'upcoming':
          return s == 'draft' ||
              s == 'scheduled' ||
              s == 'created' ||
              s == 'upcoming' ||
              s == 'pending' ||
              s == 'pending-lr-confirmation' ||
              s == 'awaiting-lr-confirmation' ||
              s == 'lr-confirmed';

        // ── In-Process: trip is actively being executed ──────────────────────
        // Mirrors web:
        //   en-route-to-pickup | arrived-at-pickup | in-progress |
        //   arrived | awaiting-pod | pod-collected → 'In-Process'
        case 'in-process':
        case 'in process':
          return s == 'in-progress' ||
              s == 'in-process' ||
              s == 'in progress' ||
              s == 'inprogress' ||
              s == 'ongoing' ||
              s == 'active' ||
              s == 'en-route-to-pickup' ||
              s == 'arrived-at-pickup' ||
              s == 'arrived' ||
              s == 'awaiting-pod' ||
              s == 'pod-collected' ||
              s.contains('process') ||
              s.contains('progress');

        // ── Completed: trip finished or cancelled ────────────────────────────
        case 'completed':
          return s == 'completed' ||
              s == 'cancelled' ||
              s == 'done' ||
              s == 'finished' ||
              s.contains('complete');

        default:
          return s == status.toLowerCase();
      }
    }).toList();
  }

  Future<void> refreshTrips(String userId) async => fetchTrips(userId);

  Future<bool> deleteTrip(String tripId, String userId) async {
    try {
      isLoading.value = true;
      AppLogger.d('📡 Deleting trip: $tripId');

      await ApiClient.instance.delete(
        ApiEndpoints.trips.delete(tripId),
      );

      await fetchTrips(userId);
      return true;
    } on dio.DioException catch (e) {
      final msg = e.error is ApiException
          ? (e.error as ApiException).message
          : 'Failed to delete trip';
      SnackBarHelper.error(msg);
      return false;
    } catch (e) {
      SnackBarHelper.error('Error deleting trip');
      return false;
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
