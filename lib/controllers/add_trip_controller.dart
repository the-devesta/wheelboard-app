import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../apihelperclass/api_helper.dart';
import '../models/get_driver_model.dart';
import '../models/get_vehicle_model.dart';
import '../utils/constants.dart';
import '../models/add_new_trip_model.dart';

class TripController extends GetxController {
  var drivers = <Driver>[].obs;
  var vehicles = <Vehicle>[].obs;

  var selectedDriver = RxnString(); // holds selected driver id
  var selectedVehicle = RxnString(); // holds selected vehicle id

  var isLoading = false.obs;
  var isVehicleLoading = false.obs;

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

  Future<void> fetchVehicles(String userId, String token) async {
    try {
      isVehicleLoading.value = true;
      final url = "${API.getVehicles}/$userId";

      final response = await HttpHelper.getData(
        endpoint: url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        vehicles.value = data.map((e) => Vehicle.fromJson(e)).toList();
      } else {
        Get.snackbar(
          "Error",
          "Failed to load vehicles: ${response.statusCode}",
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Exception: $e");
    } finally {
      isVehicleLoading.value = false;
    }
  }

  Future<void> addTrip(Trip trip, String token) async {
    try {
      isLoading.value = true;

      // ✅ Prepare fields
      final fields = {
        "TripId": trip.tripId,
        "UserId": trip.userId,
        "VehicleId": trip.vehicleId,
        "DriverId": trip.driverId,
        "PickupLocation": trip.pickupLocation,
        "DeliveryLocation": trip.deliveryLocation,
        "PickupDate": trip.pickupDate?.toIso8601String(),
        "PickupTime": trip.pickupTime,
        "SpecialInstructions": trip.specialInstructions,
        "PayRange": trip.payRange,
        "TripCode": trip.tripCode,
        "TripStatus": trip.tripStatus,
      };

      // ✅ Call HttpHelper (no files for now, so pass empty list)
      final response = await HttpHelper.uploadMultipart(
        endpoint: API.addTrip, // replace with your endpoint constant

        fields: fields,
        files: [], // if later you add images or docs
        fieldKey: "file", // backend field name for files (ignored here)
        headers: {"Authorization": "Bearer $token"},
      );

      // ✅ Parse result
      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        print("✅ Trip Added: $respStr");
        Get.snackbar("Success", "Trip added successfully!");
        // close the add trip screen
      } else {
        final respStr = await response.stream.bytesToString();
        // print("❌ Error ${response.statusCode}: $respStr");
        //   Get.snackbar("Error", "Failed: ${response.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "Exception: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
