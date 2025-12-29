import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/get_driver_model.dart';
import '../models/get_vehicle_model.dart';
import '../models/vehicle_detail_response_model.dart';
import '../utils/constants.dart';
import '../apihelperclass/api_helper.dart'; // adjust import path if needed
import '../utils/app_logger.dart';

class DriverController extends GetxController {
  // 🚗 Drivers
  var drivers = <Driver>[].obs;
  var isLoading = false.obs;

  // 🚙 Vehicles
  var vehicles = <Vehicle>[].obs;
  var isVehicleLoading = false.obs;

  // ================================
  // FETCH DRIVERS (unchanged)
  // ================================
  Future<void> fetchDrivers(String userId, String token) async {
    try {
      isLoading.value = true;

      final url = "${API.getDrivers}/$userId";

      final response = await HttpHelper.getData(
        endpoint: url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      AppLogger.d("================================== ");
      //AppLogger.d("📩 Response from Vehicles API");
      //  AppLogger.d("🔹 Status Code: ${response.statusCode}");
      AppLogger.d("🔹 Body: ${response.body} teja");
      // AppLogger.d("🔹 Headers: ${response.headers}");
      AppLogger.d("==================================");

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        drivers.value = data.map((e) => Driver.fromJson(e)).toList();
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.snackbar(
            "Error",
            "Failed to load drivers: ${response.statusCode}",
          );
        });
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar("Error", "Exception: $e");
      });
    } finally {
      isLoading.value = false;
    }
  }

  // ================================
  // FETCH VEHICLES (new code added)
  // ================================
  // Future<void> fetchVehicles(String userId, String token) async {
  //   try {
  //     isVehicleLoading.value = true;

  //     final url = "${API.getVehicles}/$userId";

  //     final response = await HttpHelper.getData(
  //       endpoint: url,
  //       headers: {
  //         "Authorization": "Bearer $token",
  //         "Content-Type": "application/json",
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       final List data = jsonDecode(response.body);
  //       vehicles.value = data.map((e) => Vehicle.fromJson(e)).toList();
  //     } else {
  //       Get.snackbar(
  //         "Error",
  //         "Failed to load vehicles: ${response.statusCode}",
  //       );
  //     }
  //   } catch (e, stack) {
  //     Get.snackbar("Error", "Exception: $e");
  //   } finally {
  //     isVehicleLoading.value = false;
  //   }
  // }

  Future<void> fetchVehicles(String userId, String token) async {
    try {
      isVehicleLoading.value = true;

      final url = "${API.getVehicles}/$userId";

      // 🔹 Log request
      // AppLogger.d("==================================");
      // AppLogger.d("📡 Fetching Vehicles");
      // AppLogger.d("👉 URL: $url");
      // AppLogger.d("👉 Headers: {Authorization: Bearer $token}");
      // AppLogger.d("==================================");

      final response = await HttpHelper.getData(
        endpoint: url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      // 🔹 Log response
      // AppLogger.d("==================================");
      // AppLogger.d("📩 Response from Vehicles API");
      // AppLogger.d("🔹 Status Code: ${response.statusCode}");
      // AppLogger.d("🔹 Body: ${response.body}");
      // AppLogger.d("🔹 Headers: ${response.headers}");
      // AppLogger.d("==================================");

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        vehicles.value = data.map((e) => Vehicle.fromJson(e)).toList();
        //  AppLogger.d("✅ Vehicles loaded: ${vehicles.length}");
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.snackbar(
            "Error",
            "Failed to load vehicles: ${response.statusCode}",
          );
        });
      }
    } catch (e) {
      //  AppLogger.d("❌ Exception in fetchVehicles: $e");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar("Error", "Exception: $e");
      });
    } finally {
      isVehicleLoading.value = false;
    }
  }

  // ================================
  // FETCH VEHICLE DETAILS BY ID
  // ================================
  var vehicleDetails = Rx<VehicleDetailResponseModel?>(null);
  var isVehicleDetailsLoading = false.obs;

  Future<void> fetchVehicleDetails(String vehicleId, String token) async {
    try {
      isVehicleDetailsLoading.value = true;

      final url = "${API.getVehicleDetailsById}$vehicleId";

      AppLogger.d("==================================");
      AppLogger.d("📡 Fetching Vehicle Details");
      AppLogger.d("👉 URL: $url");
      AppLogger.d("==================================");

      final response = await HttpHelper.getData(
        endpoint: url,
        headers: {"Authorization": "Bearer $token", "accept": "*/*"},
      );

      AppLogger.d("==================================");
      AppLogger.d("📩 Response from Vehicle Details API");
      AppLogger.d("🔹 Status Code: ${response.statusCode}");
      AppLogger.d("🔹 Body: ${response.body}");
      AppLogger.d("==================================");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        vehicleDetails.value = VehicleDetailResponseModel.fromJson(data);
        AppLogger.d("✅ Vehicle details loaded successfully");
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.snackbar(
            "Error",
            "Failed to load vehicle details: ${response.statusCode}",
          );
        });
      }
    } catch (e) {
      AppLogger.d("❌ Exception in fetchVehicleDetails: $e");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar("Error", "Exception: $e");
      });
    } finally {
      isVehicleDetailsLoading.value = false;
    }
  }
}
