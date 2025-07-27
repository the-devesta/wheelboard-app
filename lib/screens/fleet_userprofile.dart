import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FleetUserprofile extends StatelessWidget {
  final String profileImage = 'https://i.pravatar.cc/150?img=12';

  const FleetUserprofile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 🔴 Background Image
          SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.50,
            child: SvgPicture.asset('assets/bgDesign.svg', fit: BoxFit.cover),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const Text(
                  "User Profile",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(width: 24), // space to balance layout
              ],
            ),
          ),

          // ⬜️ Foreground Content
          Positioned(
            top: 250, // align content just below the curve
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: const [
                  Text("Profile Content", style: TextStyle(fontSize: 20)),
                  // ... add other widgets here
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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
