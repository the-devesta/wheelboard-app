// import 'dart:io';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import '../apihelperclass/api_helper.dart';
// import '../utils/constants.dart';
// import '../models/add_new_vehicle_model.dart';
// import 'package:flutter/foundation.dart';

// class AddVehicleController extends GetxController {
//   var isLoading = false.obs;

//   Future<bool> addVehicle(VehicleModel vehicleModel, String token) async {
//     try {
//       isLoading.value = true;

//       // Collect fields from model
//       final fields = vehicleModel.toJsonFields();
//       final List<File> files = vehicleModel.images ?? [];

//       // 🔹 Debug logs before sending
//       AppLogger.d("==================================");
//       AppLogger.d("📡 Sending Multipart Request");
//       AppLogger.d("👉 URL: ${API.addVehicle}");
//       AppLogger.d("👉 Headers: {Authorization: Bearer $token}");
//       AppLogger.d("👉 Fields: $fields");
//       AppLogger.d("👉 Files attached: ${files.length}");
//       AppLogger.d("==================================");

//       // Call helper
//       final streamedResponse = await HttpHelper.uploadMultipart(
//         endpoint: API.addVehicle,
//         fields: fields,
//         files: files,
//         fieldKey: "Images", // check backend docs
//         headers: {"Authorization": "Bearer $token"},
//       );

//       // Convert streamed response
//       final response = await http.Response.fromStream(streamedResponse);

//       // 🔹 Debug response
//       AppLogger.d("==================================");
//       AppLogger.d("📩 Response from API");
//       AppLogger.d("🔹 Status Code: ${response.statusCode}");
//       AppLogger.d("🔹 Body: ${response.body}");
//       AppLogger.d("🔹 Headers: ${response.headers}");
//       AppLogger.d("==================================");

//       if (response.statusCode == 200) {
//         Get.snackbar("Success", "Vehicle added successfully ✅");
//         return true;
//       } else {
//         Get.snackbar("Error", "Failed with status: ${response.statusCode}");
//         return false;
//       }
//     } catch (e, stack) {
//       // 🔹 Log exception with stacktrace
//       AppLogger.d("❌ Exception occurred: $e");
//       AppLogger.d("🪜 Stacktrace: $stack");
//       Get.snackbar("Error", "Something went wrong: $e");
//       return false;
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }

import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../apihelperclass/api_helper.dart';
import '../utils/constants.dart';
import '../models/add_new_vehicle_model.dart';
import '../utils/app_logger.dart';

class AddVehicleController extends GetxController {
  var isLoading = false.obs;

  Future<bool> addVehicle(VehicleModel vehicleModel, String token) async {
    try {
      isLoading.value = true;

      AppLogger.d("🚗 ==================================");
      AppLogger.d("🚗 STARTING VEHICLE ADDITION");
      AppLogger.d("🚗 ==================================");

      // Collect fields (now Map<String, dynamic>)
      final Map<String, dynamic> fields = vehicleModel.toJsonFields();
      final List<File> files = vehicleModel.images ?? [];

      AppLogger.d("🚗 Vehicle Model Data:");
      AppLogger.d("🚗 - Vehicle Type: ${vehicleModel.vehicleType}");
      AppLogger.d("🚗 - Vehicle Number: ${vehicleModel.vehicleNumber}");
      AppLogger.d("🚗 - Vehicle Model: ${vehicleModel.vehicleModel}");
      AppLogger.d("🚗 - Manufacturing Year: ${vehicleModel.manufacturingYear}");
      AppLogger.d("🚗 - Ownership Type: ${vehicleModel.ownershipType}");
      AppLogger.d("🚗 - Description: ${vehicleModel.description}");
      AppLogger.d(
        "🚗 - Is Declaration Accepted: ${vehicleModel.isDeclarationAccepted}",
      );
      AppLogger.d("🚗 - Images Count: ${files.length}");

      // 🔹 Debug logs before sending
      AppLogger.d("🚗 ==================================");
      AppLogger.d("🚗 SENDING MULTIPART REQUEST");
      AppLogger.d("🚗 ==================================");
      AppLogger.d("🚗 Full URL: ${ApiConstants.baseUrl}${API.addVehicle}");
      AppLogger.d(
        "🚗 Token: ${token.isNotEmpty ? 'Present (${token.length} chars)' : 'EMPTY OR NULL'}",
      );
      AppLogger.d("🚗 Headers: {Authorization: Bearer $token}");
      AppLogger.d("🚗 Fields: $fields");
      AppLogger.d("🚗 Files attached: ${files.length}");

      if (files.isNotEmpty) {
        for (int i = 0; i < files.length; i++) {
          AppLogger.d("🚗 File $i: ${files[i].path}");
        }
      }
      AppLogger.d("🚗 ==================================");

      // Call helper (make sure HttpHelper can handle dynamic fields)
      final streamedResponse = await HttpHelper.uploadMultipart(
        endpoint: API.addVehicle,
        fields: fields.map((k, v) => MapEntry(k, v?.toString() ?? "")),
        // 🔑 Convert dynamic to String for multipart form-data
        files: files,
        fieldKey: "Images", // matches backend
        headers: {"Authorization": "Bearer $token"},
      );

      // Convert streamed response
      final response = await http.Response.fromStream(streamedResponse);

      // 🔹 Debug response
      AppLogger.d("🚗 ==================================");
      AppLogger.d("🚗 RESPONSE FROM API");
      AppLogger.d("🚗 ==================================");
      AppLogger.d("🚗 Status Code: ${response.statusCode}");
      AppLogger.d("🚗 Response Body: ${response.body}");
      AppLogger.d("🚗 Response Headers: ${response.headers}");
      AppLogger.d("🚗 ==================================");

      if (response.statusCode == 200) {
        AppLogger.d("🚗 ✅ VEHICLE ADDED SUCCESSFULLY!");
        Get.snackbar("Success", "Vehicle added successfully ✅");
        return true;
      } else {
        AppLogger.d("🚗 ❌ VEHICLE ADDITION FAILED!");
        AppLogger.d("🚗 Error Status: ${response.statusCode}");
        AppLogger.d("🚗 Error Body: ${response.body}");
        Get.snackbar("Error", "Failed with status: ${response.statusCode}");
        return false;
      }
    } catch (e, stack) {
      // 🔹 Log exception with stacktrace
      AppLogger.d("🚗 ==================================");
      AppLogger.d("🚗 EXCEPTION OCCURRED");
      AppLogger.d("🚗 ==================================");
      AppLogger.d("🚗 Exception: $e");
      AppLogger.d("🚗 Stacktrace: $stack");
      AppLogger.d("🚗 ==================================");
      Get.snackbar("Error", "Something went wrong: $e");
      return false;
    } finally {
      isLoading.value = false;
      AppLogger.d("🚗 Loading state set to false");
    }
  }

  Future<bool> updateVehicle(VehicleModel vehicleModel, String token) async {
    try {
      isLoading.value = true;

      AppLogger.d("🚗 ==================================");
      AppLogger.d("🚗 STARTING VEHICLE UPDATE");
      AppLogger.d("🚗 ==================================");

      // Collect fields (now Map<String, dynamic>)
      final Map<String, dynamic> fields = vehicleModel.toJsonFields();
      final List<File> files = vehicleModel.images ?? [];

      AppLogger.d("🚗 Vehicle Update Data:");
      AppLogger.d("🚗 - Vehicle ID: ${vehicleModel.vehicleId}");
      AppLogger.d("🚗 - User ID: ${vehicleModel.userId}");
      AppLogger.d("🚗 - Vehicle Type: ${vehicleModel.vehicleType}");
      AppLogger.d("🚗 - Vehicle Number: ${vehicleModel.vehicleNumber}");
      AppLogger.d("🚗 - Vehicle Model: ${vehicleModel.vehicleModel}");
      AppLogger.d("🚗 - Manufacturing Year: ${vehicleModel.manufacturingYear}");
      AppLogger.d("🚗 - Ownership Type: ${vehicleModel.ownershipType}");
      AppLogger.d("🚗 - Description: ${vehicleModel.description}");
      AppLogger.d(
        "🚗 - Is Declaration Accepted: ${vehicleModel.isDeclarationAccepted}",
      );
      AppLogger.d("🚗 - Images Count: ${files.length}");

      // Check if VehicleId is valid
      if (vehicleModel.vehicleId == null || vehicleModel.vehicleId!.isEmpty) {
        AppLogger.d("🚗 ⚠️ WARNING: VehicleId is NULL or EMPTY!");
        AppLogger.d(
          "🚗 This might cause 403 error - vehicle ownership cannot be verified",
        );
      } else {
        AppLogger.d("🚗 ✅ VehicleId is present: ${vehicleModel.vehicleId}");
      }

      // Check if UserId matches
      if (vehicleModel.userId == null || vehicleModel.userId!.isEmpty) {
        AppLogger.d("🚗 ⚠️ WARNING: UserId is NULL or EMPTY!");
      } else {
        AppLogger.d("🚗 ✅ UserId is present: ${vehicleModel.userId}");
      }

      AppLogger.d("🚗 ==================================");
      AppLogger.d("🚗 SENDING UPDATE REQUEST");
      AppLogger.d("🚗 ==================================");
      AppLogger.d("🚗 URL: ${API.updateVehicle}");
      AppLogger.d("🚗 Headers: {Authorization: Bearer $token}");
      AppLogger.d("🚗 Fields: $fields");
      AppLogger.d("🚗 Files attached: ${files.length}");
      AppLogger.d("🚗 ==================================");

      // Call helper (make sure HttpHelper can handle dynamic fields)
      final streamedResponse = await HttpHelper.uploadMultipart(
        endpoint: API.updateVehicle,
        fields: fields.map((k, v) => MapEntry(k, v?.toString() ?? "")),
        // 🔑 Convert dynamic to String for multipart form-data
        files: files,
        fieldKey: "Images", // matches backend
        headers: {"Authorization": "Bearer $token"},
      );

      // Convert streamed response
      final response = await http.Response.fromStream(streamedResponse);

      AppLogger.d("🚗 ==================================");
      AppLogger.d("🚗 UPDATE RESPONSE FROM API");
      AppLogger.d("🚗 ==================================");
      AppLogger.d("🚗 Status Code: ${response.statusCode}");
      AppLogger.d("🚗 Response Body: ${response.body}");
      AppLogger.d("🚗 Response Headers: ${response.headers}");
      AppLogger.d("🚗 ==================================");

      if (response.statusCode == 200) {
        AppLogger.d("🚗 ✅ VEHICLE UPDATED SUCCESSFULLY!");
        Get.snackbar("Success", "Vehicle updated successfully ✅");
        return true;
      } else {
        AppLogger.d("🚗 ❌ VEHICLE UPDATE FAILED!");
        AppLogger.d("🚗 Error Status: ${response.statusCode}");
        AppLogger.d("🚗 Error Body: ${response.body}");
        Get.snackbar("Error", "Failed with status: ${response.statusCode}");
        return false;
      }
    } catch (e, stack) {
      // 🔹 Log exception with stacktrace
      AppLogger.d("🚗 ==================================");
      AppLogger.d("🚗 UPDATE EXCEPTION OCCURRED");
      AppLogger.d("🚗 ==================================");
      AppLogger.d("🚗 Exception: $e");
      AppLogger.d("🚗 Stacktrace: $stack");
      AppLogger.d("🚗 ==================================");
      Get.snackbar("Error", "Something went wrong: $e");
      return false;
    } finally {
      isLoading.value = false;
      AppLogger.d("🚗 Update loading state set to false");
    }
  }
}
