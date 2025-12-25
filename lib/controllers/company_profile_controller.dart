import 'dart:io' show File;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../apihelperclass/api_helper.dart';
import '../models/user_profile_model.dart';
import '../utils/constants.dart';
import '../widgets/custom_snackbar.dart';
import 'user_profile_controller.dart';
import '../utils/app_logger.dart';

class CompanyProfileController extends GetxController {
  final UserProfileController _profileController = Get.find<UserProfileController>();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController businessCategoryController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController fleetSizeController = TextEditingController();
  final TextEditingController gstController = TextEditingController();

  final Rx<XFile?> _pickedLogo = Rx<XFile?>(null);
  XFile? get pickedLogo => _pickedLogo.value;

  final Rx<String?> _existingLogoUrl = Rx<String?>(null);
  String? get existingLogoUrl => _existingLogoUrl.value;

  final Rx<bool> isSaving = Rx<bool>(false);
  String? _userId;

  File? get logoFile =>
      pickedLogo != null && !kIsWeb ? File(pickedLogo!.path) : null;

  Worker? _profileWorker;

  @override
  void onInit() {
    super.onInit();
    // Listen to changes in userProfile and pre-fill the form
    _profileWorker = ever<UserProfileModel?>(_profileController.userProfile, (profile) {
      if (profile != null && !isClosed) {
        _applyProfile(profile);
      }
    });

    // If profile is already available, pre-fill the form
    if (_profileController.userProfile.value != null && !isClosed) {
      _applyProfile(_profileController.userProfile.value!);
    } else {
      _profileController.fetchCurrentUserProfile();
    }
  }

  void _applyProfile(UserProfileModel profile) {
    // Check if controller is still valid before accessing TextEditingControllers
    if (isClosed) return;
    
    try {
      _userId = profile.userId;
      companyNameController.text = profile.companyName ?? '';
      fullNameController.text = profile.fullName ?? profile.name ?? '';
      emailController.text = profile.email ?? '';
      businessCategoryController.text = profile.businessCategory ?? '';
      locationController.text = profile.address ?? profile.city ?? profile.state ?? '';
      fleetSizeController.text = profile.fleetSize ?? '';
      gstController.text = profile.gstNumber ?? '';
      _existingLogoUrl.value = profile.companyLogoPath;
    } catch (e) {
      // Controller was disposed, ignore the error
      AppLogger.d("⚠️ Controller disposed, skipping profile application: $e");
    }
  }

  Future<void> pickLogo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (image != null) {
      _pickedLogo.value = image;
      _existingLogoUrl.value = null;
    }
  }

  Future<void> saveProfile() async {
    if (isSaving.value) return;

    final userId = _userId ?? _profileController.userProfile.value?.userId ?? '';

    if (userId.isEmpty) {
      SnackBarHelper.error("User ID not found. Please login again.");
      return;
    }

    final companyName = companyNameController.text.trim();
    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final location = locationController.text.trim();
    final fleetSize = fleetSizeController.text.trim();
    final gstNumber = gstController.text.trim();

    if (companyName.isEmpty ||
        fullName.isEmpty ||
        email.isEmpty ||
        location.isEmpty) {
      SnackBarHelper.warning("Please fill all required fields.");
      return;
    }

    isSaving.value = true;
    AppLogger.d("🔄 Updating company profile...");
    try {
      final response = await HttpHelper.uploadMultipart(
        endpoint: API.updateTransportProfile,
        fields: {
          'UserId': userId,
          'CompanyName': companyName,
          'FullName': fullName,
          'Email': email,
          'Location': location,
          'FleetSize': fleetSize.isEmpty ? '0' : fleetSize,
          'GSTNumber': gstNumber,
        },
        files: logoFile != null ? [logoFile!] : [],
        fieldKey: 'CompanyLogo',
      );
      final resolved = await http.Response.fromStream(response);
      AppLogger.d("✅ API Response Status: ${resolved.statusCode}");
      AppLogger.d("✅ API Response Body: ${resolved.body}");
      if (resolved.statusCode >= 200 && resolved.statusCode < 300) {
        AppLogger.d("✅ Profile updated successfully.");
        SnackBarHelper.success("Profile updated successfully.");
        await _profileController.fetchCurrentUserProfile();
        // Navigation will be handled by screen level listener
        // No need to navigate from controller
      } else {
        AppLogger.d("❌ Failed to update profile. Status Code: ${resolved.statusCode}");
        AppLogger.d("❌ Response Body: ${resolved.body}");
        throw Exception(
            'Failed to update profile (${resolved.statusCode}): ${resolved.body}');
      }
    } catch (e) {
      AppLogger.d("❌ An error occurred while updating profile: $e");
      SnackBarHelper.error("Failed to update profile: $e");
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    // Dispose the worker first to prevent callbacks after disposal
    _profileWorker?.dispose();
    
    // Dispose controllers
    companyNameController.dispose();
    fullNameController.dispose();
    emailController.dispose();
    businessCategoryController.dispose();
    locationController.dispose();
    fleetSizeController.dispose();
    gstController.dispose();
    super.onClose();
  }
}
