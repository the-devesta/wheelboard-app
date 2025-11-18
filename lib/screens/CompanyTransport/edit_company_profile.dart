import 'dart:io' show File;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/user_profile_controller.dart';
import '../../models/user_profile_model.dart';
import '../../services/profile_service.dart';
import '../../widgets/custom_snackbar.dart';

class EditCompanyProfileScreen extends StatefulWidget {
  const EditCompanyProfileScreen({super.key});

  @override
  State<EditCompanyProfileScreen> createState() =>
      _EditCompanyProfileScreenState();
}

class _EditCompanyProfileScreenState extends State<EditCompanyProfileScreen> {
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _businessCategoryController =
      TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _fleetSizeController = TextEditingController();
  final TextEditingController _gstController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final ProfileService _profileService = ProfileService();

  late UserProfileController _profileController;
  Worker? _profileWorker;
  bool _hasPrefilled = false;

  bool _isSaving = false;
  XFile? _pickedLogo;
  String? _existingLogoUrl;
  String? _userId;

  File? get _logoFile =>
      _pickedLogo != null && !kIsWeb ? File(_pickedLogo!.path) : null;

  @override
  void initState() {
    super.initState();
    _profileController = Get.put(UserProfileController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = _profileController.userProfile.value;
      if (profile != null) {
        _applyProfile(profile);
      } else {
        _profileController.fetchCurrentUserProfile();
      }

      _profileWorker = ever<UserProfileModel?>(
        _profileController.userProfile,
        (profile) {
          if (!_hasPrefilled && profile != null) {
            _applyProfile(profile);
          }
        },
      );
    });
  }

  void _applyProfile(UserProfileModel profile) {
    setState(() {
      _userId = profile.userId;
      _companyNameController.text = profile.companyName ?? '';
      _fullNameController.text = profile.name ?? '';
      _emailController.text = profile.email ?? '';
      _businessCategoryController.text = profile.businessCategory ?? '';
      _locationController.text = profile.city ?? profile.state ?? '';
      if (_fleetSizeController.text.isEmpty) {
        _fleetSizeController.text = '';
      }
      _gstController.text = profile.gstNumber ?? '';
      _existingLogoUrl = profile.companyLogoPath;
      _hasPrefilled = true;
    });
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _businessCategoryController.dispose();
    _locationController.dispose();
    _fleetSizeController.dispose();
    _gstController.dispose();
    _profileWorker?.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (image != null) {
      setState(() {
        _pickedLogo = image;
        _existingLogoUrl = null;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_isSaving) return;

    final userId =
        _userId ?? _profileController.userProfile.value?.userId ?? '';

    if (userId.isEmpty) {
      SnackBarHelper.error("User ID not found. Please login again.");
      return;
    }

    final companyName = _companyNameController.text.trim();
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final location = _locationController.text.trim();
    final fleetSize = _fleetSizeController.text.trim();
    final gstNumber = _gstController.text.trim();

    if (companyName.isEmpty ||
        fullName.isEmpty ||
        email.isEmpty ||
        location.isEmpty) {
      SnackBarHelper.warning("Please fill all required fields.");
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _profileService.updateTransportProfile(
        userId: userId,
        companyName: companyName,
        fullName: fullName,
        email: email,
        location: location,
        fleetSize: fleetSize.isEmpty ? '0' : fleetSize,
        gstNumber: gstNumber,
        companyLogo: _logoFile,
      );

      SnackBarHelper.success("Profile updated successfully.");
      await _profileController.fetchCurrentUserProfile();
      Get.back();
    } catch (e) {
      SnackBarHelper.error("Failed to update profile: $e");
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4E3E3),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    const Text(
                      'Register as',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF535353),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildFormCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 91,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFFCD2D2), width: 1),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 24,
            top: 55,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: const Icon(Icons.arrow_back, color: Color(0xFF1E1E1E)),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 51),
              child: Text(
                'EDIT Your Profile',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E1E1E),
                  letterSpacing: -0.14,
                ),
              ),
            ),
          ),
          Positioned(
            right: 20,
            top: 51,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: const Icon(Icons.close, color: Color(0xFF1E1E1E)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildLogoPicker(),
          const SizedBox(height: 24),
          _buildTextField(
            label: "Company Name",
            controller: _companyNameController,
            hint: "Enter Company name",
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: "Full Name",
            controller: _fullNameController,
            hint: "Enter your name",
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: "Email",
            controller: _emailController,
            hint: "Enter your email",
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: "Enter Business Category",
            controller: _businessCategoryController,
            hint: "Enter Business...",
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: "Location",
            controller: _locationController,
            hint: "Current location",
          ),
          const SizedBox(height: 16),
                      _buildTextField(
            label: "Fleet",
            controller: _fleetSizeController,
            hint: "No of Fleet Size",
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: "Company GST (Optional)",
            controller: _gstController,
            hint: "Company GST(Optional)",
          ),
          const SizedBox(height: 24),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _isSaving ? null : _saveProfile,
      child: Container(
        height: 48,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white, width: 0.8),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFF8B8B),
              Color(0xFFF25C5C),
            ],
          ),
        ),
        child: Center(
          child: _isSaving
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Save Now',
                  style: TextStyle(
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

  Widget _buildLogoPicker() {
    ImageProvider? imageProvider;
    if (_logoFile != null) {
      imageProvider = FileImage(_logoFile!);
    } else if (_existingLogoUrl != null && _existingLogoUrl!.isNotEmpty) {
      imageProvider = NetworkImage(_existingLogoUrl!);
    }

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFF36969), width: 4),
            color: Colors.grey.shade200,
            image: imageProvider != null
                ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
                : null,
          ),
          child: imageProvider == null
              ? const Icon(Icons.business, size: 40, color: Colors.grey)
              : null,
        ),
        Positioned(
          bottom: 6,
          right: 8,
          child: GestureDetector(
            onTap: _pickLogo,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF36969),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty)
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6C7278),
                letterSpacing: -0.24,
              ),
            ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6C7278),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFEDF1F3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFEDF1F3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFF36969)),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
