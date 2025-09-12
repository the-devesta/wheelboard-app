import 'dart:io';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/professional_signupmodel.dart';
import '../apihelperclass/api_helper.dart';
import '../utils/constants.dart';
import '../models/add_drivermodel.dart';

class AddDriverController extends GetxController {
  var isLoading = false.obs;

  Future<void> addDriver(DriverModel driverModel) async {
    try {
      isLoading.value = true;

      // ✅ Collect fields from model
      final fields = driverModel.toJsonFields();

      // ✅ Collect files (optional)
      final List<File> files = [];
      if (driverModel.images != null) {
        files.addAll(
          driverModel.images!,
        ); // Use addAll to add all files from the list
      }

      // ✅ Debug log what you are sending
      // print("==================================");
      // print("📡 Sending Multipart Request");
      // print("👉 Endpoint: ${API.addDriver}");
      // print("👉 Fields: $fields");
      // print("👉 Files: ${files.map((f) => f.path).toList()}");
      // print("==================================");

      // ✅ Call your helper
      final streamedResponse = await HttpHelper.uploadMultipart(
        endpoint: API.addDriver, // Adjust endpoint
        fields: fields,
        files: files,
        fieldKey: "Image", // API key for file upload
        headers: {},
      );

      // Convert streamed response to normal Response
      final response = await http.Response.fromStream(streamedResponse);

      // ✅ Debug log the response
      // print("==================================");
      // print("📥 Response Received");
      // print("👉 Status Code: ${response.statusCode}");
      // print("👉 Body: ${response.body}");
      // print("==================================");

      if (response.statusCode == 200) {
        Get.snackbar("Success", "Registered successfully ✅");
      } else {
        Get.snackbar(
          "Error",
          "Failed with status: ${response.statusCode} \n${response.body}",
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
