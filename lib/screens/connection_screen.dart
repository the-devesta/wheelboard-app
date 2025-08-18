import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ConnectionScreen extends StatelessWidget {
  final String profileImage = 'https://i.pravatar.cc/150?img=12';

  const ConnectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background SVG
        Positioned.fill(
          child: SvgPicture.asset('assets/bgDesign.svg', fit: BoxFit.cover),
        ),

        Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 60),

                Image.asset('assets/logo-bg 3.png', width: 280, height: 60),

                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Image.asset(
                    'assets/requestImage.png',
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 20),
                // AboWut Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: const BoxDecoration(
                    color: Color(
                      0xFFF4E3E3,
                    ), // Replace with your desired background
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Stats: Fleet Size & Exp
                      Text(
                        "Connection Request Sent!",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 25),
                      Text(
                        "Your connection request has been successfully sent. "
                        "You'll be notified once it's accepted.",
                        textAlign:
                            TextAlign.center, // 👈 centers text line by line
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      const SizedBox(height: 20),

                      const SizedBox(height: 24),

                      // +Connect Button
                      _buildOutlinedButton(
                        "Back to Network",
                        onTap: () {
                          // TODO: action
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildOutlinedButton(
                        "Create Another Post",
                        onTap: () {
                          // TODO: action
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildGradientButton(
                        "View Profile",
                        onTap: () {
                          // TODO: action
                        },
                      ),

                      const SizedBox(height: 200),
                    ],
                  ),
                ),

                const SizedBox(height: 200),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOutlinedButton(String text, {required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: Colors.transparent),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40), // pill shape
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF5722), // orange text
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButton(String text, {required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(40),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B2C), Color(0xFFFF3C7E)], // orange → pink
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            alignment: Alignment.center,
            child: const Text(
              "View Profile",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTag(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Color(0xFFFFF1DC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(color: Colors.orangeAccent)),
    );
  }
}
