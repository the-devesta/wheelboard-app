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
    return Container(
      height: 76,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.home_outlined,
            label: "Home",
            index: 0,
            isActive: currentIndex == 0,
          ),
          _buildNavItem(
            icon: Icons.search_outlined,
            label: "Find",
            index: 1,
            isActive: currentIndex == 1,
          ),
          _buildNavItem(
            icon: Icons.alt_route,
            label: "Trips",
            index: 2,
            isActive: currentIndex == 2,
          ),
          _buildNavItem(
            icon: Icons.article_outlined,
            label: "Feeds",
            index: 3,
            isActive: currentIndex == 3,
          ),
          _buildNavItem(
            icon: Icons.work_outline,
            label: "Jobs",
            index: 4,
            isActive: currentIndex == 4,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        width: 78,
        height: 46,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? const Color(0xFFFF5E5E) : const Color(0xFF535353),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive ? const Color(0xFFFF5E5E) : const Color(0xFF535353),
              ),
            ),
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 1),
                width: 28,
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

