import 'package:flutter/material.dart';

/// Banner Header Widget
/// Gradient overlay with background image
class BannerHeaderWidget extends StatelessWidget {
  const BannerHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 184,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF003366).withOpacity(0.9), // Dark blue
            const Color(0xFF003366).withOpacity(0.7),
            Colors.black.withOpacity(0),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background Image (if available)
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/truck.png'),
                fit: BoxFit.cover,
                opacity: 0.6,
              ),
            ),
          ),
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.topRight,
                colors: [
                  const Color(0xFF003366).withOpacity(0.9),
                  Colors.black.withOpacity(0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

