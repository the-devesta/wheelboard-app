import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Earning Stat Card Widget
/// Displays a statistic with icon, value, and label
class EarningStatCardWidget extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color? iconBackgroundColor;

  const EarningStatCardWidget({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.iconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
                  iconBackgroundColor ??
                  const Color(0xFF2F80ED).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF2F80ED)),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}
