import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Professional Bottom Navigation Widget
/// Matches Figma design exactly
class ProfessionalBottomNavWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const ProfessionalBottomNavWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      height: 76 + bottomPadding, // Responsive height with safe area padding
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0E0E0), width: 0.5)),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              context: context,
              icon: Icons.home_outlined,
              label: "Home",
              index: 0,
              isActive: currentIndex == 0,
            ),
            _buildNavItem(
              context: context,
              icon: Icons.search_outlined,
              label: "Find",
              index: 1,
              isActive: currentIndex == 1,
            ),
            _buildNavItem(
              context: context,
              icon: Icons.alt_route,
              label: "Trips",
              index: 2,
              isActive: currentIndex == 2,
            ),
            _buildNavItem(
              context: context,
              icon: Icons.article_outlined,
              label: "Feeds",
              index: 3,
              isActive: currentIndex == 3,
            ),
            _buildNavItem(
              context: context,
              icon: Icons.work_outline,
              label: "Jobs",
              index: 4,
              isActive: currentIndex == 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
    required bool isActive,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        width:
            screenWidth *
            0.2, // Responsive width (20% of screen width for 5 items)
        constraints: const BoxConstraints(
          minHeight: 46,
          maxHeight: 50, // Allow slight flexibility
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size:
                  screenWidth *
                  0.05, // Responsive icon size (5% of screen width)
              color: isActive
                  ? const Color(0xFFFF5E5E)
                  : const Color(0xFF535353),
            ),
            SizedBox(
              height: screenWidth * 0.006,
            ), // Reduced spacing to prevent overflow
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize:
                      screenWidth *
                      0.03, // Responsive font size (3% of screen width)
                  fontWeight: FontWeight.w500,
                  color: isActive
                      ? const Color(0xFFFF5E5E)
                      : const Color(0xFF535353),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isActive)
              Container(
                margin: EdgeInsets.only(
                  top: screenWidth * 0.001,
                ), // Reduced margin
                width:
                    screenWidth * 0.07, // Responsive width (7% of screen width)
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5E5E),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
