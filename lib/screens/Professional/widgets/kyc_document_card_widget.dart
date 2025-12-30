import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// KYC Document Card Widget
/// Displays a document with icon, status badge, and upload button
class KycDocumentCardWidget extends StatelessWidget {
  final String documentName;
  final String status; // 'Pending', 'Not Uploaded', 'Verified'
  final IconData icon;
  final Color iconBackgroundColor;
  final VoidCallback? onUpload;

  const KycDocumentCardWidget({
    super.key,
    required this.documentName,
    required this.status,
    required this.icon,
    required this.iconBackgroundColor,
    this.onUpload,
  });

  Color _getStatusColor() {
    switch (status) {
      case 'Verified':
        return const Color(0xFF27AE60);
      case 'Pending':
        return const Color(0xFFFFA800);
      case 'Not Uploaded':
        return const Color(0xFFFF5E5E);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _getStatusBackgroundColor() {
    switch (status) {
      case 'Verified':
        return const Color(0xFFE6FAE6);
      case 'Pending':
        return const Color(0xFFFFF7E0);
      case 'Not Uploaded':
        return const Color(0xFFFFEAEA);
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case 'Verified':
        return Icons.check_circle;
      case 'Pending':
        return Icons.pending;
      case 'Not Uploaded':
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final statusBgColor = _getStatusBackgroundColor();
    final statusIcon = _getStatusIcon();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: statusColor),
          ),
          const SizedBox(width: 14),
          // Document Name
          Expanded(
            child: Text(
              documentName,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF333333),
              ),
            ),
          ),
          // Status Badge and Upload Button
          Row(
            children: [
              if (status == 'Pending' || status == 'Not Uploaded') ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 12, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        status,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onUpload,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: status == 'Pending'
                          ? const Color(0xFFE3F2FD)
                          : const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Upload',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: status == 'Pending'
                            ? const Color(0xFF1976D2)
                            : const Color(0xFFFF5E5E),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 12, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        status,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
