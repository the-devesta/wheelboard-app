import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../models/add_drivermodel.dart';
import '../../widgets/custom_snackbar.dart';
import '../../utils/app_logger.dart';

class AddDriverController extends GetxController {
  var isLoading = false.obs;

  Future<bool> addDriver(DriverModel driverModel, String token) async {
    try {
      isLoading.value = true;

      final formData = dio.FormData.fromMap(driverModel.toJsonFields());

      final File? imageFile = driverModel.image;
      if (imageFile != null) {
        formData.files.add(MapEntry(
          'Image',
          await dio.MultipartFile.fromFile(imageFile.path),
        ));
      }

      await ApiClient.instance.upload<dynamic>(
        ApiEndpoints.fleet.addDriver,
        formData: formData,
      );

      SnackBarHelper.success("Driver added successfully");
      return true;
    } on dio.DioException catch (e) {
      final msg = e.error is ApiException
          ? (e.error as ApiException).message
          : "Unable to add driver. Please try again.";
      SnackBarHelper.error(msg);
      return false;
    } catch (e) {
      AppLogger.e("👤 Add Driver Exception: $e");
      SnackBarHelper.error(
          "Unable to connect to server. Please check your internet connection.");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateDriver(DriverModel driverModel, String token) async {
    try {
      isLoading.value = true;

      final driverId = driverModel.driverId ?? '';
      if (driverId.isEmpty) {
        SnackBarHelper.error("Driver ID is required to update.");
        return false;
      }

      final formData = dio.FormData.fromMap(driverModel.toJsonFields());

      final File? imageFile = driverModel.image;
      if (imageFile != null) {
        formData.files.add(MapEntry(
          'Image',
          await dio.MultipartFile.fromFile(imageFile.path),
        ));
      }

      await ApiClient.instance.upload<dynamic>(
        ApiEndpoints.fleet.updateDriver(driverId),
        formData: formData,
        method: 'PUT',
      );

      SnackBarHelper.success("Driver updated successfully");
      return true;
    } on dio.DioException catch (e) {
      final msg = e.error is ApiException
          ? (e.error as ApiException).message
          : "Unable to update driver. Please try again.";
      SnackBarHelper.error(msg);
      return false;
    } catch (e) {
      AppLogger.e("👤 Update Driver Exception: $e");
      SnackBarHelper.error(
          "Unable to connect to server. Please check your internet connection.");
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
