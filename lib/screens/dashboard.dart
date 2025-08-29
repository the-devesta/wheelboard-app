import 'package:flutter/material.dart';
import 'package:wheelboard/constants/apps_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: BackButton(),
        title: Text(
          "DashBoard",
          style: GoogleFonts.poppins(
            fontSize: 20, // 👈 set your size here
            fontWeight: FontWeight.bold,
            color: AppColors.buttonBg,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- Metrics Section ----------------
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.4,
              children: [
                _statCard(
                  Icons.directions_car,
                  "Active Trips",
                  "25 Trips",
                  "5 Scheduled Today",
                  Colors.green,
                ),
                _statCard(
                  Icons.local_shipping,
                  "Active Vehicles",
                  "16 Active",
                  "2 in Maintenance",
                  Colors.blue,
                ),
                _statCard(
                  Icons.wallet,
                  "Monthly Expenses",
                  "₹2,65,000",
                  "Fuel Highest (92k)",
                  Colors.red,
                ),
                _statCard(
                  Icons.work,
                  "Jobs Posted",
                  "12 Active",
                  "8 Unfilled",
                  Colors.blue,
                ),
                _statCard(
                  Icons.route,
                  "Trip Efficiency",
                  "₹3/km Avg",
                  "15,000 km/mo",
                  Colors.teal,
                ),
                _statCard(
                  Icons.car_rental,
                  "Vehicles on lease",
                  "4",
                  "2 Leased this week",
                  Colors.orange,
                ),
              ],
            ),

            const SizedBox(height: 0),

            // ---------------- Trip Completion Trend ----------------
            _sectionTitle("Trip Completion Trend (Last 7 Days)"),
            Container(
              height: 200,
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(child: Text("📊 Chart Placeholder")),
            ),

            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "Vehicle Availability",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text("Now", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _availabilityItem("12", "Available", Colors.green),
                        _availabilityItem("3", "On Trip", Colors.blue),
                        _availabilityItem("1", "On Rent", Colors.red),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ---------------- Top Rated Professionals ----------------
            _sectionTitle("Top Rated Professionals"),
            Row(
              children: [
                _chip("Drivers", true),
                const SizedBox(width: 5),
                _chip("Technicians", false),
                const SizedBox(width: 5),
                _chip("Helpers", false),
              ],
            ),
            const SizedBox(height: 10),
            _professionalTile("Sanjana Mehta", "Driver • South Zone", 4.8),
            _professionalTile("Kiran Kumar", "Technician • East Zone", 4.7),

            const SizedBox(height: 15),

            // ---------------- Jobs You Posted ----------------
            _sectionTitle("Jobs You Posted"),
            _jobCard("Driver Mumbai", "8 Applicants", "35 Likes"),
            _jobCard("Technician Pune", "4 Applicants", "10 Likes"),
            _addButton("+ Post New Job", Color(0xFFF44336)),

            const SizedBox(height: 15),

            // ---------------- Expense Overview ----------------
            _sectionTitle("Expense Overview"),
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text("🟢 Expense Pie Chart Placeholder"),
              ),
            ),

            const SizedBox(height: 15),

            // ---------------- Recent Transactions ----------------
            _sectionTitle("Recent Transactions"),
            _transactionTile(
              icon: Icons.local_gas_station,
              iconColor: Colors.blue,
              title: "Fuel",
              subtitle: "25 May • Diesel",
              amount: "₹12,000",
            ),
            _transactionTile(
              icon: Icons.local_gas_station,
              iconColor: Colors.blue,
              title: "Maintenance",
              subtitle: "24 May • Brake Repair",
              amount: "₹3500",
            ),
            _addButton("+ Add Expense", Color(0xFF1A73E8)),

            const SizedBox(height: 15),

            // ---------------- Assigned Services ----------------
            _sectionTitle("Assigned Services"),
            _serviceTile(
              title: "Tyre Replacement",
              desc:
                  "Professional tyre replacement service for all vehicle types",
              tag: "Tyre Repair",
              updatedAt: "2 days ago",
              onDelete: () {
                print("Delete tapped");
              },
            ),
            _serviceTile(
              title: "Engine Diagnostics",
              desc: "Complete engine diagnostic and repair services",
              tag: "Engine",
              updatedAt: "2 days ago",
              onDelete: () {
                print("Delete tapped");
              },
            ),

            const SizedBox(height: 15),

            // ---------------- Upcoming Trips ----------------
            _sectionTitle("Upcoming Trips"),
            _tripTile(
              id: "TR1042",
              route: "Chennai → Pune",
              time: "28 May, 07:00 AM",
              driver: "A. Rajesh",
              onManage: () {
                print("Manage Trip tapped");
              },
            ),
            _tripTile(
              id: "TR1042",
              route: "Chennai → Pune",
              time: "28 May, 07:00 AM",
              driver: "A. Rajesh",
              onManage: () {
                print("Manage Trip tapped");
              },
            ),

            const SizedBox(height: 30),
            Center(
              child: Column(
                children: const [
                  Text("App v1.3.2", style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 5),
                  Text(
                    "Terms & Conditions  •  Privacy Policy",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Reusable Widgets ----------------
  static Widget _statCard(
    IconData icon,
    String title,
    String value,
    String subtitle,
    Color iconColor, {
    Color backgroundColor = Colors.white, // default white
  }) {
    return Card(
      color: backgroundColor, // ✅ background color
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2, // optional shadow
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _availabilityItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 5),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
      ],
    );
  }

  static Widget _chip(String text, bool selected) {
    return Chip(
      label: Text(text),
      backgroundColor: selected ? Colors.blue[100] : Colors.grey[200],
    );
  }

  static Widget _professionalTile(
    String name,
    String role,
    double rating, {
    String imageUrl =
        "https://via.placeholder.com/150", // pass network image for profile
  }) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        child: Row(
          children: [
            // Profile Image
            CircleAvatar(radius: 26, backgroundImage: NetworkImage(imageUrl)),
            const SizedBox(width: 12),

            // Name + Role + Rating
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),

            // View Profile Button
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1A73E8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: const Text(
                "View Profile",
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _jobCard(String title, String applicants, String likes) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + Tags
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    _pill(applicants, Colors.blue.shade50, Colors.blue),
                    const SizedBox(width: 6),
                    _pill(likes, Colors.red.shade50, Colors.red),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _outlinedButton("View", Colors.red),
                _outlinedButton("Edit", Colors.blue),
                _outlinedButton("Share", Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Reusable Widgets ----------------
  static Widget _pill(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  static Widget _outlinedButton(String text, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        height: 38,
        child: OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: color),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  static Widget _transactionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String amount,
  }) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            // Leading circular icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),

            // Title + Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            // Amount
            Text(
              amount,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _addButton(String text, Color color) {
    return Container(
      width: double.infinity,
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(text, style: TextStyle(color: Colors.white)),
      ),
    );
  }

  static Widget _serviceTile({
    required String title,
    required String desc,
    required String tag,
    required String updatedAt,
    required VoidCallback onDelete,
  }) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + Tag Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              desc,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),

            const SizedBox(height: 12),

            // Bottom Row (Updated text + Delete Icon)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Updated $updatedAt",
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
                InkWell(
                  onTap: onDelete,
                  borderRadius: BorderRadius.circular(20),
                  child: const Icon(Icons.delete, color: Colors.red, size: 22),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _tripTile({
    required String id,
    required String route,
    required String time,
    required String driver,
    required VoidCallback onManage,
  }) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row: Trip ID + Route
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    "Trip #$id",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    route,
                    style: const TextStyle(
                      color: Colors.teal,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Trip time
            Text(
              time,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 4),

            // Driver info
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                children: [
                  const TextSpan(text: "Driver: "),
                  TextSpan(
                    text: driver,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Manage Trip button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onManage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "Manage Trip",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    );
  }
}
