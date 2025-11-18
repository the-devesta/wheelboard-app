// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/register_controller.dart';

import 'company_signup.dart';
import 'professional_signup.dart';
import 'login.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RegisterController controller = Get.put(RegisterController());
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: const Color(0xFFFCFDFC),
      body: Stack(
        children: [
          // Background Image at bottom with opacity
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 0.2,
              child: Image.asset(
                'assets/bgImage.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: screenHeight * 0.4,
              ),
            ),
          ),
          
          // Main Content with ScrollView
          SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      
                      // Logo - Responsive size
                      SizedBox(
                        height: screenHeight * 0.25,
                        width: screenWidth * 0.8,
                        child: Image.asset(
                          'assets/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      
                      SizedBox(height: screenHeight * 0.02),
                      
                      // Illustration - Responsive size
                      SizedBox(
                        height: screenHeight * 0.25,
                        width: screenWidth * 0.9,
                        child: Image.asset(
                          'assets/onboarding.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      
                      SizedBox(height: screenHeight * 0.03),
                      
                      // "Register as" Text
                      const Text(
                        'Register as',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF535353),
                          fontFamily: 'Poppins',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Toggle Buttons - Responsive width
                      Obx(
                        () => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: _buildToggleButton(
                                label: 'Professional',
                                isSelected: controller.selectedType.value == 'Professional',
                                onTap: () => controller.selectType('Professional'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildToggleButton(
                                label: 'Company',
                                isSelected: controller.selectedType.value == 'Company',
                                onTap: () => controller.selectType('Company'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Sign Up Button - Responsive width
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            if (controller.selectedType.value == 'Company') {
                              Get.to(() => Signup());
                            } else {
                              Get.to(() => ProfessionalRegisterScreen());
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF25C5C),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withOpacity(0.12),
                                  Colors.white.withOpacity(0),
                                ],
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins',
                                    letterSpacing: -0.14,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Login Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
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
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFFF25C5C),
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 40), // Bottom padding
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF26161) : const Color(0xFFFCFDFC),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
              spreadRadius: 3,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Icon(
                label == 'Professional'
                    ? Icons.person_outline
                    : Icons.local_shipping_outlined,
                color: isSelected ? Colors.white : const Color(0xFFF25C5C),
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFFF25C5C),
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  fontFamily: 'Roboto',
                  letterSpacing: 0.1,
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
