import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../controllers/service_provider/sp_register_controller.dart';
import '../../core/auth/auth_service.dart';
import '../../core/navigation/app_routes.dart';
import '../../theme/design_system.dart';
import '../../widgets/custom_snackbar.dart';

/// Business profile completion for the Service Provider persona.
///
/// 1:1 rewrite of the web `src/app/business/complete-profile/page.tsx` page —
/// same fields, same validation, same `PUT /users/profile` payload (including
/// the `kycStatus` / `kycDetails` block). Doubles as the "Edit Business
/// Profile" screen ([isEdit] = true), pre-filling from the cached user profile.
class ServiceProviderCompleteProfileScreen extends StatefulWidget {
  const ServiceProviderCompleteProfileScreen({super.key, this.isEdit = false});

  /// When true the screen edits an existing profile (pre-filled, no "skip",
  /// returns `true` to the caller on success) instead of running as the
  /// post-registration onboarding step.
  final bool isEdit;

  @override
  State<ServiceProviderCompleteProfileScreen> createState() =>
      _ServiceProviderCompleteProfileScreenState();
}

class _ServiceProviderCompleteProfileScreenState
    extends State<ServiceProviderCompleteProfileScreen> {
  final SpRegisterController _ctrl = Get.put(SpRegisterController());

  // Same option lists as the web complete-profile page.
  static const _businessTypes = <String>[
    'Mechanic Shop',
    'Auto Parts Store',
    'Car Wash',
    'Towing Service',
    'Vehicle Rental',
    'Insurance Agency',
    'Fuel Station',
    'Parking Service',
    'Fleet Management',
    'Other',
  ];

  static const _servicesOffered = <String>[
    'Engine Repair',
    'Brake Service',
    'Oil Change',
    'Tire Service',
    'AC Repair',
    'Electrical Work',
    'Body Work',
    'Painting',
    'Roadside Assistance',
    'Vehicle Inspection',
  ];

  static const _indianStates = <String>[
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
    'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya',
    'Mizoram', 'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim',
    'Tamil Nadu', 'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand',
    'West Bengal', 'Delhi', 'Jammu and Kashmir', 'Ladakh',
  ];

  // Identity fields (editable on the web profile page) — shown in edit mode.
  final _businessNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();

  final _taxIdCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();
  final _panCtrl = TextEditingController();

  String? _businessType;
  String? _state;
  final List<String> _services = [];

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) _prefillFromProfile();
    _descriptionCtrl.addListener(() => setState(() {}));
  }

  void _prefillFromProfile() {
    final p = AuthService.to.user?.profile ?? const {};
    _businessNameCtrl.text =
        (p['businessName'] ?? p['companyName'] ?? '').toString();
    _phoneCtrl.text = (p['phoneNumber'] ?? '').toString();
    _whatsappCtrl.text = (p['whatsappNumber'] ?? '').toString();
    _taxIdCtrl.text =
        (p['taxId'] ?? p['gstNumber'] ?? '').toString();
    _websiteCtrl.text = (p['website'] ?? '').toString();
    _descriptionCtrl.text = (p['description'] ?? '').toString();
    _addressCtrl.text =
        (p['address'] ?? p['businessAddress'] ?? '').toString();
    _cityCtrl.text = (p['city'] ?? '').toString();
    _zipCtrl.text = (p['zipCode'] ?? '').toString();
    _panCtrl.text = (p['panNumber'] ?? '').toString();

    final bType = (p['businessType'] ?? '').toString();
    if (_businessTypes.contains(bType)) _businessType = bType;
    final st = (p['state'] ?? '').toString();
    if (_indianStates.contains(st)) _state = st;

    final raw = p['servicesOffered'];
    final list = raw is List
        ? raw.map((e) => e.toString()).toList()
        : raw.toString().split(',').map((e) => e.trim()).toList();
    _services.addAll(list.where(_servicesOffered.contains));
  }

  @override
  void dispose() {
    _businessNameCtrl.dispose();
    _phoneCtrl.dispose();
    _whatsappCtrl.dispose();
    _taxIdCtrl.dispose();
    _websiteCtrl.dispose();
    _descriptionCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _zipCtrl.dispose();
    _panCtrl.dispose();
    super.dispose();
  }

  /// Validation.
  ///
  /// - **Edit mode** mirrors the web profile-page edit (lightweight): only the
  ///   business name is required; PAN/businessType/state are NOT re-required
  ///   (they were captured at onboarding). PAN is only checked when provided.
  /// - **Onboarding mode** mirrors the web `complete-profile` `validateForm()`
  ///   (full: businessType, address, city, state and a 10-char PAN).
  String? _validate() {
    if (widget.isEdit) {
      if (_businessNameCtrl.text.trim().isEmpty) {
        return 'Business name is required.';
      }
      final pan = _panCtrl.text.trim();
      if (pan.isNotEmpty && pan.length != 10) {
        return 'Please enter a valid 10-character PAN number.';
      }
      return null;
    }

    if (_businessType == null ||
        _addressCtrl.text.trim().isEmpty ||
        _cityCtrl.text.trim().isEmpty ||
        _state == null) {
      return 'Please fill in all required fields.';
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

    final pan = _panCtrl.text.trim().toUpperCase();
    // Merge onto the existing profile, exactly like the web page spreads
    // `...(user?.profile || {})` before overwriting with the new values.
    // IMPORTANT: only overwrite a key when we actually have a value, so editing
    // (e.g. just the name) never nulls out businessType / PAN / address that the
    // user isn't currently editing. Required fields are guaranteed present by
    // `_validate()` in onboarding mode.
    final profile = <String, dynamic>{...?AuthService.to.user?.profile};
    profile['businessCategory'] = 'Service Provider';

    void putStr(String key, String value) {
      if (value.trim().isNotEmpty) profile[key] = value.trim();
    }

    if (_businessType != null) profile['businessType'] = _businessType;
    if (_state != null) profile['state'] = _state;
    if (_services.isNotEmpty) profile['servicesOffered'] = _services;
    putStr('taxId', _taxIdCtrl.text);
    putStr('website', _websiteCtrl.text);
    putStr('description', _descriptionCtrl.text);
    putStr('address', _addressCtrl.text);
    putStr('city', _cityCtrl.text);
    putStr('zipCode', _zipCtrl.text);
    if (pan.isNotEmpty) profile['panNumber'] = pan;

    if (widget.isEdit) {
      putStr('businessName', _businessNameCtrl.text);
      putStr('phoneNumber', _phoneCtrl.text);
      putStr('whatsappNumber', _whatsappCtrl.text);
    }

    // On first completion we submit the KYC block (admin review) like the web
    // page does. While editing we leave any existing KYC state untouched.
    if (!widget.isEdit) {
      profile.addAll({
        'isVerified': false,
        'kycStatus': 'pending',
        'kycCompleted': true,
        'kycDetails': {
          'verificationMode': 'admin_review',
          'panNumber': pan,
        },
      });
    }

    final ok = await _ctrl.completeProfile(profile);
    if (!ok) return;

    if (widget.isEdit) {
      SnackBarHelper.success('Profile updated successfully!');
      Get.back(result: true);
    } else {
      SnackBarHelper.success('Profile completed successfully!');
      Get.offAllNamed(AppRoutes.serviceProviderHome);
    }
  }

  void _skip() => Get.offAllNamed(AppRoutes.serviceProviderHome);

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
        title: Text(
          widget.isEdit ? 'Edit Business Profile' : 'Complete Your Profile',
          style: AppText.h3,
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!widget.isEdit) ...[
              Text(
                'Tell us a little about your business to get better visibility and leads.',
                style: AppText.bodySm,
              ),
              AppSpacing.vGapLg,
            ],

            if (widget.isEdit) ...[
              _card('Business Info', [
                _field(
                  label: 'Business Name',
                  hint: 'Your business name',
                  controller: _businessNameCtrl,
                  required: true,
                ),
                AppSpacing.vGapLg,
                _field(
                  label: 'Phone Number',
                  hint: '+91 98765 43210',
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  optional: true,
                ),
                AppSpacing.vGapLg,
                _field(
                  label: 'WhatsApp Number',
                  hint: '+91 98765 43210',
                  controller: _whatsappCtrl,
                  keyboardType: TextInputType.phone,
                  optional: true,
                ),
              ]),
              AppSpacing.vGapLg,
            ],

            _card('Business Details', [
              _dropdown(
                label: 'Business Type',
                required: true,
                value: _businessType,
                hint: 'Select business type',
                items: _businessTypes,
                onChanged: (v) => setState(() => _businessType = v),
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
                hint: 'https://yourbusiness.com',
                controller: _websiteCtrl,
                keyboardType: TextInputType.url,
                optional: true,
              ),
              AppSpacing.vGapLg,
              _descriptionField(),
            ]),
            AppSpacing.vGapLg,

            _card('Address', [
              _field(
                label: 'Street Address',
                hint: '123 Business Street',
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

            _card('Services Offered (Optional)', [_servicesChips()]),
            const SizedBox(height: 24),

            Obx(() => AppPrimaryButton(
                  label: widget.isEdit ? 'Save Changes' : 'Complete Profile',
                  icon: Icons.check_rounded,
                  loading: _ctrl.isLoading.value,
                  onPressed: _submit,
                )),
            if (!widget.isEdit) ...[
              AppSpacing.vGapMd,
              Center(
                child: TextButton(
                  onPressed: _ctrl.isLoading.value ? null : _skip,
                  child: Text('Skip for now',
                      style: AppText.subtitle.on(AppPalette.textGrey)),
                ),
              ),
            ],
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

  Widget _descriptionField() {
    final count = _descriptionCtrl.text.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Description', optional: true),
        Container(
          decoration: _inputBox,
          child: TextField(
            controller: _descriptionCtrl,
            maxLines: 3,
            maxLength: 400,
            inputFormatters: [LengthLimitingTextInputFormatter(400)],
            style: AppText.body.on(AppPalette.textDark),
            decoration: InputDecoration(
              hintText: 'Describe your business...',
              hintStyle: AppText.body.on(AppPalette.textFaint),
              counterText: '',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text('$count/400', style: AppText.caption),
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

  Widget _servicesChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _servicesOffered.map((service) {
        final selected = _services.contains(service);
        return GestureDetector(
          onTap: () => setState(() {
            selected ? _services.remove(service) : _services.add(service);
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: selected ? AppPalette.primary : AppPalette.card,
              borderRadius: AppRadius.rPill,
              border: Border.all(
                color: selected ? AppPalette.primary : AppPalette.border,
              ),
            ),
            child: Text(
              service,
              style: AppText.bodySm.copyWith(
                color: selected ? Colors.white : AppPalette.textMid,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
