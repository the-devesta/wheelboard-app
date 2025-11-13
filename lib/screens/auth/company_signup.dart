import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wheelboard/CommonWidget/app_textfield.dart';
import 'package:wheelboard/controllers/signup_controller.dart';

import 'package:country_picker/country_picker.dart';

import '../../models/company_signupmodel.dart';
import '../../widgets/custom_snackbar.dart';
import 'professional_login.dart' show ProfessionLogin;


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
      backgroundColor: const Color(0xFFF4E3E3), // Pink background like Figma
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
                    'assets/logo.png',
                    height: 49,
                    width: 49,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
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
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  // WHEELBOARD text
                  Text(
                    'WHEELBOARD',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1C1E),
                      letterSpacing: 0.5,
                    ),
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
            child: const Icon(
              Icons.arrow_back_ios,
              size: 16,
              color: Color(0xFF1A1C1E),
            ),
          ),
          const SizedBox(height: 24),
          // Dynamic Title based on selection
          Obx(
            () => Text(
              selectedCompanyType.value != null
                  ? "Register as ${selectedCompanyType.value}"
                  : "Register as Company",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF535353),
                letterSpacing: -0.48,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Login link
          Row(
            children: [
              Text(
                "Already have an account? ",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6C7278),
                  letterSpacing: -0.12,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.to(ProfessionLogin());
                },
                child: Text(
                  "Login",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFF26262),
                    letterSpacing: -0.12,
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
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Company Name
          Text(
            "Company Name",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6C7278),
              letterSpacing: -0.24,
            ),
          ),
          const SizedBox(height: 2),
          AppTextField(
            controller: companyController,
            hintText: 'Enter company name',
          ),
          const SizedBox(height: 16),
          // Phone Number
          Text(
            "Phone Number",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6C7278),
              letterSpacing: -0.24,
            ),
          ),
          const SizedBox(height: 2),
          AppTextField(
            controller: phoneController,
            hintText: "Enter your number",
            keyboardType: TextInputType.phone,
            prefixIcon: Obx(
              () => GestureDetector(
                onTap: () {
                  showCountryPicker(
                    context: Get.context!,
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
          ),
          const SizedBox(height: 16),
          // Email
          Text(
            "Email",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6C7278),
              letterSpacing: -0.24,
            ),
          ),
          const SizedBox(height: 2),
          AppTextField(
            controller: emailController,
            hintText: 'Enter your email',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          // Set Password
          Text(
            "Set Password",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6C7278),
              letterSpacing: -0.24,
            ),
          ),
          const SizedBox(height: 2),
          AppTextField(
            controller: passwordController,
            hintText: 'Create your password',
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
            ),
          ),
          const SizedBox(height: 16),
          // Select Business Category
          Text(
            "Select Business Category",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6C7278),
              letterSpacing: -0.24,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: const Color(0xFFEDF1F3),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Obx(
              () => DropdownButtonFormField<String>(
                value: selectedCompanyType.value,
                decoration: InputDecoration(
                  hintText: 'Select category',
                  hintStyle: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFB3B3B3),
                    letterSpacing: 0.1,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  suffixIcon: const Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                items: businessCategories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(
                      category,
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1A1C1E),
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
        ],
      ),
    );
  }

  Widget _buildRegisterButton() {
    return Obx(
      () => Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF25C5C), Color(0xFFF25C5C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ElevatedButton(
          onPressed: controller.isLoading.value
              ? null
              : () async {
                  if (selectedCompanyType.value == null) {
                    SnackBarHelper.error("Please select a business category");
                    return;
                  }
                  final model = CompanySignUpModel(
                    companyName: companyController.text,
                    mobileNo: phoneController.text,
                    email: emailController.text,
                    password: passwordController.text,
                    businessCategory: selectedCompanyType.value ?? 'Transport',
                  );
                  final success = await controller.registerCompany(model);

                  if (success) {
                    SnackBarHelper.success("Company registered successfully! Please login to continue.");
                    await Future.delayed(const Duration(milliseconds: 2000));
                    Get.offAll(() => ProfessionLogin());
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: controller.isLoading.value
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : Text(
                  "Register",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: -0.14,
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
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6C7278),
              letterSpacing: -0.12,
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
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEFF0F6)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF4F5FA).withOpacity(0.6),
            blurRadius: 6,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(asset, width: 18, height: 18),
          const SizedBox(width: 10),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1C1E),
              letterSpacing: -0.14,
            ),
          ),
        ],
      ),
    );
  }
}
