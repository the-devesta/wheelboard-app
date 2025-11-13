import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../apihelperclass/api_helper.dart';
import '../models/get_driver_model.dart';
import '../models/get_vehicle_model.dart';
import '../utils/constants.dart';
import '../utils/session_manager.dart';
import '../utils/navigation_helper.dart';
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

        // ✅ Auto-select first driver if none selected
        if (drivers.isNotEmpty && selectedDriver.value == null) {
          selectedDriver.value = drivers.first.driverId;
          print("🚚 Auto-selected driver: ${drivers.first.fullName} (${drivers.first.driverId})");
        }
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

  Future<void> addTrip(Trip trip) async {
    try {
      isLoading.value = true;

      // ✅ Validate only fields that are on the screen
      // DriverId is optional (not on screen), so no validation needed
      
      if (trip.vehicleId.isEmpty) {
        Get.snackbar("Error", "Please select a vehicle", 
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isLoading.value = false;
        return;
      }

      if (trip.pickupLocation.isEmpty) {
        Get.snackbar("Error", "Please enter pickup location", 
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isLoading.value = false;
        return;
      }

      if (trip.deliveryLocation.isEmpty) {
        Get.snackbar("Error", "Please enter delivery location", 
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isLoading.value = false;
        return;
      }

      if (trip.pickupDate == null) {
        Get.snackbar("Error", "Please select pickup date", 
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isLoading.value = false;
        return;
      }

      if (trip.pickupTime.isEmpty) {
        Get.snackbar("Error", "Please select pickup time", 
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isLoading.value = false;
        return;
      }
      
      // SpecialInstructions and PayRange are optional (can be empty)

      // ✅ Validate userId (userId-based authentication, token not required)
      if (trip.userId.isEmpty) {
        Get.snackbar("Error", "User ID is missing. Please login again.", 
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isLoading.value = false;
        return;
      }

      // ✅ Get auth details from session/service (token optional but logged)
      final sessionManager = SessionManager();
      final savedUserType = await sessionManager.getString("userType");
      final savedUserId = await sessionManager.getString("userId");
      final storedToken = await sessionManager.getString("authToken") ?? "";
      final maskedToken =
          storedToken.isNotEmpty ? "${storedToken.substring(0, 6)}..." : "NONE";

      // ✅ Prepare fields according to new API structure
      // Only include fields that are on the screen, others are optional
      final fields = {
        "TripId": "", // Empty for new trips
        "UserId": trip.userId,
        "VehicleId": trip.vehicleId,
        if (trip.driverId.isNotEmpty) "DriverId": trip.driverId,
        "PickupLocation": trip.pickupLocation,
        "DeliveryLocation": trip.deliveryLocation,
        if (trip.pickupDate != null)
          "PickupDate": trip.pickupDate!.toIso8601String(),
        if (trip.pickupTime.isNotEmpty) "PickupTime": trip.pickupTime,
        if (trip.specialInstructions.isNotEmpty)
          "SpecialInstructions": trip.specialInstructions,
        if (trip.payRange.isNotEmpty) "PayRange": trip.payRange,
        if (trip.tripCode.isNotEmpty) "TripCode": trip.tripCode,
        if (trip.tripStatus.isNotEmpty) "TripStatus": trip.tripStatus,
      };
      
      // 🔍 Debug: Log all fields before sending
      print("==================================");
      print("📤 TRIP CREATION REQUEST");
      print("==================================");
      print("👤 Current User Type: ${savedUserType ?? 'NOT FOUND'}");
      print("👤 Current User ID: ${savedUserId ?? 'NOT FOUND'}");
      print("👉 Endpoint: ${API.addTrip}");
      print("👉 Token (masked - not sent): $maskedToken");
      print("👉 Trip UserId: ${trip.userId}");
      print("👉 Fields: $fields");
      print("==================================");
      
      // ⚠️ Warn if user type doesn't match expected
      if (savedUserType != null && savedUserType != "Transport") {
        print("⚠️ WARNING: User Type is '$savedUserType', but Trip creation typically requires 'Transport' type!");
      }

      // ✅ Call HttpHelper (no files for now, so pass empty list)
      // NOTE: Backend accepts userId-based auth, so we DO NOT send Authorization header
      final streamedResponse = await HttpHelper.uploadMultipart(
        endpoint: API.addTrip,
        fields: fields,
        files: [], // if later you add images or docs
        fieldKey: "file", // backend field name for files (ignored here)
        headers: {
          "Accept": "*/*",
        },
      );

      // ✅ Convert StreamedResponse to Response (can only read stream once)
      final response = await http.Response.fromStream(streamedResponse);

      // 🔍 Debug logging
      print("==================================");
      print("📥 Trip API Response Received");
      print("👉 Status Code: ${response.statusCode}");
      print("👉 Response Body: ${response.body}");
      print("👉 Response Headers: ${response.headers}");
      print("==================================");

      // ✅ Parse result
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Trip Added Successfully!");
        print("✅ Response: ${response.body}");
        
        // Try to parse JSON response if available
        try {
          final responseData = jsonDecode(response.body);
          print("✅ Parsed Response: $responseData");
        } catch (e) {
          print("ℹ️ Response is not JSON: ${response.body}");
        }
        
        Get.snackbar("Success", "Trip added successfully!", 
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        // Navigate to home screen after successful trip creation
        // Close all previous screens and go to main wrapper (home)
        Future.delayed(const Duration(milliseconds: 500), () {
          NavigationHelper.navigateToMainWrapper();
        });
      } else if (response.statusCode == 400) {
        // 🔴 Handle 400 Bad Request - Validation errors
        print("❌ 400 Bad Request - Validation Error!");
        
        String errorMessage = "Validation Error: ";
        try {
          final errorData = jsonDecode(response.body);
          
          // Check for validation errors object
          if (errorData.containsKey('errors') && errorData['errors'] is Map) {
            final errors = errorData['errors'] as Map<String, dynamic>;
            final errorMessages = <String>[];
            
            errors.forEach((field, messages) {
              if (messages is List) {
                for (var msg in messages) {
                  errorMessages.add("$field: $msg");
                }
              } else {
                errorMessages.add("$field: $messages");
              }
            });
            
            errorMessage = errorMessages.join('\n');
            print("❌ Validation Errors:");
            errors.forEach((field, messages) {
              print("   - $field: $messages");
            });
          } else {
            errorMessage = errorData['title'] ?? 
                          errorData['message'] ?? 
                          errorData.toString();
          }
        } catch (e) {
          errorMessage = response.body.isNotEmpty 
                        ? response.body 
                        : "Invalid request data";
        }
        
        Get.snackbar(
          "Validation Error", 
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      } else if (response.statusCode == 403) {
        // 🔴 Handle 403 Forbidden specifically
        print("❌ 403 Forbidden - Access Denied!");
        print("❌ This usually means:");
        print("   1. Token expired or invalid");
        print("   2. User doesn't have permission to create trips");
        print("   3. API endpoint requires different authentication");
        
        String errorMessage = "Access Denied (403). ";
        
        // Check if response contains HTML (server error page)
        if (response.body.contains('<!DOCTYPE html>') || response.body.contains('Forbidden')) {
          errorMessage += "Your session may have expired. Please try logging in again.";
        } else {
          try {
            final errorData = jsonDecode(response.body);
            errorMessage += errorData['message'] ?? 
                          errorData['error'] ?? 
                          "Please check your permissions.";
          } catch (e) {
            errorMessage += "Please login again and try.";
          }
        }
        
        Get.snackbar(
          "Access Denied", 
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      } else {
        print("❌ Trip Addition Failed!");
        print("❌ Error Status: ${response.statusCode}");
        print("❌ Error Body: ${response.body}");
        
        // Try to parse error message from response
        String errorMessage = "Failed to create trip (${response.statusCode})";
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? 
                        errorData['error'] ?? 
                        errorData.toString();
        } catch (e) {
          // If response is HTML, extract meaningful text
          if (response.body.contains('<title>')) {
            final titleMatch = RegExp(r'<title>(.*?)</title>').firstMatch(response.body);
            if (titleMatch != null) {
              errorMessage = titleMatch.group(1) ?? errorMessage;
            }
          } else if (response.body.isNotEmpty) {
            // Show first 100 chars if it's not HTML
            errorMessage = response.body.length > 100 
                          ? "${response.body.substring(0, 100)}..." 
                          : response.body;
          }
        }
        
        Get.snackbar(
          "Error", 
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Exception: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
