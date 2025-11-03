import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:wheelboard/constants/apps_colors.dart';

import '../../CommonWidget/app_textfield.dart';

class EnterOtpScreen extends StatefulWidget {
  const EnterOtpScreen({Key? key}) : super(key: key);

  @override
  State<EnterOtpScreen> createState() => _EnterOtpScreenState();
}

class _EnterOtpScreenState extends State<EnterOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Enter OTP", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Container(
        color: AppColors
            .primary, // <-- Set the background color for the entire screen
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      12,
                    ), // optional rounded corners
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        const Text(
                          "Enter the OTP sent to your registered email address.",
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                        const SizedBox(height: 24),
                        AppTextField(
                          controller: otpController,
                          hintText: "Enter OTP",
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "OTP is required";
                            }
                            if (value.length != 6) {
                              return "Please enter a valid 6-digit OTP";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            16,
          ), // <-- bottom margin
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Get.snackbar(
                    "Success",
                    "OTP verified successfully",
                    backgroundColor: Colors.green.shade300,
                    colorText: Colors.white,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Verify OTP",
                style: TextStyle(fontSize: 16, color: AppColors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
