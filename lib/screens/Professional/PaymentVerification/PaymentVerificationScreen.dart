import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentVerificationScreen extends StatelessWidget {
  const PaymentVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              height: 56,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFEDF1F3))),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      size: 20,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Payment Verification',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F2937),
                          letterSpacing: -0.95,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(shape: BoxShape.circle),
                    child: const Icon(
                      Icons.more_vert,
                      size: 20,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 4),
                    // Payment Details Card
                    _buildPaymentDetailsCard(),
                    const SizedBox(height: 12),
                    // Contact Support Button
                    _buildContactSupportButton(context),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Amount
          _buildDetailRow(
            label: 'Amount',
            value: '₹250.00',
            valueStyle: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF535353),
              letterSpacing: -1.1,
            ),
          ),
          const SizedBox(height: 24),
          // Payment Type
          _buildDetailRow(
            label: 'Payment Type',
            value: 'Bank Transfer',
            valueStyle: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1F2937),
            ),
            leadingIcon: Icons.account_balance,
          ),
          const SizedBox(height: 16),
          // Status
          _buildDetailRow(
            label: 'Status',
            value: 'Verified',
            valueStyle: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF27AE60),
            ),
            leadingIcon: Icons.check_circle,
            iconColor: const Color(0xFF27AE60),
          ),
          const SizedBox(height: 16),
          // Transaction ID
          _buildDetailRow(
            label: 'Transaction ID',
            value: 'TXN1234567890',
            valueStyle: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF535353),
            ),
            trailingIcon: Icons.copy,
            onTrailingTap: () {
              // Handle copy
            },
          ),
          const SizedBox(height: 16),
          // Payment Date
          _buildDetailRow(
            label: 'Payment Date',
            value: 'June 10, 2024',
            valueStyle: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    required TextStyle valueStyle,
    IconData? leadingIcon,
    IconData? trailingIcon,
    Color? iconColor,
    VoidCallback? onTrailingTap,
  }) {
    return Row(
      children: [
        if (leadingIcon != null) ...[
          Icon(
            leadingIcon,
            size: 16,
            color: iconColor ?? const Color(0xFF6B7280),
          ),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6B7280),
          ),
        ),
        const Spacer(),
        Text(value, style: valueStyle),
        if (trailingIcon != null) ...[
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onTrailingTap,
            child: Icon(trailingIcon, size: 16, color: const Color(0xFF6B7280)),
          ),
        ],
      ],
    );
  }

  Widget _buildContactSupportButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Handle contact support
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE74C3C),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.support_agent, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Contact Support',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.375,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
