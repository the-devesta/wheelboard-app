import 'dart:convert';
import 'package:get/get.dart';
import '../../apihelperclass/api_helper.dart';
import '../../models/driver_details_model.dart';
import '../../widgets/custom_snackbar.dart';
import '../../utils/session_manager.dart';
import '../../utils/app_logger.dart';
import '../../utils/constants.dart';

class DriverDetailsController extends GetxController {
  var isLoading = false.obs;
  Rx<DriverDetailsModel?> driverDetails = Rx<DriverDetailsModel?>(null);

  Future<void> fetchDriverDetails(String driverId) async {
    try {
      isLoading.value = true;

      AppLogger.d("👤 Fetching driver details for ID: $driverId");

      // Get auth token if available
      final sessionManager = SessionManager();
      final token = await sessionManager.getString("authToken");

      Map<String, String> headers = {'accept': '*/*'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        AppLogger.d("👤 Using auth token");
      }

      final response = await HttpHelper.getDriverDetails(
        driverId: driverId,
        headers: headers,
      );

      AppLogger.d("👤 Response Status: ${response.statusCode}");
      AppLogger.d("👤 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseBody = response.body.trim();

        if (responseBody.isEmpty) {
          AppLogger.d("❌ Empty response body");
          SnackBarHelper.error("Driver details not found");
          return;
        }

        try {
          final data = json.decode(responseBody);

          // Check if response has nested structure
          if (data is Map<String, dynamic>) {
            // If data is directly the driver object
            if (data.containsKey('driverId')) {
              driverDetails.value = DriverDetailsModel.fromJson(data);
              AppLogger.d(
                "✅ Driver details loaded successfully: ${driverDetails.value?.fullName}",
              );
            }
            // If data is wrapped in a result/response object
            else if (data.containsKey('result')) {
              final result = data['result'];
              if (result is Map<String, dynamic>) {
                driverDetails.value = DriverDetailsModel.fromJson(result);
                AppLogger.d(
                  "✅ Driver details loaded successfully: ${driverDetails.value?.fullName}",
                );
              } else {
                SnackBarHelper.error("Invalid driver data format");
              }
            } else {
              SnackBarHelper.error("Driver details not found in response");
            }
          } else {
            SnackBarHelper.error("Invalid response format");
          }
        } catch (parseError) {
          AppLogger.d("❌ JSON Parse Error: $parseError");
          SnackBarHelper.error("Failed to parse driver details");
        }
      } else if (response.statusCode == 404) {
        AppLogger.d("❌ Driver not found (404)");
        SnackBarHelper.warning("Driver details not found. Please try again.");
      } else {
        AppLogger.d("❌ Failed to load driver details: ${response.statusCode}");
        SnackBarHelper.error(
          "Failed to load driver details (Status: ${response.statusCode})",
        );
      }
    } catch (e) {
      AppLogger.d("❌ Error fetching driver details: $e");
      SnackBarHelper.error("Error fetching driver details: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteDriver(
    String driverId,
    String userId,
    String token,
  ) async {
    try {
      final url =
          "${API.deleteDriver}/$driverId${API.deleteVehicleSuffix}?modifiedBy=$userId";

      AppLogger.d("==================================");
      AppLogger.d("📡 Deleting Driver");
      AppLogger.d("👉 URL: $url");
      AppLogger.d("==================================");

      final response = await HttpHelper.postData(
        endpoint: url,
        data: {},
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "accept": "*/*",
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        SnackBarHelper.error("Failed to delete driver");
        return false;
      }
    } catch (e) {
      AppLogger.d("❌ Exception in deleteDriver: $e");
      SnackBarHelper.error("Exception: $e");
      return false;
    }
  }
}
