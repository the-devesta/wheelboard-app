import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Calendar Header Widget
/// White header with back button, title, and menu button
class CalendarHeaderWidget extends StatelessWidget {
  final String? title;
  final bool showMenu;

  const CalendarHeaderWidget({super.key, this.title, this.showMenu = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 23),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.withOpacity(0.1),
              ),
              child: const Icon(Icons.arrow_back_ios, size: 16),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                title ?? 'MY Calendar',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFF36969),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          if (showMenu)
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.withOpacity(0.1),
              ),
              child: const Icon(Icons.more_vert, size: 20),
            )
          else
            const SizedBox(width: 44),
        ],
      ),
    );
  }
}
