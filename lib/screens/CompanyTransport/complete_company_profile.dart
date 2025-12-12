import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:country_picker/country_picker.dart';
import '../../controllers/complete_profile_controller.dart';
import '../../models/company_profilemodel.dart';
import '../../constants/apps_colors.dart';
import '../../utils/session_manager.dart';
import '../../widgets/custom_snackbar.dart';
import '../auth/login.dart';

class CompanyCompleteProfile extends StatefulWidget {
  const CompanyCompleteProfile({super.key});

  @override
  State<CompanyCompleteProfile> createState() => _CompanyCompleteProfileState();
}

class _CompanyCompleteProfileState extends State<CompanyCompleteProfile> {
  final CompleteProfileController profileController = Get.put(
    CompleteProfileController(),
  );

  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController fleetSizeController = TextEditingController();
  final TextEditingController gstController = TextEditingController();

  final String userId = Get.arguments?["userId"] ?? "";
  final Rx<Country> selectedCountry = Country.parse('IN').obs;

  @override
  void initState() {
    super.initState();
    // ✅ Pre-fill data from registration if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final registrationData = Get.arguments;
      if (registrationData != null) {
        // Pre-fill company name
        if (registrationData["companyName"] != null &&
            registrationData["companyName"].toString().isNotEmpty) {
          companyNameController.text = registrationData["companyName"]
              .toString();
        }
        // Pre-fill email
        if (registrationData["email"] != null &&
            registrationData["email"].toString().isNotEmpty) {
          emailController.text = registrationData["email"].toString();
        }
        // Pre-fill phone number
        if (registrationData["mobileNo"] != null &&
            registrationData["mobileNo"].toString().isNotEmpty) {
          phoneController.text = registrationData["mobileNo"].toString();
        }
      }
    });
  }

  @override
  void dispose() {
    companyNameController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    fleetSizeController.dispose();
    gstController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1C1E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Complete your Profile",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1C1E),
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF1A1C1E)),
            onPressed: () => Get.back(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Avatar Section
                Center(
                  child: Obx(
                    () => GestureDetector(
                      onTap: () => _showImagePickerOptions(context),
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: const Color(0xFFF5F5F5),
                            backgroundImage:
                                profileController.profileImage.value != null
                                ? FileImage(
                                    profileController.profileImage.value!,
                                  )
                                : null,
                            child: profileController.profileImage.value == null
                                ? const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Color(0xFF9E9E9E),
                                  )
                                : null,
                          ),
                          // Edit icon
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF25C5C),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.edit,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Company Name
                _buildInputField(
                  label: "Company Name",
                  hint: "Enter Company name",
                  controller: companyNameController,
                ),
                const SizedBox(height: 16),

                // First Name & Last Name (Side by side)
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        label: "First Name",
                        hint: "Enter first name",
                        controller: firstNameController,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInputField(
                        label: "Last Name",
                        hint: "Enter last name",
                        controller: lastNameController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Email
                _buildInputField(
                  label: "Email",
                  hint: "Enter your email",
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Phone Number
                _buildPhoneField(context),
                const SizedBox(height: 16),

                // Address
                _buildInputField(
                  label: "Address",
                  hint: "Enter your Address",
                  controller: addressController,
                  suffixIconData: Icons.location_off,
                ),
                const SizedBox(height: 16),

                // Fleet
                _buildInputField(
                  label: "Fleet Size",
                  hint: "No of vehicles",
                  controller: fleetSizeController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                // Company GST (Optional)
                _buildInputField(
                  label: "Company GST (Optional)",
                  hint: "Enter GST number (optional)",
                  controller: gstController,
                ),
                const SizedBox(height: 24),

                // Get in Now Button
                _buildRegisterButton(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    IconData? suffixIconData,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        Container(
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFEDF1F3)),
          ),
          child: TextField(
            controller: controller,
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
              suffixIcon: suffixIconData != null
                  ? Icon(
                      suffixIconData,
                      size: 16,
                      color: const Color(0xFF6C7278),
                    )
                  : null,
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
                        profileController.updateCountry(country);
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

  void _showImagePickerOptions(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFFF25C5C)),
              title: const Text("Take Photo"),
              onTap: () {
                profileController.pickImage(ImageSource.camera);
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Color(0xFFF25C5C),
              ),
              title: const Text("Choose from Gallery"),
              onTap: () {
                profileController.pickImage(ImageSource.gallery);
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.grey),
              title: const Text("Cancel"),
              onTap: () => Get.back(),
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
          onPressed: profileController.isLoading.value
              ? null
              : () async {
                  // ✅ Prevent multiple taps
                  if (profileController.isLoading.value) {
                    return;
                  }

                  // ✅ Validate form
                  if (!_validateForm()) {
                    return;
                  }

                  final model = CompleteProfileModel(
                    userId: userId,
                    firstName: firstNameController.text.trim(),
                    lastName: lastNameController.text.trim(),
                    email: emailController.text.trim(), // ✅ Added Email field
                    address: addressController.text.trim(),
                    fleetSize: fleetSizeController.text.trim(),
                    gstNumber: gstController.text.trim().isEmpty
                        ? null
                        : gstController.text.trim(),
                    companyLogo: profileController.profileImage.value,
                  );

                  final success = await profileController.submitProfile(
                    model,
                    userId,
                  );

                  if (success) {
                    await SessionManager.setProfileCompleted(true);

                    // ✅ Clear registration data from SessionManager after successful profile completion
                    final sessionManager = SessionManager();
                    await sessionManager.remove("registration_companyName");
                    await sessionManager.remove("registration_email");
                    await sessionManager.remove("registration_mobileNo");
                    await sessionManager.remove(
                      "registration_businessCategory",
                    );

                    SnackBarHelper.success(
                      "Profile completed successfully! Please login to continue.",
                    );

                    await Future.delayed(const Duration(milliseconds: 2000));

                    // ✅ Redirect to login page after complete profile
                    // User will login and then be redirected to correct screen based on userType
                    Get.offAll(() => const LoginScreen());
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
          child: profileController.isLoading.value
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  "Get in Now",
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

  bool _validateForm() {
    if (profileController.profileImage.value == null) {
      SnackBarHelper.error("Please select Company Logo");
      return false;
    }

    if (companyNameController.text.trim().isEmpty) {
      SnackBarHelper.error("Please enter Company Name");
      return false;
    }

    if (firstNameController.text.trim().isEmpty) {
      SnackBarHelper.error("Please enter First Name");
      return false;
    }

    if (lastNameController.text.trim().isEmpty) {
      SnackBarHelper.error("Please enter Last Name");
      return false;
    }

    if (emailController.text.trim().isEmpty) {
      SnackBarHelper.error("Please enter Email");
      return false;
    }

    if (phoneController.text.trim().isEmpty) {
      SnackBarHelper.error("Please enter Phone Number");
      return false;
    }

    if (addressController.text.trim().isEmpty) {
      SnackBarHelper.error("Please enter Address");
      return false;
    }

    if (fleetSizeController.text.trim().isEmpty) {
      SnackBarHelper.error("Please enter Fleet Size");
      return false;
    }

    final fleetSize = int.tryParse(fleetSizeController.text.trim());
    if (fleetSize == null || fleetSize <= 0) {
      SnackBarHelper.error("Fleet Size must be a valid number greater than 0");
      return false;
    }

    // ✅ GST is optional - only validate if provided
    final gstNumber = gstController.text.trim();
    if (gstNumber.isNotEmpty) {
      // Validate GST format only if user has entered something
      if (gstNumber.length != 15 ||
          !RegExp(r'^[0-9A-Z]{15}$').hasMatch(gstNumber.toUpperCase())) {
        SnackBarHelper.error(
          "GST Number must be 15 characters alphanumeric (or leave empty)",
        );
        return false;
      }
    }
    // ✅ If GST is empty, it's fine - field is optional

    return true;
  }
}
