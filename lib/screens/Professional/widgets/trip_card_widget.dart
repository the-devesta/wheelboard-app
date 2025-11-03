import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Next Scheduled Trip Card Widget
class TripCardWidget extends StatelessWidget {
  final String pickupAddress;
  final String destinationAddress;
  final String dateTime;
  final List<String> tags;

  const TripCardWidget({
    super.key,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.dateTime,
    this.tags = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 18, color: Colors.black),
              const SizedBox(width: 8),
              Text(
                "Next Scheduled Trip",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Pickup
          _buildAddressRow(
            icon: Icons.location_on,
            label: "Pickup:",
            address: pickupAddress,
          ),
          const SizedBox(height: 12),
          // Destination
          _buildAddressRow(
            icon: Icons.place,
            label: "Destination:",
            address: destinationAddress,
            isDestination: true,
          ),
          const SizedBox(height: 12),
          // Date & Time
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.black),
              const SizedBox(width: 8),
              Text(
                "Date & Time:",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  dateTime,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF666666),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) => _buildTag(tag)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressRow({
    required IconData icon,
    required String label,
    required String address,
    bool isDestination = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.black),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            address,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF666666),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String tag) {
    Color borderColor = const Color(0xFF003366);
    Color textColor = const Color(0xFF003366);
    
    if (tag == "Fragile") {
      borderColor = const Color(0xFFFF5E5E);
      textColor = const Color(0xFFFF5E5E);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        tag,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}

