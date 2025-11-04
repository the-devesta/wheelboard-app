import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Transaction Item Widget
/// Displays a transaction with date, company name, and amount
class TransactionItemWidget extends StatelessWidget {
  final String date;
  final String companyName;
  final String amount;
  final double? opacity;

  const TransactionItemWidget({
    super.key,
    required this.date,
    required this.companyName,
    required this.amount,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity ?? 1.0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  companyName,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  amount,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: Color(0xFF1F2937),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

