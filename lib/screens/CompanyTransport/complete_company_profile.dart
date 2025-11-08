import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/complete_profile_controller.dart';
import '../../models/company_profilemodel.dart';
import '../../constants/apps_colors.dart';
import 'package:wheelboard/CommonWidget/app_textfield.dart';
import '../../utils/session_manager.dart';
import '../../utils/navigation_helper.dart';
import '../../widgets/custom_snackbar.dart';

class CompanyCompleteProfile extends StatefulWidget {
  const CompanyCompleteProfile({super.key});

  @override
  State<CompanyCompleteProfile> createState() => _CompanyCompleteProfileState();
}

class _CompanyCompleteProfileState extends State<CompanyCompleteProfile> {
  final CompleteProfileController profileController = Get.put(
    CompleteProfileController(),
  );

  // 🔹 Text controllers for form fields
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController fleetSizeController = TextEditingController();
  final TextEditingController gstController = TextEditingController();
  final String userId = Get.arguments["userId"];

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
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text("Complete Your Profile"),
        actions: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        color: AppColors.primary,
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // 👤 Profile Image / Company Logo
                Column(
                  children: [
                    Obx(() {
                      return GestureDetector(
                        onTap: () => _showImagePickerOptions(context),
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage:
                                  profileController.profileImage.value != null
                                  ? FileImage(profileController.profileImage.value!)
                                  : null,
                              child: profileController.profileImage.value == null
                                  ? const Icon(
                                      Icons.camera_alt,
                                      size: 40,
                                      color: Colors.grey,
                                    )
                                  : null,
                            ),
                            if (profileController.profileImage.value != null)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    Text(
                      "Company Logo*",
                      style: TextStyle(
                        fontSize: 14,
                        color: profileController.profileImage.value == null 
                            ? Colors.red 
                            : Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (profileController.profileImage.value != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          "Image selected ✓",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // // 📋 Company Name
                // _buildLabel("Company Name"),
                // AppTextField(
                //   controller: companyNameController,
                //   hintText: 'Enter company name',
                // ),
                // const SizedBox(height: 16),

                // 👤 First + Last Name
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("First Name"),
                          AppTextField(
                            controller: firstNameController,
                            hintText: "First Name",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Last Name"),
                          AppTextField(
                            controller: lastNameController,
                            hintText: "Last Name",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // // 📧 Email
                // _buildLabel("Email"),
                // AppTextField(
                //   controller: emailController,
                //   hintText: 'Enter your email',
                // ),
                // const SizedBox(height: 16),

                // // 📞 Phone
                // _buildLabel("Phone number"),
                // AppTextField(
                //   controller: phoneController,
                //   hintText: "Enter your number",
                //   keyboardType: TextInputType.phone,
                //   prefixIcon: GestureDetector(
                //     onTap: () {
                //       showCountryPicker(
                //         context: context,
                //         showPhoneCode: true,
                //         onSelect: (Country country) {
                //           profileController.updateCountry(country);
                //         },
                //       );
                //     },
                //     child: Obx(
                //       () => Container(
                //         width: 80,
                //         padding: const EdgeInsets.only(left: 8, right: 4),
                //         child: Row(
                //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //           children: [
                //             Text(profileController.selectedDialCode.value),
                //             const Icon(Icons.arrow_drop_down),
                //           ],
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                // const SizedBox(height: 16),

                // 🏠 Address
                _buildLabel("Address"),
                AppTextField(
                  controller: addressController,
                  hintText: "Enter your Address",
                ),
                const SizedBox(height: 16),

                // 🚚 Fleet
                _buildLabel("Fleet"),
                AppTextField(
                  controller: fleetSizeController,
                  hintText: "No of Fleet Size",
                ),
                const SizedBox(height: 16),

                // 🧾 GST
                AppTextField(
                  controller: gstController,
                  hintText: "Company GST (Optional)",
                ),

                const SizedBox(height: 25),

                // 🔘 Register Button
                _buildRegisterButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: const TextStyle(fontSize: 16)),
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
              leading: const Icon(Icons.camera_alt),
              title: const Text("Take Photo"),
              onTap: () {
                profileController.pickImage(ImageSource.camera);
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choose from Gallery"),
              onTap: () {
                profileController.pickImage(ImageSource.gallery);
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return Obx(() {
      return ElevatedButton(
        onPressed: profileController.isLoading.value ? null : () async {
          // ✅ Validation
          if (!_validateForm()) {
            return;
          }

          final model = CompleteProfileModel(
            userId: userId,
            firstName: firstNameController.text.trim(),
            lastName: lastNameController.text.trim(),
            address: addressController.text.trim(),
            fleetSize: fleetSizeController.text.trim(),
            gstNumber: gstController.text.trim().isEmpty ? null : gstController.text.trim(),
            companyLogo: profileController.profileImage.value,
          );

          final success = await profileController.submitProfile(model, userId);

          if (success) {
            await SessionManager.setProfileCompleted(true);
            SnackBarHelper.success("Profile completed successfully!");
            
            // Wait for snackbar to be visible
            await Future.delayed(const Duration(milliseconds: 2000));
            
            // Navigate to main wrapper after profile completion
            NavigationHelper.navigateToMainWrapper();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonBg,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: profileController.isLoading.value
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("Get in now", style: TextStyle(color: Colors.white)),
      );
    });
  }

  bool _validateForm() {
    // ✅ Validate Company Logo (Required)
    if (profileController.profileImage.value == null) {
      SnackBarHelper.error("Please select Company Logo (CompanyLogo field is required)");
      return false;
    }

    // Validate First Name
    if (firstNameController.text.trim().isEmpty) {
      SnackBarHelper.error("Please enter First Name");
      return false;
    }

    // Validate Last Name
    if (lastNameController.text.trim().isEmpty) {
      SnackBarHelper.error("Please enter Last Name");
      return false;
    }

    // Validate Address
    if (addressController.text.trim().isEmpty) {
      SnackBarHelper.error("Please enter Address");
      return false;
    }

    // Validate Fleet Size
    if (fleetSizeController.text.trim().isEmpty) {
      SnackBarHelper.error("Please enter Fleet Size");
      return false;
    }

    // Validate Fleet Size is a number
    final fleetSize = int.tryParse(fleetSizeController.text.trim());
    if (fleetSize == null || fleetSize <= 0) {
      SnackBarHelper.error("Fleet Size must be a valid number greater than 0");
      return false;
    }

    // Validate GST Number format if provided (optional but if provided should be valid)
    final gstNumber = gstController.text.trim();
    if (gstNumber.isNotEmpty) {
      // GST format: 15 characters alphanumeric
      if (gstNumber.length != 15 || !RegExp(r'^[0-9A-Z]{15}$').hasMatch(gstNumber.toUpperCase())) {
        SnackBarHelper.error("GST Number must be 15 characters alphanumeric");
        return false;
      }
    }

    return true;
  }
}
