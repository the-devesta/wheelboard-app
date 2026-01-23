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
  final TextEditingController otpController = TextEditingController();

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
                      "Enter your Phone no. to receive an OTP",
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

                          /// 📌 Phone & OTP Input Section
                          Obx(
                            () => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Phone Field (Read-only when OTP sent)
                                _buildInputField(
                                  controller: phoneController,
                                  hintText: "Enter your phone number",
                                  keyboardType: TextInputType.phone,
                                  readOnly: loginController.isOTPSent.value,
                                  prefixIcon: const Icon(
                                    Icons.phone_android,
                                    size: 20,
                                    color: Color(0xFF6C7278),
                                  ),
                                  suffixIcon: loginController.isOTPSent.value
                                      ? TextButton(
                                          onPressed: () {
                                            loginController.resetOTP();
                                            otpController.clear();
                                          },
                                          child: const Text(
                                            "Change",
                                            style: TextStyle(
                                              color: Color(0xFFF26262),
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )
                                      : null,
                                ),

                                if (loginController.isOTPSent.value) ...[
                                  const SizedBox(height: 24),
                                  Text(
                                    "Enter 6-digit OTP",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF535353),
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildInputField(
                                    controller: otpController,
                                    hintText: "Enter OTP",
                                    keyboardType: TextInputType.number,
                                    prefixIcon: const Icon(
                                      Icons.lock_outline,
                                      size: 20,
                                      color: Color(0xFF6C7278),
                                    ),
                                    maxLength: 6,
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () => loginController.sendOTP(
                                        phoneController.text,
                                      ),
                                      child: const Text(
                                        "Resend OTP",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF6C7278),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),

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
                                child: _buildTestLoginButton(
                                  "Transport",
                                  () async {
                                    phoneController.text = "9304514788";
                                    await loginController.sendOTP(
                                      phoneController.text,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildTestLoginButton(
                                  "Professional",
                                  () async {
                                    phoneController.text = "9304514789";
                                    await loginController.sendOTP(
                                      phoneController.text,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildTestLoginButton(
                                  "Service Provider",
                                  () async {
                                    phoneController.text = "9304593045";
                                    await loginController.sendOTP(
                                      phoneController.text,
                                    );
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

    if (loginController.isLoading.value) {
      return;
    }

    if (!loginController.isOTPSent.value) {
      // Step 1: Send OTP
      await loginController.sendOTP(phoneController.text.trim());
      return;
    }

    // Step 2: Login with OTP
    if (otpController.text.trim().isEmpty) {
      SnackBarHelper.error("Please enter OTP");
      return;
    }

    final responseData = await loginController.loginWithOTP(
      phoneController.text.trim(),
      otpController.text.trim(),
    );

    if (responseData != null && responseData.isNotEmpty) {
      final businessCategory = responseData['businessCategory'] ?? '';
      final isProfileComplete = responseData['isProfileComplete'] ?? false;
      final isKYCCompleted = responseData['isKYCCompleted'] ?? false;
      final isHired = responseData['isHired'] ?? false;
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
        isKYCCompleted: isKYCCompleted,
        isHired: isHired,
      );

      if (loginSuccess) {
        if (businessCategory == "Transport" && !isProfileComplete) {
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
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? prefixIcon,
    Widget? suffixIcon,
    int? maxLength,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: readOnly ? const Color(0xFFF9F9F9) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEDF1F3)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        readOnly: readOnly,
        keyboardType: keyboardType,
        maxLength: maxLength,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: readOnly ? Colors.grey : const Color(0xFF1A1C1E),
          height: 1.4,
          letterSpacing: -0.14,
          fontFamily: 'Inter',
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFADAEBC),
            height: 1.4,
            letterSpacing: -0.14,
            fontFamily: 'Inter',
          ),
          counterText: "",
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: (prefixIcon != null || suffixIcon != null) ? 14 : 12,
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
                  loginController.isOTPSent.value
                      ? "Verify & Log In"
                      : "Send OTP",
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
