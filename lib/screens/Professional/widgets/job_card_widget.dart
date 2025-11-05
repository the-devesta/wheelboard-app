import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

/// Job Card Widget matching Figma design
class JobCardWidget extends StatelessWidget {
  final String companyName;
  final String? jobId; // Job ID from API
  final int likes;
  final int applicants;
  final bool isApplying; // Show loading state when applying
  final VoidCallback? onCallNow;
  final VoidCallback? onApplyNow;

  const JobCardWidget({
    super.key,
    required this.companyName,
    this.jobId,
    this.likes = 0,
    this.applicants = 0,
    this.isApplying = false,
    this.onCallNow,
    this.onApplyNow,
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
          // Company Name and Call Now Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  companyName,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF003366),
                  ),
                ),
              ),
              _buildCallNowButton(onTap: onCallNow),
            ],
          ),
          const SizedBox(height: 12),
          // Likes and Applicants
          Row(
            children: [
              const Icon(Icons.thumb_up_outlined, size: 13, color: Colors.black),
              const SizedBox(width: 6),
              Text(
                "$likes Likes",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1F1F1F),
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.people_outline, size: 13, color: Colors.black),
              const SizedBox(width: 6),
              Text(
                "$applicants Applicants",
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
              Expanded(
                child: _buildShareButton(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildApplyButton(onTap: onApplyNow),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCallNowButton({VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFD500), // Yellow
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Text(
          "Call Now",
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF003366),
          ),
        ),
      ),
    );
  }

  Widget _buildShareButton() {
    return ElevatedButton.icon(
      onPressed: () {
        Share.share("Check out this job on WheelBoard!\n$companyName");
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
    return GestureDetector(
      onTap: isApplying ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isApplying 
              ? const Color(0xFFFFD500).withOpacity(0.6) 
              : const Color(0xFFFFD500), // Yellow
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Center(
          child: isApplying
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF003366)),
                  ),
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

  Widget _buildInviteButton() {
    return Container(
      width: 120,
      height: 43.5,
      decoration: BoxDecoration(
        color: const Color(0xFFFF5E5E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          "Invite",
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.325,
          ),
        ),
      ),
    );
  }

  Widget _buildSOSButton() {
    return Container(
      width: 120,
      height: 43.5,
      decoration: BoxDecoration(
        color: const Color(0xFFFF5E5E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          "SOS",
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.325,
          ),
        ),
      ),
    );
  }
}

