import 'dart:convert';
import 'package:get/get.dart';
import '../models/get_driver_model.dart';
import '../models/get_vehicle_model.dart';
import '../models/vehicle_detail_response_model.dart';
import '../utils/constants.dart';
import '../apihelperclass/api_helper.dart'; // adjust import path if needed

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

      print("================================== ");
      //print("📩 Response from Vehicles API");
      //  print("🔹 Status Code: ${response.statusCode}");
      print("🔹 Body: ${response.body} teja");
      // print("🔹 Headers: ${response.headers}");
      print("==================================");

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        drivers.value = data.map((e) => Driver.fromJson(e)).toList();
      } else {
        Get.snackbar("Error", "Failed to load drivers: ${response.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "Exception: $e");
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
      // print("==================================");
      // print("📡 Fetching Vehicles");
      // print("👉 URL: $url");
      // print("👉 Headers: {Authorization: Bearer $token}");
      // print("==================================");

      final response = await HttpHelper.getData(
        endpoint: url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      // 🔹 Log response
      // print("==================================");
      // print("📩 Response from Vehicles API");
      // print("🔹 Status Code: ${response.statusCode}");
      // print("🔹 Body: ${response.body}");
      // print("🔹 Headers: ${response.headers}");
      // print("==================================");

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        vehicles.value = data.map((e) => Vehicle.fromJson(e)).toList();
        //  print("✅ Vehicles loaded: ${vehicles.length}");
      } else {
        Get.snackbar(
          "Error",
          "Failed to load vehicles: ${response.statusCode}",
        );
      }
    } catch (e) {
      //  print("❌ Exception in fetchVehicles: $e");
      Get.snackbar("Error", "Exception: $e");
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

      print("==================================");
      print("📡 Fetching Vehicle Details");
      print("👉 URL: $url");
      print("==================================");

      final response = await HttpHelper.getData(
        endpoint: url,
        headers: {
          "Authorization": "Bearer $token",
          "accept": "*/*",
        },
      );

      print("==================================");
      print("📩 Response from Vehicle Details API");
      print("🔹 Status Code: ${response.statusCode}");
      print("🔹 Body: ${response.body}");
      print("==================================");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        vehicleDetails.value = VehicleDetailResponseModel.fromJson(data);
        print("✅ Vehicle details loaded successfully");
      } else {
        Get.snackbar(
          "Error",
          "Failed to load vehicle details: ${response.statusCode}",
        );
      }
    } catch (e) {
      print("❌ Exception in fetchVehicleDetails: $e");
      Get.snackbar("Error", "Exception: $e");
    } finally {
      isVehicleDetailsLoading.value = false;
    }
  }
}
