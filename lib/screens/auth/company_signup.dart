import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:wheelboard/CommonWidget/app_textfield.dart';
import 'package:wheelboard/commonwidget/app_dropdown.dart';
import 'package:wheelboard/controllers/signup_controller.dart';

import 'package:country_picker/country_picker.dart';

import '../../constants/apps_colors.dart';
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
      constraints: BoxConstraints(
        maxWidth: 500, // Limit maximum width for better responsiveness
      ),
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
          Text(
            "Register as Company",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text("Already have an account? ", style: Theme.of(context).textTheme.bodyMedium),
              GestureDetector(
                onTap: () {
                  Get.to(ProfessionLogin());
                },
                child: Text(
                  "Login",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFF36B5A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildFormFields(context),
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
          Text("Company Name", style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          AppTextField(
            controller: companyController,
            hintText: 'Enter company name',
          ),
          const SizedBox(height: 16),
          Text("Email", style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          AppTextField(
            controller: emailController,
            hintText: 'Enter your email',
          ),
          const SizedBox(height: 16),
          Text("Phone Number", style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
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
                      selectedCountry.value.flagEmoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text("Set Password", style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
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
          Text("Select Business Category", style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
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
                if (selectedCompanyType.value == "Transport") {
                  final model = CompanySignUpModel(
                    companyName: companyController.text,
                    mobileNo: phoneController.text,
                    email: emailController.text,
                    password: passwordController.text,
                    businessCategory: selectedCompanyType.value ?? '',
                  );
                  final success = await controller.registerCompany(model);

                  if (success) {
                    // ✅ Show success message
                    SnackBarHelper.success("Company registered successfully! Please login to continue.");
                    
                    // ✅ Wait for snackbar to be visible
                    await Future.delayed(const Duration(milliseconds: 2000));
                    
                    // ✅ Navigate to login page - don't set login state yet
                    // User needs to login first, then complete profile
                    Get.offAll(() => ProfessionLogin());
                  }
                } else {
                  final model = CompanySignUpModel(
                    companyName: companyController.text,
                    mobileNo: phoneController.text,
                    email: emailController.text,
                    password: passwordController.text,
                    businessCategory: selectedCompanyType.value ?? '',
                  );
                  final success = await controller.registerCompany(model);
                  
                  if (success) {
                    // ✅ Show success message
                    SnackBarHelper.success("Company registered successfully! Please login to continue.");
                    
                    // ✅ Wait for snackbar to be visible
                    await Future.delayed(const Duration(milliseconds: 2000));
                    
                    // ✅ Navigate to login page - don't set login state yet
                    // User needs to login first, then complete profile
                    Get.offAll(() => ProfessionLogin());
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
