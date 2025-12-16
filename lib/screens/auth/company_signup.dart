import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:wheelboard/controllers/signup_controller.dart';

import 'package:country_picker/country_picker.dart';

import '../../models/company_signupmodel.dart';
import '../../widgets/custom_snackbar.dart';
import '../../utils/session_manager.dart';
import '../../screens/CompanyTransport/complete_company_profile.dart';
import 'service_provider_login.dart';
import 'login.dart';

class Signup extends StatelessWidget {
  Signup({super.key});

  final SignupController controller = Get.put(SignupController());
  final TextEditingController companyController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final Rx<String?> selectedCompanyType = Rx<String?>('Transport');
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
        const SizedBox(height: 12),
        // Selectable Cards
        Obx(() {
          return Row(
            children: [
              Expanded(
                child: _buildCategoryCard(
                  title: 'Transport',
                  icon: Icons.local_shipping,
                  isSelected: selectedCompanyType.value == 'Transport',
                  onTap: () {
                    selectedCompanyType.value = 'Transport';
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCategoryCard(
                  title: 'Service Provider',
                  icon: Icons.warehouse,
                  isSelected: selectedCompanyType.value == 'Service Provider',
                  onTap: () {
                    selectedCompanyType.value = 'Service Provider';
                  },
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF4F4) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFF25C5C)
                : const Color(0xFFEDF1F3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFF25C5C).withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFF25C5C)
                    : const Color(0xFFF5F5F5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : const Color(0xFF6C7278),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFFF25C5C)
                    : const Color(0xFF6C7278),
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFF25C5C)
                      : const Color(0xFFD1D5DB),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF25C5C),
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
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
                    email: emailController.text
                        .trim(), // Keep for backend but not shown in UI
                    password: passwordController.text.trim(),
                    businessCategory: selectedCompanyType.value ?? 'Transport',
                  );
                  final success = await controller.registerCompany(model);

                  if (success) {
                    final userId = controller.userId.value;
                    if (userId == null || userId.isEmpty) {
                      SnackBarHelper.error(
                        "Registration successful but user ID not received",
                      );
                      return;
                    }

                    // ✅ Store registration data in SessionManager for complete profile
                    final sessionManager = SessionManager();
                    await sessionManager.saveString(
                      "registration_companyName",
                      companyController.text.trim(),
                    );
                    await sessionManager.saveString(
                      "registration_email",
                      emailController.text.trim(),
                    );
                    await sessionManager.saveString(
                      "registration_mobileNo",
                      phoneController.text.trim(),
                    );
                    await sessionManager.saveString(
                      "registration_businessCategory",
                      selectedCompanyType.value ?? 'Transport',
                    );

                    // ✅ Prepare registration data for complete profile
                    final registrationData = {
                      "userId": userId,
                      "companyName": companyController.text.trim(),
                      "email": emailController.text.trim(),
                      "mobileNo": phoneController.text.trim(),
                      "businessCategory":
                          selectedCompanyType.value ?? 'Transport',
                    };

                    SnackBarHelper.success("Company registered successfully!");
                    await Future.delayed(const Duration(milliseconds: 1500));

                    // ✅ Navigate based on business category
                    if (selectedCompanyType.value == 'Service Provider') {
                      // Navigate to Service Provider registration screen
                      Get.offAll(
                        () => AlliedBusinessRegistrationScreen(),
                        arguments: registrationData,
                      );
                    } else {
                      // Navigate to Transport complete profile screen
                      Get.offAll(
                        () => CompanyCompleteProfile(),
                        arguments: registrationData,
                      );
                    }
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
        Expanded(child: Container(height: 1, color: const Color(0xFFEDF1F3))),
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
        Expanded(child: Container(height: 1, color: const Color(0xFFEDF1F3))),
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
