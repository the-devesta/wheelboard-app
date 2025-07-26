import 'package:flutter/material.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCEEF0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Icon(Icons.arrow_back, color: Colors.black),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text("Your Jobs", style: TextStyle(color: Colors.black)),
            SizedBox(width: 16),
            Text("Applications", style: TextStyle(color: Colors.black38)),
          ],
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          JobCard(
            role: 'Driver',
            image:
                'https://images.unsplash.com/photo-1517142089942-ba376ce32a2e',
            duration: 'Task-Based',
            openings: '5',
            salary: '₹18,000',
            city: 'Mumbai',
            description: 'Description..........',
          ),
          SizedBox(height: 16),
          JobCard(
            role: 'Technician',
            image:
                'https://images.unsplash.com/photo-1581090700227-1e8c79c6ee65',
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
        onPressed: () {},
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("+ Post Job", style: TextStyle(color: Colors.white)),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Image.network(
              image,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  ],
                ),
                const SizedBox(height: 10),

                _infoRow("Duration", duration),
                _infoRow("Openings", openings),
                _infoRow("Salary", salary),
                _infoRow("City", city),
                _infoRow("Description", description),

                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5C5C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                    label: const Text(
                      "Edit",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const Text(": "),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
