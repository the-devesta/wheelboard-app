import 'dart:io' show File;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../controllers/user_profile_controller.dart';
import '../../../models/user_profile_model.dart';
import '../../../services/profile_service.dart';
import '../../../widgets/custom_snackbar.dart';

class EditYourProfile01Screen extends StatefulWidget {
  const EditYourProfile01Screen({super.key});

  @override
  State<EditYourProfile01Screen> createState() =>
      _EditYourProfile01ScreenState();
}

class _EditYourProfile01ScreenState extends State<EditYourProfile01Screen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _yearsOfExperienceController =
      TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final ProfileService _profileService = ProfileService();

  late UserProfileController _profileController;
  Worker? _profileWorker;

  String? _selectedState;
  String? _selectedCity;
  DateTime? _selectedDob;
  XFile? _pickedDriverImage;
  String? _existingDriverImageUrl;
  bool _isSaving = false;
  bool _hasPrefilled = false;

  final List<String> _states = [
    'Delhi',
    'Uttar Pradesh',
    'Maharashtra',
    'Karnataka',
    'Gujarat',
  ];

  final Map<String, List<String>> _citiesByState = {
    'Delhi': ['New Delhi', 'Dwarka', 'Saket', 'Rohini'],
    'Uttar Pradesh': ['Noida', 'Ghaziabad', 'Lucknow', 'Kanpur'],
    'Maharashtra': ['Mumbai', 'Pune', 'Nagpur', 'Nashik'],
    'Karnataka': ['Bengaluru', 'Mysuru', 'Mangalore'],
    'Gujarat': ['Ahmedabad', 'Surat', 'Vadodara'],
  };

  List<String> get _cityOptions =>
      _selectedState != null ? (_citiesByState[_selectedState] ?? []) : [];

  File? get _driverImageFile =>
      _pickedDriverImage != null && !kIsWeb ? File(_pickedDriverImage!.path) : null;

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
      _fullNameController.text = profile.name ?? '';
      _fatherNameController.text = profile.fatherName ?? '';
      _selectedState = profile.state;

      if (_selectedState != null && !_states.contains(_selectedState)) {
        _selectedState = null;
      }

      _selectedCity =
          _cityOptions.contains(profile.city) ? profile.city : null;
      _existingDriverImageUrl = profile.profileImagePath;

      if (profile.dateOfBirth != null) {
        final parsed = DateTime.tryParse(profile.dateOfBirth!);
        if (parsed != null) {
          _selectedDob = parsed;
          _birthDateController.text = _formatDate(parsed);
        }
      }

      _hasPrefilled = true;
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _fatherNameController.dispose();
    _yearsOfExperienceController.dispose();
    _birthDateController.dispose();
    _profileWorker?.dispose();
    super.dispose();
  }

  Future<void> _pickDriverImage() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (image != null) {
      setState(() {
        _pickedDriverImage = image;
        _existingDriverImageUrl = null;
      });
    }
  }

  Future<void> _submitProfile() async {
    if (_isSaving) return;

    final userId = _profileController.userProfile.value?.userId ?? '';
    if (userId.isEmpty) {
      SnackBarHelper.error("User ID not found. Please login again.");
      return;
    }

    if (_fullNameController.text.trim().isEmpty ||
        _fatherNameController.text.trim().isEmpty ||
        _selectedDob == null ||
        _selectedState == null ||
        _selectedCity == null) {
      SnackBarHelper.warning("Please complete all required fields.");
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _profileService.updateProfessionalProfile(
        userId: userId,
        fullName: _fullNameController.text.trim(),
        fathersName: _fatherNameController.text.trim(),
        yearsOfExperience: _yearsOfExperienceController.text.trim().isEmpty
            ? '0'
            : _yearsOfExperienceController.text.trim(),
        birthDateIso: _selectedDob!.toIso8601String(),
        state: _selectedState ?? '',
        city: _selectedCity ?? '',
        driverImage: _driverImageFile,
      );

      SnackBarHelper.success("Profile updated successfully.");
      await _profileController.fetchCurrentUserProfile();
      Get.back();
    } catch (e) {
      SnackBarHelper.error("Failed to update profile: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4E3E3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Edit Your Profile',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E1E1E),
            letterSpacing: -0.14,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E1E1E)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFF36969),
                            width: 4,
                          ),
                          color: Colors.grey[200],
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 48,
                          color: Colors.grey,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF36969),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _buildTextField(
                  controller: _fullNameController,
                  label: 'Full Name',
                  hint: 'Enter your full name',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _fatherNameController,
                  label: 'Father\'s name',
                  hint: 'Enter father\'s name',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _yearsOfExperienceController,
                  label: 'Years Of Experience',
                  hint: 'Eg. 6',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildDateField(),
                const SizedBox(height: 24),
                _buildDropdownField(
                  label: 'Select State',
                  value: _selectedState,
                  hint: 'Select state',
                  icon: Icons.location_on,
                  options: _states,
                  onChanged: (value) {
                    setState(() {
                      _selectedState = value;
                      if (!_cityOptions.contains(_selectedCity)) {
                        _selectedCity = null;
                      }
                    });
                  },
                ),
                const SizedBox(height: 24),
                _buildDropdownField(
                  label: 'Select City',
                  value: _selectedCity,
                  hint: 'Select city',
                  icon: Icons.location_city,
                  options: _cityOptions,
                  onChanged: (value) {
                    setState(() {
                      _selectedCity = value;
                    });
                  },
                  enabled: _selectedState != null,
                ),
                const SizedBox(height: 24),
                _buildImageUploadField(),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _submitProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF25C5C),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Save Now',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: -0.14,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFF36969),
          ),
        ),
        const SizedBox(height: 2),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF6C7278),
            ),
            filled: true,
            fillColor: Colors.white,
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
          ),
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Birth of date',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFF36969),
          ),
        ),
        const SizedBox(height: 2),
        TextField(
          controller: _birthDateController,
          readOnly: true,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDob ?? DateTime.now(),
              firstDate: DateTime(1950),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              setState(() {
                _selectedDob = date;
                _birthDateController.text = _formatDate(date);
              });
            }
          },
          decoration: InputDecoration(
            hintText: 'DD/MM/YYYY',
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF6C7278),
            ),
            filled: true,
            fillColor: Colors.white,
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            suffixIcon: const Icon(
              Icons.calendar_today,
              size: 16,
              color: Color(0xFFACB5BB),
            ),
          ),
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required String hint,
    required IconData icon,
    required List<String> options,
    required Function(String?) onChanged,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFF36969),
              ),
            ),
            Text(
              '*',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFFFF5E5E),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 51,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFEDF1F3)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(icon, size: 18, color: const Color(0xFF6C7278)),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    value: enabled && options.contains(value) ? value : null,
                    isExpanded: true,
                    underline: const SizedBox(),
                    hint: Text(
                      hint,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: const Color(0xFF6C7278),
                      ),
                    ),
                    items: options
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Text(
                              item,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: enabled ? onChanged : null,
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  size: 15,
                  color: Color(0xFF6C7278),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageUploadField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 4,
          runSpacing: 2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Upload Driver Image',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFF36969),
              ),
            ),
            Text(
              '*',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFFFF5E5E),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'JPG/PNG, max 2MB',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF888888),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickDriverImage,
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  border: Border.all(color: const Color(0xFFEDF1F3)),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.upload_file,
                  size: 24,
                  color: Color(0xFF888888),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Container(
                  height: 37,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    border: Border.all(color: const Color(0xFFEDF1F3)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      _pickedDriverImage != null
                          ? _pickedDriverImage!.name
                          : (_existingDriverImageUrl != null
                              ? 'Current image selected'
                              : 'Tap to upload image'),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF888888),
                      ),
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

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }
}

