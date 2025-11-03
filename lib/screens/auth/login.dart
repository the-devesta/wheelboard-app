// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:wheelboard/CommonWidget/app_textfield.dart';
// import 'package:wheelboard/constants/apps_colors.dart';
// import 'package:wheelboard/screens/complete_company_profile.dart';
// import 'package:wheelboard/screens/forgot_password.dart';
// import 'package:wheelboard/screens/service_provider_login.dart';
// import 'package:wheelboard/utils/session_manager.dart';
// import 'bottom_navigation.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import '../controllers/login_controller.dart';

// class ProfessionLogin extends StatelessWidget {
//   ProfessionLogin({super.key});
//   final LoginController loginController = Get.put(LoginController());
//   final TextEditingController phoneController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;
//     bool _obscurePassword = true;

//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: Size.fromHeight(0),
//         child: AppBar(elevation: 0, backgroundColor: Colors.transparent),
//       ),
//       backgroundColor: AppColors.primary,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: ConstrainedBox(
//             constraints: BoxConstraints(minHeight: screenHeight),
//             child: IntrinsicHeight(
//               child: Padding(
//                 padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
//                 child: Column(
//                   children: [
//                     // SizedBox(height: screenHeight * 0.04),
//                     Image.asset(
//                       'assets/mainlogo.png',
//                       height: screenHeight * 0.12,
//                     ),
//                     SizedBox(height: screenHeight * 0.01),
//                     Text(
//                       "Sign in to your\nAccount",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: screenWidth * 0.065,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     SizedBox(height: screenHeight * 0.01),
//                     Text(
//                       "Enter your Phone no. and password to log in",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: Colors.black54,
//                         fontSize: screenWidth * 0.038,
//                       ),
//                     ),
//                     SizedBox(height: screenHeight * 0.03),
//                     Container(
//                       width: double.infinity,
//                       padding: EdgeInsets.all(screenWidth * 0.05),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: const [
//                           BoxShadow(color: Colors.black12, blurRadius: 4),
//                         ],
//                       ),
//                       child: Column(
//                         children: [
//                           _socialButton(
//                             "Continue with Google",
//                             "assets/google.svg",
//                             screenWidth,
//                           ),
//                           SizedBox(height: screenHeight * 0.03),
//                           _buildDivider(screenWidth),
//                           SizedBox(height: screenHeight * 0.03),
//                           AppTextField(
//                             hintText: "Enter your phone number",
//                             controller: phoneController,
//                           ),
//                           SizedBox(height: screenHeight * 0.03),
//                           AppTextField(
//   hintText: "Enter your password",
//   controller: passwordController,
//   obscureText: _obscurePassword,
//   suffixIcon: IconButton(
//     icon: Icon(
//       _obscurePassword ? Icons.visibility_off : Icons.visibility,
//       color: Colors.grey,
//     ),
//     onPressed: () {
//       setState(() {
//         _obscurePassword = !_obscurePassword;
//       });
//     },
//   ),
// ),
//                           // AppTextField(
//                           //   hintText: "Enter your password",
//                           //   controller: passwordController,
//                           //   isPassword: true,
//                           // ),
//                           SizedBox(height: screenHeight * 0.01),
//                           Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Row(
//                                 children: [
//                                   Checkbox(value: false, onChanged: (_) {}),
//                                   Text(
//                                     "Remember me",
//                                     style: TextStyle(
//                                       fontSize: screenWidth * 0.035,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               TextButton(
//                                 onPressed: () {
//                                   Get.to(ForgotPasswordScreen());
//                                 },
//                                 child: Text(
//                                   "Forgot Password ?",
//                                   style: TextStyle(
//                                     color: AppColors.buttonBg,
//                                     fontSize: screenWidth * 0.035,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: screenHeight * 0.02),
//                           _buildLoginButton(screenWidth),
//                           SizedBox(height: screenHeight * 0.03),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Text(
//                                 "Don’t have an account?",
//                                 style: TextStyle(fontSize: screenWidth * 0.035),
//                               ),
//                               const SizedBox(width: 4),
//                               GestureDetector(
//                                 onTap: () {
//                                   Get.back();
//                                 },
//                                 child: Text(
//                                   "Sign Up",
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.red,
//                                     fontSize: screenWidth * 0.035,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: screenHeight * 0.02),
//                         ],
//                       ),
//                     ),
//                     SizedBox(height: screenHeight * 0.04),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _socialButton(String text, String asset, double screenWidth) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.symmetric(vertical: screenWidth * 0.035),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: Colors.black12),
//         color: Colors.white,
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SvgPicture.asset(asset, height: screenWidth * 0.06),
//           SizedBox(width: screenWidth * 0.03),
//           Text(
//             text,
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: screenWidth * 0.04,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDivider(double screenWidth) {
//     return Row(
//       children: [
//         const Expanded(child: Divider()),
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
//           child: Text("Or", style: TextStyle(fontSize: screenWidth * 0.035)),
//         ),
//         const Expanded(child: Divider()),
//       ],
//     );
//   }

//   Widget _buildLoginButton(double screenWidth) {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: () async {
//           final responseData = await loginController.login(
//             phoneController.text.trim(),
//             passwordController.text.trim(),
//           );

//           if (responseData != null) {
//             final businessCategory = responseData['businessCategory'];
//             final isProfileComplete = responseData['isProfileComplete'];

//             if (businessCategory == "Transport" && !isProfileComplete) {
//               final sessionManager = SessionManager();
//               await sessionManager.saveString(
//                 "authToken",
//                 responseData['token'],
//               );
//               await sessionManager.saveString("userId", responseData['userId']);
//               Get.to(
//                 CompanyCompleteProfile(),
//                 arguments: {"userId": responseData['userId']},
//               );
//               // Navigate to the transport profile completion screen
//               //  Get.to(() => TransportProfileScreen());
//             } else if (businessCategory == "Service Provider" &&
//                 !isProfileComplete) {
//               print("Token received: ${responseData['token']}");
//               final sessionManager = SessionManager();
//               await sessionManager.saveString(
//                 "authToken",
//                 responseData['token'],
//               );
//               await sessionManager.saveString("userId", responseData['userId']);
//               Get.to(
//                 AlliedBusinessRegistrationScreen(),
//                 arguments: {"userId": responseData['userId']},
//               );
//               // Navigate to the transport profile completion screen
//               //  Get.to(() => TransportProfileScreen());
//             } else {
//               print("userid received: ${responseData['userId']}");
//               print("Token received: ${responseData['token']}");
//               final sessionManager = SessionManager();
//               await sessionManager.saveString(
//                 "authToken",
//                 responseData['token'],
//               );
//               await sessionManager.saveString("userId", responseData['userId']);
//               // Navigate to the main home screen
//               Get.offAll(() => BottomNavScreen());
//             }
//           }
//           // final success = await loginController.login(
//           //   phoneController.text.trim(),
//           //   passwordController.text.trim(),
//           // );

//           // if (success) {
//           //   Get.to(() => BottomNavScreen());
//           // }
//         },
//         style: ElevatedButton.styleFrom(
//           backgroundColor: AppColors.buttonBg,
//           padding: EdgeInsets.symmetric(vertical: screenWidth * 0.045),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//         ),
//         child: Text(
//           "Log In",
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: screenWidth * 0.045,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wheelboard/CommonWidget/app_textfield.dart';
import 'package:wheelboard/constants/apps_colors.dart';
import 'package:wheelboard/screens/CompanyTransport/complete_company_profile.dart';

import '../../../utils/navigation_helper.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../controllers/login_controller.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_snackbar.dart';
import 'forget_password_screen.dart';
import 'service_provider_login.dart';

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
              minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Flexible(
                      child: Image.asset(
                        'assets/mainlogo.png',
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Sign in to your\nAccount",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Enter your Phone no. and password to log in",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
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
                          ),
                          const SizedBox(height: 24),
                          _buildDivider(context),
                          const SizedBox(height: 24),

                          /// 📌 Phone Number
                          AppTextField(
                            hintText: "Enter your phone number",
                            controller: phoneController,
                          ),
                          const SizedBox(height: 24),

                          /// 📌 Password with Eye Toggle (Obx)
                          Obx(
                            () => AppTextField(
                              hintText: "Enter your password",
                              controller: passwordController,
                              obscureText:
                                  loginController.obscurePassword.value,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  loginController.obscurePassword.value
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  loginController.obscurePassword.value =
                                      !loginController.obscurePassword.value;
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          /// 📌 Remember me + Forgot Password
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(value: false, onChanged: (_) {}),
                                  Text(
                                    "Remember me",
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () {
                                  Get.to(ForgotPasswordScreen());
                                },
                                child: Text(
                                  "Forgot Password ?",
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.buttonBg,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          /// 📌 Login Button
                          _buildLoginButton(),
                          const SizedBox(height: 24),

                          /// 📌 Signup Redirect
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account?",
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () {
                                  Get.back();
                                },
                                child: Text(
                                  "Sign Up",
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
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

  Widget _socialButton(String text, String asset) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(asset, height: 24),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text("Or", style: Theme.of(context).textTheme.bodySmall),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  // Widget _buildLoginButton(double screenWidth) {
  //   return SizedBox(
  //     width: double.infinity,
  //     child: ElevatedButton(
  //       onPressed: () async {
  //         final responseData = await loginController.login(
  //           phoneController.text.trim(),
  //           passwordController.text.trim(),
  //         );

  //         if (responseData != null) {
  //           final businessCategory = responseData['businessCategory'];
  //           final isProfileComplete = responseData['isProfileComplete'];

  //           if (businessCategory == "Transport" && !isProfileComplete) {
  //             final sessionManager = SessionManager();
  //             await sessionManager.saveString(
  //               "authToken",
  //               responseData['token'],
  //             );
  //             await sessionManager.saveString("userId", responseData['userId']);
  //             Get.to(
  //               CompanyCompleteProfile(),
  //               arguments: {"userId": responseData['userId']},
  //             );
  //           } else if (businessCategory == "Service Provider" &&
  //               !isProfileComplete) {
  //             final sessionManager = SessionManager();
  //             await sessionManager.saveString(
  //               "authToken",
  //               responseData['token'],
  //             );
  //             await sessionManager.saveString("userId", responseData['userId']);
  //             Get.to(
  //               AlliedBusinessRegistrationScreen(),
  //               arguments: {"userId": responseData['userId']},
  //             );
  //           } else {
  //             final sessionManager = SessionManager();
  //             await sessionManager.saveString(
  //               "authToken",
  //               responseData['token'],
  //             );
  //             await sessionManager.saveString("userId", responseData['userId']);
  //             Get.offAll(() => BottomNavScreen());
  //           }
  //         }
  //       },
  //       style: ElevatedButton.styleFrom(
  //         backgroundColor: AppColors.buttonBg,
  //         padding: EdgeInsets.symmetric(vertical: screenWidth * 0.045),
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(10),
  //         ),
  //       ),
  //       child: Text(
  //         "Log In",
  //         style: TextStyle(
  //           color: Colors.white,
  //           fontSize: screenWidth * 0.045,
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildLoginButton() {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: loginController.isLoading.value
              ? null // Disable button while loading
              : () async {
                  print("🔐 Starting login process...");
                  final responseData = await loginController.login(
                    phoneController.text.trim(),
                    passwordController.text.trim(),
                  );

                  print("🔐 Login response: $responseData");
                  
                  if (responseData != null) {
                    final businessCategory = responseData['businessCategory'] ?? '';
                    final isProfileComplete = responseData['isProfileComplete'] ?? false;
                    final token = responseData['token'] ?? '';
                    final userId = responseData['userId'] ?? '';
                    
                    print("🔐 Business Category: $businessCategory");
                    print("🔐 Is Profile Complete: $isProfileComplete");
                    print("🔐 Token: ${token.isNotEmpty ? 'Present' : 'Empty'}");
                    print("🔐 UserId: $userId");
                    
                    // ✅ Use AuthService for login
                    final authService = AuthService.to;
                    final loginSuccess = await authService.login(
                      token: token,
                      userId: userId,
                      userType: businessCategory,
                    );
                    
                    print("🔐 AuthService login result: $loginSuccess");

                    if (loginSuccess) {
                      SnackBarHelper.success("Login successful! Welcome back.");
                    }

                    if (businessCategory == "Transport" && !isProfileComplete) {
                      print("🔐 Navigating to CompanyCompleteProfile");
                      Get.to(
                        CompanyCompleteProfile(),
                        arguments: {"userId": userId},
                      );
                    } else if (businessCategory == "Service Provider" &&
                        !isProfileComplete) {
                      print("🔐 Navigating to AlliedBusinessRegistrationScreen");
                      Get.to(
                        AlliedBusinessRegistrationScreen(),
                        arguments: {"userId": userId},
                      );
                    } else {
                      // ✅ Navigate to appropriate wrapper based on user type
                      print("🔐 Navigating to appropriate wrapper based on user type");
                      NavigationHelper.navigateToMainWrapper();
                    }
                  } else {
                    // ✅ Show error if login fails
                    SnackBarHelper.error("Invalid credentials. Please try again.");
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonBg,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
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
              : const Text(
                  "Log In",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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
