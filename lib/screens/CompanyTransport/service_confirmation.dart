import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wheelboard/screens/CompanyTransport/service_dashboard.dart';

class ServiceConfirmationPage extends StatelessWidget {
  const ServiceConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ✅ Top Success Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4ADE80), Color(0xFF22C55E)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: Column(
                children: const [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.check, color: Colors.white, size: 40),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Service Assigned\nSuccessfully",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "The service has been successfully assigned!",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ✅ Service Details Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.assignment, color: Color(0xFF3867d6)),
                          SizedBox(width: 8),
                          Text(
                            "Service Details",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),

                      // Service Title
                      _detailRow("Service Title", "Tyre Replacement"),
                      const SizedBox(height: 12),

                      // Vehicle Number
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            "Vehicle Number",
                            style: TextStyle(color: Colors.black54),
                          ),
                          Chip(
                            label: Text("DL01AB1234"),
                            backgroundColor: Color(0xFFF5F5F5),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Date & Time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            "Service Date",
                            style: TextStyle(color: Colors.black54),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: Color(0xFF3867d6),
                                size: 18,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Dec 15, 2024",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            "Service Time",
                            style: TextStyle(color: Colors.black54),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                color: Color(0xFF3867d6),
                                size: 18,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "2:30 PM",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Description
                      const Text(
                        "Service Description",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Complete tyre replacement service including wheel alignment and balancing. Premium quality tyres with 2-year warranty coverage.",
                        style: TextStyle(color: Colors.black87, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ✅ Service ID Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFFBBF7D0)),
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xFFE9FFF5),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Service ID",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            "#WBD-2024121501",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Icon(Icons.copy, color: Color(0xFF00B894)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Linked with the client dashboard and trackable via Admin.",
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ✅ Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Get.to(ServiceDashboardScreen());
                    },
                    icon: const Icon(Icons.home, color: Colors.white),
                    label: const Text(
                      "Back to Dashboard",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: Colors.black26),
                    ),
                    onPressed: () {
                      Get.back();
                    },
                    icon: const Icon(Icons.add, color: Colors.black87),
                    label: const Text(
                      "Assign Another Service",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // 🔹 Helper widget for detail row
  Widget _detailRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.black54)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
