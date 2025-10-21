import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../apihelperclass/api_helper.dart';
import '../utils/constants.dart';
import '../models/add_drivermodel.dart';

class AddDriverController extends GetxController {
  var isLoading = false.obs;

  Future<bool> addDriver(DriverModel driverModel, String token) async {
    try {
      isLoading.value = true;

      final fields = driverModel.toJsonFields();
      final File? imageFile = driverModel.image; // ✅ single image

      final streamedResponse = await HttpHelper.uploadMultipart(
        endpoint: API.addDriver,
        fields: fields,
        files: imageFile != null ? [imageFile] : [], // ✅ only 1 file allowed
        fieldKey: "Image", // ✅ must match backend
        headers: {"Authorization": "Bearer $token"},
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        Get.snackbar("Success", "Driver added successfully ✅");
        return true;
      } else {
        print(
          "Failed with status: ${response.statusCode} , body: ${response.body}",
        );
        Get.snackbar("Error", "Failed with status: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateDriver(DriverModel driverModel, String token) async {
    try {
      isLoading.value = true;

      final fields = driverModel.toJsonFields();
      final File? imageFile = driverModel.image; // ✅ single image

      final streamedResponse = await HttpHelper.uploadMultipart(
        endpoint: API.updateDriver,
        fields: fields,
        files: imageFile != null ? [imageFile] : [], // ✅ only 1 file allowed
        fieldKey: "Image", // ✅ must match backend
        headers: {"Authorization": "Bearer $token"},
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        Get.snackbar("Success", "Driver updated successfully ✅");
        return true;
      } else {
        print(
          "Failed with status: ${response.statusCode} , body: ${response.body}",
        );
        Get.snackbar("Error", "Failed with status: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
