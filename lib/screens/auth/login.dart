import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wheelboard/constants/apps_colors.dart';
import 'package:wheelboard/screens/CompanyTransport/complete_company_profile.dart';

import '../../controllers/login_controller.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_snackbar.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/session_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../auth/forget_password_screen.dart';
import '../auth/service_provider_login.dart';

import 'onboarding_screen.dart';

class ProfessionLogin extends StatelessWidget {
  ProfessionLogin({super.key});

  final LoginController loginController = Get.put(LoginController());
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: AppBar(elevation: 0, backgroundColor: Colors.transparent),
      ),
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    // Logo
                    Image.asset(
                      'assets/mainlogo.png',
                      height: 85,
                      width: 85,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 24),
                    // Title
                    Text(
                      "Sign in to your\nAccount",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF535353),
                        height: 1.2,
                        letterSpacing: -0.64,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Subtitle
                    Text(
                      "Enter your Phone no. and password to log in",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFF535353),
                        height: 1.4,
                        letterSpacing: -0.13,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 32),
                    // White Card Container
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 4),
                        ],
                      ),
                      child: Column(
                        children: [
                          _socialButton(
                            "Continue with Google",
                            "assets/google.svg",
                          ),
                          const SizedBox(height: 24),
                          _buildDivider(context),
                          const SizedBox(height: 24),

                          /// 📌 Phone Number
                          _buildInputField(
                            controller: phoneController,
                            hintText: "Enter your phone number",
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),

                          /// 📌 Password with Eye Toggle (Obx)
                          Obx(
                            () => _buildInputField(
                              controller: passwordController,
                              hintText: "Enter your password",
                              obscureText:
                                  loginController.obscurePassword.value,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  loginController.obscurePassword.value
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: const Color(0xFF6C7278),
                                  size: 16,
                                ),
                                onPressed: () {
                                  loginController.obscurePassword.value =
                                      !loginController.obscurePassword.value;
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          /// 📌 Forgot Password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Get.to(ForgotPasswordScreen());
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                "Forgot Password ?",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: const Color(0xFFF26262),
                                  height: 1.4,
                                  letterSpacing: -0.12,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          /// 📌 Login Button
                          _buildLoginButton(),
                          const SizedBox(height: 24),

                          /// 📌 Signup Redirect
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account?",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: const Color(0xFF6C7278),
                                  height: 1.4,
                                  letterSpacing: -0.12,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () {
                                  Get.to(RegisterScreen());
                                },
                                child: Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFF26262),
                                    height: 1.4,
                                    letterSpacing: -0.12,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          /// Quick Login Buttons (for testing)
                          Text(
                            "--- Quick Logins for Testing ---",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTestLoginButton("Transport", () {
                                  phoneController.text = "9304514788";
                                  passwordController.text = "qqqqqq";
                                  _performLogin();
                                }),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildTestLoginButton(
                                  "Professional",
                                  () {
                                    phoneController.text = "9304514789";
                                    passwordController.text = "qqqqqq";
                                    _performLogin();
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildTestLoginButton(
                                  "Service Provider",
                                  () {
                                    phoneController.text = "9304514701";
                                    passwordController.text = "qqqqqq";
                                    _performLogin();
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Helper method for test login buttons
  Widget _buildTestLoginButton(String role, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF26262),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        minimumSize: const Size(0, 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          role,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// Encapsulated login logic
  Future<void> _performLogin() async {
    if (phoneController.text.trim().isEmpty) {
      SnackBarHelper.error("Please enter phone number");
      return;
    }
    if (passwordController.text.trim().isEmpty) {
      SnackBarHelper.error("Please enter password");
      return;
    }
    if (loginController.isLoading.value) {
      return;
    }

    final responseData = await loginController.login(
      phoneController.text.trim(),
      passwordController.text.trim(),
    );

    if (responseData != null && responseData.isNotEmpty) {
      final businessCategory = responseData['businessCategory'] ?? '';
      final isProfileComplete = responseData['isProfileComplete'] ?? false;
      final token = responseData['token'] ?? '';
      final userId = responseData['userId'] ?? '';

      if (token.isEmpty || userId.isEmpty) {
        SnackBarHelper.error("Login failed: Invalid response from server");
        return;
      }

      final authService = AuthService.to;
      final loginSuccess = await authService.login(
        token: token,
        userId: userId,
        userType: businessCategory,
      );

      if (loginSuccess) {
        // Note: Success toast is already shown by AuthService.login()
        if (businessCategory == "Transport" && !isProfileComplete) {
          // ✅ Get registration data from SessionManager
          final sessionManager = SessionManager();
          final registrationData = {
            "userId": userId,
            "companyName":
                await sessionManager.getString("registration_companyName") ??
                "",
            "email": await sessionManager.getString("registration_email") ?? "",
            "mobileNo":
                await sessionManager.getString("registration_mobileNo") ?? "",
            "businessCategory":
                await sessionManager.getString(
                  "registration_businessCategory",
                ) ??
                "Transport",
          };

          Get.to(CompanyCompleteProfile(), arguments: registrationData);
        } else if (businessCategory == "Service Provider" &&
            !isProfileComplete) {
          Get.to(
            AlliedBusinessRegistrationScreen(),
            arguments: {"userId": userId},
          );
        } else {
          NavigationHelper.navigateToMainWrapper();
        }
      } else {
        SnackBarHelper.error("Login failed: Could not save session");
      }
    } else {
      SnackBarHelper.error("Invalid credentials. Please try again.");
    }
  }

  Widget _socialButton(String text, String asset) {
    return InkWell(
      onTap: () {
        // TODO: Implement Google sign in
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFEFF0F6)),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(asset, height: 18, width: 18),
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1C1E),
                height: 1.4,
                letterSpacing: -0.14,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: const Color(0xFFEDF1F3))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Or login with",
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF6C7278),
              height: 1.5,
              letterSpacing: -0.12,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: const Color(0xFFEDF1F3))),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEDF1F3)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1A1C1E),
          height: 1.4,
          letterSpacing: -0.14,
          fontFamily: 'Inter',
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1A1C1E),
            height: 1.4,
            letterSpacing: -0.14,
            fontFamily: 'Inter',
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: loginController.isLoading.value
              ? null // Disable button while loading
              : _performLogin, // Use the encapsulated login logic
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF26262),
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
          child: loginController.isLoading.value
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  "Log In",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    letterSpacing: -0.14,
                    fontFamily: 'Poppins',
                  ),
                ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfessionLogin();
  }
}
