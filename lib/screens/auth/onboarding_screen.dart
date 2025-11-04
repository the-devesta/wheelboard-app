// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wheelboard/constants/apps_colors.dart';

import '../../controllers/register_controller.dart';

import 'login.dart';
import 'company_signup.dart';
import 'professional_signup.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RegisterController controller = Get.put(RegisterController());
    return Scaffold(
      backgroundColor: Color(0xFFFCFDFC),
      body: SafeArea(
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.asset(
                'assets/bgImage.png',
                fit: BoxFit.cover,
              ),
            ),
            // Content
            Column(
              children: [
                // Logo and App Title Section
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Column(
                    children: [
                      // Logo
                      Image.asset(
                        'assets/logo.png',
                        height: 60,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 12),
                      // App Name
                      Text(
                        'WHEELBOARD',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Tagline
                      Text(
                        'Empowering Growth, connecting success',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Handshake Illustration
                Flexible(
                  flex: 2,
                  child: Image.asset(
                    'assets/onboarding.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 16),
                // Registration Section
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Register as',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Obx(
                          () => Row(
                            children: [
                              Expanded(
                                child: _buildToggleButton(
                                  label: 'Professional',
                                  isSelected:
                                      controller.selectedType.value ==
                                      'Professional',
                                  onTap: () =>
                                      controller.selectType('Professional'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildToggleButton(
                                  label: 'Company',
                                  isSelected:
                                      controller.selectedType.value ==
                                      'Company',
                                  onTap: () => controller.selectType('Company'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              print(
                                'Selected: ${controller.selectedType.value}',
                              );
                              if (controller.selectedType.value == 'Company') {
                                Get.to(() => Signup());
                              } else {
                                Get.to(() => ProfessionalRegisterScreen());
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.buttonBg,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 4,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(Icons.arrow_forward, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Login Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.to(() => LoginScreen());
                              },
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.buttonBg,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.buttonBg : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.buttonBg : Colors.grey.shade300,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              label == 'Professional'
                  ? Icons.person_outline
                  : Icons.local_shipping_outlined,
              color: isSelected ? Colors.white : AppColors.buttonBg,
              size: 18,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.buttonBg,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
