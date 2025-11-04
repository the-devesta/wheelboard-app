import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditYourProfile01Screen extends StatefulWidget {
  const EditYourProfile01Screen({super.key});

  @override
  State<EditYourProfile01Screen> createState() => _EditYourProfile01ScreenState();
}

class _EditYourProfile01ScreenState extends State<EditYourProfile01Screen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _yearsOfExperienceController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  String? _selectedState;
  String? _selectedCity;

  @override
  void dispose() {
    _fullNameController.dispose();
    _fatherNameController.dispose();
    _yearsOfExperienceController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4E3E3),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              height: 91,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFFCD2D2), width: 1),
                ),
              ),
              child: Stack(
                children: [
                  // Back Button
                  Positioned(
                    left: 27,
                    top: 51,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back,
                        size: 18,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                  ),
                  // Title
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 51),
                      child: Text(
                        'EDIT Your Profile',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E1E1E),
                          letterSpacing: -0.14,
                        ),
                      ),
                    ),
                  ),
                  // Close Button
                  Positioned(
                    right: 13,
                    top: 51,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 9),
                    // Title
                    Text(
                      'Register as',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF535353),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Form Card
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 25),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          // Profile Image
                          Stack(
                            children: [
                              Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFF36969),
                                    width: 4,
                                  ),
                                  color: Colors.grey[200],
                                ),
                                child: const Icon(
                                  Icons.person,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF36969),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          // Full Name
                          _buildTextField(
                            controller: _fullNameController,
                            label: 'Full Name',
                            hint: 'Enter your full name',
                          ),
                          const SizedBox(height: 16),
                          // Father's Name
                          _buildTextField(
                            controller: _fatherNameController,
                            label: 'Father\'s name',
                            hint: 'Enter father\'s name',
                          ),
                          const SizedBox(height: 16),
                          // Years Of Experience
                          _buildTextField(
                            controller: _yearsOfExperienceController,
                            label: 'Years Of Experience',
                            hint: 'Eg. 6',
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          // Birth of Date
                          _buildDateField(),
                          const SizedBox(height: 24),
                          // Select State
                          _buildDropdownField(
                            label: 'Select State',
                            value: _selectedState,
                            hint: 'Select state',
                            icon: Icons.location_on,
                            onChanged: (value) {
                              setState(() {
                                _selectedState = value;
                              });
                            },
                          ),
                          const SizedBox(height: 24),
                          // Select City
                          _buildDropdownField(
                            label: 'Select City',
                            value: _selectedCity,
                            hint: 'Select City',
                            icon: Icons.location_city,
                            onChanged: (value) {
                              setState(() {
                                _selectedCity = value;
                              });
                            },
                          ),
                          const SizedBox(height: 24),
                          // Upload Driver Image
                          _buildImageUploadField(),
                          const SizedBox(height: 32),
                          // Save Now Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // Handle save
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF25C5C),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Save Now',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: -0.14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFF36969),
          ),
        ),
        const SizedBox(height: 2),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF6C7278),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFEDF1F3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFEDF1F3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFF36969)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
          ),
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Birth of date',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFF36969),
          ),
        ),
        const SizedBox(height: 2),
        TextField(
          controller: _birthDateController,
          readOnly: true,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1950),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              setState(() {
                _birthDateController.text =
                    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
              });
            }
          },
          decoration: InputDecoration(
            hintText: 'DD/MM/YYYY',
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF6C7278),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFEDF1F3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFEDF1F3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFF36969)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            suffixIcon: const Icon(
              Icons.calendar_today,
              size: 16,
              color: Color(0xFFACB5BB),
            ),
          ),
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required String hint,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFF36969),
              ),
            ),
            Text(
              '*',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFFFF5E5E),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 51,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFEDF1F3)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(icon, size: 18, color: const Color(0xFF6C7278)),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    value: value,
                    isExpanded: true,
                    underline: const SizedBox(),
                    hint: Text(
                      hint,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: const Color(0xFF6C7278),
                      ),
                    ),
                    items: ['State 1', 'State 2', 'State 3']
                        .map((item) => DropdownMenuItem(
                              value: item,
                              child: Text(
                                item,
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                            ))
                        .toList(),
                    onChanged: onChanged,
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  size: 15,
                  color: Color(0xFF6C7278),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageUploadField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Upload Driver Image',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFF36969),
              ),
            ),
            Text(
              '*',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFFFF5E5E),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'JPG/PNG, max 2MB',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF888888),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                border: Border.all(color: const Color(0xFFEDF1F3)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.upload_file,
                size: 24,
                color: Color(0xFF888888),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Container(
                height: 37,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  border: Border.all(color: const Color(0xFFEDF1F3)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'No Image Uploaded.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF888888),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

