import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/add_new_trip_model.dart';
import 'edit_trip_screen.dart';
import '../../core/auth/auth_service.dart';
import '../../controllers/Transport/add_trip_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

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
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          "Trip Details",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trip ID Banner
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF97316), Color(0xFFEA580C)], // Orange gradient
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF97316).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "Trip ID",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      trip.tripCode.isNotEmpty ? trip.tripCode.toUpperCase() : "N/A",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),

              // Locations Container
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoCard(
                      icon: Iconsax.location,
                      iconColor: const Color(0xFF16A34A), // Green
                      title: "Pickup Address",
                      value: trip.pickupLocation.isNotEmpty ? trip.pickupLocation : "Not specified",
                      bgColor: const Color(0xFFF0FDF4),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Iconsax.location5,
                      iconColor: const Color(0xFFDC2626), // Red
                      title: "Destination Address",
                      value: trip.deliveryLocation.isNotEmpty ? trip.deliveryLocation : "Not specified",
                      bgColor: const Color(0xFFFEF2F2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Trip Meta Details
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoCard(
                      icon: Iconsax.calendar_1,
                      iconColor: const Color(0xFFF36969), // Primary
                      title: "Date and Time",
                      value: _formatDate(trip.pickupDate, trip.pickupTime),
                      bgColor: const Color(0xFFFFF1F1),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Iconsax.document_text,
                      iconColor: const Color(0xFFF36969),
                      title: "Special Requirements",
                      value: trip.specialInstructions.isNotEmpty ? trip.specialInstructions : "No special requirements",
                      bgColor: const Color(0xFFFFF1F1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Personnel & Equipment
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoCard(
                      icon: Iconsax.user,
                      iconColor: const Color(0xFF2563EB), // Blue
                      title: "Assigned Driver",
                      value: trip.driverName?.isNotEmpty == true ? trip.driverName! : "Not assigned",
                      bgColor: const Color(0xFFEFF6FF),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Iconsax.truck,
                      iconColor: const Color(0xFF9333EA), // Purple
                      title: "Vehicle Requirements",
                      value: trip.vehicleType?.isNotEmpty == true ? trip.vehicleType! : "Any compatible vehicle",
                      bgColor: const Color(0xFFFAF5FF),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.to(() => EditTripScreen(trip: trip));
                      },
                      icon: const Icon(Iconsax.edit, size: 18),
                      label: Text("Edit", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF36969),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _shareTrip,
                      icon: const Icon(Iconsax.share, size: 18),
                      label: Text("Share", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF36969),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Get.dialog(
                      Dialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: const BoxDecoration(color: Color(0xFFFEF2F2), shape: BoxShape.circle),
                                child: const Icon(Iconsax.trash, color: Color(0xFFDC2626), size: 32),
                              ),
                              const SizedBox(height: 16),
                              Text("Delete Trip", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 8),
                              Text("Are you sure you want to delete this trip?\nThis action cannot be undone.",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54)),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => Get.back(),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      child: Text("Cancel", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black87)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        Get.back(); // Close dialog
                                        final controller = Get.find<TripController>();
                                        // Auth is token-based; userId is only used for the
                                        // post-delete list refresh.
                                        final userId = AuthService.to.userId;

                                        Get.dialog(const Center(child: CircularProgressIndicator(color: Color(0xFFDC2626))), barrierDismissible: false);
                                        // Backend resolves trips by Mongo _id (web parity).
                                        final idToUse = trip.id.isNotEmpty ? trip.id : trip.tripId;
                                        final bool success = await controller.deleteTrip(idToUse, userId);
                                        if (Get.isDialogOpen ?? false) Get.back(); // close loading indicator

                                        if (success) {
                                          Get.back(); // return to trips screen
                                          Get.snackbar(
                                            "Success",
                                            "Trip deleted successfully",
                                            snackPosition: SnackPosition.TOP,
                                            backgroundColor: const Color(0xFF16A34A),
                                            colorText: Colors.white,
                                            margin: const EdgeInsets.all(16),
                                            borderRadius: 12,
                                            icon: const Icon(Iconsax.tick_circle, color: Colors.white),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFDC2626),
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      child: Text("Delete", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Iconsax.trash, size: 18),
                  label: Text("Delete Trip", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFDC2626),
                    side: const BorderSide(color: Color(0xFFDC2626)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required Color bgColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: iconColor.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF374151), // Gray 700
            ),
          ),
        ],
      ),
    );
  }

  void _shareTrip() {
    final pickupShort = trip.pickupLocation.split(',').first.trim();
    final deliveryShort = trip.deliveryLocation.split(',').first.trim();

    final dateStr = trip.pickupDate != null
        ? '${trip.pickupDate!.day}/${trip.pickupDate!.month}/${trip.pickupDate!.year}'
        : 'Not scheduled';

    final shareText = '''
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
