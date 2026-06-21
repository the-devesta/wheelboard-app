import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'login.dart';
import 'company_signup.dart';
import 'professional_signup.dart';
import 'service_provider_register_screen.dart';

// ─── Onboarding data ───────────────────────────────────────────────────────

class _OnboardingPage {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBg;

  const _OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
  });
}

const _pages = [
  _OnboardingPage(
    title: 'Smart Fleet\nManagement',
    subtitle: 'Track and manage your vehicles, drivers and trips — all from one powerful dashboard.',
    icon: Icons.local_shipping_rounded,
    iconBg: Color(0xFFFFECEC),
  ),
  _OnboardingPage(
    title: 'Find Jobs &\nOpportunities',
    subtitle: 'Drivers and logistics professionals can browse jobs, bid on trips, and grow their career.',
    icon: Icons.work_outline_rounded,
    iconBg: Color(0xFFFFECEC),
  ),
  _OnboardingPage(
    title: 'Connect with\nServices',
    subtitle: 'Discover garages, mechanics, spare parts dealers and essential transport services near you.',
    icon: Icons.build_circle_outlined,
    iconBg: Color(0xFFFFECEC),
  ),
];

// ─── Onboarding screen ────────────────────────────────────────────────────

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _showRoleSelection = false;

  late AnimationController _slideController;
  late Animation<Offset> _slideIn;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideIn = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _fadeIn = CurvedAnimation(parent: _slideController, curve: Curves.easeIn);
    _slideController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _showRoleSelectionView();
    }
  }

  void _showRoleSelectionView() {
    setState(() => _showRoleSelection = true);
    _slideController.reset();
    _slideController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _showRoleSelection ? _buildRoleSelection() : _buildSlides(),
      ),
    );
  }

  // ── Slides view ──────────────────────────────────────────────────────────

  Widget _buildSlides() {
    return Column(
      children: [
        // Skip button
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 20, 0),
            child: TextButton(
              onPressed: _showRoleSelectionView,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF9CA3AF),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              child: const Text(
                'Skip',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),

        // Page view
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _pages.length,
            itemBuilder: (_, i) => _buildSlidePage(_pages[i]),
          ),
        ),

        // Dots + button
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDots(),
              _buildNextButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSlidePage(_OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration area
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: page.iconBg,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Color(0xFFF36969),
                  shape: BoxShape.circle,
                ),
                child: Icon(page.icon, size: 56, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 48),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1C1E),
              height: 1.25,
              fontFamily: 'Poppins',
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            page.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6B7280),
              height: 1.6,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      children: List.generate(_pages.length, (i) {
        final active = i == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(right: 6),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? const Color(0xFFF36969) : const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildNextButton() {
    final isLast = _currentPage == _pages.length - 1;
    return GestureDetector(
      onTap: _nextPage,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        clipBehavior: Clip.hardEdge,
        width: isLast ? 140 : 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFF36969),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF36969).withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: isLast
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Get Started',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                ],
              )
            : const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 22),
      ),
    );
  }

  // ── Role selection view ──────────────────────────────────────────────────

  Widget _buildRoleSelection() {
    return FadeTransition(
      opacity: _fadeIn,
      child: SlideTransition(
        position: _slideIn,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                // Header
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.asset(
                        'assets/mainlogo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.local_shipping_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'WHEELBOARD',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1C1E),
                        letterSpacing: 1.5,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Title
                const Text(
                  'Join as',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1C1E),
                    fontFamily: 'Poppins',
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                ),
                const Text(
                  'who are you?',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFF36969),
                    fontFamily: 'Poppins',
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select your role to get started with the right experience.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    fontFamily: 'Poppins',
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // Role cards
                _RoleCard(
                  icon: Icons.person_outline_rounded,
                  title: 'Professional',
                  subtitle: 'Driver, Technician, or Helper looking for work',
                  onTap: () => Get.to(
                    () => const ProfessionalRegisterScreen(),
                    transition: Transition.rightToLeft,
                  ),
                ),
                const SizedBox(height: 14),
                _RoleCard(
                  icon: Icons.local_shipping_rounded,
                  title: 'Transport Company',
                  subtitle: 'Fleet owner managing vehicles, drivers and trips',
                  onTap: () => Get.to(
                    () => Signup(initialCategory: 'Transport'),
                    transition: Transition.rightToLeft,
                  ),
                ),
                const SizedBox(height: 14),
                _RoleCard(
                  icon: Icons.store_mall_directory_rounded,
                  title: 'Service Provider',
                  subtitle: 'Garage, workshop or parts dealer offering services',
                  onTap: () => Get.to(
                    () => const ServiceProviderRegisterScreen(),
                    transition: Transition.rightToLeft,
                  ),
                ),

                const SizedBox(height: 32),

                // Login link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account?',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
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
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFF36969),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Role card widget ─────────────────────────────────────────────────────

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFFF36969), size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1C1E),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      fontFamily: 'Poppins',
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFF36969),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Keep RegisterScreen as alias for backward compatibility ─────────────

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) => const OnboardingScreen();
}
