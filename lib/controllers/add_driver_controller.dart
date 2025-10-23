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

      print("👤 ==================================");
      print("👤 STARTING DRIVER ADDITION");
      print("👤 ==================================");

      final fields = driverModel.toJsonFields();
      final File? imageFile = driverModel.image; // ✅ single image

      print("👤 Driver Model Data:");
      print("👤 - Driver ID: ${driverModel.driverId}");
      print("👤 - User ID: ${driverModel.userId}");
      print("👤 - Full Name: ${driverModel.fullName}");
      print("👤 - Contact Number: ${driverModel.contactNumber}");
      print("👤 - Vehicle Type: ${driverModel.vehicleType}");
      print("👤 - Vehicle Number: ${driverModel.vehicleNumber}");
      print("👤 - Description: ${driverModel.description}");
      print("👤 - Partner ID: ${driverModel.partnerId}");
      print("👤 - Modified User ID: ${driverModel.modifiedUserId}");
      print("👤 - Is Declaration Accepted: ${driverModel.isDeclarationAccepted}");
      print("👤 - Image File: ${imageFile?.path ?? 'No image'}");

      print("👤 ==================================");
      print("👤 SENDING MULTIPART REQUEST");
      print("👤 ==================================");
      print("👤 Full URL: ${ApiConstants.baseUrl}${API.addDriver}");
      print("👤 Token: ${token.isNotEmpty ? 'Present (${token.length} chars)' : 'EMPTY OR NULL'}");
      print("👤 Headers: {Authorization: Bearer $token}");
      print("👤 Fields: $fields");
      print("👤 Image File: ${imageFile?.path ?? 'No image'}");
      print("👤 ==================================");

      final streamedResponse = await HttpHelper.uploadMultipart(
        endpoint: API.addDriver,
        fields: fields,
        files: imageFile != null ? [imageFile] : [], // ✅ only 1 file allowed
        fieldKey: "Image", // ✅ must match backend
        headers: {"Authorization": "Bearer $token"},
      );

      final response = await http.Response.fromStream(streamedResponse);

      print("👤 ==================================");
      print("👤 RESPONSE FROM API");
      print("👤 ==================================");
      print("👤 Status Code: ${response.statusCode}");
      print("👤 Response Body: ${response.body}");
      print("👤 Response Headers: ${response.headers}");
      print("👤 ==================================");

      if (response.statusCode == 200) {
        print("👤 ✅ DRIVER ADDED SUCCESSFULLY!");
        Get.snackbar("Success", "Driver added successfully ✅");
        return true;
      } else {
        print("👤 ❌ DRIVER ADDITION FAILED!");
        print("👤 Error Status: ${response.statusCode}");
        print("👤 Error Body: ${response.body}");
        Get.snackbar("Error", "Failed with status: ${response.statusCode}");
        return false;
      }
    } catch (e, stack) {
      print("👤 ==================================");
      print("👤 EXCEPTION OCCURRED");
      print("👤 ==================================");
      print("👤 Exception: $e");
      print("👤 Stacktrace: $stack");
      print("👤 ==================================");
      Get.snackbar("Error", "Something went wrong: $e");
      return false;
    } finally {
      isLoading.value = false;
      print("👤 Loading state set to false");
    }
  }

  Future<bool> updateDriver(DriverModel driverModel, String token) async {
    try {
      isLoading.value = true;

      print("👤 ==================================");
      print("👤 STARTING DRIVER UPDATE");
      print("👤 ==================================");

      final fields = driverModel.toJsonFields();
      final File? imageFile = driverModel.image; // ✅ single image

      print("👤 Driver Update Data:");
      print("👤 - Driver ID: ${driverModel.driverId}");
      print("👤 - User ID: ${driverModel.userId}");
      print("👤 - Full Name: ${driverModel.fullName}");
      print("👤 - Contact Number: ${driverModel.contactNumber}");
      print("👤 - Vehicle Type: ${driverModel.vehicleType}");
      print("👤 - Vehicle Number: ${driverModel.vehicleNumber}");
      print("👤 - Description: ${driverModel.description}");
      print("👤 - Partner ID: ${driverModel.partnerId}");
      print("👤 - Modified User ID: ${driverModel.modifiedUserId}");
      print("👤 - Is Declaration Accepted: ${driverModel.isDeclarationAccepted}");
      print("👤 - Image File: ${imageFile?.path ?? 'No image'}");
      
      // Check if DriverId is valid
      if (driverModel.driverId == null || driverModel.driverId!.isEmpty) {
        print("👤 ⚠️ WARNING: DriverId is NULL or EMPTY!");
        print("👤 This might cause 403 error - driver ownership cannot be verified");
      } else {
        print("👤 ✅ DriverId is present: ${driverModel.driverId}");
      }
      
      // Check if UserId matches
      if (driverModel.userId == null || driverModel.userId!.isEmpty) {
        print("👤 ⚠️ WARNING: UserId is NULL or EMPTY!");
      } else {
        print("👤 ✅ UserId is present: ${driverModel.userId}");
      }

      print("👤 ==================================");
      print("👤 SENDING UPDATE REQUEST");
      print("👤 ==================================");
      print("👤 URL: ${API.updateDriver}");
      print("👤 Headers: {Authorization: Bearer $token}");
      print("👤 Fields: $fields");
      print("👤 Image File: ${imageFile?.path ?? 'No image'}");
      print("👤 ==================================");

      final streamedResponse = await HttpHelper.uploadMultipart(
        endpoint: API.updateDriver,
        fields: fields,
        files: imageFile != null ? [imageFile] : [], // ✅ only 1 file allowed
        fieldKey: "Image", // ✅ must match backend
        headers: {"Authorization": "Bearer $token"},
      );

      final response = await http.Response.fromStream(streamedResponse);

      print("👤 ==================================");
      print("👤 UPDATE RESPONSE FROM API");
      print("👤 ==================================");
      print("👤 Status Code: ${response.statusCode}");
      print("👤 Response Body: ${response.body}");
      print("👤 Response Headers: ${response.headers}");
      print("👤 ==================================");

      if (response.statusCode == 200) {
        print("👤 ✅ DRIVER UPDATED SUCCESSFULLY!");
        Get.snackbar("Success", "Driver updated successfully ✅");
        return true;
      } else {
        print("👤 ❌ DRIVER UPDATE FAILED!");
        print("👤 Error Status: ${response.statusCode}");
        print("👤 Error Body: ${response.body}");
        Get.snackbar("Error", "Failed with status: ${response.statusCode}");
        return false;
      }
    } catch (e, stack) {
      print("👤 ==================================");
      print("👤 UPDATE EXCEPTION OCCURRED");
      print("👤 ==================================");
      print("👤 Exception: $e");
      print("👤 Stacktrace: $stack");
      print("👤 ==================================");
      Get.snackbar("Error", "Something went wrong: $e");
      return false;
    } finally {
      isLoading.value = false;
      print("👤 Update loading state set to false");
    }
  }
}
