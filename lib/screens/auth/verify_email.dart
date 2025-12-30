// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class VerifyEmailScreen extends StatefulWidget {
//   final String email;

//   const VerifyEmailScreen({
//     Key? key,
//     required this.email,
//   }) : super(key: key);

//   @override
//   State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
// }

// class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
//   final List<TextEditingController> _controllers = List.generate(
//     5,
//     (index) => TextEditingController(),
//   );
//   final List<FocusNode> _focusNodes = List.generate(
//     5,
//     (index) => FocusNode(),
//   );

//   @override
//   void dispose() {
//     for (var controller in _controllers) {
//       controller.dispose();
//     }
//     for (var node in _focusNodes) {
//       node.dispose();
//     }
//     super.dispose();
//   }

//   void _onDigitChanged(int index, String value) {
//     if (value.isNotEmpty && index < 4) {
//       _focusNodes[index + 1].requestFocus();
//     }
//   }

//   void _verifyCode() {
//     String code = _controllers.map((c) => c.text).join();
//     if (code.length != 5) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter complete 5-digit code')),
//       );
//       return;
//     }
//     // Yahan verification logic add karein
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Code verified successfully!')),
//     );
//   }

//   void _resendEmail() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Verification code sent again!')),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 20),
//               // Back button
//               GestureDetector(
//                 onTap: () => Navigator.pop(context),
//                 child: Container(
//                   width: 40,
//                   height: 40,
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade100,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: const Icon(
//                     Icons.arrow_back_ios_new,
//                     size: 18,
//                     color: Colors.black87,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 40),
//               // Title
//               const Text(
//                 'Check your email',
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               // Subtitle with email
//               RichText(
//                 text: TextSpan(
//                   style: TextStyle(
//                     fontSize: 15,
//                     color: Colors.grey.shade600,
//                     height: 1.5,
//                   ),
//                   children: [
//                     const TextSpan(text: 'We sent a reset link to '),
//                     TextSpan(
//                       text: widget.email,
//                       style: const TextStyle(
//                         color: Colors.black,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 'enter 5 digit code that mentioned in the email',
//                 style: TextStyle(
//                   fontSize: 15,
//                   color: Colors.grey.shade600,
//                   height: 1.5,
//                 ),
//               ),
//               const SizedBox(height: 40),
//               // OTP Input boxes
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: List.generate(5, (index) {
//                   return SizedBox(
//                     width: 60,
//                     height: 60,
//                     child: TextField(
//                       controller: _controllers[index],
//                       focusNode: _focusNodes[index],
//                       textAlign: TextAlign.center,
//                       keyboardType: TextInputType.number,
//                       maxLength: 1,
//                       style: const TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.w600,
//                       ),
//                       inputFormatters: [
//                         FilteringTextInputFormatter.digitsOnly,
//                       ],
//                       decoration: InputDecoration(
//                         counterText: '',
//                         filled: true,
//                         fillColor: Colors.white,
//                         contentPadding: EdgeInsets.zero,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(
//                             color: Colors.grey.shade300,
//                             width: 1.5,
//                           ),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(
//                             color: Colors.grey.shade300,
//                             width: 1.5,
//                           ),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(
//                             color: Colors.blue.shade300,
//                             width: 2,
//                           ),
//                         ),
//                       ),
//                       onChanged: (value) => _onDigitChanged(index, value),
//                     ),
//                   );
//                 }),
//               ),
//               const SizedBox(height: 32),
//               // Verify Code button
//               SizedBox(
//                 width: double.infinity,
//                 height: 56,
//                 child: ElevatedButton(
//                   onPressed: _verifyCode,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFFB8C5E8),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     elevation: 0,
//                   ),
//                   child: const Text(
//                     'Verify Code',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.white,
//                       letterSpacing: 0.3,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               // Resend email link
//               Center(
//                 child: RichText(
//                   text: TextSpan(
//                     style: TextStyle(
//                       fontSize: 15,
//                       color: Colors.grey.shade600,
//                     ),
//                     children: [
//                       const TextSpan(text: "Haven't got the email yet? "),
//                       WidgetSpan(
//                         child: GestureDetector(
//                           onTap: _resendEmail,
//                           child: const Text(
//                             'Resend email',
//                             style: TextStyle(
//                               fontSize: 15,
//                               color: Color(0xFFF46E6E),
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/custom_snackbar.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;

  const VerifyEmailScreen({super.key, required this.email});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final List<TextEditingController> _controllers = List.generate(
    5,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(5, (index) => FocusNode());

  bool _isOTPComplete = false;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < 4) {
      _focusNodes[index + 1].requestFocus();
    }

    setState(() {
      _isOTPComplete = _controllers.every(
        (controller) => controller.text.isNotEmpty,
      );
    });
  }

  void _verifyCode() {
    String code = _controllers.map((c) => c.text).join();
    if (code.length != 5) {
      SnackBarHelper.error("Please enter complete 5-digit code");
      return;
    }
    // Yahan verification logic add karein
    SnackBarHelper.success("Code verified successfully!");
  }

  void _resendEmail() {
    SnackBarHelper.info("Verification code sent again!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Back button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 18,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Title
              const Text(
                'Check your email',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              // Subtitle with email
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: 'We sent a reset link to '),
                    TextSpan(
                      text: widget.email,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'enter 5 digit code that mentioned in the email',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              // OTP Input boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (index) {
                  return SizedBox(
                    width: 60,
                    height: 60,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.blue.shade300,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) => _onDigitChanged(index, value),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
              // Verify Code button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isOTPComplete ? _verifyCode : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isOTPComplete
                        ? const Color(0xFFF46E6E)
                        : const Color(0xFFB8C5E8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Verify Code',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Resend email link
              Center(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                    children: [
                      const TextSpan(text: "Haven't got the email yet? "),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: _resendEmail,
                          child: const Text(
                            'Resend email',
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFFF46E6E),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
