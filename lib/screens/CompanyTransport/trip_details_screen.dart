import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wheelboard/utils/app_logger.dart';
import '../../models/add_new_trip_model.dart';
import 'edit_trip_screen.dart';
import '../../utils/session_manager.dart';
import '../../controllers/Transport/add_trip_controller.dart';
import '../../utils/constants.dart';

class TripDetailsScreen extends StatelessWidget {
  final Trip trip;

  const TripDetailsScreen({super.key, required this.trip});

  String _formatDate(DateTime? date, String time) {
    if (date == null) return time.isNotEmpty ? time : 'Not specified';

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final dateStr = '${months[date.month - 1]} ${date.day}, ${date.year}';

    if (time.isNotEmpty) {
      // Parse time string (format: HH:mm:ss or HH:mm)
      final timeParts = time.split(':');
      if (timeParts.isNotEmpty) {
        final hour = int.tryParse(timeParts[0]) ?? 0;
        final minute = timeParts.length > 1
            ? int.tryParse(timeParts[1]) ?? 0
            : 0;

        String period = 'A.M';
        int displayHour = hour;

        if (hour == 0) {
          displayHour = 12;
        } else if (hour == 12) {
          period = 'P.M';
        } else if (hour > 12) {
          displayHour = hour - 12;
          period = 'P.M';
        }

        final minuteStr = minute.toString().padLeft(2, '0');
        return '$dateStr, $displayHour:$minuteStr $period';
      }
    }

    return dateStr;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDEEEF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const Text(
          "Trip Details",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white, width: 2),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Trip Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    "assets/driver.png",
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),

                // Trip Details
                _buildDetailRow(
                  "Pickup Address",
                  trip.pickupLocation.isNotEmpty
                      ? trip.pickupLocation
                      : "Not specified",
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  "Destination Address",
                  trip.deliveryLocation.isNotEmpty
                      ? trip.deliveryLocation
                      : "Not specified",
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  "Date and Time",
                  _formatDate(trip.pickupDate, trip.pickupTime),
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  "Special Requirements",
                  trip.specialInstructions.isNotEmpty
                      ? trip.specialInstructions
                      : "No special requirements",
                ),
                const SizedBox(height: 16),

                // Driver Name
                _buildDetailRow(
                  "Driver Name",
                  trip.driverName?.isNotEmpty == true
                      ? trip.driverName!
                      : "Not assigned",
                ),
                const SizedBox(height: 24),

                // Action Buttons - Stacked vertically
                Column(
                  children: [
                    // Share Trip Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _shareTrip();
                        },
                        icon: const Icon(Icons.share, size: 20),
                        label: const Text(
                          "Share Trip",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF36969),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Delete Trip Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Confirm Dialog
                          Get.defaultDialog(
                            title: "Delete Trip",
                            middleText:
                                "Are you sure you want to delete this trip?",
                            textConfirm: "Delete",
                            textCancel: "Cancel",
                            confirmTextColor: Colors.white,
                            buttonColor: Colors.red,
                            onConfirm: () async {
                              Get.back(); // close dialog
                              final controller = Get.find<TripController>();
                              final sessionManager = SessionManager();
                              final userId = await sessionManager.getString(
                                "userId",
                              );

                              if (userId != null) {
                                bool success = await controller.deleteTrip(
                                  trip.tripId,
                                  userId,
                                );
                                AppLogger.d(
                                  "🗑️ Deletion success result: $success",
                                );
                                if (success) {
                                  // Go back to trips screen first
                                  Get.back();

                                  // Then show success message on the list screen
                                  Get.snackbar(
                                    "Success",
                                    "Trip deleted successfully",
                                    snackPosition: SnackPosition.TOP,
                                    backgroundColor: Colors.green,
                                    colorText: Colors.white,
                                    duration: const Duration(seconds: 3),
                                  );
                                }
                              } else {
                                Get.snackbar(
                                  "Error",
                                  "User not found",
                                  snackPosition: SnackPosition.TOP,
                                );
                              }
                            },
                          );
                        },
                        icon: const Icon(Icons.delete_outline, size: 20),
                        label: const Text(
                          "Delete Trip",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Edit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.to(() => EditTripScreen(trip: trip));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF36969),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Edit Trip",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Trip ID Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFF36969)),
                          foregroundColor: const Color(0xFFF36969),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          trip.tripCode.isNotEmpty
                              ? "Trip ID: ${trip.tripCode}"
                              : "Trip ID: N/A",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ],
    );
  }

  void _shareTrip() {
    final pickupShort = trip.pickupLocation.split(',').first.trim();
    final deliveryShort = trip.deliveryLocation.split(',').first.trim();

    final dateStr = trip.pickupDate != null
        ? '${trip.pickupDate!.day}/${trip.pickupDate!.month}/${trip.pickupDate!.year}'
        : 'Not scheduled';

    final shareText =
        '''
🚚 Trip Details from Wheelboard

📍 From: $pickupShort
📍 To: $deliveryShort
📅 Date: $dateStr
⏰ Time: ${trip.pickupTime.isNotEmpty ? trip.pickupTime : 'Not specified'}
🚗 Driver: ${trip.driverName ?? 'Not assigned'}

🔗 View on Wheelboard: https://wheelboard.in/trips/${trip.tripId}
''';

    Share.share(shareText.trim());
  }
}
