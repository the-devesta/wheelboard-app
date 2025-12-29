import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Quick Action Button Widget
/// Red card button for quick actions
class QuickActionButtonWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const QuickActionButtonWidget({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final lines = title.split('\n');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: screenWidth * 0.17, // Responsive width (~17% of screen width)
        height:
            screenWidth * 0.22, // Responsive height (maintains aspect ratio)
        decoration: BoxDecoration(
          color: const Color(0xFFE83B4F), // Exact Figma red
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white, width: 0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size:
                  screenWidth *
                  0.06, // Responsive icon size (6% of screen width)
            ),
            SizedBox(height: screenWidth * 0.02), // Responsive spacing
            ...lines.map(
              (line) => Text(
                line,
                style: GoogleFonts.poppins(
                  fontSize:
                      screenWidth *
                      0.033, // Responsive font size (3.3% of screen width)
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
