import 'package:flutter/material.dart';
import 'trips_info_widget.dart';

class TripPage extends StatelessWidget {
  const TripPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/headingImg.png', // Replace with your logo
                      height: 40,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    // Search Bar with Shadow
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const TextField(
                            decoration: InputDecoration(
                              hintText: "Search Trips",
                              border: InputBorder.none,
                              icon: Icon(Icons.search),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Filter Icon with Shadow
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.tune),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Recent Trips
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Recent Trips",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text("See all", style: TextStyle(color: Colors.blue)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 185,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      tripCard(
                        title: "Trip to Ahmedabad",
                        subtitle: "From Surat → Ahmedabad",
                        tag: "Completed",
                        label: "Cold Storage",
                        date: "June 30, 2024 – 9:00 AM",
                        tagColor: Colors.green,
                      ),
                      const SizedBox(width: 16),
                      tripCard(
                        title: "Trip to Bhopal",
                        subtitle: "Indore → Bhopal",
                        tag: "Upcoming",
                        label: "Express Delivery",
                        date: "July 10, 2024",
                        tagColor: Colors.blue,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Filter Tabs
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      filterTab("Completed", Icons.check_circle, Colors.green),
                      filterTab("In-Process", Icons.autorenew, Colors.blue),
                      filterTab("Upcoming", Icons.access_time, Colors.orange),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                TripInfoCard(
                  imagePath: 'assets/tripImage.png',
                  status: 'Completed',
                  badge: 'Standard',
                  title: 'Trip to Los Angeles',
                  tag: 'Package Delivery',
                  destination: 'Los Angeles',
                  departureDate: '2024-06-01',
                  vehicle: 'shipment truck-GJ 06 K9 1442',
                  driver: 'Deepak kumar',
                ),

                // Trip Detail Card
                // Stack(
                //   children: [
                //     Container(
                //       width: double.infinity,
                //       margin: const EdgeInsets.only(bottom: 16),
                //       decoration: BoxDecoration(
                //         color: Colors.grey[100],
                //         borderRadius: BorderRadius.circular(16),
                //       ),
                //       child: Column(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         children: [
                //           // Trip image with tags
                //           Stack(
                //             children: [
                //               ClipRRect(
                //                 borderRadius: const BorderRadius.only(
                //                   topLeft: Radius.circular(16),
                //                   topRight: Radius.circular(16),
                //                 ),
                //                 child: Image.asset(
                //                   'assets/truck.jpg', // Replace with your image
                //                   width: double.infinity,
                //                   height: 180,
                //                   fit: BoxFit.cover,
                //                 ),
                //               ),
                //               Positioned(
                //                 left: 8,
                //                 top: 8,
                //                 child: statusLabel("Completed", Colors.green),
                //               ),
                //               Positioned(
                //                 right: 8,
                //                 top: 8,
                //                 child: statusLabel("Standard", Colors.teal),
                //               ),
                //             ],
                //           ),

                //           Padding(
                //             padding: const EdgeInsets.all(16.0),
                //             child: Column(
                //               crossAxisAlignment: CrossAxisAlignment.start,
                //               children: [
                //                 Text(
                //                   "Trip to Los Angeles",
                //                   style: TextStyle(
                //                     fontSize: 18,
                //                     fontWeight: FontWeight.bold,
                //                   ),
                //                 ),
                //                 SizedBox(height: 4),
                //                 Text(
                //                   "Package Delivery",
                //                   style: TextStyle(color: Colors.teal),
                //                 ),
                //                 SizedBox(height: 12),
                //                 tripInfoRow(
                //                   Icons.location_on,
                //                   "Destination: Los Angeles",
                //                 ),
                //                 tripInfoRow(
                //                   Icons.calendar_today,
                //                   "Departure: 2024-06-01",
                //                 ),
                //                 tripInfoRow(
                //                   Icons.fire_truck,
                //                   "Vehicle: shipment truck-GJ 01 AB 1234",
                //                 ),
                //                 tripInfoRow(
                //                   Icons.person,
                //                   "Driver: Deepak Kumar",
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),

                //     // FAB Actions
                //     Positioned(
                //       right: 0,
                //       top: 160,
                //       child: Column(
                //         children: [
                //           fabAction("Manage Trips", Icons.dashboard_customize),
                //           fabAction("Schedule", Icons.calendar_month),
                //           fabAction("New Trip", Icons.add),
                //         ],
                //       ),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget tripCard({
    required String title,
    required String subtitle,
    required String tag,
    required String label,
    required String date,
    required Color tagColor,
  }) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✔ Completed pill with icon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: tagColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: tagColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: tagColor, size: 14),
                const SizedBox(width: 4),
                Text(
                  tag,
                  style: TextStyle(
                    color: tagColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 4),

          // Subtitle (e.g. From Surat → Ahmedabad)
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  subtitle,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Cold Storage Label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Calendar Row
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.black54),
              const SizedBox(width: 6),
              Text(
                date,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget filterTab(String label, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }

  static Widget statusLabel(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static Widget tripInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.teal),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  static Widget fabAction(String label, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ElevatedButton.icon(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 6,
        ),
        icon: Icon(icon, size: 16),
        label: Text(label),
      ),
    );
  }
}

Widget tripInfoRow(IconData icon, String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6.0),
    child: Row(
      children: [
        Icon(icon, size: 16, color: Colors.teal),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    ),
  );
}

Widget fabAction(String label, IconData icon) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 6),
    child: ElevatedButton.icon(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 6,
      ),
      icon: Icon(icon, size: 16),
      label: Text(label),
    ),
  );
}
