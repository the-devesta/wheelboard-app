import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FleetUserprofile extends StatelessWidget {
  final String profileImage = 'https://i.pravatar.cc/150?img=12';

  const FleetUserprofile({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

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

                // AppBar-style row
                Container(
                  margin: EdgeInsets.all(10),
                  color: Colors.white, // or any other background color
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.arrow_back),
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

                const SizedBox(height: 8),

                // Role Tag
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.person_add_alt_1,
                            color: Colors.white,
                          ),
                          label: const Text(
                            "+ Connect",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor:
                                Colors.teal, // Gradient workaround optional
                            shape: const StadiumBorder(),
                            elevation: 4,
                            shadowColor: Colors.black26,
                          ),
                        ),
                      ),

                      // const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
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

  // @override
  // Widget build(BuildContext context) {
  //   final screenHeight = MediaQuery.of(context).size.height;
  //   return Stack(
  //     children: [
  //       // Background image behind everything
  //       Positioned.fill(
  //         child: SvgPicture.asset(
  //           'assets/bgDesign.svg',
  //           fit: BoxFit.cover, // ensure it fills the whole screen
  //         ),
  //       ),

  //       // Foreground UI inside Scaffold
  //     ],
  //   );
  // }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: Colors.white,
  //     body: Stack(
  //       children: [
  //         // 🔴 Background Image
  //         SizedBox(
  //           width: double.infinity,
  //           height: MediaQuery.of(context).size.height * 0.50,
  //           child: SvgPicture.asset('assets/bgDesign.svg', fit: BoxFit.cover),
  //         ),

  //         Positioned(
  //           height: MediaQuery.of(context).size.height * 0.06,
  //           top: MediaQuery.of(context).padding.top,
  //           left: 4,
  //           right: 4,
  //           child: ClipRRect(
  //             borderRadius: BorderRadius.circular(12), // Set corner radius
  //             child: Container(
  //               clipBehavior:
  //                   Clip.antiAlias, // Clip content to match border radius
  //               decoration: BoxDecoration(
  //                 color: Colors.white,
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   // Back button
  //                   GestureDetector(
  //                     onTap: () => Navigator.pop(context),
  //                     child: const Icon(Icons.arrow_back, color: Colors.black),
  //                   ),
  //                   const Text(
  //                     "User Profile",
  //                     style: TextStyle(
  //                       color: Colors.black,
  //                       fontWeight: FontWeight.bold,
  //                       fontSize: 18,
  //                     ),
  //                   ),
  //                   const SizedBox(width: 24),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ),

  //         // ⬜️ Foreground Content
  //         Positioned(
  //           top:
  //               MediaQuery.of(context).size.height * 0.06 +
  //               MediaQuery.of(context).padding.top +
  //               5, // align content just below the curve
  //           left: 0,
  //           right: 0,
  //           child: Column(
  //             children: const [
  //               CircleAvatar(
  //                 radius: 50,
  //                 backgroundColor: Colors.white,
  //                 child: CircleAvatar(
  //                   radius: 45,
  //                   backgroundImage: NetworkImage(
  //                     'https://i.pravatar.cc/150?img=12',
  //                   ),
  //                 ),
  //               ),
  //               // ... add other widgets here
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: Color(0xFFFCECEC),
  //     appBar: AppBar(
  //       leading: IconButton(
  //         icon: const Icon(Icons.arrow_back, color: Colors.black),
  //         onPressed: () {
  //           Navigator.pop(context); // 👈 go back
  //         },
  //       ),
  //       title: const Text("Your Jobs", style: TextStyle(color: Colors.black)),
  //       backgroundColor: Colors.white,
  //       elevation: 0,
  //     ),
  //   );
  // }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: Color(0xFFFCECEC),
  //     body: Column(
  //       children: [
  //         // Header
  //         Container(
  //           decoration: BoxDecoration(
  //             color: Color(0xFFFF5D5D),
  //             borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
  //           ),
  //           padding: EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
  //           child: Column(
  //             children: [
  //               // Top Row
  //               Row(
  //                 children: [
  //                   Icon(Icons.arrow_back, color: Colors.black),
  //                   Spacer(),
  //                   Text(
  //                     "User Profile",
  //                     style: TextStyle(
  //                       fontWeight: FontWeight.bold,
  //                       fontSize: 18,
  //                     ),
  //                   ),
  //                   Spacer(),
  //                   SizedBox(width: 24), // To center the title
  //                 ],
  //               ),
  //               SizedBox(height: 20),

  //               // Profile Image
  //               CircleAvatar(
  //                 radius: 45,
  //                 backgroundColor: Colors.white,
  //                 child: CircleAvatar(
  //                   radius: 42,
  //                   backgroundImage: NetworkImage(profileImage),
  //                 ),
  //               ),
  //               SizedBox(height: 10),

  //               // Badge
  //               Container(
  //                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
  //                 decoration: BoxDecoration(
  //                   color: Colors.green,
  //                   borderRadius: BorderRadius.circular(20),
  //                   boxShadow: [
  //                     BoxShadow(
  //                       color: Colors.black26,
  //                       blurRadius: 4,
  //                       offset: Offset(0, 2),
  //                     ),
  //                   ],
  //                 ),
  //                 child: Text(
  //                   "Fleet Manager",
  //                   style: TextStyle(color: Colors.white, fontSize: 12),
  //                 ),
  //               ),
  //               SizedBox(height: 10),

  //               // Name + Title
  //               Text(
  //                 "Alex Johnson",
  //                 style: TextStyle(
  //                   fontWeight: FontWeight.bold,
  //                   fontSize: 20,
  //                   color: Colors.black,
  //                 ),
  //               ),
  //               SizedBox(height: 4),
  //               Text("Fleet Manager", style: TextStyle(color: Colors.white)),

  //               // Location + chat icon
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Icon(Icons.location_pin, color: Colors.white, size: 18),
  //                   Text(
  //                     "Pune, MH, INDIA",
  //                     style: TextStyle(color: Colors.white),
  //                   ),
  //                   SizedBox(width: 8),
  //                   Container(
  //                     padding: EdgeInsets.all(6),
  //                     decoration: BoxDecoration(
  //                       color: Colors.white,
  //                       shape: BoxShape.circle,
  //                     ),
  //                     child: Icon(
  //                       Icons.chat_bubble,
  //                       size: 16,
  //                       color: Color(0xFFFF5D5D),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),

  //         // Info Section
  //         Expanded(
  //           child: SingleChildScrollView(
  //             padding: EdgeInsets.all(16),
  //             child: Column(
  //               children: [
  //                 // Stats
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                   children: [
  //                     Column(
  //                       children: [
  //                         Text(
  //                           "50+",
  //                           style: TextStyle(
  //                             fontWeight: FontWeight.bold,
  //                             fontSize: 18,
  //                           ),
  //                         ),
  //                         Text(
  //                           "Fleet Size",
  //                           style: TextStyle(color: Colors.grey),
  //                         ),
  //                       ],
  //                     ),
  //                     Column(
  //                       children: [
  //                         Text(
  //                           "10+",
  //                           style: TextStyle(
  //                             fontWeight: FontWeight.bold,
  //                             fontSize: 18,
  //                           ),
  //                         ),
  //                         Text(
  //                           "Years Exp.",
  //                           style: TextStyle(color: Colors.grey),
  //                         ),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //                 SizedBox(height: 20),

  //                 // Tags
  //                 Wrap(
  //                   spacing: 10,
  //                   runSpacing: 10,
  //                   alignment: WrapAlignment.center,
  //                   children: [
  //                     buildTag("Fleet Optimization"),
  //                     buildTag("Driver Management"),
  //                     buildTag("Route Planning"),
  //                   ],
  //                 ),
  //                 SizedBox(height: 20),

  //                 // About Section
  //                 Container(
  //                   padding: EdgeInsets.all(16),
  //                   decoration: BoxDecoration(
  //                     color: Colors.white,
  //                     borderRadius: BorderRadius.circular(16),
  //                   ),
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Text(
  //                         "About",
  //                         style: TextStyle(
  //                           fontWeight: FontWeight.bold,
  //                           fontSize: 16,
  //                         ),
  //                       ),
  //                       SizedBox(height: 10),
  //                       Text(
  //                         "Passionate about scaling logistics and delivering excellence. I optimize fleets, empower drivers, and ensure routes are always efficient. Let’s connect and drive results together.",
  //                         style: TextStyle(color: Colors.black87, fontSize: 14),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 SizedBox(height: 20),

  //                 // Connect Button
  //                 Container(
  //                   width: double.infinity,
  //                   decoration: BoxDecoration(
  //                     borderRadius: BorderRadius.circular(30),
  //                     gradient: LinearGradient(
  //                       colors: [Color(0xFFFF6B6B), Color(0xFFFF9068)],
  //                     ),
  //                     boxShadow: [
  //                       BoxShadow(color: Colors.black26, blurRadius: 4),
  //                     ],
  //                   ),
  //                   child: TextButton.icon(
  //                     onPressed: () {},
  //                     icon: Icon(Icons.person_add, color: Colors.white),
  //                     label: Text(
  //                       "+ Connect",
  //                       style: TextStyle(
  //                         color: Colors.white,
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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
