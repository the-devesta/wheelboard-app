import 'package:flutter/material.dart';

class EnquiryFormPage extends StatelessWidget {
  const EnquiryFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          "Enquiry Form",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),

            /// Title
            const Text(
              "Service Enquiry",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            /// Service options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildServiceOption(
                  icon: Icons.build,
                  title: "Tire Services",
                  subtitle: "We Manage and Mantain\nYour Tires",
                  selected: true,
                  color: const Color(0xFFFF6B6B),
                ),
                _buildServiceOption(
                  icon: Icons.show_chart,
                  title: "Consulting",
                  subtitle: "We manage Your\nOperational Complexities",
                  selected: false,
                  color: const Color(0xFF0984E3),
                ),
              ],
            ),

            const SizedBox(height: 25),

            /// Input fields
            _buildLabel("REQUIRED SERVICE LOCATION:"),
            const SizedBox(height: 6),
            _buildInputField(
              hint: "Enter your service location...",
              icon: Icons.location_on,
              iconColor: Colors.blue,
            ),

            const SizedBox(height: 20),
            _buildLabel("CURRENT CHALLENGES FACED:"),
            const SizedBox(height: 6),
            _buildInputField(
              hint: "Describe current issues...",
              icon: Icons.warning,
              iconColor: Colors.red,
              maxLines: 3,
            ),

            const SizedBox(height: 20),
            _buildLabel("SPECIAL REQUIREMENTS (IF ANY):"),
            const SizedBox(height: 6),
            _buildInputField(
              hint: "Mention any special instructions...",
              icon: Icons.info,
              iconColor: Colors.blue,
              maxLines: 3,
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),

      /// Bottom button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B6B),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            "SUBMIT ENQUIRY",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  /// Widget for service option card
  Widget _buildServiceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool selected,
    required Color color,
  }) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: selected ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? color : Colors.grey.shade400,
          width: 2,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 22,
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white70 : Colors.black87,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Label Text
  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  /// Custom Input field
  Widget _buildInputField({
    required String hint,
    required IconData icon,
    required Color iconColor,
    int maxLines = 1,
  }) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: iconColor),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
