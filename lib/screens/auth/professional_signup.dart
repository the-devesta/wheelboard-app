import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/Transport/professional_signup_controller.dart';
import '../../widgets/custom_snackbar.dart';
import '../../widgets/legal_widgets.dart';
import 'login.dart';

// ─── Constants ─────────────────────────────────────────────────────────────

const _primary = Color(0xFFF36969);
const _textDark = Color(0xFF1A1C1E);
const _textGrey = Color(0xFF6B7280);
const _border = Color(0xFFE5E7EB);
const _inputBg = Color(0xFFF9FAFB);

// ─── ProfessionalRegisterScreen ────────────────────────────────────────────

class ProfessionalRegisterScreen extends StatefulWidget {
  const ProfessionalRegisterScreen({super.key});

  @override
  State<ProfessionalRegisterScreen> createState() =>
      _ProfessionalRegisterScreenState();
}

class _ProfessionalRegisterScreenState
    extends State<ProfessionalRegisterScreen>
    with SingleTickerProviderStateMixin {
  final ProfessionalController _ctrl = Get.put(ProfessionalController());

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();

  final _obscurePass = true.obs;
  String? _selectedType;
  bool _acceptedLegal = false;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const _professionalTypes = ['Driver', 'Technician', 'Helper', 'Loader'];

  @override
  void initState() {
    super.initState();
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
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final firstName = _firstNameCtrl.text.trim();
    final lastName = _lastNameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final pass = _passCtrl.text.trim();

    if (firstName.isEmpty) {
      SnackBarHelper.error('Please enter your first name');
      return;
    }
    if (lastName.isEmpty) {
      SnackBarHelper.error('Please enter your last name');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      SnackBarHelper.error('Please enter a valid email address');
      return;
    }
    if (phone.isEmpty || phone.length < 10) {
      SnackBarHelper.error('Please enter a valid 10-digit phone number');
      return;
    }
    if (pass.isEmpty || pass.length < 6) {
      SnackBarHelper.error('Password must be at least 6 characters');
      return;
    }
    if (!_acceptedLegal) {
      SnackBarHelper.error(
          'Please accept the Terms & Conditions and Privacy Policy to continue.');
      return;
    }

    final success = await _ctrl.registerProfessional(
      email: email,
      password: pass,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      professionalType: _selectedType,
      city: _cityCtrl.text.trim().isNotEmpty ? _cityCtrl.text.trim() : null,
    );

    if (success) {
      await Future.delayed(const Duration(milliseconds: 800));
      Get.offAll(() => const LoginScreen(), transition: Transition.fadeIn);
    }
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
              _buildAppBar(),
              SliverToBoxAdapter(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
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
          child: Stack(
            children: [
              // decorative circles
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Positioned(
                bottom: -20,
                right: 60,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Join as a\nProfessional',
                        style: TextStyle(
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
                        'Driver, Technician, or Helper — find work fast',
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
            ],
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
          // Name row
          Row(
            children: [
              Expanded(
                child: _field(
                  label: 'First Name',
                  hint: 'Enter first name',
                  controller: _firstNameCtrl,
                  icon: Icons.person_outline_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _field(
                  label: 'Last Name',
                  hint: 'Enter last name',
                  controller: _lastNameCtrl,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _field(
            label: 'Email Address',
            hint: 'you@example.com',
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            icon: Icons.alternate_email_rounded,
          ),
          const SizedBox(height: 16),
          _field(
            label: 'Phone Number',
            hint: '10-digit mobile number',
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            icon: Icons.phone_android_rounded,
          ),
          const SizedBox(height: 16),
          Obx(() => _field(
            label: 'Password',
            hint: 'At least 6 characters',
            controller: _passCtrl,
            obscure: _obscurePass.value,
            icon: Icons.lock_outline_rounded,
            suffix: IconButton(
              icon: Icon(
                _obscurePass.value
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
                color: _textGrey,
              ),
              onPressed: () => _obscurePass.value = !_obscurePass.value,
              splashRadius: 18,
            ),
          )),
          const SizedBox(height: 24),

          // Professional type selection
          _buildTypeSection(),
          const SizedBox(height: 24),

          // City (optional)
          _field(
            label: 'City (Optional)',
            hint: 'e.g. Mumbai, Delhi, Pune',
            controller: _cityCtrl,
            icon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 24),

          // Mandatory legal acceptance
          LegalAcceptanceCheckbox(
            value: _acceptedLegal,
            onChanged: (v) => setState(() => _acceptedLegal = v),
          ),
          const SizedBox(height: 24),

          // Submit button
          Obx(() => _submitButton()),
          const SizedBox(height: 24),

          // Login redirect
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Already have an account?',
                  style: TextStyle(
                    fontSize: 13,
                    color: _textGrey,
                    fontFamily: 'Poppins',
                  ),
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

  Widget _buildTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Professional Type',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _textDark,
            fontFamily: 'Poppins',
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Optional — you can update this later',
          style: TextStyle(
            fontSize: 11,
            color: _textGrey,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _professionalTypes.map((type) {
            final selected = _selectedType == type;
            return GestureDetector(
              onTap: () => setState(() {
                _selectedType = selected ? null : type;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? _primary : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected ? _primary : _border,
                    width: selected ? 2 : 1.5,
                  ),
                  boxShadow: selected
                      ? [BoxShadow(
                          color: _primary.withValues(alpha: 0.18),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (selected)
                      const Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: Icon(Icons.check_circle_rounded, size: 14, color: Colors.white),
                      ),
                    Text(
                      type,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : _textGrey,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
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
              prefixIcon: icon != null
                  ? Icon(icon, size: 18, color: _textGrey)
                  : null,
              suffixIcon: suffix,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 16,
              ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _ctrl.isLoading.value
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Create Professional Account',
                  style: TextStyle(
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
