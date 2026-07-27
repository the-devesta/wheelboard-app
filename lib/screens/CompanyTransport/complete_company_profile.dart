import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../core/auth/auth_service.dart';
import '../../core/navigation/app_routes.dart';
import '../../services/kyc_service.dart';
import '../../services/profile_service.dart';
import '../../theme/design_system.dart';
import '../../widgets/custom_snackbar.dart';

/// Transport Company profile completion.
///
/// Mirrors the web `src/app/company/complete-profile/page.tsx` page — same
/// fields, same validation, same "Skip for now" behaviour.
///
/// The PAN entered here is submitted to the canonical KYC module
/// (`POST /kyc/verify/pan`) so it is auto-verified against Invincible Ocean and
/// recognised later by the KYC screen. Verification status itself is decided
/// and persisted by the backend, never by this form.
class CompanyCompleteProfile extends StatefulWidget {
  const CompanyCompleteProfile({super.key});

  @override
  State<CompanyCompleteProfile> createState() =>
      _CompanyCompleteProfileState();
}

class _CompanyCompleteProfileState extends State<CompanyCompleteProfile> {
  final ProfileService _profileService = ProfileService();

  // Same option list as the web complete-profile page.
  static const _indianStates = <String>[
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
    'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya',
    'Mizoram', 'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim',
    'Tamil Nadu', 'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand',
    'West Bengal', 'Delhi', 'Jammu and Kashmir', 'Ladakh',
  ];

  final _registrationNumberCtrl = TextEditingController();
  final _taxIdCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _panCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();

  String? _state;
  bool _saving = false;

  @override
  void dispose() {
    _registrationNumberCtrl.dispose();
    _taxIdCtrl.dispose();
    _websiteCtrl.dispose();
    _panCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _zipCtrl.dispose();
    super.dispose();
  }

  /// Mirrors the web `validateForm()`: address/city/state required, plus a
  /// 10-character PAN.
  String? _validate() {
    if (_addressCtrl.text.trim().isEmpty ||
        _cityCtrl.text.trim().isEmpty ||
        _state == null) {
      return 'Please fill in all required address fields.';
    }
    if (_panCtrl.text.trim().length != 10) {
      return 'Please enter a valid 10-character PAN number.';
    }
    return null;
  }

  Future<void> _submit() async {
    final error = _validate();
    if (error != null) {
      SnackBarHelper.error(error);
      return;
    }
    setState(() => _saving = true);

    // Merge onto the existing profile (web spreads `...user.profile` first).
    final profile = <String, dynamic>{...?AuthService.to.user?.profile};

    void putStr(String key, String value) {
      if (value.trim().isNotEmpty) profile[key] = value.trim();
    }

    putStr('registrationNumber', _registrationNumberCtrl.text);
    putStr('taxId', _taxIdCtrl.text);
    putStr('website', _websiteCtrl.text);
    putStr('address', _addressCtrl.text);
    putStr('city', _cityCtrl.text);
    if (_state != null) profile['state'] = _state;
    putStr('zipCode', _zipCtrl.text);

    final pan = _panCtrl.text.trim().toUpperCase();
    profile['panNumber'] = pan;
    // `kycCompleted` marks the onboarding form as SUBMITTED (route guards read
    // it). Verification state itself — isVerified / kycStatus / kycDetails — is
    // owned by the backend and is no longer sent from here; the server strips
    // those fields from client profile updates.
    profile['kycCompleted'] = true;

    try {
      await _profileService.updateProfile(profile: profile);

      // Route the PAN through the canonical KYC module so it is verified
      // against Invincible Ocean and persisted as the single authoritative PAN
      // state. Previously the PAN was only written into the profile blob, so
      // the KYC screen saw no PAN and asked the user for it a second time.
      //
      // A verification failure must NOT block onboarding: the PAN is recorded
      // as pending manual review and the user completes it from the KYC screen.
      try {
        await KycService().verifyPan(pan);
      } catch (_) {
        // Non-blocking — the KYC screen surfaces the pending/manual state.
      }

      // Refresh the cached user so home/route guards see the completed profile.
      await AuthService.to.getProfile();
      if (!mounted) return;
      SnackBarHelper.success('Profile completed successfully!');
      Get.offAllNamed(AppRoutes.companyHome);
    } catch (e) {
      SnackBarHelper.error('Failed to update profile. Please try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _skip() => Get.offAllNamed(AppRoutes.companyHome);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.bg,
      appBar: AppBar(
        backgroundColor: AppPalette.card,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppPalette.textDark),
          onPressed: () => Get.back(),
        ),
        title: Text('Complete Your Profile', style: AppText.h3),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please provide additional details about your company.',
              style: AppText.bodySm,
            ),
            AppSpacing.vGapLg,

            _card('Company Details', [
              _field(
                label: 'Registration Number',
                hint: 'Company Reg. No.',
                controller: _registrationNumberCtrl,
                optional: true,
              ),
              AppSpacing.vGapLg,
              _field(
                label: 'Tax ID (GST)',
                hint: 'GSTIN Number',
                controller: _taxIdCtrl,
                optional: true,
              ),
              AppSpacing.vGapLg,
              _field(
                label: 'Website',
                hint: 'https://yourcompany.com',
                controller: _websiteCtrl,
                keyboardType: TextInputType.url,
                optional: true,
              ),
            ]),
            AppSpacing.vGapLg,

            _card('Identity Verification', [
              _field(
                label: 'PAN Number',
                hint: 'ABCDE1234F',
                controller: _panCtrl,
                required: true,
                maxLength: 10,
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 6),
              Text(
                'PAN will be reviewed manually by admin after submission.',
                style: AppText.caption,
              ),
            ]),
            AppSpacing.vGapLg,

            _card('Address', [
              _field(
                label: 'Street Address',
                hint: '123 Company Street',
                controller: _addressCtrl,
                required: true,
              ),
              AppSpacing.vGapLg,
              _field(
                label: 'City',
                hint: 'Mumbai',
                controller: _cityCtrl,
                required: true,
              ),
              AppSpacing.vGapLg,
              _dropdown(
                label: 'State',
                required: true,
                value: _state,
                hint: 'Select state',
                items: _indianStates,
                onChanged: (v) => setState(() => _state = v),
              ),
              AppSpacing.vGapLg,
              _field(
                label: 'ZIP Code',
                hint: '400001',
                controller: _zipCtrl,
                keyboardType: TextInputType.number,
                optional: true,
              ),
            ]),
            const SizedBox(height: 24),

            AppPrimaryButton(
              label: 'Complete Profile',
              icon: Icons.check_rounded,
              loading: _saving,
              onPressed: _submit,
            ),
            AppSpacing.vGapMd,
            Center(
              child: TextButton(
                onPressed: _saving ? null : _skip,
                child: Text('Skip for now',
                    style: AppText.subtitle.on(AppPalette.textGrey)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(String title, List<Widget> children) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: AppText.micro.copyWith(letterSpacing: 0.8)),
          AppSpacing.vGapMd,
          ...children,
        ],
      ),
    );
  }

  Widget _label(String text, {bool required = false, bool optional = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          text: text,
          style: AppText.label.copyWith(color: AppPalette.textMid),
          children: [
            if (required)
              const TextSpan(text: ' *', style: TextStyle(color: AppPalette.danger)),
            if (optional)
              TextSpan(text: '  (Optional)', style: AppText.caption),
          ],
        ),
      ),
    );
  }

  BoxDecoration get _inputBox => BoxDecoration(
        color: AppPalette.bg,
        borderRadius: AppRadius.rLg,
        border: Border.all(color: AppPalette.border),
      );

  Widget _field({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool required = false,
    bool optional = false,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, required: required, optional: optional),
        Container(
          decoration: _inputBox,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLength: maxLength,
            textCapitalization: textCapitalization,
            inputFormatters: maxLength != null
                ? [LengthLimitingTextInputFormatter(maxLength)]
                : null,
            style: AppText.body.on(AppPalette.textDark),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppText.body.on(AppPalette.textFaint),
              counterText: '',
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropdown({
    required String label,
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, required: required),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: _inputBox,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.expand_more_rounded, color: AppPalette.textGrey),
              hint: Text(hint, style: AppText.body.on(AppPalette.textFaint)),
              style: AppText.body.on(AppPalette.textDark),
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
