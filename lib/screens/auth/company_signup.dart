import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:wheelboard/controllers/signup_controller.dart';

import 'package:country_picker/country_picker.dart';

import '../../models/company_signupmodel.dart';
import '../../widgets/custom_snackbar.dart';
import 'login.dart';

class Signup extends StatelessWidget {
  Signup({super.key});

  final SignupController controller = Get.put(SignupController());
  final TextEditingController companyController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final Rx<String?> selectedCompanyType = Rx<String?>(null);
  final Rx<Country> selectedCountry = Country.parse('IN').obs;
  
  final List<String> businessCategories = ['Transport', 'Service Provider'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4E3E3), // Pink background
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: AppBar(elevation: 0, backgroundColor: Colors.transparent),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header with Logo and WHEELBOARD text
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
              child: Row(
                children: [
                  // Logo
                  Image.asset(
                    'assets/headingImg.png',
                    width: 211,
                    height: 49,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Row(
                        children: [
                          Container(
                            width: 49,
                            height: 49,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF25C5C),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.local_shipping,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'WHEELBOARD',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A1C1E),
                              letterSpacing: 0.5,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // White card with form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildWhiteCard(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhiteCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 24,
              height: 24,
              child: const Icon(
                Icons.arrow_back,
                size: 20,
                color: Color(0xFF1A1C1E),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Title - always "Register as Company"
          Text(
            "Register as Company",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF535353),
              letterSpacing: -0.48,
              fontFamily: 'Poppins',
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          // Login link
          Row(
            children: [
              Text(
                "Already have an account?",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6C7278),
                  height: 1.4,
                  letterSpacing: -0.12,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () {
                  Get.to(LoginScreen());
                },
                child: Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFF26262),
                    height: 1.4,
                    letterSpacing: -0.12,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildFormFields(context),
          const SizedBox(height: 16),
          _buildRegisterButton(),
          const SizedBox(height: 16),
          _buildDivider(),
          const SizedBox(height: 16),
          _buildSocialButtons(),
        ],
      ),
    );
  }


  Widget _buildFormFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Company Name
        _buildInputField(
          label: "Company Name",
          hint: "Enter company name",
          controller: companyController,
        ),
        const SizedBox(height: 16),
        // Phone Number
        _buildPhoneField(context),
        const SizedBox(height: 16),
        // Set Password
        Obx(
          () => _buildInputField(
            label: "Set Password",
            hint: "Create your password",
            controller: passwordController,
            obscureText: controller.obscurePassword.value,
            suffixIcon: IconButton(
              icon: Icon(
                controller.obscurePassword.value
                    ? Icons.visibility_off
                    : Icons.visibility,
                size: 16,
                color: const Color(0xFF6C7278),
              ),
              onPressed: () => controller.obscurePassword.toggle(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Select Business Category
        _buildBusinessCategoryDropdown(),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6C7278),
            height: 1.6,
            letterSpacing: -0.24,
            fontFamily: 'Plus Jakarta Sans',
          ),
        ),
        const SizedBox(height: 2),
        // Input field
        Container(
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFEDF1F3)),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: const Color(0xFF1A1C1E),
              height: 1.4,
              letterSpacing: -0.14,
              fontFamily: 'Inter',
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: const Color(0xFF6C7278),
                height: 1.4,
                letterSpacing: -0.14,
                fontFamily: 'Inter',
              ),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          "Phone Number",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6C7278),
            height: 1.6,
            letterSpacing: -0.24,
            fontFamily: 'Plus Jakarta Sans',
          ),
        ),
        const SizedBox(height: 2),
        // Input field with country code
        Container(
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFEDF1F3)),
          ),
          child: Row(
            children: [
              // Country code selector
              Obx(
                () => GestureDetector(
                  onTap: () {
                    showCountryPicker(
                      context: context,
                      showPhoneCode: true,
                      onSelect: (Country country) {
                        selectedCountry.value = country;
                      },
                    );
                  },
                  child: Container(
                    width: 62,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: const Color(0xFFEDF1F3)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            selectedCountry.value.flagEmoji,
                            style: const TextStyle(fontSize: 16),
                            overflow: TextOverflow.visible,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down, size: 12),
                      ],
                    ),
                  ),
                ),
              ),
              // Phone number input
              Expanded(
                child: TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: const Color(0xFF1A1C1E),
                    height: 1.4,
                    letterSpacing: -0.14,
                    fontFamily: 'Inter',
                  ),
                  decoration: InputDecoration(
                    hintText: "Enter your number",
                    hintStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: const Color(0xFF6C7278),
                      height: 1.4,
                      letterSpacing: -0.14,
                      fontFamily: 'Inter',
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          "Select Business Category",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6C7278),
            height: 1.6,
            letterSpacing: -0.24,
            fontFamily: 'Plus Jakarta Sans',
          ),
        ),
        const SizedBox(height: 2),
        // Dropdown
        Container(
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFEDF1F3)),
          ),
          child: Obx(
            () => DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedCompanyType.value,
                hint: Padding(
                  padding: const EdgeInsets.only(left: 14),
                  child: Text(
                    'Select category',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFB3B3B3),
                      letterSpacing: 0.1,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
                icon: const Padding(
                  padding: EdgeInsets.only(right: 14),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                isExpanded: true,
                items: businessCategories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 14),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1A1C1E),
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? value) {
                  selectedCompanyType.value = value;
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: controller.isLoading.value
              ? null
              : () async {
                  // ✅ Validate fields
                  if (companyController.text.trim().isEmpty) {
                    SnackBarHelper.error("Please enter company name");
                    return;
                  }
                  if (phoneController.text.trim().isEmpty) {
                    SnackBarHelper.error("Please enter phone number");
                    return;
                  }
                  if (passwordController.text.trim().isEmpty) {
                    SnackBarHelper.error("Please enter password");
                    return;
                  }
                  if (selectedCompanyType.value == null) {
                    SnackBarHelper.error("Please select a business category");
                    return;
                  }

                  // ✅ Prevent multiple taps
                  if (controller.isLoading.value) {
                    return;
                  }

                  final model = CompanySignUpModel(
                    companyName: companyController.text.trim(),
                    mobileNo: phoneController.text.trim(),
                    email: emailController.text.trim(), // Keep for backend but not shown in UI
                    password: passwordController.text.trim(),
                    businessCategory: selectedCompanyType.value ?? 'Transport',
                  );
                  final success = await controller.registerCompany(model);

                  if (success) {
                    SnackBarHelper.success("Company registered successfully! Please login to continue.");
                    await Future.delayed(const Duration(milliseconds: 2000));
                    Get.offAll(() => LoginScreen());
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF25C5C),
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
            disabledBackgroundColor: const Color(0xFFF25C5C).withOpacity(0.6),
          ),
          child: controller.isLoading.value
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  "Register",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.4,
                    letterSpacing: -0.14,
                    fontFamily: 'Poppins',
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFFEDF1F3),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Or",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6C7278),
              height: 1.5,
              letterSpacing: -0.12,
              fontFamily: 'Inter',
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFFEDF1F3),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Column(
      children: [
        _socialButton("Continue with Google", "assets/google.svg"),
        const SizedBox(height: 12),
        _socialButton("Continue with Facebook", "assets/facebook.svg"),
      ],
    );
  }

  Widget _socialButton(String text, String asset) {
    return InkWell(
      onTap: () {
        // TODO: Implement social login
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFEFF0F6)),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(asset, width: 18, height: 18),
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1C1E),
                height: 1.4,
                letterSpacing: -0.14,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
