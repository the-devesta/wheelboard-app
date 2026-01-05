import 'package:get/get.dart';
import '../../apihelperclass/api_helper.dart';

import 'package:wheelboard/services/auth_service.dart';

import 'package:wheelboard/utils/app_logger.dart';

class TrackTripController extends GetxController {
  final isLoading = false.obs;
  final AuthService _authService = Get.find<AuthService>();

  Future<void> startTrip(String tripId) async {
    AppLogger.d("🚀 Starting trip with ID: $tripId");
    isLoading.value = true;
    try {
      final headers = {
        'Authorization': 'Bearer ${_authService.currentToken}',
        'Content-Type': 'application/json',
      };

      // HttpHelper.startTrip currently doesn't accept headers, we need to update api_helper.dart first
      // Assuming api_helper.dart will be updated to accept headers
      final response = await HttpHelper.startTrip(tripId, headers: headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Success", "Trip started successfully");
      } else {
        Get.snackbar("Error", "Failed to start trip: ${response.body}");
      }
    } catch (e) {
      Get.snackbar("Error", "An error occurred: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> endTrip(String tripId) async {
    AppLogger.d("🏁 Ending trip with ID: $tripId");
    isLoading.value = true;
    try {
      final headers = {
        'Authorization': 'Bearer ${_authService.currentToken}',
        'Content-Type': 'application/json',
      };

      final response = await HttpHelper.endTrip(tripId, headers: headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Success", "Trip ended successfully");
      } else {
        Get.snackbar("Error", "Failed to end trip: ${response.body}");
      }
    } catch (e) {
      Get.snackbar("Error", "An error occurred: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
