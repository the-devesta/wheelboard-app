import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:wheelboard/constants/apps_colors.dart';
import 'job_form_screen.dart';
import 'job_application_screen.dart';
import 'package:share_plus/share_plus.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Icon(Icons.arrow_back, color: Colors.black),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text("Your Jobs", style: TextStyle(color: Colors.black)),
            const SizedBox(width: 40),
            GestureDetector(
              onTap: () {
                // Handle the tap here
                Get.to(JobApplicationsScreen());
              },
              child: const Text(
                "Applications",
                style: TextStyle(color: Colors.black38),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          JobCard(
            role: 'Driver',
            image: 'assets/feed.svg',
            duration: 'Task-Based',
            openings: '5',
            salary: '₹18,000',
            city: 'Mumbai',
            description: 'Description..........',
          ),
          SizedBox(height: 16),
          JobCard(
            role: 'Technician',
            image: 'assets/feedImage.svg',
            duration: 'Permanent',
            openings: '2',
            salary: '₹35,000',
            city: 'Pune',
            description: 'Description..........',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFFF5C5C),
        onPressed: () {
          Get.to(PostJobScreen());
        },
        icon: SvgPicture.asset(
          'assets/add_circle.svg', // <-- your SVG path
          width: 24,
          height: 24,
          color: Colors.white, // optional, applies if SVG supports it
        ),
        label: const Text("Post Job", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class JobCard extends StatelessWidget {
  final String role;
  final String image;
  final String duration;
  final String openings;
  final String salary;
  final String city;
  final String description;

  const JobCard({
    super.key,
    required this.role,
    required this.image,
    required this.duration,
    required this.openings,
    required this.salary,
    required this.city,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main Card
        Container(
          margin: const EdgeInsets.only(
            bottom: 30,
          ), // leave space for overlay button
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Image
              ClipRRect(
                child: Image.asset(
                  "assets/jobdescription.png", // Replace with the PNG file path
                  width: double.infinity,
                  height: 140,
                  fit: BoxFit.fill, // You can adjust the fit as needed
                ),
              ),

              // Info
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Role & Icons
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                offset: const Offset(0, 4),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const Text(
                            "Technician",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SvgPicture.asset(
                          'assets/heart.svg',
                          width: 32,
                          height: 32,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            // Perform your share action here
                            Share.share("WheelBoard");
                          },
                          child: SvgPicture.asset(
                            'assets/shareBtnWBg.svg',
                            width: 32,
                            height: 32,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _infoRow("Duration", duration),
                    _infoRow("Openings", openings),
                    _infoRow("Salary", salary),
                    _infoRow("City", city),
                    _infoRow("Description", description),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Floating Edit Button (Overlayed)
        Positioned(
          right: 16,
          bottom: 40,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5C5C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(
                  // 👈 border color and width
                  color: Colors.white,
                  width: 2,
                ),
              ),
              elevation: 4,
            ),
            onPressed: () {},
            icon: const Icon(Icons.edit, size: 16, color: Colors.white),
            label: const Text("Edit", style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF8C8C8C),
              ),
            ),
          ),
          const Text(": "),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
