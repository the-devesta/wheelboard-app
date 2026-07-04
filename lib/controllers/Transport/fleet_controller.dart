import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../models/get_driver_model.dart';
import '../../models/get_vehicle_model.dart';
import '../../services/fleet_payment_service.dart';
import '../../services/profile_service.dart';
import '../../utils/app_logger.dart';
import '../../widgets/custom_snackbar.dart';

class DriverController extends GetxController {
  // ── State ──────────────────────────────────────────────────────────────────
  final drivers = <Driver>[].obs;
  final vehicles = <Vehicle>[].obs;
  final isLoading = false.obs;
  final isVehicleLoading = false.obs;

  // ── Vehicle detail (kept for backward compat with vehicle_detail_screen) ──
  final vehicleDetails = Rxn<Map<String, dynamic>>();
  final isVehicleDetailsLoading = false.obs;

  // ── Razorpay — fleet payment service instances ─────────────────────────────
  // Each is created on-demand when a 402 is received and disposed after use.
  FleetPaymentService? _driverPaymentService;
  FleetPaymentService? _vehiclePaymentService;

  @override
  void onInit() {
    super.onInit();
    refresh();
  }

  @override
  void onClose() {
    _driverPaymentService?.dispose();
    _vehiclePaymentService?.dispose();
    super.onClose();
  }

  @override
  void refresh() {
    fetchDrivers();
    fetchVehicles();
  }

  // ── Drivers ────────────────────────────────────────────────────────────────

  Future<void> fetchDrivers() async {
    try {
      isLoading.value = true;
      final data = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.fleet.drivers,
      );
      final list = data is List ? data : (data['data'] ?? data) as List;
      drivers.value = list
          .map((e) => Driver.fromJson(e as Map<String, dynamic>))
          .toList();
    } on dio.DioException catch (e) {
      final msg = e.error is ApiException
          ? (e.error as ApiException).message
          : 'Failed to load drivers';
      SnackBarHelper.error(msg);
      AppLogger.e('❌ fetchDrivers: $e');
    } catch (e) {
      AppLogger.e('❌ fetchDrivers: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Creates a driver.
  ///
  /// If the backend returns 402 (plan limit exceeded):
  ///   - `upgradeRequired` → shows upgrade dialog, navigates to subscriptions.
  ///   - per-driver charge   → opens Razorpay checkout; on payment success the
  ///     create call is retried automatically with the payment proof attached.
  ///
  /// Returns `true` if the driver was created (either directly or after payment).
  /// Returns `false` on error or if payment flow was opened (result arrives async).
  Future<bool> createDriver({
    required String name,
    required String licenseNumber,
    required String dateOfBirth, // ISO-8601
    required String phoneNumber,
    required String vehicleType,
    String description = '',
    String experience = '',
    String status = 'Available',
    String email = '',
    String location = '',
    String address = '',
    String licenseExpiryDate = '',
    String vehicleCategoryDetail = '',
    File? image,
    // Payment proof — populated on the Razorpay-retry path only.
    Map<String, dynamic>? payment,
  }) async {
    try {
      final formData = await _buildDriverFormData(
        name: name,
        licenseNumber: licenseNumber,
        dateOfBirth: dateOfBirth,
        phoneNumber: phoneNumber,
        vehicleType: vehicleType,
        description: description,
        experience: experience,
        status: status,
        email: email,
        location: location,
        address: address,
        licenseExpiryDate: licenseExpiryDate,
        vehicleCategoryDetail: vehicleCategoryDetail,
        image: image,
        payment: payment,
      );

      await ApiClient.instance.upload<dynamic>(
        ApiEndpoints.fleet.addDriver,
        formData: formData,
      );
      SnackBarHelper.success('Driver added successfully');
      await fetchDrivers();
      return true;
    } on dio.DioException catch (e) {
      if (e.response?.statusCode == 402) {
        _handle402Driver(e, {
          'name': name,
          'licenseNumber': licenseNumber,
          'dateOfBirth': dateOfBirth,
          'phoneNumber': phoneNumber,
          'vehicleType': vehicleType,
          'description': description,
          'experience': experience,
          'status': status,
          'email': email,
          'location': location,
          'address': address,
          'licenseExpiryDate': licenseExpiryDate,
          'vehicleCategoryDetail': vehicleCategoryDetail,
          // image cannot be re-passed directly; user would need to re-select.
          // We capture image path to re-attach on retry.
          '_imagePath': image?.path,
        });
        return false; // result arrives asynchronously via Razorpay callbacks
      }
      SnackBarHelper.error(_actionError(e, 'Failed to add driver'));
      AppLogger.e('❌ createDriver: $e');
      return false;
    } catch (e) {
      SnackBarHelper.error('Failed to add driver');
      AppLogger.e('❌ createDriver: $e');
      return false;
    }
  }

  /// Handles a 402 response for driver creation.
  /// Matches web app's `handleSaveDriver` 402 block exactly.
  void _handle402Driver(
    dio.DioException e,
    Map<String, dynamic> originalParams,
  ) {
    final responseData = _extract402Data(e);
    final upgradeRequired = responseData['upgradeRequired'] == true ||
        responseData['feeType'] == 'upgrade_required';

    AppLogger.d('[Fleet 402] driver | upgradeRequired=$upgradeRequired | data=$responseData');

    if (upgradeRequired) {
      final limit = (responseData['limit'] as num?)?.toInt() ?? 0;
      showFleetUpgradeLimitDialog(resourceType: 'driver', limit: limit);
      return;
    }

    // Per-driver charge — open Razorpay.
    _driverPaymentService?.dispose();
    _driverPaymentService = FleetPaymentService(
      onPaymentSuccess: (orderId, paymentId, signature) async {
        AppLogger.d('[Fleet] Driver payment success, retrying create…');
        final imagePath = originalParams['_imagePath'] as String?;
        final ok = await createDriver(
          name: originalParams['name'] as String,
          licenseNumber: originalParams['licenseNumber'] as String,
          dateOfBirth: originalParams['dateOfBirth'] as String,
          phoneNumber: originalParams['phoneNumber'] as String,
          vehicleType: originalParams['vehicleType'] as String,
          description: (originalParams['description'] as String?) ?? '',
          experience: (originalParams['experience'] as String?) ?? '',
          status: (originalParams['status'] as String?) ?? 'Available',
          email: (originalParams['email'] as String?) ?? '',
          location: (originalParams['location'] as String?) ?? '',
          address: (originalParams['address'] as String?) ?? '',
          licenseExpiryDate:
              (originalParams['licenseExpiryDate'] as String?) ?? '',
          vehicleCategoryDetail:
              (originalParams['vehicleCategoryDetail'] as String?) ?? '',
          image: imagePath != null ? File(imagePath) : null,
          payment: {
            'orderId': orderId,
            'paymentId': paymentId,
            'signature': signature,
          },
        );
        if (ok) {
          _driverPaymentService?.dispose();
          _driverPaymentService = null;
        }
      },
      onPaymentError: (message) {
        SnackBarHelper.error(message);
        _driverPaymentService?.dispose();
        _driverPaymentService = null;
      },
    );

    _driverPaymentService!.openCheckout(
      orderData: responseData,
      description:
          'Extra Driver Charge — ₹${(responseData['amount'] as num?)?.toStringAsFixed(0) ?? '0'}',
    );
  }

  Future<bool> updateDriver({
    required String driverId,
    required String name,
    required String licenseNumber,
    required String dateOfBirth,
    required String phoneNumber,
    required String vehicleType,
    String description = '',
    String experience = '',
    String status = 'Available',
    String email = '',
    String location = '',
    String address = '',
    String licenseExpiryDate = '',
    String vehicleCategoryDetail = '',
    File? image,
  }) async {
    try {
      final formData = await _buildDriverFormData(
        name: name,
        licenseNumber: licenseNumber,
        dateOfBirth: dateOfBirth,
        phoneNumber: phoneNumber,
        vehicleType: vehicleType,
        description: description,
        experience: experience,
        status: status,
        email: email,
        location: location,
        address: address,
        licenseExpiryDate: licenseExpiryDate,
        vehicleCategoryDetail: vehicleCategoryDetail,
        image: image,
      );
      await ApiClient.instance.upload<dynamic>(
        ApiEndpoints.fleet.updateDriver(driverId),
        formData: formData,
        method: 'PUT',
      );
      SnackBarHelper.success('Driver updated successfully');
      await fetchDrivers();
      return true;
    } on dio.DioException catch (e) {
      SnackBarHelper.error(_actionError(e, 'Failed to update driver'));
      AppLogger.e('❌ updateDriver: $e');
      return false;
    } catch (e) {
      SnackBarHelper.error('Failed to update driver');
      AppLogger.e('❌ updateDriver: $e');
      return false;
    }
  }

  Future<bool> deleteDriver(String driverId, [String? _, String? __]) async {
    try {
      await ApiClient.instance
          .delete(ApiEndpoints.fleet.deleteDriver(driverId));
      drivers.removeWhere((d) => d.driverId == driverId);
      SnackBarHelper.success('Driver removed');
      return true;
    } catch (e) {
      SnackBarHelper.error('Failed to remove driver');
      AppLogger.e('❌ deleteDriver: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> fetchDriverDetail(String driverId) async {
    try {
      final data = await ApiClient.instance.get<Map<String, dynamic>>(
        ApiEndpoints.fleet.driverDetails(driverId),
      );
      return data;
    } catch (e) {
      AppLogger.e('❌ fetchDriverDetail: $e');
      return null;
    }
  }

  Future<bool> updateDriverPerformance(
      String driverId, Map<String, dynamic> fields) async {
    try {
      await ApiClient.instance.put(
        ApiEndpoints.fleet.updateDriver(driverId),
        data: fields,
      );
      SnackBarHelper.success('Performance updated');
      return true;
    } catch (e) {
      SnackBarHelper.error('Failed to update performance');
      return false;
    }
  }

  // ── Vehicles ───────────────────────────────────────────────────────────────

  Future<void> fetchVehicles() async {
    try {
      isVehicleLoading.value = true;
      final data = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.fleet.vehicles,
      );
      final list = data is List ? data : (data['data'] ?? data) as List;
      vehicles.value = list
          .map((e) => Vehicle.fromJson(e as Map<String, dynamic>))
          .toList();
    } on dio.DioException catch (e) {
      final msg = e.error is ApiException
          ? (e.error as ApiException).message
          : 'Failed to load vehicles';
      SnackBarHelper.error(msg);
      AppLogger.e('❌ fetchVehicles: $e');
    } catch (e) {
      AppLogger.e('❌ fetchVehicles: $e');
    } finally {
      isVehicleLoading.value = false;
    }
  }

  /// Creates a vehicle.
  ///
  /// 1:1 with the web `VehicleFormModal`/`handleSaveVehicle`: sends a plain JSON
  /// body matching `CreateVehicleDto` (the backend route has no file
  /// interceptor, so multipart was silently rejected by the strict
  /// `ValidationPipe` — this is why vehicles never actually saved before).
  ///
  /// 402 handling mirrors the web app:
  ///   - `upgradeRequired` → upgrade dialog.
  ///   - per-vehicle charge → Razorpay checkout → retry with payment proof.
  Future<bool> createVehicle({
    required String name,
    required String model,
    required String registrationNumber,
    required int year,
    required String ownership,
    required String category,
    String categoryDetail = '',
    String fuelType = 'Diesel',
    String capacity = '',
    String mileage = '',
    String location = '',
    double avgRun = 0,
    double tripEfficiency = 0,
    double monthlyUsage = 0,
    File? image,
    // Payment proof — populated on the Razorpay-retry path only.
    Map<String, dynamic>? payment,
  }) async {
    try {
      final data = await _buildVehiclePayload(
        name: name,
        model: model,
        registrationNumber: registrationNumber,
        year: year,
        ownership: ownership,
        category: category,
        categoryDetail: categoryDetail,
        fuelType: fuelType,
        capacity: capacity,
        mileage: mileage,
        location: location,
        avgRun: avgRun,
        tripEfficiency: tripEfficiency,
        monthlyUsage: monthlyUsage,
        statusBadge: 'Available',
        image: image,
        payment: payment,
      );
      await ApiClient.instance.post<dynamic>(
        ApiEndpoints.fleet.addVehicle,
        data: data,
      );
      SnackBarHelper.success('Vehicle added successfully');
      await fetchVehicles();
      return true;
    } on dio.DioException catch (e) {
      if (e.response?.statusCode == 402) {
        _handle402Vehicle(e, {
          'name': name,
          'model': model,
          'registrationNumber': registrationNumber,
          'year': year,
          'ownership': ownership,
          'category': category,
          'categoryDetail': categoryDetail,
          'fuelType': fuelType,
          'capacity': capacity,
          'mileage': mileage,
          'location': location,
          'avgRun': avgRun,
          'tripEfficiency': tripEfficiency,
          'monthlyUsage': monthlyUsage,
          '_imagePath': image?.path,
        });
        return false;
      }
      SnackBarHelper.error(_actionError(e, 'Failed to add vehicle'));
      AppLogger.e('❌ createVehicle: $e');
      return false;
    } catch (e) {
      SnackBarHelper.error('Failed to add vehicle');
      AppLogger.e('❌ createVehicle: $e');
      return false;
    }
  }

  /// Handles a 402 response for vehicle creation.
  /// Mirrors web app's `handleSaveVehicle` 402 block exactly.
  void _handle402Vehicle(
    dio.DioException e,
    Map<String, dynamic> originalParams,
  ) {
    final responseData = _extract402Data(e);
    final upgradeRequired = responseData['upgradeRequired'] == true ||
        responseData['feeType'] == 'upgrade_required';

    AppLogger.d('[Fleet 402] vehicle | upgradeRequired=$upgradeRequired | data=$responseData');

    if (upgradeRequired) {
      final limit = (responseData['limit'] as num?)?.toInt() ?? 0;
      showFleetUpgradeLimitDialog(resourceType: 'vehicle', limit: limit);
      return;
    }

    // Per-vehicle charge — open Razorpay.
    _vehiclePaymentService?.dispose();
    _vehiclePaymentService = FleetPaymentService(
      onPaymentSuccess: (orderId, paymentId, signature) async {
        AppLogger.d('[Fleet] Vehicle payment success, retrying create…');
        final imagePath = originalParams['_imagePath'] as String?;
        final ok = await createVehicle(
          name: originalParams['name'] as String,
          model: originalParams['model'] as String,
          registrationNumber: originalParams['registrationNumber'] as String,
          year: originalParams['year'] as int,
          ownership: originalParams['ownership'] as String,
          category: originalParams['category'] as String,
          categoryDetail: (originalParams['categoryDetail'] as String?) ?? '',
          fuelType: (originalParams['fuelType'] as String?) ?? 'Diesel',
          capacity: (originalParams['capacity'] as String?) ?? '',
          mileage: (originalParams['mileage'] as String?) ?? '',
          location: (originalParams['location'] as String?) ?? '',
          avgRun: (originalParams['avgRun'] as num?)?.toDouble() ?? 0,
          tripEfficiency:
              (originalParams['tripEfficiency'] as num?)?.toDouble() ?? 0,
          monthlyUsage:
              (originalParams['monthlyUsage'] as num?)?.toDouble() ?? 0,
          image: imagePath != null ? File(imagePath) : null,
          payment: {
            'orderId': orderId,
            'paymentId': paymentId,
            'signature': signature,
          },
        );
        if (ok) {
          _vehiclePaymentService?.dispose();
          _vehiclePaymentService = null;
        }
      },
      onPaymentError: (message) {
        SnackBarHelper.error(message);
        _vehiclePaymentService?.dispose();
        _vehiclePaymentService = null;
      },
    );

    _vehiclePaymentService!.openCheckout(
      orderData: responseData,
      description:
          'Extra Vehicle Charge — ₹${(responseData['amount'] as num?)?.toStringAsFixed(0) ?? '0'}',
    );
  }

  Future<bool> updateVehicle({
    required String vehicleId,
    required String name,
    required String model,
    required String registrationNumber,
    required int year,
    required String ownership,
    required String category,
    String categoryDetail = '',
    String fuelType = 'Diesel',
    String capacity = '',
    String mileage = '',
    String location = '',
    double avgRun = 0,
    double tripEfficiency = 0,
    double monthlyUsage = 0,
    String? statusBadge,
    File? image,
  }) async {
    try {
      final data = await _buildVehiclePayload(
        name: name,
        model: model,
        registrationNumber: registrationNumber,
        year: year,
        ownership: ownership,
        category: category,
        categoryDetail: categoryDetail,
        fuelType: fuelType,
        capacity: capacity,
        mileage: mileage,
        location: location,
        avgRun: avgRun,
        tripEfficiency: tripEfficiency,
        monthlyUsage: monthlyUsage,
        statusBadge: statusBadge ?? 'Available',
        image: image,
      );
      await ApiClient.instance.put<dynamic>(
        ApiEndpoints.fleet.updateVehicle(vehicleId),
        data: data,
      );
      SnackBarHelper.success('Vehicle updated successfully');
      await fetchVehicles();
      return true;
    } on dio.DioException catch (e) {
      SnackBarHelper.error(_actionError(e, 'Failed to update vehicle'));
      AppLogger.e('❌ updateVehicle: $e');
      return false;
    } catch (e) {
      SnackBarHelper.error('Failed to update vehicle');
      AppLogger.e('❌ updateVehicle: $e');
      return false;
    }
  }

  Future<bool> deleteVehicle(String vehicleId, [String? _, String? __]) async {
    try {
      await ApiClient.instance
          .delete(ApiEndpoints.fleet.deleteVehicle(vehicleId));
      vehicles.removeWhere((v) => v.vehicleId == vehicleId);
      SnackBarHelper.success('Vehicle removed');
      return true;
    } catch (e) {
      SnackBarHelper.error('Failed to remove vehicle');
      AppLogger.e('❌ deleteVehicle: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> fetchVehicleDetails(
      String vehicleId, [String? _]) async {
    try {
      isVehicleDetailsLoading.value = true;
      final data = await ApiClient.instance.get<Map<String, dynamic>>(
        ApiEndpoints.fleet.vehicleDetails(vehicleId),
      );
      vehicleDetails.value = data;
      return data;
    } catch (e) {
      AppLogger.e('❌ fetchVehicleDetails: $e');
      return null;
    } finally {
      isVehicleDetailsLoading.value = false;
    }
  }

  /// RC verification via the Invincible Ocean integration (mirrors web
  /// `fleetAPI.verifyVehicleRegistration`). GET /fleet/vehicles/verify/registration.
  ///
  /// The query param MUST be `registrationNumber` — the backend reads
  /// `@Query('registrationNumber')`. The old code sent `number`, so the backend
  /// received `undefined` and verification silently failed ("RC verification not
  /// working"). Surfaces the real backend message on failure.
  Future<Map<String, dynamic>?> verifyVehicleRegistration(
      String regNumber) async {
    try {
      final data = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.fleet.verifyVehicleRegistration,
        queryParameters: {'registrationNumber': regNumber},
      );
      final body = data is Map<String, dynamic>
          ? (data['data'] is Map<String, dynamic>
              ? data['data'] as Map<String, dynamic>
              : data)
          : null;
      return body;
    } on dio.DioException catch (e) {
      AppLogger.e('❌ verifyVehicleRegistration: $e');
      SnackBarHelper.error(_verifyError(e, 'Could not verify this RC number'));
      return null;
    } catch (e) {
      AppLogger.e('❌ verifyVehicleRegistration: $e');
      SnackBarHelper.error('Could not verify this RC number');
      return null;
    }
  }

  /// DL verification via the Invincible Ocean integration (mirrors web
  /// `fleetAPI.verifyDriverLicense`). GET /fleet/drivers/verify/license.
  ///
  /// Backend reads `@Query('licenseNumber')` + `@Query('dateOfBirth')` (DOB in
  /// DD/MM/YYYY). The old code sent `number`/`dob` → backend got undefined.
  Future<Map<String, dynamic>?> verifyDriverLicense(
      String licenseNumber, String dob) async {
    try {
      final data = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.fleet.verifyDriverLicense,
        queryParameters: {
          'licenseNumber': licenseNumber,
          'dateOfBirth': dob,
        },
      );
      final body = data is Map<String, dynamic>
          ? (data['data'] is Map<String, dynamic>
              ? data['data'] as Map<String, dynamic>
              : data)
          : null;
      return body;
    } on dio.DioException catch (e) {
      AppLogger.e('❌ verifyDriverLicense: $e');
      SnackBarHelper.error(_verifyError(e, 'Could not verify this licence'));
      return null;
    } catch (e) {
      AppLogger.e('❌ verifyDriverLicense: $e');
      SnackBarHelper.error('Could not verify this licence');
      return null;
    }
  }

  String _verifyError(dio.DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      final m = data['message'];
      return m is List ? m.join(', ') : m.toString();
    }
    return fallback;
  }

  /// Surfaces the backend's real validation/error message instead of a
  /// generic fallback (`ApiException` is never actually attached to
  /// `DioException.error` by the interceptor, so `e.error is ApiException`
  /// is always false — read straight from the response body instead).
  String _actionError(dio.DioException e, String fallback) => _verifyError(e, fallback);

  // ── Filtered views ─────────────────────────────────────────────────────────

  List<Vehicle> filteredVehicles(String query, String filter) {
    var list = vehicles.toList();
    if (filter != 'All' && filter.isNotEmpty) {
      list = list.where((v) {
        final s = v.status.toLowerCase();
        final f = filter.toLowerCase();
        if (f == 'owned') return v.ownershipType.toLowerCase() == 'owned';
        if (f == 'attached') return v.ownershipType.toLowerCase() == 'attached';
        return s == f;
      }).toList();
    }
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      list = list
          .where((v) =>
              v.vehicleModel.toLowerCase().contains(q) ||
              v.vehicleNumber.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  List<Driver> filteredDrivers(String query, String filter) {
    var list = drivers.toList();
    if (filter != 'All' && filter.isNotEmpty) {
      list = list.where((d) {
        final s = d.status.toLowerCase();
        final f = filter.toLowerCase();
        return s == f || d.vehicleType.toLowerCase().contains(f);
      }).toList();
    }
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      list = list
          .where((d) =>
              d.fullName.toLowerCase().contains(q) ||
              d.vehicleNumber.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  /// Extracts the inner data map from a 402 DioException response.
  /// Backend wraps data as: `{ status: 402, data: { orderId, razorpayKey, ... } }`
  Map<String, dynamic> _extract402Data(dio.DioException e) {
    final raw = e.response?.data;
    if (raw is Map<String, dynamic>) {
      final inner = raw['data'];
      if (inner is Map<String, dynamic>) return inner;
      return raw;
    }
    return {};
  }

  /// Builds the driver FormData, optionally embedding a Razorpay payment proof.
  Future<dio.FormData> _buildDriverFormData({
    required String name,
    required String licenseNumber,
    required String dateOfBirth,
    required String phoneNumber,
    required String vehicleType,
    String description = '',
    String experience = '',
    String status = 'Available',
    String email = '',
    String location = '',
    String address = '',
    String licenseExpiryDate = '',
    String vehicleCategoryDetail = '',
    File? image,
    Map<String, dynamic>? payment,
  }) async {
    final fields = <String, dynamic>{
      'name': name,
      'licenseNumber': licenseNumber,
      'dateOfBirth': dateOfBirth,
      'phoneNumber': phoneNumber,
      'vehicleCategoryExpertise': vehicleType,
      'description': description,
      'experience': experience,
      'status': status,
      'isDeclarationAccepted': true,
      if (email.isNotEmpty) 'email': email,
      if (location.isNotEmpty) 'location': location,
      if (address.isNotEmpty) 'address': address,
      if (licenseExpiryDate.isNotEmpty) 'licenseExpiryDate': licenseExpiryDate,
      if (vehicleCategoryDetail.isNotEmpty)
        'vehicleCategoryExpertiseDetail': vehicleCategoryDetail,
      // Attach payment proof so backend can verify and allow resource creation.
      if (payment != null) 'payment[orderId]': payment['orderId'],
      if (payment != null) 'payment[paymentId]': payment['paymentId'],
      if (payment != null) 'payment[signature]': payment['signature'],
    };

    final formData = dio.FormData.fromMap(fields);
    if (image != null) {
      formData.files.add(MapEntry(
        'image',
        await dio.MultipartFile.fromFile(image.path),
      ));
    }
    return formData;
  }

  /// Builds the vehicle JSON payload — 1:1 with the web `handleSaveVehicle`
  /// (`CreateVehicleDto`/`UpdateVehicleDto`): `status` mirrors `ownership`
  /// (the web form reuses the same value for both), `metrics` is always sent
  /// as a full object (defaults to 0, matching the web form's pre-filled
  /// zeros), and the image — if any — is inlined as a base64 data-URL exactly
  /// like the web's `FileReader.readAsDataURL` (no separate upload endpoint).
  Future<Map<String, dynamic>> _buildVehiclePayload({
    required String name,
    required String model,
    required String registrationNumber,
    required int year,
    required String ownership,
    required String category,
    required String statusBadge,
    String categoryDetail = '',
    String fuelType = 'Diesel',
    String capacity = '',
    String mileage = '',
    String location = '',
    double avgRun = 0,
    double tripEfficiency = 0,
    double monthlyUsage = 0,
    File? image,
    Map<String, dynamic>? payment,
  }) async {
    String? imageDataUrl;
    if (image != null) {
      imageDataUrl = await ProfileService.fileToBase64DataUrl(image);
    }
    return {
      'name': name,
      'model': model,
      'year': year,
      'registrationNumber': registrationNumber,
      'status': ownership,
      'fuelType': fuelType,
      'capacity': capacity,
      'mileage': mileage,
      'location': location.trim().isEmpty ? 'Not Specified' : location.trim(),
      if (imageDataUrl != null) 'image': imageDataUrl,
      'statusBadge': statusBadge,
      'ownership': ownership,
      'metrics': {
        'avgRun': avgRun,
        'tripEfficiency': tripEfficiency,
        'monthlyUsage': monthlyUsage,
      },
      'category': category,
      if (category == 'Others' && categoryDetail.trim().isNotEmpty)
        'categoryDetail': categoryDetail.trim(),
      if (payment != null) 'payment': payment,
    };
  }
}
