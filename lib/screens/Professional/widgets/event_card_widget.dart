import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Event Card Widget
/// Displays trip/event information with route and status
class EventCardWidget extends StatelessWidget {
  final String fromLocation;
  final String toLocation;
  final String time;
  final String vehicleNumber;
  final String status;
  final VoidCallback? onViewDetails;

  const EventCardWidget({
    super.key,
    required this.fromLocation,
    required this.toLocation,
    required this.time,
    required this.vehicleNumber,
    required this.status,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 17),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Route
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Color(0xFFF36969)),
              const SizedBox(width: 4),
              Text(
                fromLocation,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFF36969),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward,
                size: 16,
                color: Color(0xFFF36969),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.location_on, size: 16, color: Color(0xFFF36969)),
              const SizedBox(width: 4),
              Text(
                toLocation,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFF36969),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Time and Vehicle Number
          Row(
            children: [
              const Icon(Icons.access_time, size: 12, color: Color(0xFF757575)),
              const SizedBox(width: 4),
              Text(
                time,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF757575),
                ),
              ),
              const SizedBox(width: 24),
              const Icon(
                Icons.local_shipping,
                size: 15,
                color: Color(0xFF757575),
              ),
              const SizedBox(width: 4),
              Text(
                vehicleNumber,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF757575),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Status only (View Details removed)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: status == 'Active'
                  ? const Color(0xFFE8F5E9) // Light green for active
                  : const Color(0xFFFFEBEE), // Light red for inactive
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: status == 'Active'
                    ? const Color(0xFF4CAF50) // Green for active
                    : const Color(0xFFE53935), // Red for inactive
              ),
            ),
          ),
        ],
      ),
    );
  }
}
