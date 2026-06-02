import 'dart:io' show File;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../models/user_profile_model.dart';
import '../../widgets/custom_snackbar.dart';
import 'user_profile_controller.dart';
import '../../utils/app_logger.dart';

class CompanyProfileController extends GetxController {
  final UserProfileController _profileController =
      Get.find<UserProfileController>();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController businessCategoryController =
      TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController fleetSizeController = TextEditingController();
  final TextEditingController gstController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();

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
    _profileWorker = ever<UserProfileModel?>(_profileController.userProfile, (
      profile,
    ) {
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
      locationController.text =
          profile.address ?? profile.city ?? profile.state ?? '';
      fleetSizeController.text = profile.fleetSize ?? '';
      gstController.text = profile.gstNumber ?? '';
      phoneController.text = profile.mobileNo ?? '';
      whatsappController.text = profile.mobileNo ?? ''; // same default
      _existingLogoUrl.value = profile.companyLogoPath;
    } catch (e) {
      // Controller was disposed, ignore the error
      AppLogger.d("⚠️ Controller disposed, skipping profile application: $e");
    }
  }

  Future<void> pickLogo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (image != null) {
      _pickedLogo.value = image;
      _existingLogoUrl.value = null;
    }
  }

  Future<void> saveProfile() async {
    if (isSaving.value) return;

    final userId =
        _userId ?? _profileController.userProfile.value?.userId ?? '';

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
      final phone = phoneController.text.trim();
      final whatsapp = whatsappController.text.trim();
      final description = descriptionController.text.trim();
      final website = websiteController.text.trim();

      final formData = dio.FormData.fromMap({
        'UserId': userId,
        'CompanyName': companyName,
        'FullName': fullName,
        'Email': email,
        'Location': location,
        'FleetSize': fleetSize.isEmpty ? '0' : fleetSize,
        'GSTNumber': gstNumber,
        if (phone.isNotEmpty) 'PhoneNumber': phone,
        if (whatsapp.isNotEmpty) 'WhatsappNumber': whatsapp,
        if (description.isNotEmpty) 'Description': description,
        if (website.isNotEmpty) 'Website': website,
      });

      if (logoFile != null) {
        formData.files.add(MapEntry(
          'CompanyLogo',
          await dio.MultipartFile.fromFile(logoFile!.path),
        ));
      }

      await ApiClient.instance.upload<dynamic>(
        ApiEndpoints.users.updateTransportProfile,
        formData: formData,
      );

      AppLogger.d("✅ Profile updated successfully.");
      SnackBarHelper.success("Profile updated successfully.");
      await _profileController.fetchCurrentUserProfile();
      // Navigation will be handled by screen level listener
      // No need to navigate from controller
    } on dio.DioException catch (e) {
      AppLogger.d("❌ An error occurred while updating profile: $e");
      final msg = e.error is ApiException ? (e.error as ApiException).message : 'Failed to update profile';
      SnackBarHelper.error("Failed to update profile: $msg");
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
    phoneController.dispose();
    whatsappController.dispose();
    descriptionController.dispose();
    websiteController.dispose();
    super.onClose();
  }
}
