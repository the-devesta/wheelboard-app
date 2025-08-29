import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({super.key});
  final String profileImage = 'https://i.pravatar.cc/150?img=12';

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
          body: SafeArea(
            top: true,
            bottom: false,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      height: 60,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Center(
                            child: Text(
                              "Driver Profile",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              onTap: () {
                                if (Get.previousRoute.isNotEmpty) {
                                  Get.back();
                                }
                              },
                              child: Container(
                                width: 53,
                                height: 53,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                padding: const EdgeInsets.all(6),
                                child: Image.asset(
                                  'assets/logobg.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),

                          // Align(
                          //   alignment: Alignment.centerLeft,
                          //   child: Container(
                          //     width: 53,
                          //     height: 53,
                          //     decoration: const BoxDecoration(
                          //       shape: BoxShape.circle,
                          //       color: Colors.white,
                          //     ),
                          //     padding: const EdgeInsets.all(6),
                          //     child: Image.asset(
                          //       'assets/logobg.png',
                          //       fit: BoxFit.contain,
                          //     ),
                          //   ),
                          // ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.calendar_month,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 80),

                  // Main Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                      top: 60,
                      bottom: 24,
                    ), // leave space for avatar
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Top row with avatar + buttons
                        Stack(
                          alignment: Alignment.topCenter,
                          clipBehavior: Clip.none,
                          children: [
                            // Buttons Row
                            Positioned(
                              left: -100,
                              top: -90,
                              child: _actionButton(
                                Icons.call,
                                "Call",
                                onTap: () {
                                  // TODO: Call action
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 120,
                            ), // leave space for avatar in center
                            Positioned(
                              top: -90,
                              right: -90,
                              child: _actionButton(
                                Icons.email,
                                "Email",
                                onTap: () {
                                  // TODO: Email action
                                },
                              ),
                            ),

                            // Profile Avatar (overlapping)
                            Positioned(
                              top: -100, // moves avatar outside container top
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 46,
                                  backgroundImage: NetworkImage(
                                    "https://randomuser.me/api/portraits/men/32.jpg",
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Hired Chip
                        Chip(
                          avatar: const Icon(
                            Icons.work,
                            color: Colors.white,
                            size: 18,
                          ),
                          label: const Text("Hired"),
                          backgroundColor: Colors.green,
                          labelStyle: const TextStyle(color: Colors.white),
                        ),

                        const SizedBox(height: 12),

                        // Name + Plate
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.delete, color: Colors.redAccent),
                            SizedBox(width: 6),
                            Text(
                              "Deepak Kumar",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.favorite_border,
                              color: Colors.redAccent,
                            ),
                          ],
                        ),
                        const Text(
                          "Plate: MH-12-AB-1234",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),

                        const SizedBox(height: 16),

                        // Performance Overview
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFFFFF8F8),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Driver Performance Overview",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),

                              _performanceRow(
                                "Timely Delivery",
                                0.92,
                                Colors.green,
                                "92%",
                              ),
                              _performanceRow(
                                "Trip Efficiency",
                                0.85,
                                Colors.green,
                                "85%",
                              ),
                              _performanceRow(
                                "Safety",
                                0.80,
                                Colors.orange,
                                "80%",
                              ),

                              const SizedBox(height: 16),

                              // Rating
                              Row(
                                children: [
                                  const Text(
                                    "Enter rating : ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Row(
                                    children: List.generate(5, (index) {
                                      return Icon(
                                        index < 4
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.orange,
                                      );
                                    }),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "4.0",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Feedback
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "Enter Feedback ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "Skilled Driver with good response time",
                                      style: TextStyle(color: Colors.black87),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Recent Reviews
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: const Text(
                            "Recent Reviews",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "No Reviews yet!",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(height: 70), // spacing below avatar

                        const SizedBox(height: 25),

                        const SizedBox(height: 500),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _performanceRow(
    String label,
    double value,
    Color color,
    String percent,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label)),
          Expanded(
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: Color(0xFFFFF8F8),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            percent,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    IconData icon,
    String label, {
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.redAccent, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.redAccent,
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
              borderRadius: BorderRadius.circular(40),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF5722),
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
                colors: [Color(0xFFFF6B2C), Color(0xFFFF3C7E)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              text,
              style: const TextStyle(
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
}
