import 'package:flutter/material.dart';
import 'package:wheelboard/constants/apps_colors.dart';

class EditCompanyProfileScreen extends StatelessWidget {
  const EditCompanyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        title: const Text(
          "EDIT Your Profile",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: false,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.close, color: Colors.black),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                const CircleAvatar(
                  radius: 55,
                  backgroundImage: NetworkImage(
                    "https://i.pravatar.cc/150?img=12",
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.camera_alt, color: Colors.redAccent),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            _buildTextField(label: "Company Name", hint: "Enter Company name"),
            _buildTextField(label: "Full Name", hint: "Enter your name"),
            _buildTextField(label: "Email", hint: "Enter your email"),
            _buildTextField(
              label: "Enter Business Category",
              hint: "Enter Business...",
            ),
            _buildTextField(label: "Location", hint: "Current location"),
            _buildTextField(label: "Fleet", hint: "No of Fleet Size"),
            _buildTextField(label: "", hint: "Company GST (Optional)"),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.blueAccent),
                  ),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  // Save logic
                },
                child: const Text(
                  "Save Now",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required String hint}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty)
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          const SizedBox(height: 6),
          TextField(
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
