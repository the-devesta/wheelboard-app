import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:wheelboard/CommonWidget/app_textfield.dart';
import 'package:wheelboard/commonwidget/app_dropdown.dart';
import 'package:wheelboard/controllers/signup_controller.dart';
import 'package:wheelboard/screens/login.dart';
import '../constants/apps_colors.dart';
import 'package:country_picker/country_picker.dart';
import 'complete_company_profile.dart';
import '../models/company_signupmodel.dart';
import '../utils/session_manager.dart';

class Signup extends StatelessWidget {
  Signup({super.key});

  final SignupController controller = Get.put(SignupController());
  final TextEditingController companyController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final RxnString selectedCompanyType = RxnString();
  final Rx<Country> selectedCountry = Country.parse('IN').obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _headingTitle(),
                const SizedBox(height: 20),
                _buildWhiteCard(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWhiteCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            "Register as Company",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text("Already have an account? "),
              GestureDetector(
                onTap: () {
                  Get.to(ProfessionLogin());
                },
                child: const Text(
                  "Login",
                  style: TextStyle(
                    color: Color(0xFFF36B5A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildFormFields(),
          _buildRegisterButton(),
          const SizedBox(height: 16),
          _buildDivider(),
          const SizedBox(height: 16),
          _buildSocialButtons(),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: double.infinity, child: Text("Company Name")),
          const SizedBox(height: 5),
          AppTextField(
            controller: companyController,
            hintText: 'Enter company name',
          ),
          const SizedBox(height: 16),
          const SizedBox(width: double.infinity, child: Text("Email")),
          const SizedBox(height: 5),
          AppTextField(
            controller: emailController,
            hintText: 'Enter your email',
          ),
          const SizedBox(height: 16),
          const SizedBox(width: double.infinity, child: Text("Phone Number")),
          const SizedBox(height: 5),
          AppTextField(
            controller: phoneController,
            hintText: "Enter your number",
            keyboardType: TextInputType.phone,
            prefixIcon: GestureDetector(
              onTap: () {
                showCountryPicker(
                  context: Get.context!,
                  showPhoneCode: true,
                  onSelect: (Country country) {
                    selectedCountry.value = country;
                    // selectedCountry
                  },
                );
              },
              child: Container(
                width: 80,
                padding: const EdgeInsets.only(left: 8, right: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedCountry.value?.flagEmoji ?? '🌐',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const SizedBox(width: double.infinity, child: Text("Set Password")),
          const SizedBox(height: 5),
          AppTextField(
            controller: passwordController,
            hintText: 'Enter your password',
            obscureText: controller.obscurePassword.value,
            suffixIcon: IconButton(
              icon: Icon(
                controller.obscurePassword.value
                    ? Icons.visibility_off
                    : Icons.visibility,
              ),
              onPressed: () => controller.obscurePassword.toggle(),
            ),
          ),
          const SizedBox(height: 16),
          const SizedBox(
            width: double.infinity,
            child: Text("Select Business Category"),
          ),
          const SizedBox(height: 5),
          AppDropdown<String>(
            value: selectedCompanyType.value,
            hintText: "Choose your country",
            items: const [
              DropdownMenuItem(value: 'Transport', child: Text('Transport')),
              DropdownMenuItem(
                value: 'Service Provider',
                child: Text('Service Provider'),
              ),
            ],
            onChanged: (value) => selectedCompanyType.value = value,
          ),
          const SizedBox(height: 25),
        ],
      ),
    );
  }

  Widget _buildRegisterButton() {
    return Obx(
      () => ElevatedButton(
        onPressed: controller.isLoading.value
            ? null // Disable the button when loading
            : () async {
                //   Get.to(() => CompanyCompleteProfile());
                final model = CompanySignUpModel(
                  companyName: companyController.text,
                  mobileNo: phoneController.text,
                  email: emailController.text,
                  password: passwordController.text,
                  businessCategory: selectedCompanyType.value ?? '',
                );
                final success = await controller.registerCompany(model);
                final userId = controller.userId.value;

                if (success) {
                  // ✅ Condition check
                  if (selectedCompanyType.value == "Transport" ||
                      selectedCompanyType.value == null ||
                      selectedCompanyType.value!.isEmpty) {
                    await SessionManager.setLogin(true);
                    await SessionManager.setProfileCompleted(false);
                    // Get.to(() => CompanyCompleteProfile());

                    Get.to(
                      () => CompanyCompleteProfile(),
                      arguments: {"userId": userId},
                    );
                  } else {
                    // Your default navigation
                    // Get.offAll(() => const DashboardScreen());
                  }
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonBg,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: controller.isLoading.value
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : const Text("Register", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: const [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text("Or"),
        ),
        Expanded(child: Divider()),
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
        color: Colors.white,
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(asset, width: 20, height: 20),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
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
