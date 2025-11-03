import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../Notification1/Notification1Screen.dart';
import '../YourProfile/YourProfileScreen.dart';

/// Professional Header Widget
/// Red header with back button, title, and notification bell
class ProfessionalHeaderWidget extends StatelessWidget {
  const ProfessionalHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: Color(0xFFFF5E5E), // Exact Figma red color
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Menu Icon (Left)
              GestureDetector(
                onTap: () {
                  Get.to(const YourProfileScreen());
                },
                child: Container(
                  width: 17.5,
                  height: 20,
                  child: const Icon(
                    Icons.menu,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const Spacer(),
              // Title - Centered
              Text(
                "WHEELBOARD",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              // Notification Bell
              GestureDetector(
                onTap: () {
                  Get.to(const Notification1Screen());
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

