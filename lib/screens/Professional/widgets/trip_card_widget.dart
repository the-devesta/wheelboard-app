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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with paper airplane icon - More visible
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF003366).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.send,
                  size: 20,
                  color: Color(0xFF003366),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "Next Scheduled Trip",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF003366),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Pickup with red pin
          _buildAddressRow(
            icon: Icons.location_on,
            label: "Pickup:",
            address: pickupAddress,
            iconColor: const Color(0xFFFF5E5E),
          ),
          const SizedBox(height: 12),
          // Destination with blue pin
          _buildAddressRow(
            icon: Icons.location_on,
            label: "Destination:",
            address: destinationAddress,
            iconColor: const Color(0xFF003366),
            isDestination: true,
          ),
          const SizedBox(height: 12),
          // Date & Time with red calendar icon
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.calendar_today,
                size: 16,
                color: Color(0xFFFF5E5E),
              ),
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
                    color: const Color(0xFFADADB7),
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
    Color? iconColor,
    bool isDestination = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: iconColor ?? Colors.black,
        ),
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
              color: const Color(0xFFADADB7),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String tag) {
    Color backgroundColor = const Color(0xFFF5F5F5);
    Color textColor = const Color(0xFF003366);
    IconData icon = Icons.inventory_2; // Box icon for Cargo
    
    if (tag == "Fragile") {
      backgroundColor = const Color(0xFFFFE5E5);
      textColor = const Color(0xFFFF5E5E);
      icon = Icons.error_outline;
    } else if (tag == "Lift Gate") {
      backgroundColor = const Color(0xFFF5F5F5);
      textColor = const Color(0xFF003366);
      icon = Icons.elevator;
    } else if (tag == "Cargo") {
      backgroundColor = const Color(0xFFF5F5F5);
      textColor = const Color(0xFF003366);
      icon = Icons.inventory_2;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: textColor,
          ),
          const SizedBox(width: 6),
          Text(
            tag,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

