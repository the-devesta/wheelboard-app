import 'dart:async';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../Professional/assigned_trip_controller.dart';
import '../../utils/app_logger.dart';
import '../../widgets/custom_snackbar.dart';

/// Trip navigation step machine — mirrors the web navigate/page.tsx step enum.
enum TripStep {
  confirmOtp,       // status == pending-lr-confirmation
  readyToStart,     // status == scheduled | lr-confirmed
  navigatingToPickup, // status == en-route-to-pickup
  atPickup,         // status == arrived-at-pickup
  inTransit,        // status == in-progress
  atDestination,    // status == arrived | awaiting-pod
  podUpload,        // synthetic: arrived and uploading POD
  completed,        // status == completed
}

class TripNavigationController extends GetxController {
  // ── observables ────────────────────────────────────────────────────────
  final isLoading = false.obs;
  final currentStep = TripStep.readyToStart.obs;
  final tripData = Rxn<Map<String, dynamic>>();

  // location
  final currentPosition = Rxn<Position>();
  final distanceRemaining = 'Calculating...'.obs;
  final eta = 'Calculating...'.obs;
  final progress = 0.0.obs;

  // OTP
  final otpError = RxnString();
  final isConfirmingOtp = false.obs;

  // start-trip OTP
  final startTripOtpError = RxnString();
  final isStartingTrip = false.obs;

  // GPS / location pinging
  StreamSubscription<Position>? _positionStream;
  Timer? _locationPingTimer;

  AssignedTripController get _assignedCtrl {
    if (!Get.isRegistered<AssignedTripController>()) {
      return Get.put(AssignedTripController());
    }
    return Get.find<AssignedTripController>();
  }

  @override
  void onClose() {
    stopTracking();
    super.onClose();
  }

  // ── initialise from backend status ─────────────────────────────────────
  void initFromStatus(String backendStatus) {
    currentStep.value = _stepFromStatus(backendStatus);
    AppLogger.d('TripNavigation: init step = ${currentStep.value} (status=$backendStatus)');
  }

  TripStep _stepFromStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending-lr-confirmation':
        return TripStep.confirmOtp;
      case 'scheduled':
      case 'lr-confirmed':
        return TripStep.readyToStart;
      case 'en-route-to-pickup':
        return TripStep.navigatingToPickup;
      case 'arrived-at-pickup':
        return TripStep.atPickup;
      case 'in-progress':
        return TripStep.inTransit;
      case 'arrived':
      case 'awaiting-pod':
      case 'pod-collected':
        return TripStep.atDestination;
      case 'completed':
      case 'cancelled':
        return TripStep.completed;
      default:
        return TripStep.readyToStart;
    }
  }

  // ── OTP confirmation (pending-lr-confirmation) ──────────────────────────
  Future<bool> confirmOtp(String tripId, String otp) async {
    if (otp.length != 6) {
      otpError.value = 'Please enter a valid 6-digit OTP';
      return false;
    }
    isConfirmingOtp.value = true;
    otpError.value = null;
    try {
      await ApiClient.instance.post(
        ApiEndpoints.trips.confirmOtp(tripId),
        data: {'otp': otp},
      );
      currentStep.value = TripStep.readyToStart;
      _updateLocalStatus(tripId, 'scheduled');
      SnackBarHelper.success('Trip confirmed successfully');
      return true;
    } on DioException catch (e) {
      final msg = e.error is ApiException
          ? (e.error as ApiException).message
          : e.response?.data?['message'] ?? 'Invalid OTP. Please try again.';
      otpError.value = msg;
      return false;
    } catch (e) {
      otpError.value = 'Invalid OTP. Please try again.';
      return false;
    } finally {
      isConfirmingOtp.value = false;
    }
  }

  // ── start pickup journey ──────────────────────────────────────────────
  Future<void> startPickup(String tripId) async {
    isLoading.value = true;
    try {
      await ApiClient.instance.post(ApiEndpoints.trips.pickupStart(tripId));
      currentStep.value = TripStep.navigatingToPickup;
      _updateLocalStatus(tripId, 'en-route-to-pickup');
      await _startGps(tripId);
    } on DioException catch (e) {
      final msg = e.error is ApiException
          ? (e.error as ApiException).message
          : 'Failed to start pickup journey';
      SnackBarHelper.error(msg);
    } finally {
      isLoading.value = false;
    }
  }

  // ── start trip with OTP (at-pickup → in-progress) ────────────────────
  Future<bool> startTrip(String tripId, String otp, {
    double? lat,
    double? lng,
  }) async {
    if (otp.length != 6) {
      startTripOtpError.value = 'Please enter a valid 6-digit OTP';
      return false;
    }
    isStartingTrip.value = true;
    startTripOtpError.value = null;
    try {
      final body = <String, dynamic>{'otp': otp};
      if (lat != null && lng != null) {
        body['startLocation'] = {
          'coordinates': [lng, lat],
          'address': 'Current Location',
        };
      }
      await ApiClient.instance.post(ApiEndpoints.trips.start(tripId), data: body);
      currentStep.value = TripStep.inTransit;
      _updateLocalStatus(tripId, 'in-progress');
      await _startGps(tripId);
      SnackBarHelper.success('Trip started successfully!');
      return true;
    } on DioException catch (e) {
      final msg = e.error is ApiException
          ? (e.error as ApiException).message
          : e.response?.data?['message'] ?? 'Failed to start trip';
      startTripOtpError.value = msg;
      return false;
    } finally {
      isStartingTrip.value = false;
    }
  }

  // ── start trip directly (from ready-to-start with no OTP on backend) ─
  Future<void> startTripDirect(String tripId, {double? lat, double? lng}) async {
    isLoading.value = true;
    try {
      final body = <String, dynamic>{};
      if (lat != null && lng != null) {
        body['startLocation'] = {
          'coordinates': [lng, lat],
          'address': 'Current Location',
        };
      }
      await ApiClient.instance.post(ApiEndpoints.trips.start(tripId), data: body);
      currentStep.value = TripStep.inTransit;
      _updateLocalStatus(tripId, 'in-progress');
      await _startGps(tripId);
      SnackBarHelper.success('Trip started successfully!');
    } on DioException catch (e) {
      final msg = e.error is ApiException
          ? (e.error as ApiException).message
          : 'Failed to start trip';
      SnackBarHelper.error(msg);
    } finally {
      isLoading.value = false;
    }
  }

  // ── arrive at pickup ──────────────────────────────────────────────────
  Future<void> arriveAtPickup(String tripId) async {
    isLoading.value = true;
    try {
      await ApiClient.instance.post(ApiEndpoints.trips.pickupArrive(tripId));
      currentStep.value = TripStep.atPickup;
      _updateLocalStatus(tripId, 'arrived-at-pickup');
      SnackBarHelper.success('Arrived at pickup location');
    } on DioException catch (e) {
      final msg = e.error is ApiException
          ? (e.error as ApiException).message
          : 'Failed to mark arrival at pickup';
      SnackBarHelper.error(msg);
    } finally {
      isLoading.value = false;
    }
  }

  // ── arrive at destination ─────────────────────────────────────────────
  Future<void> arriveAtDestination(String tripId, {
    double? lat,
    double? lng,
    String? reason,
  }) async {
    isLoading.value = true;
    try {
      final body = <String, dynamic>{};
      if (lat != null && lng != null) {
        body['arrivalLocation'] = {
          'coordinates': [lng, lat],
          'address': 'Destination',
        };
      }
      await ApiClient.instance.post(ApiEndpoints.trips.arrive(tripId), data: body);
      currentStep.value = TripStep.atDestination;
      _updateLocalStatus(tripId, 'awaiting-pod');
      SnackBarHelper.success('Arrived at destination. Please upload POD.');
    } on DioException catch (e) {
      final msg = e.error is ApiException
          ? (e.error as ApiException).message
          : 'Failed to mark arrival at destination';
      SnackBarHelper.error(msg);
    } finally {
      isLoading.value = false;
    }
  }

  // ── complete trip (legacy direct path — no POD) ───────────────────────
  Future<void> endTripDirect(String tripId) async {
    isLoading.value = true;
    try {
      await ApiClient.instance.post(ApiEndpoints.trips.arrive(tripId));
      currentStep.value = TripStep.completed;
      _updateLocalStatus(tripId, 'completed');
      await _assignedCtrl.fetchAssignedTrips();
    } on DioException catch (e) {
      final msg = e.error is ApiException
          ? (e.error as ApiException).message
          : 'Failed to complete trip';
      SnackBarHelper.error(msg);
    } finally {
      isLoading.value = false;
    }
  }

  // ── GPS tracking + backend location ping ─────────────────────────────
  Future<void> _startGps(String tripId) async {
    if (_positionStream != null) return; // already running
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) return;
    }
    if (perm == LocationPermission.deniedForever) return;

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((pos) {
      currentPosition.value = pos;
      _pingLocation(tripId, pos);
    });

    // Also ping every 15 seconds regardless of movement
    _locationPingTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      final pos = currentPosition.value;
      if (pos != null) _pingLocation(tripId, pos);
    });
  }

  Future<void> _pingLocation(String tripId, Position pos) async {
    try {
      await ApiClient.instance.post(
        ApiEndpoints.trips.updateLocation(tripId),
        data: {
          'coordinates': [pos.longitude, pos.latitude],
          'speed': pos.speed,
          'accuracy': pos.accuracy,
          'heading': pos.heading,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
      );
    } catch (_) {
      // Location pings are best-effort; don't surface errors to the user.
    }
  }

  void stopTracking() {
    _positionStream?.cancel();
    _positionStream = null;
    _locationPingTimer?.cancel();
    _locationPingTimer = null;
  }

  void startTrackingForTrip(String tripId) {
    _startGps(tripId);
  }

  // ── helper: optimistically update local trip status ───────────────────
  void _updateLocalStatus(String tripId, String newStatus) {
    final trips = _assignedCtrl.assignedTrips;
    final idx = trips.indexWhere((t) => t.tripId == tripId);
    if (idx != -1) {
      _assignedCtrl.assignedTrips[idx] =
          trips[idx].copyWith(tripStatus: newStatus);
    }
  }
}
