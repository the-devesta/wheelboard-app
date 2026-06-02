import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../models/add_new_vehicle_model.dart';
import '../../widgets/custom_snackbar.dart';
import '../../utils/app_logger.dart';

class AddVehicleController extends GetxController {
  var isLoading = false.obs;

  Future<bool> addVehicle(VehicleModel vehicleModel, String token) async {
    try {
      isLoading.value = true;

      AppLogger.d("🚗 Adding vehicle: ${vehicleModel.vehicleNumber}");

      final formData = dio.FormData.fromMap(vehicleModel.toJsonFields());

      final List<File> files = vehicleModel.images ?? [];
      for (final file in files) {
        formData.files.add(MapEntry(
          'Images',
          await dio.MultipartFile.fromFile(file.path),
        ));
      }

      await ApiClient.instance.upload<dynamic>(
        ApiEndpoints.fleet.addVehicle,
        formData: formData,
      );

      AppLogger.d("🚗 ✅ Vehicle added successfully");
      SnackBarHelper.success("Vehicle added successfully");
      return true;
    } on dio.DioException catch (e) {
      final msg = e.error is ApiException
          ? (e.error as ApiException).message
          : 'Failed to add vehicle';
      SnackBarHelper.error(msg);
      return false;
    } catch (e) {
      AppLogger.e("🚗 Add Vehicle Exception: $e");
      SnackBarHelper.error("Failed to add vehicle");
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
        SnackBarHelper.error("Vehicle ID is required to update.");
        return false;
      }

      AppLogger.d("🚗 Updating vehicle: $vehicleId");

      final formData = dio.FormData.fromMap(vehicleModel.toJsonFields());

      final List<File> files = vehicleModel.images ?? [];
      for (final file in files) {
        formData.files.add(MapEntry(
          'Images',
          await dio.MultipartFile.fromFile(file.path),
        ));
      }

      await ApiClient.instance.upload<dynamic>(
        ApiEndpoints.fleet.updateVehicle(vehicleId),
        formData: formData,
        method: 'PUT',
      );

      AppLogger.d("🚗 ✅ Vehicle updated successfully");
      SnackBarHelper.success("Vehicle updated successfully");
      return true;
    } on dio.DioException catch (e) {
      final msg = e.error is ApiException
          ? (e.error as ApiException).message
          : 'Failed to update vehicle';
      SnackBarHelper.error(msg);
      return false;
    } catch (e) {
      AppLogger.e("🚗 Update Vehicle Exception: $e");
      SnackBarHelper.error("Failed to update vehicle");
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
