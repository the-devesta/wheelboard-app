import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../../widgets/custom_loader.dart';

/// Job Card Widget matching Figma design
class JobCardWidget extends StatelessWidget {
  final String companyName;
  final String? role; // Job role like Driver, Helper, Technician
  final String? city; // Job location city
  final String? jobId; // Job ID from API
  final int applicants;
  final bool isApplying; // Show loading state when applying
  final bool isApplied; // Whether user has already applied
  final bool isSaved; // Whether user has saved/bookmarked this job
  final VoidCallback? onApplyNow;
  final VoidCallback? onSaveToggle; // Callback for save/bookmark toggle

  const JobCardWidget({
    super.key,
    required this.companyName,
    this.role,
    this.city,
    this.jobId,
    this.applicants = 0,
    this.isApplying = false,
    this.isApplied = false,
    this.isSaved = false,
    this.onApplyNow,
    this.onSaveToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Company Name
          Text(
            companyName,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF003366),
            ),
          ),
          // Role (Driver, Helper, etc.) - shown below company name
          if (role != null && role!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              role!,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF666666),
              ),
            ),
          ],
          const SizedBox(height: 10),
          // Save/bookmark and Openings
          Row(
            children: [
              // Save / bookmark button (clickable)
              GestureDetector(
                onTap: onSaveToggle,
                child: Row(
                  children: [
                    Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      size: 15,
                      color: isSaved ? const Color(0xFF00AEEF) : Colors.black,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isSaved ? "Saved" : "Save",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isSaved
                            ? const Color(0xFF00AEEF)
                            : const Color(0xFF1F1F1F),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.people_outline, size: 13, color: Colors.black),
              const SizedBox(width: 6),
              Text(
                "$applicants Openings",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1F1F1F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Share and Apply Buttons
          Row(
            children: [
              Expanded(child: _buildShareButton()),
              const SizedBox(width: 12),
              Expanded(child: _buildApplyButton(onTap: onApplyNow)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton() {
    // WheelBoard app share URL
    const String wheelboardUrl = "https://wheelboard.app";

    return ElevatedButton.icon(
      onPressed: () {
        final shareText =
            "🚛 Job Opening at $companyName!\n\n"
            "${role != null && role!.isNotEmpty ? '📋 Role: $role\n' : ''}"
            "${city != null && city!.isNotEmpty ? '📍 Location: $city\n' : ''}"
            "👥 Openings: $applicants\n\n"
            "Apply now on WheelBoard:\n$wheelboardUrl";
        Share.share(shareText);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00AEEF), // Blue
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(vertical: 10),
      ),
      icon: const Icon(Icons.share, color: Colors.white, size: 13),
      label: Text(
        "Share",
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildApplyButton({VoidCallback? onTap}) {
    // If already applied, show disabled state
    if (isApplied) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade300, // Gray for disabled
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Center(
          child: Text(
            "Applied",
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: isApplying ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isApplying
              ? const Color(0xFFFFD500).withValues(alpha: 0.6)
              : const Color(0xFFFFD500), // Yellow
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Center(
          child: isApplying
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CustomLoader.small(),
                )
              : Text(
                  "Apply now",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF003366),
                  ),
                ),
        ),
      ),
    );
  }
}
