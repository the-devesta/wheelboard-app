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
import 'package:flutter/foundation.dart';

class AddVehicleController extends GetxController {
  var isLoading = false.obs;

  Future<bool> addVehicle(VehicleModel vehicleModel, String token) async {
    try {
      isLoading.value = true;

      // Collect fields (now Map<String, dynamic>)
      final Map<String, dynamic> fields = vehicleModel.toJsonFields();
      final List<File> files = vehicleModel.images ?? [];

      // 🔹 Debug logs before sending
      // debugPrint("==================================");
      // debugPrint("📡 Sending Multipart Request");
      // debugPrint("👉 URL: ${API.addVehicle}");
      // debugPrint("👉 Headers: {Authorization: Bearer $token}");
      // debugPrint("👉 Fields: $fields");
      // debugPrint("👉 Files attached: ${files.length}");
      // debugPrint("==================================");

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
      // debugPrint("==================================");
      // debugPrint("📩 Response from API");
      // debugPrint("🔹 Status Code: ${response.statusCode}");
      // debugPrint("🔹 Body: ${response.body}");
      // debugPrint("🔹 Headers: ${response.headers}");
      // debugPrint("==================================");

      if (response.statusCode == 200) {
        Get.snackbar("Success", "Vehicle added successfully ✅");
        return true;
      } else {
        Get.snackbar("Error", "Failed with status: ${response.statusCode}");
        return false;
      }
    } catch (e, stack) {
      // 🔹 Log exception with stacktrace
      debugPrint("❌ Exception occurred: $e");
      debugPrint("🪜 Stacktrace: $stack");
      Get.snackbar("Error", "Something went wrong: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
