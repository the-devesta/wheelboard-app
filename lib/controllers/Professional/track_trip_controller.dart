import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wheelboard/controllers/Professional/assigned_trip_controller.dart';
import 'package:wheelboard/screens/Professional/TrackTrip/TrackTripScreen.dart';
import '../../apihelperclass/api_helper.dart';

import 'package:wheelboard/services/auth_service.dart';

import 'package:wheelboard/utils/app_logger.dart';

class TrackTripController extends GetxController {
  final isLoading = false.obs;
  final AuthService _authService = Get.find<AuthService>();
  final AssignedTripController _assignedTripController =
      Get.find<AssignedTripController>();

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
        // Update local status
        final index = _assignedTripController.assignedTrips.indexWhere(
          (t) => t.tripId == tripId,
        );
        if (index != -1) {
          final trip = _assignedTripController.assignedTrips[index];
          _assignedTripController.assignedTrips[index] = trip.copyWith(
            tripStatus: 'In Progress',
          );
        }
        Get.snackbar(
          "Success",
          "Trip started successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // Navigate to TrackTripScreen after starting
        Get.off(() => TrackTripScreen(tripId: tripId));
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
        // Update local status
        final index = _assignedTripController.assignedTrips.indexWhere(
          (t) => t.tripId == tripId,
        );
        if (index != -1) {
          final trip = _assignedTripController.assignedTrips[index];
          _assignedTripController.assignedTrips[index] = trip.copyWith(
            tripStatus: 'Completed',
          );
        }
        // Force refresh all trips to reflect changes in UI
        await _assignedTripController.fetchAssignedTrips();
        _showCompletionDialog();
      } else {
        Get.snackbar("Error", "Failed to end trip: ${response.body}");
      }
    } catch (e) {
      Get.snackbar("Error", "An error occurred: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _showCompletionDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close Button
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: const Icon(
                    Icons.close,
                    size: 20,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Celebration Icon
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF8C00), Color(0xFFFFC000)],
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Text('🎉', style: TextStyle(fontSize: 48)),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                'Congratulations!',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Trip Successfully Completed!',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF27AE60),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Great job completing the trip successfully!\nKeep driving to earn more rewards.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF8E8E8E),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27AE60),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Back to Home',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
