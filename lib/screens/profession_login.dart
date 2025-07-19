import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wheelboard/CommonWidget/app_textfield.dart';
import 'package:wheelboard/constants/apps_colors.dart';

class ProfessionLogin extends StatelessWidget {
  const ProfessionLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: BackButton()),
      backgroundColor: AppColors.primary,

      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),

          child: Column(
            children: [
              Image.asset('assets/logo.png', height: 100),
              const SizedBox(height: 24),
              const Text(
                "Sign in to your\nAccount",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Enter your Phone no. and password to log in",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                child: Column(
                  children: [
                    _socialButton("Continue with Google", "assets/google.png"),
                    SizedBox(height: 24),
                    _buildDivider(),
                    SizedBox(height: 24),
                    AppTextField(hintText: "Enter your email"),
                    SizedBox(height: 24),
                    AppTextField(hintText: "Enter your password"),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(value: false, onChanged: (_) {}),
                            const Text("Remember me"),
                          ],
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            "Forgot Password ?",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildRegisterButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _socialButton(String text, String asset) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.black12),
      color: Colors.white,
    ),
    padding: EdgeInsets.symmetric(vertical: 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(asset, height: 24),
        SizedBox(width: 12),
        Text(text, style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );
}

Widget _buildDivider() {
  return Row(
    children: [
      Expanded(child: Divider()),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text("Or"),
      ),
      Expanded(child: Divider()),
    ],
  );
}

Widget _buildRegisterButton() {
  return ElevatedButton(
    onPressed: () {
      Get.to(ProfessionLogin());
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.buttonBg,
      minimumSize: Size(double.infinity, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    child: Text("Get in now ", style: TextStyle(color: Colors.white)),
  );
}
