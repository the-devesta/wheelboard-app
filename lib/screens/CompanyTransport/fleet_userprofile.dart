import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:wheelboard/screens/CompanyTransport/connection_screen.dart';

class FleetUserprofile extends StatelessWidget {
  final String profileImage = 'https://i.pravatar.cc/150?img=12';

  const FleetUserprofile({super.key});

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
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // const SizedBox(height: 60),
                  Container(
                    margin: EdgeInsets.all(10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white, // Background color
                      borderRadius: BorderRadius.circular(12), // Corner radius
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.black, // optional
                          ),
                        ),
                        Spacer(),
                        Text(
                          "User Profile",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Spacer(flex: 2),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Profile Image with Badge
                  Container(
                    padding: const EdgeInsets.all(
                      4,
                    ), // Thickness of the white border
                    decoration: BoxDecoration(
                      color: Colors.white, // Border color
                      shape: BoxShape.circle,
                    ),
                    child: const CircleAvatar(
                      radius: 48,
                      backgroundImage: NetworkImage(
                        "https://randomuser.me/api/portraits/men/32.jpg",
                      ),
                    ),
                  ),

                  // Role Tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFF13C77B),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Fleet Manager",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Name & Title
                  const Text(
                    "Alex Johnson",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Text(
                    "Fleet Manager",
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),

                  const SizedBox(height: 8),

                  // Location and message icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: Colors.white,
                      ),
                      Text(
                        "Pune, MH, INDIA",
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(width: 12),
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 20,
                        color: Colors.white,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: const [
                            Column(
                              children: [
                                Text(
                                  "50+",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text("Fleet Size"),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  "10+",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text("Years Exp."),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Skills Chips
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            _chip("Fleet Optimization"),
                            _chip("Driver Management"),
                            _chip("Route Planning"),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // About Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "About",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Passionate about scaling logistics and delivering excellence. I optimize fleets, empower drivers, and ensure routes are always efficient. Let’s connect and drive results together.",
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // +Connect Button
                        gradientButton(),

                        const SizedBox(height: 200),
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

  Widget _chip(String label) {
    return Chip(
      label: Text(label, style: const TextStyle(color: Colors.deepOrange)),
      backgroundColor: const Color(0xFFFFF3E0),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
    );
  }

  Widget gradientButton() {
    return Container(
      width: double.infinity,
      height: 56,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF5F6D), Color(0xFFFFC371)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: () {
          // Handle tap here
          Get.to(ConnectionScreen());
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.person_add_alt_1, color: Colors.white),
            SizedBox(width: 8),
            Text(
              "+ Connect",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
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
