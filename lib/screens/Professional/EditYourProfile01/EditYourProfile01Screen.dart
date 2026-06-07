import 'dart:io' show File;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

import '../../../controllers/Transport/user_profile_controller.dart';
import '../../../models/user_profile_model.dart';
import '../../../services/profile_service.dart';
import '../../../widgets/custom_snackbar.dart';
import '../../../widgets/custom_loader.dart';

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
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

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
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
    'Delhi',
    'Jammu and Kashmir',
    'Ladakh',
  ];

  final Map<String, List<String>> _citiesByState = {
    'Andhra Pradesh': [
      'Visakhapatnam',
      'Vijayawada',
      'Guntur',
      'Nellore',
      'Kurnool',
    ],
    'Arunachal Pradesh': ['Itanagar', 'Naharlagun', 'Tawang'],
    'Assam': ['Guwahati', 'Silchar', 'Dibrugarh', 'Jorhat', 'Nagaon'],
    'Bihar': ['Patna', 'Gaya', 'Bhagalpur', 'Muzaffarpur', 'Purnia'],
    'Chhattisgarh': ['Raipur', 'Bhilai', 'Bilaspur', 'Durg', 'Korba'],
    'Goa': ['Panaji', 'Margao', 'Vasco da Gama', 'Mapusa'],
    'Gujarat': [
      'Ahmedabad',
      'Surat',
      'Vadodara',
      'Rajkot',
      'Bhavnagar',
      'Jamnagar',
    ],
    'Haryana': ['Gurgaon', 'Faridabad', 'Panipat', 'Ambala', 'Karnal'],
    'Himachal Pradesh': ['Shimla', 'Mandi', 'Dharamshala', 'Solan'],
    'Jharkhand': ['Ranchi', 'Jamshedpur', 'Dhanbad', 'Bokaro', 'Hazaribagh'],
    'Karnataka': [
      'Bangalore',
      'Bengaluru',
      'Mysore',
      'Mysuru',
      'Hubli',
      'Mangalore',
      'Belgaum',
    ],
    'Kerala': [
      'Kochi',
      'Thiruvananthapuram',
      'Kozhikode',
      'Thrissur',
      'Kollam',
    ],
    'Madhya Pradesh': ['Bhopal', 'Indore', 'Gwalior', 'Jabalpur', 'Ujjain'],
    'Maharashtra': ['Mumbai', 'Pune', 'Nagpur', 'Nashik', 'Aurangabad'],
    'Manipur': ['Imphal', 'Thoubal', 'Bishnupur'],
    'Meghalaya': ['Shillong', 'Tura', 'Jowai'],
    'Mizoram': ['Aizawl', 'Lunglei', 'Saiha'],
    'Nagaland': ['Kohima', 'Dimapur', 'Mokokchung'],
    'Odisha': ['Bhubaneswar', 'Cuttack', 'Rourkela', 'Berhampur'],
    'Punjab': ['Ludhiana', 'Amritsar', 'Jalandhar', 'Patiala', 'Bathinda'],
    'Rajasthan': ['Jaipur', 'Jodhpur', 'Kota', 'Bikaner', 'Ajmer', 'Udaipur'],
    'Sikkim': ['Gangtok', 'Namchi', 'Mangan'],
    'Tamil Nadu': [
      'Chennai',
      'Coimbatore',
      'Madurai',
      'Tiruchirappalli',
      'Salem',
    ],
    'Telangana': ['Hyderabad', 'Warangal', 'Nizamabad', 'Karimnagar'],
    'Tripura': ['Agartala', 'Udaipur', 'Dharmanagar'],
    'Uttar Pradesh': [
      'Lucknow',
      'Kanpur',
      'Agra',
      'Varanasi',
      'Allahabad',
      'Noida',
      'Ghaziabad',
    ],
    'Uttarakhand': ['Dehradun', 'Haridwar', 'Roorkee', 'Haldwani'],
    'West Bengal': ['Kolkata', 'Howrah', 'Durgapur', 'Asansol', 'Siliguri'],
    'Delhi': ['New Delhi', 'Delhi', 'Dwarka', 'Saket', 'Rohini'],
    'Jammu and Kashmir': ['Srinagar', 'Jammu', 'Anantnag'],
    'Ladakh': ['Leh', 'Kargil'],
  };

  List<String> get _cityOptions {
    if (_selectedState == null) return [];
    final cities = List<String>.from(_citiesByState[_selectedState] ?? []);
    // If city from profile is not in the list, add it
    if (_selectedCity != null && !cities.contains(_selectedCity)) {
      cities.add(_selectedCity!);
    }
    return cities;
  }

  File? get _driverImageFile => _pickedDriverImage != null && !kIsWeb
      ? File(_pickedDriverImage!.path)
      : null;

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

      _profileWorker = ever<UserProfileModel?>(_profileController.userProfile, (
        profile,
      ) {
        if (!_hasPrefilled && profile != null) {
          _applyProfile(profile);
        }
      });
    });
  }

  void _applyProfile(UserProfileModel profile) {
    setState(() {
      _fullNameController.text = profile.name ?? '';
      _fatherNameController.text = profile.fatherName ?? '';
      _phoneController.text = profile.mobileNo ?? '';
      _whatsappController.text = profile.mobileNo ?? '';
      // description not yet in UserProfileModel — leave blank for first-time edit

      // Set state from profile - if not in list, add it temporarily
      _selectedState = profile.state;
      if (_selectedState != null && !_states.contains(_selectedState)) {
        // Add state to list if it's not there
        _states.add(_selectedState!);
      }

      // Set city from profile - will be handled in getter
      _selectedCity = profile.city;

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
    _phoneController.dispose();
    _whatsappController.dispose();
    _descriptionController.dispose();
    _profileWorker?.dispose();
    super.dispose();
  }

  Future<void> _pickDriverImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
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
        phoneNumber: _phoneController.text.trim(),
        whatsappNumber: _whatsappController.text.trim(),
        description: _descriptionController.text.trim(),
        driverImage: _driverImageFile,
      );

      SnackBarHelper.success("Profile updated successfully.");
      await _profileController.fetchCurrentUserProfile();
      // Navigate back to profile screen after successful update
      // Add small delay to ensure snackbar is shown and profile is refreshed
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context, true);
      } else if (mounted) {
        Get.back(result: true);
      }
    } catch (e) {
      SnackBarHelper.error("Failed to update profile: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: const Color(0xFFE5E7EB),
        centerTitle: true,
        title: Text(
          'Edit Profile',
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 16),
          child: Container(
            width: double.infinity,
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
                    alignment: Alignment.center,
                    children: [
                      GestureDetector(
                        onTap: _pickDriverImage,
                        child: Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFF36969),
                              width: 4,
                            ),
                            image:
                                _existingDriverImageUrl != null &&
                                    _existingDriverImageUrl!.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(
                                      _existingDriverImageUrl!,
                                    ),
                                    fit: BoxFit.cover,
                                    onError: (exception, stackTrace) {
                                      // Handle image load error
                                    },
                                  )
                                : _pickedDriverImage != null
                                ? DecorationImage(
                                    image: FileImage(
                                      File(_pickedDriverImage!.path),
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            color:
                                _existingDriverImageUrl == null ||
                                    _existingDriverImageUrl!.isEmpty
                                ? (_pickedDriverImage == null
                                      ? Colors.grey[200]
                                      : null)
                                : null,
                          ),
                          child:
                              (_existingDriverImageUrl == null ||
                                      _existingDriverImageUrl!.isEmpty) &&
                                  _pickedDriverImage == null
                              ? const Icon(
                                  Icons.person,
                                  size: 48,
                                  color: Colors.grey,
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: _pickDriverImage,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF36969),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.white,
                            ),
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
                      // Only clear city if it's not in the new state's city list
                      // But keep it if it was from profile (will be added to list by getter)
                      final cityOptions = _citiesByState[_selectedState] ?? [];
                      if (_selectedCity != null &&
                          !cityOptions.contains(_selectedCity) &&
                          _hasPrefilled) {
                        // Keep the city - it will be added to options by getter
                      } else if (_selectedCity != null &&
                          !cityOptions.contains(_selectedCity)) {
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
                _buildTextField(
                  controller: _phoneController,
                  label: 'Mobile Number',
                  hint: '+91 XXXXX XXXXX',
                  keyboardType: TextInputType.phone,
                  prefixIcon: Iconsax.call,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _whatsappController,
                  label: 'WhatsApp Number',
                  hint: '+91 XXXXX XXXXX',
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.chat_rounded,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _descriptionController,
                  label: 'About You (Optional)',
                  hint: 'Briefly describe your skills and experience…',
                  maxLines: 3,
                  prefixIcon: Iconsax.document_text,
                ),
                const SizedBox(height: 24),
                _buildImageUploadField(),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _submitProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF36969),
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
                            child: CustomLoader.small(color: Colors.white),
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
    IconData? prefixIcon,
    int maxLines = 1,
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
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 18, color: const Color(0xFF6C7278))
                : null,
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
                    value: enabled && value != null && options.contains(value)
                        ? value
                        : null,
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
        // Image Preview
        if (_pickedDriverImage != null ||
            (_existingDriverImageUrl != null &&
                _existingDriverImageUrl!.isNotEmpty))
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFEDF1F3)),
                    image: _pickedDriverImage != null
                        ? DecorationImage(
                            image: FileImage(File(_pickedDriverImage!.path)),
                            fit: BoxFit.cover,
                          )
                        : _existingDriverImageUrl != null &&
                              _existingDriverImageUrl!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(_existingDriverImageUrl!),
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) {
                              // Handle error
                            },
                          )
                        : null,
                    color: Colors.grey[200],
                  ),
                  child:
                      (_pickedDriverImage == null &&
                          (_existingDriverImageUrl == null ||
                              _existingDriverImageUrl!.isEmpty))
                      ? const Icon(Icons.image, size: 40, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _pickedDriverImage != null
                            ? _pickedDriverImage!.name
                            : 'Current profile image',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF424242),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _pickedDriverImage != null
                            ? 'Tap to change image'
                            : 'Tap to upload new image',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
                          ? 'Change image'
                          : (_existingDriverImageUrl != null &&
                                    _existingDriverImageUrl!.isNotEmpty
                                ? 'Change current image'
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
