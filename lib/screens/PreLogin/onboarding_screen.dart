// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wheelboard/constants/apps_colors.dart';
import 'package:wheelboard/screens/company_signup.dart';
import '../../controllers/register_controller.dart';
import '../professional_signup.dart';
import '../login.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RegisterController controller = Get.put(RegisterController());
    return Scaffold(
      backgroundColor: Color(0xFFFCFDFC),

      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            // Logo and App Title Section
            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Column(
                children: [
                  // Logo
                  Image.asset(
                    'assets/logo.png', 
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 16),
                  // App Name
                  Text(
                    'WHEELBOARD',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 8),
                  // Tagline
                  Text(
                    'Empowering Growth, connecting success',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 40),
            
            // Handshake Illustration
            Image.asset(
              'assets/onboarding.png', 
              height: 200,
              fit: BoxFit.contain,
            ),
            
            SizedBox(height: 40),

            // Registration Section with Background
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background Image
                  Positioned.fill(
                    child: Image.asset(
                      'assets/bgImage.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Overlay Content
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 30,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Register as',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 24),
                        Obx(
                          () => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
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
                              SizedBox(width: 16),
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
                        SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () {
                            print(
                              'Selected: ${controller.selectedType.value}',
                            );
                            if (controller.selectedType.value == 'Company') {
                              Get.to(Signup());
                            } else {
                              Get.to(ProfessionalRegisterScreen());
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonBg,
                            padding: EdgeInsets.symmetric(
                              horizontal: 100,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 4,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, color: Colors.white),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
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
                ],
              ),
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
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              label == 'Professional' ? Icons.person_outline : Icons.local_shipping_outlined,
              color: isSelected ? Colors.white : AppColors.buttonBg,
              size: 15,
            ),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.buttonBg,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
