import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wheelboard/CommonWidget/app_textfield.dart';
import 'package:wheelboard/commonwidget/app_dropdown.dart';
import 'package:wheelboard/controllers/profile_controller.dart';
import 'package:wheelboard/controllers/signup_controller.dart';
import '../constants/apps_colors.dart';
import 'package:country_picker/country_picker.dart';
import 'dart:ui' as ui;
import 'complete_profile.dart';

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final SignupController controller = Get.put(SignupController());
  String? _selectedCompanyType;
  bool _obscurePassword = true;
  Country? _selectedCountry;

  @override
  void initState() {
    super.initState();

    // Set default country from locale
    final deviceLocale = ui.window.locale.countryCode;
    _selectedCountry = Country.parse(deviceLocale ?? 'IN'); // fallback to IN
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),

              child: Column(
                children: [
                  _headingTitle(),
                  SizedBox(height: 20),
                  _buildWhiteCard(context),
                ],
              ),
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
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),

          // Title
          Text(
            "Register as Company",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),

          SizedBox(height: 8),

          // Login text
          Row(
            children: [
              Text("Already have an account? "),
              GestureDetector(
                onTap: () {
                  // Navigate to login
                },
                child: Text(
                  "Login",
                  style: TextStyle(
                    color: Color(0xFFF36B5A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 20),

          // Form fields...
          _buildFormFields(),

          // Register button...
          _buildRegisterButton(),

          SizedBox(height: 16),
          _buildDivider(),
          SizedBox(height: 16),
          _buildSocialButtons(),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    final TextEditingController _companyController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          child: Text("Company Name", textAlign: TextAlign.left),
        ),
        SizedBox(height: 5),
        AppTextField(
          controller: _companyController,
          hintText: 'Enter company name',
        ),
        SizedBox(height: 16),
        Container(
          width: double.infinity,
          child: Text("Phone Number", textAlign: TextAlign.left),
        ),
        SizedBox(height: 5),
        AppTextField(
          hintText: "Enter your number",
          keyboardType: TextInputType.phone,
          prefixIcon: GestureDetector(
            onTap: () {
              showCountryPicker(
                context: context,
                showPhoneCode: true,
                onSelect: (Country country) {
                  setState(() {
                    _selectedCountry = country;
                  });
                },
              );
            },
            child: Container(
              width: 80,
              padding: EdgeInsets.only(left: 8, right: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedCountry?.flagEmoji ?? '🌐',
                    style: TextStyle(fontSize: 20),
                  ),
                  Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
        Container(
          width: double.infinity,
          child: Text("Set Password", textAlign: TextAlign.left),
        ),
        SizedBox(height: 5),

        AppTextField(
          controller: _passwordController,
          hintText: 'Enter your password',
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
        SizedBox(height: 16),
        Container(
          width: double.infinity,
          child: Text("Select Business Category", textAlign: TextAlign.left),
        ),
        SizedBox(height: 5),
        AppDropdown<String>(
          value: _selectedCompanyType,
          hintText: "Choose your country",
          items: [
            DropdownMenuItem(value: 'us', child: Text('United States')),
            DropdownMenuItem(value: 'in', child: Text('India')),
            DropdownMenuItem(value: 'uk', child: Text('United Kingdom')),
          ],
          onChanged: (value) {
            setState(() {
              _selectedCompanyType = value;
            });
          },
        ),
        SizedBox(height: 25),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: () {
        Get.to(MyprofileScreen());
        // Get.to(ProfileController());
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.buttonBg,
        minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text("Register", style: TextStyle(color: Colors.white)),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text("Or"),
        ),
        Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Column(
      children: [
        _socialButton("Continue with Google", "assets/google.png"),
        SizedBox(height: 12),
        _socialButton("Continue with Facebook", "assets/1.png"),
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
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(asset, height: 24),
          SizedBox(width: 12),
          Text(text, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Heading Image
  Widget _headingTitle() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            // Logo Image
            Image.asset('assets/headingImg.png', width: 210, height: 30),
            SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}
