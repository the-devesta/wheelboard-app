import 'dart:convert';
import 'package:get/get.dart';
import '../apihelperclass/api_helper.dart';
import '../utils/constants.dart';
import '../models/vehicle_lease_model.dart';
import '../widgets/custom_snackbar.dart';

/// Controller for Vehicle Lease operations
class VehicleLeaseController extends GetxController {
  var isLoading = false.obs;
  var leaseList = <VehicleLeaseModel>[].obs;

  /// Add a new vehicle lease
  Future<bool> addVehicleLease(
    VehicleLeaseModel leaseModel,
    String token,
  ) async {
    try {
      isLoading.value = true;

      print("🚛 ==================================");
      print("🚛 STARTING VEHICLE LEASE ADDITION");
      print("🚛 ==================================");

      final requestData = leaseModel.toJson();

      print("🚛 Lease Data:");
      print("🚛 - User ID: ${leaseModel.userId}");
      print("🚛 - Vehicle ID: ${leaseModel.vehicleId}");
      print("🚛 - Vehicle Title: ${leaseModel.vehicleTitle}");
      print("🚛 - Vehicle Number: ${leaseModel.vehicleNumber}");
      print("🚛 - Model: ${leaseModel.model}");
      print("🚛 - Odometer Reading: ${leaseModel.odometerStartReading}");
      print("🚛 - Pricing Type: ${leaseModel.pricingType}");
      print("🚛 - Flat Price: ${leaseModel.flatPrice}");
      print("🚛 - Avg Monthly Run: ${leaseModel.avgMonthlyRun}");
      print("🚛 - Trip Efficiency Rate: ${leaseModel.tripEfficiencyRate}");
      print("🚛 - Start Date: ${leaseModel.startDate}");
      print("🚛 - End Date: ${leaseModel.endDate}");
      print("🚛 - Business Days: ${leaseModel.businessDays}");
      print("🚛 - Start Time: ${leaseModel.startTime}");
      print("🚛 - End Time: ${leaseModel.endTime}");
      print("🚛 - Instructions: ${leaseModel.instructions}");
      print("🚛 ==================================");
      print("🚛 Request JSON: ${jsonEncode(requestData)}");
      print("🚛 ==================================");

      final response = await HttpHelper.postData(
        endpoint: API.addVehicleLease,
        data: requestData,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'accept': '*/*',
        },
      );

      print("🚛 ==================================");
      print("🚛 RESPONSE FROM API");
      print("🚛 ==================================");
      print("🚛 Status Code: ${response.statusCode}");
      print("🚛 Response Body: ${response.body}");
      print("🚛 ==================================");

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true) {
          print("🚛 ✅ VEHICLE LEASE ADDED SUCCESSFULLY!");
          SnackBarHelper.success(
            responseBody['message'] ?? "Lease posted successfully",
          );
          return true;
        } else {
          print("🚛 ❌ API returned success: false");
          SnackBarHelper.error(
            responseBody['message'] ?? "Failed to add lease",
          );
          return false;
        }
      } else {
        print("🚛 ❌ VEHICLE LEASE ADDITION FAILED!");
        print("🚛 Error Status: ${response.statusCode}");
        print("🚛 Error Body: ${response.body}");

        String errorMessage = "Failed to add lease";
        try {
          final errorBody = jsonDecode(response.body);

          // Check for validation errors
          if (errorBody['errors'] != null) {
            final errors = errorBody['errors'] as Map<String, dynamic>;
            List<String> errorMessages = [];
            errors.forEach((key, value) {
              if (value is List && value.isNotEmpty) {
                errorMessages.add(value.first.toString());
              }
            });
            if (errorMessages.isNotEmpty) {
              errorMessage = errorMessages.join('\n');
            }
          } else {
            errorMessage =
                errorBody['message'] ?? errorBody['title'] ?? errorMessage;
          }
        } catch (_) {}

        SnackBarHelper.error(errorMessage);
        return false;
      }
    } catch (e, stack) {
      print("🚛 ==================================");
      print("🚛 EXCEPTION OCCURRED");
      print("🚛 ==================================");
      print("🚛 Exception: $e");
      print("🚛 Stacktrace: $stack");
      print("🚛 ==================================");
      SnackBarHelper.error("Something went wrong: $e");
      return false;
    } finally {
      isLoading.value = false;
      print("🚛 Loading state set to false");
    }
  }

  /// Get vehicle lease list (if API available)
  Future<void> getVehicleLeases(String userId, String token) async {
    try {
      isLoading.value = true;

      // TODO: Implement when GET lease list API is available
      print("🚛 Get Vehicle Leases - Not yet implemented");
    } catch (e) {
      print("🚛 Error fetching leases: $e");
      SnackBarHelper.error("Failed to fetch leases");
    } finally {
      isLoading.value = false;
    }
  }

  /// Clear lease data
  void clearData() {
    leaseList.clear();
  }
}
