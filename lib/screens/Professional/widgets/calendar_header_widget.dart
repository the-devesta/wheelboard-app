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
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Color(0xFFFF5E5E)),
            ),
            Expanded(
              child: Center(
                child: Text(
                  title ?? 'MY Calendar',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFF36969),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            if (showMenu)
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.refresh, color: Color(0xFFFF5E5E)),
              )
            else
              const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }
}
