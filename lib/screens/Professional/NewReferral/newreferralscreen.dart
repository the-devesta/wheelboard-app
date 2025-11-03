import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class NewReferralScreen extends StatefulWidget {
  const NewReferralScreen({super.key});

  @override
  State<NewReferralScreen> createState() => _AddReferralScreenState();
}

class _AddReferralScreenState extends State<NewReferralScreen> {
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _locationController = TextEditingController();

  bool _notify = false;
  String? _selectedRole;

  final List<Map<String, dynamic>> roles = [
    {"title": "Driver", "icon": Icons.local_shipping_outlined},
    {"title": "Tyre Fitter", "icon": Icons.build_outlined},
    {"title": "Mechanic", "icon": Icons.settings_outlined},
    {"title": "Consulting Agent", "icon": Icons.person_outline},
  ];

  bool get _isFormValid =>
      _nameController.text.isNotEmpty &&
      _mobileController.text.isNotEmpty &&
      _selectedRole != null;

  void _validateForm() => setState(() {});

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateForm);
    _mobileController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _locationController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Add Referral",
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.redAccent),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: const [
          Icon(Icons.more_vert, color: Colors.grey),
          SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Referral Details",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const Text(
              "Fill out the details of the person you’d like to refer",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 18),

            /// Full Name
            _buildTextField(
              controller: _nameController,
              label: "Full Name",
              hint: "Enter full name",
              required: true,
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 14),

            /// Mobile Number
            _buildTextField(
              controller: _mobileController,
              label: "Mobile Number",
              prefixText: "+91 ",
              required: true,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 14),

            /// Email
            _buildTextField(
              controller: _emailController,
              label: "Email (Optional)",
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 18),

            /// Select Role
            const Text(
              "Select Role*",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: roles.map((role) {
                final isSelected = _selectedRole == role["title"];
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        role["icon"],
                        size: 18,
                        color: isSelected ? Colors.white : Colors.black54,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        role["title"],
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.grey.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  selected: isSelected,
                  selectedColor: Colors.redAccent,
                  backgroundColor: Colors.white,
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: isSelected
                          ? Colors.redAccent
                          : Colors.grey.shade400,
                    ),
                  ),
                  onSelected: (_) {
                    setState(() => _selectedRole = role["title"]);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 18),

            /// Location
            _buildTextField(
              controller: _locationController,
              label: "Location (Optional)",
              hint: "Enter city, district or area",
              keyboardType: TextInputType.text,
            ),

            const SizedBox(height: 18),

            /// Notify checkbox
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _notify,
                  activeColor: Colors.redAccent,
                  onChanged: (val) {
                    setState(() => _notify = val ?? false);
                  },
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Notify me when this referral is accepted",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "You may get an SMS or app alert if your referral is accepted.",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            /// Send Invite Button
            ElevatedButton(
              onPressed: _isFormValid
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Referral submitted successfully!"),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isFormValid
                    ? Colors.redAccent
                    : Colors.redAccent.shade100,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                "SEND INVITE",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),

            const SizedBox(height: 20),

            /// Note
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: const [
                  Icon(Icons.lightbulb_outline, color: Colors.amber, size: 22),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Refer people who are active in transport or service fields for higher chances of acceptance.",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool required = false,
    String? prefixText,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixText: prefixText,
        labelText: required ? "$label *" : label,
        hintText: hint,
        labelStyle: const TextStyle(fontSize: 13, color: Colors.black54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
