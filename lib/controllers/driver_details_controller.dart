import 'dart:convert';
import 'package:get/get.dart';
import '../apihelperclass/api_helper.dart';
import '../models/driver_details_model.dart';
import '../widgets/custom_snackbar.dart';
import '../utils/session_manager.dart';

class DriverDetailsController extends GetxController {
  var isLoading = false.obs;
  Rx<DriverDetailsModel?> driverDetails = Rx<DriverDetailsModel?>(null);

  Future<void> fetchDriverDetails(String driverId) async {
    try {
      isLoading.value = true;

      print("👤 Fetching driver details for ID: $driverId");

      // Get auth token if available
      final sessionManager = SessionManager();
      final token = await sessionManager.getString("authToken");
      
      Map<String, String> headers = {'accept': '*/*'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        print("👤 Using auth token");
      }

      final response = await HttpHelper.getDriverDetails(
        driverId: driverId,
        headers: headers,
      );

      print("👤 Response Status: ${response.statusCode}");
      print("👤 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseBody = response.body.trim();
        
        if (responseBody.isEmpty) {
          print("❌ Empty response body");
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
              print("✅ Driver details loaded successfully: ${driverDetails.value?.fullName}");
            } 
            // If data is wrapped in a result/response object
            else if (data.containsKey('result')) {
              final result = data['result'];
              if (result is Map<String, dynamic>) {
                driverDetails.value = DriverDetailsModel.fromJson(result);
                print("✅ Driver details loaded successfully: ${driverDetails.value?.fullName}");
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
          print("❌ JSON Parse Error: $parseError");
          SnackBarHelper.error("Failed to parse driver details");
        }
      } else if (response.statusCode == 404) {
        print("❌ Driver not found (404)");
        SnackBarHelper.warning("Driver details not found. Please try again.");
      } else {
        print("❌ Failed to load driver details: ${response.statusCode}");
        SnackBarHelper.error("Failed to load driver details (Status: ${response.statusCode})");
      }
    } catch (e) {
      print("❌ Error fetching driver details: $e");
      SnackBarHelper.error("Error fetching driver details: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }
}

