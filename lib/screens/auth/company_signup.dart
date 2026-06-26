import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_picker/country_picker.dart';

import '../../controllers/Transport/signup_controller.dart';
import '../../models/company_signupmodel.dart';
import '../../utils/session_manager.dart';
import '../../widgets/custom_snackbar.dart';
import '../../widgets/legal_widgets.dart';
import '../CompanyTransport/complete_company_profile.dart';
import 'login.dart';

// ─── Constants ─────────────────────────────────────────────────────────────

const _primary = Color(0xFFF36969);
const _textDark = Color(0xFF1A1C1E);
const _textGrey = Color(0xFF6B7280);
const _border = Color(0xFFE5E7EB);
const _inputBg = Color(0xFFF9FAFB);

// ─── Signup ────────────────────────────────────────────────────────────────

class Signup extends StatefulWidget {
  const Signup({super.key, this.initialCategory = 'Transport'});

  final String initialCategory;

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> with SingleTickerProviderStateMixin {
  final SignupController _ctrl = Get.put(SignupController());

  final _companyCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _acceptedLegal = false;

  late String _selectedCategory;
  Country _selectedCountry = Country.parse('IN');

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _companyCtrl.dispose();
    _contactCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  bool get _isServiceProvider => _selectedCategory == 'Service Provider';

  Future<void> _submit() async {
    final company = _companyCtrl.text.trim();
    final contact = _contactCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final pass = _passCtrl.text.trim();

    if (company.isEmpty) { SnackBarHelper.error('Please enter ${_isServiceProvider ? "business" : "company"} name'); return; }
    if (phone.isEmpty) { SnackBarHelper.error('Please enter phone number'); return; }
    if (pass.isEmpty) { SnackBarHelper.error('Please enter a password'); return; }
    if (pass.length < 6) { SnackBarHelper.error('Password must be at least 6 characters'); return; }
    if (!_acceptedLegal) { SnackBarHelper.error('Please accept the Terms & Conditions and Privacy Policy to continue.'); return; }

    final model = CompanySignUpModel(
      companyName: company,
      contactPerson: contact.isNotEmpty ? contact : company,
      mobileNo: phone,
      email: email.isNotEmpty ? email : '$phone@wheelboard.in',
      password: pass,
      businessCategory: _selectedCategory,
    );

    final success = await _ctrl.registerCompany(model);
    if (!success) return;

    final userId = _ctrl.userId.value ?? '';

    final sessionManager = SessionManager();
    await sessionManager.saveString('registration_companyName', company);
    await sessionManager.saveString('registration_email', email);
    await sessionManager.saveString('registration_mobileNo', phone);
    await sessionManager.saveString('registration_businessCategory', _selectedCategory);

    final args = {
      'userId': userId,
      'companyName': company,
      'email': email,
      'mobileNo': phone,
      'businessCategory': _selectedCategory,
    };

    Get.offAll(() => CompanyCompleteProfile(), arguments: args);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: CustomScrollView(
            slivers: [
              _buildAppBar(context),
              SliverToBoxAdapter(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: _primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF36969), Color(0xFFFF8A8A)],
            ),
          ),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isServiceProvider ? 'Register as\nService Provider' : 'Register as\nTransport Company',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      height: 1.25,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isServiceProvider
                        ? 'Offer services to the transport ecosystem'
                        : 'Manage your fleet, drivers and trips',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.82),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Form fields
          _field(
            label: _isServiceProvider ? 'Business Name' : 'Company Name',
            hint: _isServiceProvider ? 'Enter your business name' : 'Enter company name',
            controller: _companyCtrl,
            icon: _isServiceProvider ? Icons.store_rounded : Icons.business_rounded,
          ),
          const SizedBox(height: 16),
          _field(
            label: _isServiceProvider ? 'Owner / Contact Name' : 'Contact Person',
            hint: 'Full name of primary contact',
            controller: _contactCtrl,
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 16),
          _phoneField(),
          const SizedBox(height: 16),
          _field(
            label: 'Email Address',
            hint: 'company@example.com (optional)',
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            icon: Icons.alternate_email_rounded,
          ),
          const SizedBox(height: 16),
          Obx(() => _field(
            label: 'Password',
            hint: 'Create a strong password',
            controller: _passCtrl,
            obscure: _ctrl.obscurePassword.value,
            icon: Icons.lock_outline_rounded,
            suffix: IconButton(
              icon: Icon(
                _ctrl.obscurePassword.value
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
                color: _textGrey,
              ),
              onPressed: () => _ctrl.obscurePassword.toggle(),
              splashRadius: 18,
            ),
          )),
          const SizedBox(height: 24),

          // Mandatory legal acceptance
          LegalAcceptanceCheckbox(
            value: _acceptedLegal,
            onChanged: (v) => setState(() => _acceptedLegal = v),
          ),
          const SizedBox(height: 24),

          // Register button
          Obx(() => _submitButton()),
          const SizedBox(height: 24),

          // Login redirect
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Already have an account?',
                  style: TextStyle(fontSize: 13, color: _textGrey, fontFamily: 'Poppins'),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => Get.to(
                    () => const LoginScreen(),
                    transition: Transition.rightToLeft,
                  ),
                  child: const Text(
                    'Log In',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _primary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _phoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phone Number',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _textDark,
            fontFamily: 'Poppins',
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: _inputBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _border),
          ),
          child: Row(
            children: [
              // Country code picker
              GestureDetector(
                onTap: () => showCountryPicker(
                  context: context,
                  showPhoneCode: true,
                  onSelect: (c) => setState(() => _selectedCountry = c),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: const BoxDecoration(
                    border: Border(right: BorderSide(color: _border)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_selectedCountry.flagEmoji, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 4),
                      Text(
                        '+${_selectedCountry.phoneCode}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: _textDark,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.expand_more_rounded, size: 16, color: _textGrey),
                    ],
                  ),
                ),
              ),
              // Number input
              Expanded(
                child: TextField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _textDark,
                    fontFamily: 'Poppins',
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Enter mobile number',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: Color(0xFFB0B7C3),
                      fontFamily: 'Poppins',
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

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
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _textDark,
            fontFamily: 'Poppins',
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: _inputBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _border),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscure,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _textDark,
              fontFamily: 'Poppins',
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 13,
                color: Color(0xFFB0B7C3),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: icon != null ? Icon(icon, size: 18, color: _textGrey) : null,
              suffixIcon: suffix,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _ctrl.isLoading.value ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          disabledBackgroundColor: _primary.withValues(alpha: 0.55),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          shadowColor: _primary.withValues(alpha: 0.4),
        ),
        child: _ctrl.isLoading.value
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              )
            : FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _isServiceProvider ? 'Create Service Provider Account' : 'Create Company Account',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
      ),
    );
  }
}
