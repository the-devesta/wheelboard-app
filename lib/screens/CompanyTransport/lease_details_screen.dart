import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wheelboard/constants/apps_colors.dart';

/// Static Lease Details page (Transport side)
/// Hook with: Get.to(() => const LeaseDetailsScreen());
class LeaseDetailsScreen extends StatelessWidget {
  const LeaseDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black87),
        title: Text(
          'Lease Details',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionCard(
              title: 'Vehicle Summary',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _kvRow('Model', 'Ashok Leyland 4825'),
                  SizedBox(height: 8),
                  _kvRow('Vehicle No.', 'MH 12 AB 3456'),
                  SizedBox(height: 8),
                  _kvRow('Ownership', 'On Lease'),
                  SizedBox(height: 8),
                  _kvRow('Lease Start', '12 Jan 2025'),
                  SizedBox(height: 8),
                  _kvRow('Lease End', '12 Jan 2026'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _sectionCard(
              title: 'Contract',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _kvRow('Lessor', 'ABC Leasing Pvt. Ltd.'),
                  SizedBox(height: 8),
                  _kvRow('Lessee', 'WheelBoard Transport'),
                  SizedBox(height: 8),
                  _kvRow('Tenure', '12 months'),
                  SizedBox(height: 8),
                  _kvRow('Renewal', 'Auto-renew (30 days notice)'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _sectionCard(
              title: 'Payment',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _kvRow('Monthly Rent', '₹ 65,000'),
                  SizedBox(height: 8),
                  _kvRow('Security Deposit', '₹ 1,00,000 (refundable)'),
                  SizedBox(height: 8),
                  _kvRow('Due Date', '5th of every month'),
                  SizedBox(height: 8),
                  _kvRow('Last Paid', '05 Feb 2025'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _sectionCard(
              title: 'Usage & Maintenance',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _bullet('Max 12,000 km / month included'),
                  _bullet('Wear & tear covered up to ₹20,000 / year'),
                  _bullet('Lessee handles fines & challans'),
                  _bullet('Insurance: Comprehensive (included)'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _sectionCard(
              title: 'Key Contacts',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _kvRow('Relationship Manager', 'Rahul Sharma • +91 98765 43210'),
                  SizedBox(height: 8),
                  _kvRow('Service Support', 'support@ableasing.com'),
                  SizedBox(height: 8),
                  _kvRow('24x7 Helpline', '1800-209-LEASE'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.buttonBg),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Download Agreement',
                      style: TextStyle(
                        color: AppColors.buttonBg,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonBg,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Renew Lease',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  'Raise Issue / Request Support',
                  style: TextStyle(
                    color: Color(0xFF1E88E5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _sectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _sectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _kvRow extends StatelessWidget {
  final String label;
  final String value;
  const _kvRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}

class _bullet extends StatelessWidget {
  final String text;
  const _bullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: AppColors.buttonBg,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

