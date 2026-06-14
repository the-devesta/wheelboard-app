import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/service_provider/sp_register_controller.dart';
import '../../theme/design_system.dart';
import '../../widgets/custom_snackbar.dart';
import '../CompanyServiceProvider/complete_profile_screen.dart';
import 'company_signup.dart';
import 'login.dart';
import 'professional_signup.dart';

/// Service Provider (Business) account registration.
///
/// 1:1 rewrite of the web `src/app/register/business/page.tsx` page — same
/// fields, same validation, same API. On success it pushes the business
/// profile step ([ServiceProviderCompleteProfileScreen]), exactly mirroring the
/// web redirect into the post-registration onboarding.
class ServiceProviderRegisterScreen extends StatefulWidget {
  const ServiceProviderRegisterScreen({super.key});

  @override
  State<ServiceProviderRegisterScreen> createState() =>
      _ServiceProviderRegisterScreenState();
}

class _ServiceProviderRegisterScreenState
    extends State<ServiceProviderRegisterScreen> {
  final SpRegisterController _ctrl = Get.put(SpRegisterController());

  final _businessNameCtrl = TextEditingController();
  final _ownerNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _businessNameCtrl.dispose();
    _ownerNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  /// Mirrors the web `validateForm()` in register/business/page.tsx.
  String? _validate() {
    if (_businessNameCtrl.text.trim().isEmpty ||
        _ownerNameCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        _phoneCtrl.text.trim().isEmpty ||
        _passCtrl.text.isEmpty) {
      return 'Please fill in all required fields.';
    }
    if (_passCtrl.text.length < 6) {
      return 'Password must be at least 6 characters long.';
    }
    if (_passCtrl.text != _confirmCtrl.text) {
      return 'Passwords do not match.';
    }
    if (_phoneCtrl.text.trim().length < 10) {
      return 'Please enter a valid phone number.';
    }
    return null;
  }

  Future<void> _submit() async {
    final error = _validate();
    if (error != null) {
      SnackBarHelper.error(error);
      return;
    }

    final ok = await _ctrl.register(
      businessName: _businessNameCtrl.text.trim(),
      ownerName: _ownerNameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phoneNumber: _phoneCtrl.text.trim(),
      password: _passCtrl.text,
    );
    if (!ok) return;

    SnackBarHelper.success('Account created! Please complete your profile.');
    // Web redirects into the business onboarding; we continue straight to the
    // profile-completion step (PUT /users/profile).
    Get.off(() => const ServiceProviderCompleteProfileScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.bg,
      body: CustomScrollView(
        slivers: [
          _buildHeader(),
          SliverToBoxAdapter(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 188,
      pinned: true,
      backgroundColor: AppPalette.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppPalette.brandGradient),
          child: Stack(
            children: [
              Positioned(
                top: -28,
                right: -24,
                child: _circle(128, 0.08),
              ),
              Positioned(
                bottom: -16,
                right: 64,
                child: _circle(64, 0.06),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 48, 24, 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: AppRadius.rXl,
                        ),
                        child: const Icon(Icons.store_mall_directory_rounded,
                            color: Colors.white, size: 26),
                      ),
                      const SizedBox(height: 12),
                      Text('Create Service\nProvider Account',
                          style: AppText.h1
                              .on(Colors.white)
                              .size(24)
                              .copyWith(height: 1.25)),
                      const SizedBox(height: 4),
                      Text('Register your business to offer services',
                          style: AppText.bodySm
                              .on(Colors.white.withValues(alpha: 0.85))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circle(double size, double opacity) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: opacity),
        ),
      );

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _roleSelector(),
          const SizedBox(height: 24),

          _sectionTitle('Account Information'),
          AppSpacing.vGapMd,
          _field(
            label: 'Business Name',
            hint: 'Your business name',
            controller: _businessNameCtrl,
            icon: Icons.store_rounded,
          ),
          AppSpacing.vGapLg,
          _field(
            label: 'Owner Name',
            hint: 'Full name of the owner',
            controller: _ownerNameCtrl,
            icon: Icons.person_outline_rounded,
          ),
          AppSpacing.vGapLg,
          _field(
            label: 'Email Address',
            hint: 'business@example.com',
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            icon: Icons.alternate_email_rounded,
          ),
          AppSpacing.vGapLg,
          _field(
            label: 'Phone Number',
            hint: '10-digit mobile number',
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            icon: Icons.phone_android_rounded,
          ),
          const SizedBox(height: 24),

          _sectionTitle('Security'),
          AppSpacing.vGapMd,
          Obx(() => _field(
                label: 'Password',
                hint: 'Min 6 characters',
                controller: _passCtrl,
                obscure: _ctrl.obscurePassword.value,
                icon: Icons.lock_outline_rounded,
                suffix: _visibilityToggle(_ctrl.obscurePassword),
              )),
          AppSpacing.vGapLg,
          Obx(() => _field(
                label: 'Confirm Password',
                hint: 'Re-enter password',
                controller: _confirmCtrl,
                obscure: _ctrl.obscureConfirm.value,
                icon: Icons.lock_outline_rounded,
                suffix: _visibilityToggle(_ctrl.obscureConfirm),
              )),
          const SizedBox(height: 28),

          Obx(() => AppPrimaryButton(
                label: 'Create Account',
                icon: Icons.arrow_forward_rounded,
                loading: _ctrl.isLoading.value,
                onPressed: _submit,
              )),
          AppSpacing.vGapLg,

          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Already have an account?', style: AppText.bodySm),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => Get.to(() => const LoginScreen(),
                      transition: Transition.rightToLeft),
                  child: Text('Log In',
                      style: AppText.subtitle.on(AppPalette.primary)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Role chips — mirrors the web register page's Professional / Service
  /// Provider / Transport switcher.
  Widget _roleSelector() {
    return Row(
      children: [
        Expanded(
          child: _roleChip(
            'Professional',
            selected: false,
            onTap: () => Get.off(() => const ProfessionalRegisterScreen()),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _roleChip('Service Provider', selected: true, onTap: () {}),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _roleChip(
            'Transport',
            selected: false,
            onTap: () => Get.off(() => const Signup(initialCategory: 'Transport')),
          ),
        ),
      ],
    );
  }

  Widget _roleChip(String label,
      {required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppPalette.primary : AppPalette.card,
          borderRadius: AppRadius.rPill,
          border: Border.all(
            color: selected ? AppPalette.primary : AppPalette.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: AppText.label.copyWith(
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppPalette.textGrey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
        text.toUpperCase(),
        style: AppText.micro.copyWith(letterSpacing: 0.8),
      );

  Widget _visibilityToggle(RxBool obscured) => IconButton(
        icon: Icon(
          obscured.value
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          size: 18,
          color: AppPalette.textGrey,
        ),
        onPressed: obscured.toggle,
        splashRadius: 18,
      );

  Widget _field({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    IconData? icon,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.label.copyWith(color: AppPalette.textMid)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppPalette.card,
            borderRadius: AppRadius.rLg,
            border: Border.all(color: AppPalette.border),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscure,
            style: AppText.body.on(AppPalette.textDark),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppText.body.on(AppPalette.textFaint),
              prefixIcon:
                  icon != null ? Icon(icon, size: 18, color: AppPalette.textGrey) : null,
              suffixIcon: suffix,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            ),
          ),
        ),
      ],
    );
  }
}
