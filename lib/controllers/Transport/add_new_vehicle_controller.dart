import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../models/add_new_vehicle_model.dart';
import '../../widgets/custom_snackbar.dart';
import '../../utils/app_logger.dart';

/// Vehicle create/update — 1:1 with wheelboard-fe `fleetAPI.createVehicle`.
///
/// The backend (NestJS) exposes a SINGLE JSON contract for both web and app:
///   POST /fleet/vehicles      body: CreateVehicleDto (camelCase)
///   PUT  /fleet/vehicles/:id   body: UpdateVehicleDto (camelCase)
/// Images are sent as base64 data-URLs in `images[]`; the backend uploads them
/// to Firebase and stores only the resulting URLs (never base64).
///
/// (The old PascalCase multipart `Images` payload this used to send was
/// silently rejected by the backend's strict `forbidNonWhitelisted` validation,
/// so vehicle add/update never actually worked from the app.)
class AddVehicleController extends GetxController {
  var isLoading = false.obs;

  /// Read each picked image file as a base64 data-URL, matching the shape the
  /// web sends and the backend expects.
  Future<List<String>> _imagesToDataUrls(List<File> files) async {
    final out = <String>[];
    for (final file in files) {
      try {
        final bytes = await file.readAsBytes();
        final p = file.path.toLowerCase();
        final mime = p.endsWith('.png')
            ? 'image/png'
            : p.endsWith('.webp')
                ? 'image/webp'
                : 'image/jpeg';
        out.add('data:$mime;base64,${base64Encode(bytes)}');
      } catch (e) {
        AppLogger.e('🚗 Failed to read vehicle image ${file.path}: $e');
      }
    }
    return out;
  }

  Future<bool> addVehicle(VehicleModel vehicleModel, String token) async {
    try {
      isLoading.value = true;

      AppLogger.d('🚗 Adding vehicle: ${vehicleModel.vehicleNumber}');

      final images = await _imagesToDataUrls(vehicleModel.images ?? []);
      final model = (vehicleModel.vehicleModel ?? '').trim();

      // Full create payload — supplies every field CreateVehicleDto requires.
      final body = <String, dynamic>{
        'name': model,
        'model': model,
        'registrationNumber': (vehicleModel.vehicleNumber ?? '').trim(),
        if (vehicleModel.manufacturingYear != null)
          'year': vehicleModel.manufacturingYear,
        'ownership': vehicleModel.ownershipType ?? 'Owned',
        if (vehicleModel.vehicleType != null &&
            vehicleModel.vehicleType!.isNotEmpty)
          'category': vehicleModel.vehicleType,
        'description': vehicleModel.description ?? '',
        'status': vehicleModel.ownershipType ?? 'Owned',
        'statusBadge': 'Available',
        'location': 'Not Specified',
        'metrics': {'avgRun': 0, 'tripEfficiency': 0, 'monthlyUsage': 0},
        if (images.isNotEmpty) 'images': images,
      };

      await ApiClient.instance.post<dynamic>(
        ApiEndpoints.fleet.addVehicle,
        data: body,
      );

      AppLogger.d('🚗 ✅ Vehicle added successfully');
      SnackBarHelper.success('Vehicle added successfully');
      return true;
    } on dio.DioException catch (e) {
      final msg = e.error is ApiException
          ? (e.error as ApiException).message
          : 'Failed to add vehicle';
      SnackBarHelper.error(msg);
      return false;
    } catch (e) {
      AppLogger.e('🚗 Add Vehicle Exception: $e');
      SnackBarHelper.error('Failed to add vehicle');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateVehicle(VehicleModel vehicleModel, String token) async {
    try {
      isLoading.value = true;

      final vehicleId = vehicleModel.vehicleId ?? '';
      if (vehicleId.isEmpty) {
        SnackBarHelper.error('Vehicle ID is required to update.');
        return false;
      }

      AppLogger.d('🚗 Updating vehicle: $vehicleId');

      final images = await _imagesToDataUrls(vehicleModel.images ?? []);
      final model = (vehicleModel.vehicleModel ?? '').trim();

      // Partial update — only send edited fields so metrics/status/location set
      // at creation are preserved. `images` is sent only when new photos were
      // picked, so a plain field edit never wipes the existing vehicle photos.
      final body = <String, dynamic>{
        if (model.isNotEmpty) 'name': model,
        if (model.isNotEmpty) 'model': model,
        if ((vehicleModel.vehicleNumber ?? '').trim().isNotEmpty)
          'registrationNumber': vehicleModel.vehicleNumber!.trim(),
        if (vehicleModel.manufacturingYear != null)
          'year': vehicleModel.manufacturingYear,
        if (vehicleModel.ownershipType != null)
          'ownership': vehicleModel.ownershipType,
        if (vehicleModel.vehicleType != null &&
            vehicleModel.vehicleType!.isNotEmpty)
          'category': vehicleModel.vehicleType,
        if (vehicleModel.description != null)
          'description': vehicleModel.description,
        if (images.isNotEmpty) 'images': images,
      };

      await ApiClient.instance.put<dynamic>(
        ApiEndpoints.fleet.updateVehicle(vehicleId),
        data: body,
      );

      AppLogger.d('🚗 ✅ Vehicle updated successfully');
      SnackBarHelper.success('Vehicle updated successfully');
      return true;
    } on dio.DioException catch (e) {
      final msg = e.error is ApiException
          ? (e.error as ApiException).message
          : 'Failed to update vehicle';
      SnackBarHelper.error(msg);
      return false;
    } catch (e) {
      AppLogger.e('🚗 Update Vehicle Exception: $e');
      SnackBarHelper.error('Failed to update vehicle');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
