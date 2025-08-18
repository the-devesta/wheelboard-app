import 'package:flutter/material.dart';
import 'banner_carousel.dart';
import 'package:get/get.dart';
import 'service_details.dart';
import 'service_confirmation.dart';
import 'enquiry_form_page.dart';
import 'success_popup.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(246, 247, 248, 1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(),
        title: const Text("Services", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search and Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Search bar with filter icon
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.grey),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search services...',
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.filter_alt_outlined,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            // Handle filter action
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Dropdown filter
                Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: 'All',
                      items: ['All', 'Active', 'Inactive']
                          .map(
                            (label) => DropdownMenuItem(
                              value: label,
                              child: Text(
                                label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        // Handle dropdown selection
                      },
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Carousel Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                "assets/service.png",
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // CTA Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () {
                Get.to(SuccessPopup());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B894),
                elevation: 6, // adds the shadow
                shadowColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: const StadiumBorder(), // capsule shape
              ),
              child: const Center(
                child: Text(
                  "Book Services near you !",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Service List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 6,
              itemBuilder: (context, index) {
                return ServiceCard();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  const ServiceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + Verified Badge
            Row(
              children: const [
                Expanded(
                  child: Text(
                    "Tyre Replacement & Balancing",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.verified, color: Color(0xFF00B894), size: 18),
                SizedBox(width: 4),
                Text("Verified", style: TextStyle(color: Color(0xFF00B894))),
              ],
            ),

            const SizedBox(height: 6),

            // Tag + Address
            Row(
              children: [
                Chip(
                  label: Text(
                    "Workshop",
                    style: TextStyle(
                      color: Color(0xFF00B894),
                      fontSize: 12, // smaller font
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  backgroundColor: Color(0xFFE6F9F2),
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                  visualDensity: VisualDensity(
                    horizontal: 0,
                    vertical: -4,
                  ), // reduces chip height
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide.none, // ← ensures no border
                  ), // minimizes touch area
                ),
                SizedBox(width: 8),
                Text("Raj Tyre Works · Surat, Gujarat"),
              ],
            ),

            const SizedBox(height: 6),

            // Rating + Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.star, color: Colors.amber, size: 20),
                    SizedBox(width: 4),
                    Text("4.6"),
                    SizedBox(width: 4),
                    Text("(132 reviews)", style: TextStyle(color: Colors.grey)),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    Get.to(ServiceDetailScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00B894),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    "View Details",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
