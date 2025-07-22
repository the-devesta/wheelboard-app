import 'package:flutter/material.dart';
import 'package:wheelboard/constants/apps_colors.dart';

class ProfessionalRegisterScreen extends StatelessWidget {
  const ProfessionalRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final padding = width * 0.08;

    return Scaffold(
      backgroundColor: const Color(0xFFFDECEC),
      appBar: null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: padding, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Heading Title placed at the top
              _headingTitle(),

              // ✅ White container for form content
              Container(
                color: AppColors.white,
                padding: const EdgeInsets.fromLTRB(16, 5, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      iconSize: 28, // Set your desired size here
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      "Register as Professional",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text("Already have an account? "),
                        GestureDetector(
                          onTap: () {},
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildTextField("Full Name"),
                    _buildTextField("Father’s name"),
                    _buildTextField(
                      "Birth of date",
                      suffixIcon: Icons.calendar_today,
                    ),
                    _buildTextField(
                      "Phone Number",
                      hint: "Eg.(+91) 98734 9864",
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown("Select State", Icons.map),
                    const SizedBox(height: 12),
                    _buildDropdown("Select City", Icons.location_city),
                    const SizedBox(height: 20),
                    const Text(
                      "Upload Driver Image*",
                      style: TextStyle(color: AppColors.buttonBg),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        // Add your file picker logic here
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.camera_alt, color: Colors.redAccent),
                            SizedBox(width: 10),
                            Text(
                              "No Image Uploaded.",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildRegisterButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, {String? hint, IconData? suffixIcon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.buttonBg)),
        const SizedBox(height: 6),
        TextField(
          decoration: InputDecoration(
            hintText: hint ?? 'Enter $label',
            suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDropdown(String label, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label*", style: const TextStyle(color: AppColors.buttonBg)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: DropdownButtonFormField<String>(
            hint: Text(label),
            decoration: const InputDecoration(border: InputBorder.none),
            icon: const Icon(Icons.keyboard_arrow_down),
            items: [
              'Option 1',
              'Option 2',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (value) {},
          ),
        ),
      ],
    );
  }

  Widget _headingTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Image.asset('assets/headingImg.png', width: 210, height: 30),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

Widget _buildRegisterButton() {
  return ElevatedButton(
    onPressed: () {
      // Get.to(() => MyprofileScreen());
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.buttonBg,
      minimumSize: const Size(double.infinity, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    child: const Text("Register", style: TextStyle(color: Colors.white)),
  );
}
