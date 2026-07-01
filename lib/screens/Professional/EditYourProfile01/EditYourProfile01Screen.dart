import 'dart:io' show File;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

import '../../../controllers/Transport/user_profile_controller.dart';
import '../../../core/auth/auth_service.dart';
import '../../../services/profile_service.dart';
import '../../../services/firebase_storage_service.dart';
import '../../../theme/design_system.dart';
import '../../../widgets/custom_snackbar.dart';

/// Professional "Edit Profile" — a 1:1 port of the web `/professional/profile`
/// inline edit (`userAPI.updateProfile` → `PUT /users/profile`).
///
/// Editable fields mirror the web exactly: profile image, First/Last name,
/// Location (address), Vehicle Type, Experience, License Number, Date of Birth,
/// Mobile, Email, WhatsApp. City / State / Zip / Description / Skills are not
/// edited here (web doesn't expose them) but are preserved on save so we never
/// blank them out. The old Father's-name + required State/City dropdown form has
/// been removed.
class EditYourProfile01Screen extends StatefulWidget {
  const EditYourProfile01Screen({super.key});

  @override
  State<EditYourProfile01Screen> createState() =>
      _EditYourProfile01ScreenState();
}

class _EditYourProfile01ScreenState extends State<EditYourProfile01Screen> {
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController(); // address
  final _vehicleTypeCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController();
  final _licenseCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final ProfileService _profileService = ProfileService();
  late final UserProfileController _profileController;

  DateTime? _selectedDob;
  XFile? _pickedImage;
  String? _existingImageUrl;
  bool _isSaving = false;

  // Preserved (not edited here, sent unchanged — web parity).
  String? _city;
  String? _state;
  String? _zipCode;
  String? _description;
  List<dynamic>? _skills;

  @override
  void initState() {
    super.initState();
    _profileController = Get.put(UserProfileController());
    _prefillFromUser();
  }

  /// Mirrors the web `fetchProfile`: read `userData.profile` (the raw map) for
  /// every field. Falls back to splitting `fullName`/`name` when first/last are
  /// not stored separately.
  void _prefillFromUser() {
    final user = AuthService.to.user;
    final p = user?.profile ?? const <String, dynamic>{};
    String s(dynamic v) => v?.toString() ?? '';

    var first = s(p['firstName']);
    var last = s(p['lastName']);
    if (first.isEmpty && last.isEmpty) {
      final full = s(p['fullName']).isNotEmpty ? s(p['fullName']) : s(p['name']);
      final parts = full.trim().split(RegExp(r'\s+'));
      if (parts.isNotEmpty && parts.first.isNotEmpty) {
        first = parts.first;
        last = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      }
    }

    _firstNameCtrl.text = first;
    _lastNameCtrl.text = last;
    _locationCtrl.text = s(p['address']);
    _vehicleTypeCtrl.text =
        s(p['vehicleType']).isNotEmpty ? s(p['vehicleType']) : 'Driver';
    final exp = p['experience'];
    _experienceCtrl.text =
        (exp == null || s(exp) == '0') ? '' : s(exp);
    _licenseCtrl.text = s(p['licenseNumber']);
    _phoneCtrl.text =
        s(p['phoneNumber']).isNotEmpty ? s(p['phoneNumber']) : s(user?.phoneNumber);
    _emailCtrl.text = s(user?.email).isNotEmpty ? s(user?.email) : s(p['email']);
    _whatsappCtrl.text = s(p['whatsappNumber']);

    final dobRaw = s(p['dateOfBirth']);
    if (dobRaw.isNotEmpty) {
      final parsed = DateTime.tryParse(dobRaw);
      if (parsed != null) {
        _selectedDob = parsed;
        _dobCtrl.text = _formatDate(parsed);
      }
    }

    _existingImageUrl = s(p['avatar']).isNotEmpty
        ? s(p['avatar'])
        : (s(p['profileImage']).isNotEmpty ? s(p['profileImage']) : null);

    // Preserved fields.
    _city = s(p['city']).isNotEmpty ? s(p['city']) : null;
    _state = s(p['state']).isNotEmpty ? s(p['state']) : null;
    _zipCode = s(p['zipCode']).isNotEmpty ? s(p['zipCode']) : null;
    _description = s(p['description']).isNotEmpty ? s(p['description']) : null;
    _skills = p['skills'] is List ? p['skills'] as List : null;
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _locationCtrl.dispose();
    _vehicleTypeCtrl.dispose();
    _experienceCtrl.dispose();
    _licenseCtrl.dispose();
    _dobCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _whatsappCtrl.dispose();
    super.dispose();
  }

  File? get _imageFile =>
      _pickedImage != null && !kIsWeb ? File(_pickedImage!.path) : null;

  Future<void> _pickImage([ImageSource source = ImageSource.gallery]) async {
    final image = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
    }
  }

  void _showPhotoSourceSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppPalette.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Iconsax.camera, color: AppPalette.primary),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(sheetCtx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.gallery, color: AppPalette.primary),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(sheetCtx);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_isSaving) return;

    if (_firstNameCtrl.text.trim().isEmpty) {
      SnackBarHelper.warning('Please enter your first name.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      String? imageBase64;
      final file = _imageFile;
      if (file != null) {
        imageBase64 = await FirebaseStorageService.uploadProfileImage(file);
        if (imageBase64.isEmpty) {
          SnackBarHelper.error('Could not upload the selected photo. Please try again.');
          setState(() => _isSaving = false);
          return;
        }
      }

      final experience = int.tryParse(_experienceCtrl.text.trim());

      // Build the same `profile` payload the web sends in handleSave().
      final profile = <String, dynamic>{
        'firstName': _firstNameCtrl.text.trim(),
        'lastName': _lastNameCtrl.text.trim(),
        'fullName':
            '${_firstNameCtrl.text.trim()} ${_lastNameCtrl.text.trim()}'.trim(),
        'phoneNumber': _phoneCtrl.text.trim(),
        'whatsappNumber': _whatsappCtrl.text.trim(),
        if (_selectedDob != null)
          'dateOfBirth': _selectedDob!.toIso8601String(),
        'address': _locationCtrl.text.trim(),
        if (_city != null) 'city': _city,
        if (_state != null) 'state': _state,
        if (_zipCode != null) 'zipCode': _zipCode,
        'licenseNumber': _licenseCtrl.text.trim(),
        'vehicleType': _vehicleTypeCtrl.text.trim(),
        if (experience != null) 'experience': experience,
        if (_description != null) 'description': _description,
        if (_skills != null) 'skills': _skills,
      };

      await _profileService.updateProfile(
        profile: profile,
        profileImageBase64: imageBase64,
        email: _emailCtrl.text.trim().isNotEmpty ? _emailCtrl.text.trim() : null,
      );

      SnackBarHelper.success('Professional profile updated successfully.');

      // Refresh both the auth user (raw map) and the profile controller so the
      // YourProfile screen reflects the changes immediately.
      await AuthService.to.refreshLoginStatus();
      await _profileController.fetchCurrentUserProfile();

      if (mounted) Get.back(result: true);
    } catch (e) {
      SnackBarHelper.error('Failed to update profile: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.bg,
      appBar: AppBar(
        backgroundColor: AppPalette.card,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppPalette.border,
        centerTitle: true,
        title: Text('Edit Profile', style: AppText.h2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: AppPalette.textDark),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _avatar(),
            AppSpacing.vGapLg,
            _sectionCard('Personal Details', [
              Row(children: [
                Expanded(
                    child: _field('First Name', _firstNameCtrl,
                        hint: 'First name')),
                AppSpacing.hGapMd,
                Expanded(
                    child:
                        _field('Last Name', _lastNameCtrl, hint: 'Last name')),
              ]),
              _field('Location', _locationCtrl,
                  hint: 'Address', icon: Iconsax.location),
              _field('Vehicle Type', _vehicleTypeCtrl,
                  hint: 'e.g. Driver, Technician', icon: Iconsax.car),
              _field('Experience (years)', _experienceCtrl,
                  hint: 'e.g. 6',
                  keyboardType: TextInputType.number,
                  icon: Iconsax.chart),
              _field('License Number', _licenseCtrl,
                  hint: 'Driving license number', icon: Iconsax.card),
              _dateField(),
            ]),
            AppSpacing.vGapLg,
            _sectionCard('Contact Information', [
              _field('Mobile Number', _phoneCtrl,
                  hint: '+91 XXXXX XXXXX',
                  keyboardType: TextInputType.phone,
                  icon: Iconsax.call),
              _field('Email Address', _emailCtrl,
                  hint: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  icon: Iconsax.sms),
              _field('WhatsApp Number', _whatsappCtrl,
                  hint: '+91 XXXXX XXXXX',
                  keyboardType: TextInputType.phone,
                  icon: Icons.chat_rounded),
            ]),
            AppSpacing.vGapXl,
            Row(children: [
              Expanded(
                child: AppSecondaryButton(
                  label: 'Cancel',
                  onPressed: _isSaving ? null : () => Get.back(),
                ),
              ),
              AppSpacing.hGapMd,
              Expanded(
                flex: 2,
                child: AppPrimaryButton(
                  label: 'Save Changes',
                  icon: Iconsax.tick_circle,
                  loading: _isSaving,
                  onPressed: _save,
                ),
              ),
            ]),
            AppSpacing.vGapLg,
          ],
        ),
      ),
    );
  }

  // ── Avatar ──────────────────────────────────────────────────────────────────
  Widget _avatar() {
    final hasPicked = _pickedImage != null;
    final hasExisting =
        _existingImageUrl != null && _existingImageUrl!.isNotEmpty;
    return Center(
      child: GestureDetector(
        onTap: _showPhotoSourceSheet,
        child: Stack(alignment: Alignment.bottomRight, children: [
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppPalette.primary, width: 3),
              color: AppPalette.primaryLight,
            ),
            child: ClipOval(
              child: hasPicked
                  ? Image.file(File(_pickedImage!.path), fit: BoxFit.cover)
                  : hasExisting
                      ? Image.network(_existingImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _avatarFallback())
                      : _avatarFallback(),
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppPalette.primary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Iconsax.camera, size: 15, color: Colors.white),
          ),
        ]),
      ),
    );
  }

  Widget _avatarFallback() => const Center(
        child: Icon(Iconsax.user, size: 44, color: AppPalette.primary),
      );

  // ── Section card ────────────────────────────────────────────────────────────
  Widget _sectionCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppPalette.card,
        borderRadius: AppRadius.rLg,
        border: Border.all(color: AppPalette.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: AppText.title.on(AppPalette.textDark)),
        AppSpacing.vGapMd,
        ...children,
      ]),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    String hint = '',
    TextInputType? keyboardType,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: AppText.label.on(AppPalette.primary).weight(FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: AppText.body.on(AppPalette.textDark),
          decoration: _decoration(hint, icon),
        ),
      ]),
    );
  }

  Widget _dateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Date of Birth',
            style: AppText.label.on(AppPalette.primary).weight(FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: _dobCtrl,
          readOnly: true,
          style: AppText.body.on(AppPalette.textDark),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDob ?? DateTime(2000),
              firstDate: DateTime(1950),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              setState(() {
                _selectedDob = date;
                _dobCtrl.text = _formatDate(date);
              });
            }
          },
          decoration: _decoration('DD/MM/YYYY', Iconsax.calendar),
        ),
      ]),
    );
  }

  InputDecoration _decoration(String hint, IconData? icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppText.bodySm.on(AppPalette.textFaint),
      prefixIcon:
          icon != null ? Icon(icon, size: 18, color: AppPalette.textGrey) : null,
      filled: true,
      fillColor: AppPalette.bg,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
          borderRadius: AppRadius.rLg,
          borderSide: const BorderSide(color: AppPalette.border)),
      enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.rLg,
          borderSide: const BorderSide(color: AppPalette.border)),
      focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.rLg,
          borderSide: const BorderSide(color: AppPalette.primary)),
    );
  }

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }
}
