// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wheelboard/constants/apps_colors.dart';
import 'package:wheelboard/screens/signup.dart';
import '../controllers/register_controller.dart';

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
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset('assets/logo.png', height: 400),

                // Your logo
                Image.asset('assets/onboarding.png', height: 200), // Your image
                SizedBox(height: 10),

                // ⬇️ Section with background truck image and overlay content
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/bgImage.png', // ← replace with your actual truck image asset
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 30,
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Register as',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 20),
                          Obx(
                            () => Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildToggleButton(
                                  label: 'Professional',
                                  isSelected:
                                      controller.selectedType.value ==
                                      'Professional',
                                  onTap: () =>
                                      controller.selectType('Professional'),
                                ),
                                SizedBox(width: 16),
                                _buildToggleButton(
                                  label: 'Company',
                                  isSelected:
                                      controller.selectedType.value ==
                                      'Company',
                                  onTap: () => controller.selectType('Company'),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: () {
                              print(
                                'Selected: ${controller.selectedType.value}',
                              );
                              Get.to(Signup());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.buttonBg, // custom red
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
                                  style: TextStyle(color: Colors.white),
                                ),

                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, color: Colors.white),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.buttonBg : Colors.white,
          border: Border.all(color: AppColors.buttonBg),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              label == 'Professional' ? Icons.person : Icons.business,
              color: isSelected ? Colors.white : Colors.redAccent,
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
