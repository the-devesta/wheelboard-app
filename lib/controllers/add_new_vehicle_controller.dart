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
//       debugPrint("==================================");
//       debugPrint("📡 Sending Multipart Request");
//       debugPrint("👉 URL: ${API.addVehicle}");
//       debugPrint("👉 Headers: {Authorization: Bearer $token}");
//       debugPrint("👉 Fields: $fields");
//       debugPrint("👉 Files attached: ${files.length}");
//       debugPrint("==================================");

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
//       debugPrint("==================================");
//       debugPrint("📩 Response from API");
//       debugPrint("🔹 Status Code: ${response.statusCode}");
//       debugPrint("🔹 Body: ${response.body}");
//       debugPrint("🔹 Headers: ${response.headers}");
//       debugPrint("==================================");

//       if (response.statusCode == 200) {
//         Get.snackbar("Success", "Vehicle added successfully ✅");
//         return true;
//       } else {
//         Get.snackbar("Error", "Failed with status: ${response.statusCode}");
//         return false;
//       }
//     } catch (e, stack) {
//       // 🔹 Log exception with stacktrace
//       debugPrint("❌ Exception occurred: $e");
//       debugPrint("🪜 Stacktrace: $stack");
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

class AddVehicleController extends GetxController {
  var isLoading = false.obs;

  Future<bool> addVehicle(VehicleModel vehicleModel, String token) async {
    try {
      isLoading.value = true;

      print("🚗 ==================================");
      print("🚗 STARTING VEHICLE ADDITION");
      print("🚗 ==================================");

      // Collect fields (now Map<String, dynamic>)
      final Map<String, dynamic> fields = vehicleModel.toJsonFields();
      final List<File> files = vehicleModel.images ?? [];

      print("🚗 Vehicle Model Data:");
      print("🚗 - Vehicle Type: ${vehicleModel.vehicleType}");
      print("🚗 - Vehicle Number: ${vehicleModel.vehicleNumber}");
      print("🚗 - Vehicle Model: ${vehicleModel.vehicleModel}");
      print("🚗 - Manufacturing Year: ${vehicleModel.manufacturingYear}");
      print("🚗 - Ownership Type: ${vehicleModel.ownershipType}");
      print("🚗 - Description: ${vehicleModel.description}");
      print("🚗 - Is Declaration Accepted: ${vehicleModel.isDeclarationAccepted}");
      print("🚗 - Images Count: ${files.length}");

      // 🔹 Debug logs before sending
      print("🚗 ==================================");
      print("🚗 SENDING MULTIPART REQUEST");
      print("🚗 ==================================");
      print("🚗 Full URL: ${ApiConstants.baseUrl}${API.addVehicle}");
      print("🚗 Token: ${token.isNotEmpty ? 'Present (${token.length} chars)' : 'EMPTY OR NULL'}");
      print("🚗 Headers: {Authorization: Bearer $token}");
      print("🚗 Fields: $fields");
      print("🚗 Files attached: ${files.length}");
      
      if (files.isNotEmpty) {
        for (int i = 0; i < files.length; i++) {
          print("🚗 File $i: ${files[i].path}");
        }
      }
      print("🚗 ==================================");

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
      print("🚗 ==================================");
      print("🚗 RESPONSE FROM API");
      print("🚗 ==================================");
      print("🚗 Status Code: ${response.statusCode}");
      print("🚗 Response Body: ${response.body}");
      print("🚗 Response Headers: ${response.headers}");
      print("🚗 ==================================");

      if (response.statusCode == 200) {
        print("🚗 ✅ VEHICLE ADDED SUCCESSFULLY!");
        Get.snackbar("Success", "Vehicle added successfully ✅");
        return true;
      } else {
        print("🚗 ❌ VEHICLE ADDITION FAILED!");
        print("🚗 Error Status: ${response.statusCode}");
        print("🚗 Error Body: ${response.body}");
        Get.snackbar("Error", "Failed with status: ${response.statusCode}");
        return false;
      }
    } catch (e, stack) {
      // 🔹 Log exception with stacktrace
      print("🚗 ==================================");
      print("🚗 EXCEPTION OCCURRED");
      print("🚗 ==================================");
      print("🚗 Exception: $e");
      print("🚗 Stacktrace: $stack");
      print("🚗 ==================================");
      Get.snackbar("Error", "Something went wrong: $e");
      return false;
    } finally {
      isLoading.value = false;
      print("🚗 Loading state set to false");
    }
  }

  Future<bool> updateVehicle(VehicleModel vehicleModel, String token) async {
    try {
      isLoading.value = true;

      print("🚗 ==================================");
      print("🚗 STARTING VEHICLE UPDATE");
      print("🚗 ==================================");

      // Collect fields (now Map<String, dynamic>)
      final Map<String, dynamic> fields = vehicleModel.toJsonFields();
      final List<File> files = vehicleModel.images ?? [];

      print("🚗 Vehicle Update Data:");
      print("🚗 - Vehicle ID: ${vehicleModel.vehicleId}");
      print("🚗 - User ID: ${vehicleModel.userId}");
      print("🚗 - Vehicle Type: ${vehicleModel.vehicleType}");
      print("🚗 - Vehicle Number: ${vehicleModel.vehicleNumber}");
      print("🚗 - Vehicle Model: ${vehicleModel.vehicleModel}");
      print("🚗 - Manufacturing Year: ${vehicleModel.manufacturingYear}");
      print("🚗 - Ownership Type: ${vehicleModel.ownershipType}");
      print("🚗 - Description: ${vehicleModel.description}");
      print("🚗 - Is Declaration Accepted: ${vehicleModel.isDeclarationAccepted}");
      print("🚗 - Images Count: ${files.length}");
      
      // Check if VehicleId is valid
      if (vehicleModel.vehicleId == null || vehicleModel.vehicleId!.isEmpty) {
        print("🚗 ⚠️ WARNING: VehicleId is NULL or EMPTY!");
        print("🚗 This might cause 403 error - vehicle ownership cannot be verified");
      } else {
        print("🚗 ✅ VehicleId is present: ${vehicleModel.vehicleId}");
      }
      
      // Check if UserId matches
      if (vehicleModel.userId == null || vehicleModel.userId!.isEmpty) {
        print("🚗 ⚠️ WARNING: UserId is NULL or EMPTY!");
      } else {
        print("🚗 ✅ UserId is present: ${vehicleModel.userId}");
      }

      print("🚗 ==================================");
      print("🚗 SENDING UPDATE REQUEST");
      print("🚗 ==================================");
      print("🚗 URL: ${API.updateVehicle}");
      print("🚗 Headers: {Authorization: Bearer $token}");
      print("🚗 Fields: $fields");
      print("🚗 Files attached: ${files.length}");
      print("🚗 ==================================");

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

      print("🚗 ==================================");
      print("🚗 UPDATE RESPONSE FROM API");
      print("🚗 ==================================");
      print("🚗 Status Code: ${response.statusCode}");
      print("🚗 Response Body: ${response.body}");
      print("🚗 Response Headers: ${response.headers}");
      print("🚗 ==================================");

      if (response.statusCode == 200) {
        print("🚗 ✅ VEHICLE UPDATED SUCCESSFULLY!");
        Get.snackbar("Success", "Vehicle updated successfully ✅");
        return true;
      } else {
        print("🚗 ❌ VEHICLE UPDATE FAILED!");
        print("🚗 Error Status: ${response.statusCode}");
        print("🚗 Error Body: ${response.body}");
        Get.snackbar("Error", "Failed with status: ${response.statusCode}");
        return false;
      }
    } catch (e, stack) {
      // 🔹 Log exception with stacktrace
      print("🚗 ==================================");
      print("🚗 UPDATE EXCEPTION OCCURRED");
      print("🚗 ==================================");
      print("🚗 Exception: $e");
      print("🚗 Stacktrace: $stack");
      print("🚗 ==================================");
      Get.snackbar("Error", "Something went wrong: $e");
      return false;
    } finally {
      isLoading.value = false;
      print("🚗 Update loading state set to false");
    }
  }
}
