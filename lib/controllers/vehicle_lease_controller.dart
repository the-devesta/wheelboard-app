import 'dart:convert';
import 'package:get/get.dart';
import '../apihelperclass/api_helper.dart';
import '../utils/constants.dart';
import '../models/vehicle_lease_model.dart';
import '../widgets/custom_snackbar.dart';
import '../utils/app_logger.dart';

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

      AppLogger.d("🚛 ==================================");
      AppLogger.d("🚛 STARTING VEHICLE LEASE ADDITION");
      AppLogger.d("🚛 ==================================");

      final requestData = leaseModel.toJson();

      AppLogger.d("🚛 Lease Data:");
      AppLogger.d("🚛 - User ID: ${leaseModel.userId}");
      AppLogger.d("🚛 - Vehicle ID: ${leaseModel.vehicleId}");
      AppLogger.d("🚛 - Vehicle Title: ${leaseModel.vehicleTitle}");
      AppLogger.d("🚛 - Vehicle Number: ${leaseModel.vehicleNumber}");
      AppLogger.d("🚛 - Model: ${leaseModel.model}");
      AppLogger.d("🚛 - Odometer Reading: ${leaseModel.odometerStartReading}");
      AppLogger.d("🚛 - Pricing Type: ${leaseModel.pricingType}");
      AppLogger.d("🚛 - Flat Price: ${leaseModel.flatPrice}");
      AppLogger.d("🚛 - Avg Monthly Run: ${leaseModel.avgMonthlyRun}");
      AppLogger.d("🚛 - Trip Efficiency Rate: ${leaseModel.tripEfficiencyRate}");
      AppLogger.d("🚛 - Start Date: ${leaseModel.startDate}");
      AppLogger.d("🚛 - End Date: ${leaseModel.endDate}");
      AppLogger.d("🚛 - Business Days: ${leaseModel.businessDays}");
      AppLogger.d("🚛 - Start Time: ${leaseModel.startTime}");
      AppLogger.d("🚛 - End Time: ${leaseModel.endTime}");
      AppLogger.d("🚛 - Instructions: ${leaseModel.instructions}");
      AppLogger.d("🚛 ==================================");
      AppLogger.d("🚛 Request JSON: ${jsonEncode(requestData)}");
      AppLogger.d("🚛 ==================================");

      final response = await HttpHelper.postData(
        endpoint: API.addVehicleLease,
        data: requestData,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'accept': '*/*',
        },
      );

      AppLogger.d("🚛 ==================================");
      AppLogger.d("🚛 RESPONSE FROM API");
      AppLogger.d("🚛 ==================================");
      AppLogger.d("🚛 Status Code: ${response.statusCode}");
      AppLogger.d("🚛 Response Body: ${response.body}");
      AppLogger.d("🚛 ==================================");

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true) {
          AppLogger.d("🚛 ✅ VEHICLE LEASE ADDED SUCCESSFULLY!");
          SnackBarHelper.success(
            responseBody['message'] ?? "Lease posted successfully",
          );
          return true;
        } else {
          AppLogger.d("🚛 ❌ API returned success: false");
          SnackBarHelper.error(
            responseBody['message'] ?? "Failed to add lease",
          );
          return false;
        }
      } else {
        AppLogger.d("🚛 ❌ VEHICLE LEASE ADDITION FAILED!");
        AppLogger.d("🚛 Error Status: ${response.statusCode}");
        AppLogger.d("🚛 Error Body: ${response.body}");

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
      AppLogger.d("🚛 ==================================");
      AppLogger.d("🚛 EXCEPTION OCCURRED");
      AppLogger.d("🚛 ==================================");
      AppLogger.d("🚛 Exception: $e");
      AppLogger.d("🚛 Stacktrace: $stack");
      AppLogger.d("🚛 ==================================");
      SnackBarHelper.error("Something went wrong: $e");
      return false;
    } finally {
      isLoading.value = false;
      AppLogger.d("🚛 Loading state set to false");
    }
  }

  /// Get vehicle lease list (if API available)
  Future<void> getVehicleLeases(String userId, String token) async {
    try {
      isLoading.value = true;

      // TODO: Implement when GET lease list API is available
      AppLogger.d("🚛 Get Vehicle Leases - Not yet implemented");
    } catch (e) {
      AppLogger.d("🚛 Error fetching leases: $e");
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
