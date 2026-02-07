import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../apihelperclass/api_helper.dart';
import '../../models/get_driver_model.dart';
import '../../models/get_vehicle_model.dart';
import '../../utils/constants.dart';
import '../../utils/session_manager.dart';
import '../../utils/navigation_helper.dart';
import '../../models/add_new_trip_model.dart';
import '../../utils/app_logger.dart';

class TripController extends GetxController {
  var drivers = <Driver>[].obs;
  var vehicles = <Vehicle>[].obs;
  var trips = <Trip>[].obs;

  var selectedDriver = RxnString(); // holds selected driver id
  var selectedVehicle = RxnString(); // holds selected vehicle id

  var isLoading = false.obs;
  var isVehicleLoading = false.obs;
  var isTripsLoading = false.obs;

  Future<void> fetchDrivers(String userId) async {
    try {
      isLoading.value = true;
      final url = "${API.getDrivers}/$userId";

      final response = await HttpHelper.getData(
        endpoint: url,
        headers: {"Accept": "*/*"},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        drivers.value = data.map((e) => Driver.fromJson(e)).toList();

        // ✅ Auto-select first driver if none selected
        if (drivers.isNotEmpty && selectedDriver.value == null) {
          selectedDriver.value = drivers.first.driverId;
          AppLogger.d(
            "🚚 Auto-selected driver: ${drivers.first.fullName} (${drivers.first.driverId})",
          );
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

  Future<void> fetchVehicles(String userId) async {
    try {
      isVehicleLoading.value = true;
      final url = "${API.getVehicles}/$userId";

      final response = await HttpHelper.getData(
        endpoint: url,
        headers: {"Accept": "*/*"},
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
        Get.snackbar(
          "Error",
          "Please select a vehicle",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isLoading.value = false;
        return;
      }

      if (trip.pickupLocation.isEmpty) {
        Get.snackbar(
          "Error",
          "Please enter pickup location",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isLoading.value = false;
        return;
      }

      if (trip.deliveryLocation.isEmpty) {
        Get.snackbar(
          "Error",
          "Please enter delivery location",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isLoading.value = false;
        return;
      }

      if (trip.pickupDate == null) {
        Get.snackbar(
          "Error",
          "Please select pickup date",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isLoading.value = false;
        return;
      }

      if (trip.pickupTime.isEmpty) {
        Get.snackbar(
          "Error",
          "Please select pickup time",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isLoading.value = false;
        return;
      }

      // SpecialInstructions and PayRange are optional (can be empty)

      // ✅ Validate userId (userId-based authentication, token not required)
      if (trip.userId.isEmpty) {
        Get.snackbar(
          "Error",
          "User ID is missing. Please login again.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isLoading.value = false;
        return;
      }

      // ✅ Get auth details from session/service (token not needed, userId-based auth)
      final sessionManager = SessionManager();
      final savedUserType = await sessionManager.getString("userType");
      final savedUserId = await sessionManager.getString("userId");

      // ✅ Get vehicle number from selected vehicle
      String vehicleNumber = "";
      if (trip.vehicleId.isNotEmpty) {
        try {
          final selectedVehicle = vehicles.firstWhere(
            (v) => v.vehicleId == trip.vehicleId,
          );
          vehicleNumber = selectedVehicle.vehicleNumber;
        } catch (e) {
          AppLogger.d("⚠️ Vehicle not found for vehicleId: ${trip.vehicleId}");
        }
      }

      // ✅ Prepare fields according to new API structure
      // PayRange and SpecialInstructions are optional - send empty string if not provided
      // TripId not needed for new trips - backend will generate it
      // DriverId should NOT be sent for new trips (post trip) - only for scheduled trips with driver selection
      final fields = <String, String>{
        "UserId": trip.userId,
        "VehicleId": trip.vehicleId,
        "PickupLocation": trip.pickupLocation,
        "DeliveryLocation": trip.deliveryLocation,
        "PickupDate": trip.pickupDate != null
            ? trip.pickupDate!.toIso8601String()
            : "",
        "PickupTime": trip.pickupTime.trim().isNotEmpty
            ? trip.pickupTime.trim()
            : "",
        // Send empty string if not provided (backend accepts empty string)
        "SpecialInstructions": trip.specialInstructions.trim(),
        "PayRange": trip.payRange.trim(),
        "TripCode": trip.tripCode.trim().isNotEmpty ? trip.tripCode.trim() : "",
        "TripStatus": trip.tripStatus.trim().isNotEmpty
            ? trip.tripStatus.trim()
            : "Pending",
        "Latitude": (trip.latitude ?? 0).toString(),
        "Longitude": (trip.longitude ?? 0).toString(),
        "Distance": trip.distance ?? "",
      };

      // ✅ DriverId logic:
      // - For SCHEDULED trips (isScheduledTrip = true): Send DriverId if selected
      // - For POST trips (isScheduledTrip = false): Do NOT send DriverId
      // This allows scheduled trips to have assigned drivers while post trips remain open for bidding

      // 🔍 DEBUG: Log DriverId decision logic
      AppLogger.d("=================================");
      AppLogger.d("🔍 DRIVER ID DECISION LOGIC");
      AppLogger.d("=================================");
      AppLogger.d("Is Scheduled Trip: ${trip.isScheduledTrip}");
      AppLogger.d("Trip DriverId value: '${trip.driverId}'");
      AppLogger.d("Trip DriverId isEmpty: ${trip.driverId.isEmpty}");
      AppLogger.d("Trip DriverId after trim: '${trip.driverId.trim()}'");
      AppLogger.d(
        "Trip DriverId.trim().isNotEmpty: ${trip.driverId.trim().isNotEmpty}",
      );

      // ✅ Send DriverId ONLY for scheduled trips with driver selected
      if (trip.isScheduledTrip && trip.driverId.trim().isNotEmpty) {
        fields["DriverId"] = trip.driverId.trim();
        AppLogger.d(
          "✅ DriverId WILL BE SENT: ${trip.driverId.trim()} (Scheduled Trip)",
        );
      } else {
        if (!trip.isScheduledTrip) {
          AppLogger.d(
            "❌ DriverId NOT SENT - Reason: This is a POST trip (not scheduled)",
          );
        } else if (trip.driverId.trim().isEmpty) {
          AppLogger.d("❌ DriverId NOT SENT - Reason: driverId is empty");
        }
      }
      AppLogger.d("=================================");

      // ✅ Include VehicleNo if available (optional field from backend)
      if (vehicleNumber.isNotEmpty) {
        fields["VehicleNo"] = vehicleNumber;
      }

      // 🔍 Debug: Log all fields before sending
      AppLogger.d("==================================");
      AppLogger.d("📤 TRIP CREATION REQUEST");
      AppLogger.d("==================================");
      AppLogger.d("👤 Current User Type: ${savedUserType ?? 'NOT FOUND'}");
      AppLogger.d("👤 Current User ID: ${savedUserId ?? 'NOT FOUND'}");
      AppLogger.d("👉 Endpoint: ${API.addTrip}");
      AppLogger.d("👉 Authentication: userId-based (UserId in headers)");
      AppLogger.d("👉 Trip UserId: ${trip.userId}");
      AppLogger.d("👉 Headers: {Accept: */*, UserId: ${trip.userId}}");
      AppLogger.d("==================================");
      AppLogger.d("📋 FIELDS BEING SENT:");
      AppLogger.d("==================================");
      fields.forEach((key, value) {
        if (key == "DriverId") {
          AppLogger.d("👨‍✈️ $key: '$value' ✅ DRIVER ID IS BEING SENT!");
        } else {
          AppLogger.d("   $key: '$value'");
        }
      });
      if (!fields.containsKey("DriverId")) {
        AppLogger.d("⚠️ DriverId: NOT INCLUDED IN REQUEST");
      }
      AppLogger.d("==================================");

      // ⚠️ Warn if user type doesn't match expected
      if (savedUserType != null && savedUserType != "Transport") {
        AppLogger.d(
          "⚠️ WARNING: User Type is '$savedUserType', but Trip creation typically requires 'Transport' type!",
        );
      }

      // ✅ Call HttpHelper (no files for now, so pass empty list)
      // NOTE: Backend uses userId-based auth - include userId in headers for authentication
      final streamedResponse = await HttpHelper.uploadMultipart(
        endpoint: API.addTrip,
        fields: fields,
        files: [], // if later you add images or docs
        fieldKey: "file", // backend field name for files (ignored here)
        headers: {
          "Accept": "*/*",
          "UserId": trip
              .userId, // Include userId in headers for userId-based authentication
        },
      );

      // ✅ Convert StreamedResponse to Response (can only read stream once)
      final response = await http.Response.fromStream(streamedResponse);

      // 🔍 Debug logging
      AppLogger.d("==================================");
      AppLogger.d("📥 Trip API Response Received");
      AppLogger.d("👉 Status Code: ${response.statusCode}");
      AppLogger.d("👉 Response Body: ${response.body}");
      AppLogger.d("👉 Response Headers: ${response.headers}");
      AppLogger.d("==================================");

      // ✅ Parse result
      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.d("✅ Trip Added Successfully!");
        AppLogger.d("✅ Response: ${response.body}");

        // Try to parse JSON response if available
        try {
          final responseData = jsonDecode(response.body);
          AppLogger.d("✅ Parsed Response: $responseData");
        } catch (e) {
          AppLogger.d("ℹ️ Response is not JSON: ${response.body}");
        }

        Get.snackbar(
          "Success",
          "Trip added successfully!",
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
        AppLogger.d("❌ 400 Bad Request - Validation Error!");

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
            AppLogger.d("❌ Validation Errors:");
            errors.forEach((field, messages) {
              AppLogger.d("   - $field: $messages");
            });
          } else {
            errorMessage =
                errorData['title'] ??
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
        AppLogger.d("❌ 403 Forbidden - Access Denied!");
        AppLogger.d("❌ This usually means:");
        AppLogger.d("   1. Token expired or invalid");
        AppLogger.d("   2. User doesn't have permission to create trips");
        AppLogger.d("   3. API endpoint requires different authentication");

        String errorMessage = "Access Denied (403). ";

        // Check if response contains HTML (server error page)
        if (response.body.contains('<!DOCTYPE html>') ||
            response.body.contains('Forbidden')) {
          errorMessage +=
              "Your session may have expired. Please try logging in again.";
        } else {
          try {
            final errorData = jsonDecode(response.body);
            errorMessage +=
                errorData['message'] ??
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
        AppLogger.d("❌ Trip Addition Failed!");
        AppLogger.d("❌ Error Status: ${response.statusCode}");
        AppLogger.d("❌ Error Body: ${response.body}");

        // Try to parse error message from response
        String errorMessage = "Failed to create trip (${response.statusCode})";
        try {
          final errorData = jsonDecode(response.body);
          errorMessage =
              errorData['message'] ??
              errorData['error'] ??
              errorData.toString();
        } catch (e) {
          // If response is HTML, extract meaningful text
          if (response.body.contains('<title>')) {
            final titleMatch = RegExp(
              r'<title>(.*?)</title>',
            ).firstMatch(response.body);
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

  /// Update an existing trip
  Future<void> updateTrip(Trip trip) async {
    try {
      isLoading.value = true;

      // ✅ Validate required fields
      if (trip.tripId.isEmpty) {
        Get.snackbar(
          "Error",
          "Trip ID is missing. Cannot update trip.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isLoading.value = false;
        return;
      }

      if (trip.vehicleId.isEmpty) {
        Get.snackbar(
          "Error",
          "Please select a vehicle",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isLoading.value = false;
        return;
      }

      if (trip.pickupLocation.isEmpty) {
        Get.snackbar(
          "Error",
          "Please enter pickup location",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isLoading.value = false;
        return;
      }

      if (trip.deliveryLocation.isEmpty) {
        Get.snackbar(
          "Error",
          "Please enter delivery location",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isLoading.value = false;
        return;
      }

      if (trip.pickupDate == null) {
        Get.snackbar(
          "Error",
          "Please select pickup date",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isLoading.value = false;
        return;
      }

      if (trip.pickupTime.isEmpty) {
        Get.snackbar(
          "Error",
          "Please select pickup time",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isLoading.value = false;
        return;
      }

      if (trip.userId.isEmpty) {
        Get.snackbar(
          "Error",
          "User ID is missing. Please login again.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isLoading.value = false;
        return;
      }

      // ✅ Get vehicle number from selected vehicle
      String vehicleNumber = "";
      if (trip.vehicleId.isNotEmpty) {
        try {
          final selectedVehicle = vehicles.firstWhere(
            (v) => v.vehicleId == trip.vehicleId,
          );
          vehicleNumber = selectedVehicle.vehicleNumber;
        } catch (e) {
          AppLogger.d("⚠️ Vehicle not found for vehicleId: ${trip.vehicleId}");
        }
      }

      // ✅ Prepare JSON body for update (camelCase as expected by Swagger/Backend)
      final body = <String, dynamic>{
        "tripId": trip.tripId,
        "userId": trip.userId,
        "vehicleId": trip.vehicleId,
        "driverId": trip.driverId.isNotEmpty ? trip.driverId : trip.userId,
        "pickupLocation": trip.pickupLocation,
        "deliveryLocation": trip.deliveryLocation,
        "pickupDate": trip.pickupDate != null
            ? trip.pickupDate!.toIso8601String()
            : "",
        "pickupTime": trip.pickupTime.trim(),
        "specialInstructions": trip.specialInstructions.trim(),
        "payRange": trip.payRange.trim(),
        "tripCode": trip.tripCode.trim(),
        "tripStatus": trip.tripStatus.trim().isNotEmpty
            ? trip.tripStatus.trim()
            : "Pending",
        "vehicleNo": vehicleNumber,
        "distance": trip.distance ?? "",
        "latitude": trip.latitude ?? 0,
        "longitude": trip.longitude ?? 0,
      };

      // 🔍 Debug: Log request
      AppLogger.d("==================================");
      AppLogger.d("📤 TRIP UPDATE REQUEST (JSON)");
      AppLogger.d("👉 Endpoint: ${API.updateTrip}");
      AppLogger.d("👉 Body: ${json.encode(body)}");
      AppLogger.d("==================================");

      // ✅ Call API using HttpHelper.postData (JSON endpoint)
      final response = await HttpHelper.postData(
        endpoint: API.updateTrip,
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'UserId': trip.userId,
        },
        data: body,
      );

      // 🔍 Debug response
      AppLogger.d("==================================");
      AppLogger.d("📥 Trip Update Response");
      AppLogger.d("👉 Status Code: ${response.statusCode}");
      AppLogger.d("👉 Response Body: ${response.body}");
      AppLogger.d("==================================");

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.d("✅ Trip Updated Successfully!");

        Get.snackbar(
          "Success",
          "Trip updated successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Navigate back and refresh trips list
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.back(result: true); // Return true to indicate success
        });
      } else if (response.statusCode == 400) {
        AppLogger.d("❌ 400 Bad Request - Validation Error!");

        String errorMessage = "Validation Error: ";
        try {
          final errorData = jsonDecode(response.body);
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
          } else {
            errorMessage =
                errorData['title'] ??
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
      } else {
        AppLogger.d("❌ Trip Update Failed!");
        AppLogger.d("❌ Error Status: ${response.statusCode}");
        AppLogger.d("❌ Error Body: ${response.body}");

        String errorMessage = "Failed to update trip (${response.statusCode})";
        try {
          final errorData = jsonDecode(response.body);
          errorMessage =
              errorData['message'] ??
              errorData['error'] ??
              errorData.toString();
        } catch (e) {
          if (response.body.isNotEmpty) {
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
      AppLogger.d("❌ Exception during trip update: $e");
      Get.snackbar("Error", "Exception: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch trips for current user
  Future<void> fetchTrips(String userId) async {
    try {
      isTripsLoading.value = true;

      AppLogger.d("🚚 Fetching trips for userId: $userId");

      final response = await HttpHelper.getData(
        endpoint: '${API.getTripList}$userId',
        headers: {'Accept': '*/*'},
      );

      AppLogger.d("🚚 Trips response status: ${response.statusCode}");
      AppLogger.d("🚚 Trips response body: ${response.body}");

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        trips.value = data.map((e) => Trip.fromJson(e)).toList();
        AppLogger.d("✅ Fetched ${trips.length} trips");
      } else {
        AppLogger.d("❌ Failed to fetch trips: ${response.statusCode}");
      }
    } catch (e) {
      AppLogger.d("❌ Error fetching trips: $e");
    } finally {
      isTripsLoading.value = false;
    }
  }

  /// Get trips by status
  List<Trip> getTripsByStatus(String status) {
    return trips.where((trip) {
      final tripStatus = trip.tripStatus.toLowerCase();
      final searchStatus = status.toLowerCase();

      if (searchStatus == 'completed') {
        return tripStatus == 'completed' || tripStatus.contains('complete');
      } else if (searchStatus == 'in-process' || searchStatus == 'in process') {
        return tripStatus == 'in-process' ||
            tripStatus == 'in process' ||
            tripStatus.contains('process') ||
            tripStatus.contains('progress') ||
            tripStatus == 'ongoing';
      } else if (searchStatus == 'upcoming') {
        return tripStatus == 'upcoming' || tripStatus == 'pending';
      }
      return tripStatus == searchStatus;
    }).toList();
  }

  /// Refresh trips list
  Future<void> refreshTrips(String userId) async {
    await fetchTrips(userId);
  }

  /// Delete a trip
  Future<bool> deleteTrip(String tripId, String userId) async {
    try {
      isLoading.value = true;
      final queryParams = {'tripId': tripId, 'userId': userId};

      AppLogger.d('📡 Deleting trip with ID: $tripId, UserID: $userId');

      final response = await HttpHelper.postWithQuery(
        endpoint: 'api/Trip/delete-trip',
        queryParams: queryParams,
        headers: {'accept': '*/*'},
      );

      AppLogger.d('📡 Delete response status: ${response.statusCode}');
      AppLogger.d('📡 Delete response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Refresh local list
        await fetchTrips(userId);
        return true;
      } else {
        Get.snackbar(
          'Error',
          'Failed to delete trip: ${response.statusCode}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }
    } catch (e) {
      AppLogger.e('❌ Error deleting trip: $e');
      Get.snackbar(
        'Error',
        'Error deleting trip',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
