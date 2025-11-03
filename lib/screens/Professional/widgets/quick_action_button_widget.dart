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
    final lines = title.split('\n');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 69,
        height: 90,
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
              size: 24,
            ),
            const SizedBox(height: 8),
            ...lines.map((line) => Text(
                  line,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                )),
          ],
        ),
      ),
    );
  }
}

