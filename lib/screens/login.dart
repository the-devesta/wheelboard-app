import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wheelboard/CommonWidget/app_textfield.dart';
import 'package:wheelboard/constants/apps_colors.dart';
import 'bottom_navigation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../controllers/login_controller.dart';

class ProfessionLogin extends StatelessWidget {
  ProfessionLogin({super.key});
  final LoginController loginController = Get.put(LoginController());
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: AppBar(elevation: 0, backgroundColor: Colors.transparent),
      ),
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: screenHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                child: Column(
                  children: [
                    // SizedBox(height: screenHeight * 0.04),
                    Image.asset(
                      'assets/mainlogo.png',
                      height: screenHeight * 0.12,
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      "Sign in to your\nAccount",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenWidth * 0.065,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      "Enter your Phone no. and password to log in",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: screenWidth * 0.038,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(screenWidth * 0.05),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 4),
                        ],
                      ),
                      child: Column(
                        children: [
                          _socialButton(
                            "Continue with Google",
                            "assets/google.svg",
                            screenWidth,
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          _buildDivider(screenWidth),
                          SizedBox(height: screenHeight * 0.03),
                          AppTextField(
                            hintText: "Enter your phone number",
                            controller: phoneController,
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          AppTextField(
                            hintText: "Enter your password",
                            controller: passwordController,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(value: false, onChanged: (_) {}),
                                  Text(
                                    "Remember me",
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  "Forgot Password ?",
                                  style: TextStyle(
                                    color: AppColors.buttonBg,
                                    fontSize: screenWidth * 0.035,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          _buildLoginButton(screenWidth),
                          SizedBox(height: screenHeight * 0.03),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don’t have an account?",
                                style: TextStyle(fontSize: screenWidth * 0.035),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () {
                                  Get.back();
                                },
                                child: Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                    fontSize: screenWidth * 0.035,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.02),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.04),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialButton(String text, String asset, double screenWidth) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.035),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(asset, height: screenWidth * 0.06),
          SizedBox(width: screenWidth * 0.03),
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.04,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(double screenWidth) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
          child: Text("Or", style: TextStyle(fontSize: screenWidth * 0.035)),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildLoginButton(double screenWidth) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          final success = await loginController.login(
            phoneController.text.trim(),
            passwordController.text.trim(),
          );

          if (success) {
            Get.to(() => BottomNavScreen());
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonBg,
          padding: EdgeInsets.symmetric(vertical: screenWidth * 0.045),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          "Log In",
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
