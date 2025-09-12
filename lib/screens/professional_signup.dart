// import 'package:flutter/material.dart';
// import 'package:wheelboard/constants/apps_colors.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:get/get.dart';
// import '../controllers/professional_signup_controller.dart';
// import '../models/professional_signupmodel.dart';
// import 'dart:io';

// class ProfessionalRegisterScreen extends StatefulWidget {
//   const ProfessionalRegisterScreen({super.key});

//   @override
//   State<ProfessionalRegisterScreen> createState() =>
//       _ProfessionalRegisterScreenState();
// }

// class _ProfessionalRegisterScreenState
//     extends State<ProfessionalRegisterScreen> {
//   final ProfessionalController controller = Get.put(ProfessionalController());

//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _fullNameController = TextEditingController();
//   final TextEditingController _fatherNameController = TextEditingController();
//   final TextEditingController _dobController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final RxnString selectedProfessionalType = RxnString();
//   final RxnString selectedState = RxnString();
//   final RxnString selectedCity = RxnString();
//   List<PlatformFile> _pickedImages = [];

//   Future<void> _pickImages() async {
//     final result = await FilePicker.platform.pickFiles(
//       type: FileType.image,
//       allowMultiple: true,
//       withData: true, // useful for previews/thumbnails on Web
//     );

//     if (result != null && result.files.isNotEmpty) {
//       setState(() {
//         _pickedImages = result.files;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _fullNameController.dispose();
//     _fatherNameController.dispose();
//     _dobController.dispose();
//     _phoneController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//     final padding = width * 0.08;

//     return Scaffold(
//       backgroundColor: const Color(0xFFFDECEC),
//       appBar: null,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: EdgeInsets.symmetric(horizontal: padding, vertical: 0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // ✅ Heading Title placed at the top
//               _headingTitle(),

//               // ✅ White container for form content
//               Container(
//                 // color: AppColors.white,
//                 padding: const EdgeInsets.fromLTRB(16, 5, 16, 0),
//                 decoration: BoxDecoration(
//                   color: AppColors.white,
//                   borderRadius: BorderRadius.circular(
//                     16,
//                   ), // 👈 Corner radius added
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black12,
//                       blurRadius: 6,
//                       offset: Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.arrow_back),
//                       iconSize: 28, // Set your desired size here
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                     const Text(
//                       "Register as Professional",
//                       style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         const Text("Already have an account? "),
//                         GestureDetector(
//                           onTap: () {},
//                           child: const Text(
//                             "Login",
//                             style: TextStyle(
//                               color: Colors.redAccent,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 20),
//                     _buildTextField("Email", controller: _emailController),
//                     _buildTextField(
//                       "Password",
//                       controller: _passwordController,
//                     ),
//                     _buildTextField(
//                       "Full Name",
//                       controller: _fullNameController,
//                     ),
//                     _buildTextField(
//                       "Father’s name",
//                       controller: _fatherNameController,
//                     ),

//                     _buildTextField(
//                       "Birth of date",
//                       suffixIcon: Icons.calendar_today,
//                       controller: _dobController,
//                       onTap: () async {
//                         final DateTime? pickedDate = await showDatePicker(
//                           context: context,
//                           initialDate: DateTime(2000),
//                           firstDate: DateTime(1900),
//                           lastDate: DateTime.now(),
//                         );

//                         if (pickedDate != null) {
//                           setState(() {
//                             _dobController.text =
//                                 "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
//                           });
//                         }
//                       },
//                     ),
//                     _buildTextField(
//                       "Phone Number",
//                       hint: "Enter Phone Number",
//                       controller: _phoneController,
//                     ),
//                     const SizedBox(height: 12),
//                     _buildDropdown(
//                       "Professional Type",
//                       Icons.map,
//                       selectedProfessionalType,
//                     ),
//                     const SizedBox(height: 12),
//                     _buildDropdown("Select State", Icons.map, selectedState),
//                     const SizedBox(height: 12),
//                     _buildDropdown(
//                       "Select City",
//                       Icons.location_city,
//                       selectedCity,
//                     ),
//                     const SizedBox(height: 20),
//                     const Text(
//                       "Upload Driver Image*",
//                       style: TextStyle(color: AppColors.buttonBg),
//                     ),
//                     const SizedBox(height: 8),
//                     GestureDetector(
//                       onTap: _pickImages,
//                       child: Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 14,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(color: Colors.grey.shade400),
//                         ),
//                         child: Row(
//                           children: [
//                             const Icon(
//                               Icons.camera_alt,
//                               color: Colors.redAccent,
//                             ),
//                             const SizedBox(width: 10),
//                             Expanded(
//                               child: Text(
//                                 _pickedImages.isNotEmpty
//                                     ? _pickedImages
//                                           .map((e) => e.name)
//                                           .join(", ")
//                                     : "No Image Uploaded.",
//                                 overflow: TextOverflow.ellipsis,
//                                 style: TextStyle(
//                                   color: _pickedImages.isNotEmpty
//                                       ? Colors.black
//                                       : Colors.grey,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     if (_pickedImages.isNotEmpty) ...[
//                       const SizedBox(height: 12),
//                       Wrap(
//                         spacing: 8,
//                         runSpacing: 8,
//                         children: _pickedImages.map((file) {
//                           return Chip(
//                             label: Text(
//                               file.name,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             deleteIcon: const Icon(Icons.close),
//                             onDeleted: () {
//                               setState(() {
//                                 _pickedImages.remove(file);
//                               });
//                             },
//                           );
//                         }).toList(),
//                       ),
//                     ],

//                     const SizedBox(height: 30),
//                     _buildRegisterButton(),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField(
//     String label, {
//     String? hint,
//     IconData? suffixIcon,
//     TextEditingController? controller,
//     VoidCallback? onTap,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: const TextStyle(color: AppColors.buttonBg)),
//         const SizedBox(height: 6),
//         TextField(
//           controller: controller,
//           readOnly:
//               onTap != null, // 👈 prevents manual typing if picker is used
//           onTap: onTap,
//           decoration: InputDecoration(
//             hintText: hint ?? 'Enter $label',
//             suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 12,
//               vertical: 14,
//             ),
//           ),
//         ),
//         const SizedBox(height: 16),
//       ],
//     );
//   }

//   Widget _buildDropdown(String label, IconData icon, RxnString selectedValue) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text("$label*", style: const TextStyle(color: AppColors.buttonBg)),
//         const SizedBox(height: 6),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12),
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey),
//             borderRadius: BorderRadius.circular(8),
//             color: Colors.white,
//           ),
//           child: Obx(
//             () => DropdownButtonFormField<String>(
//               value: selectedValue.value, // 👈 bind current value
//               hint: Text(label),
//               decoration: const InputDecoration(border: InputBorder.none),
//               icon: const Icon(Icons.keyboard_arrow_down),
//               items: [
//                 'Option 1',
//                 'Option 2',
//                 'Option 3',
//               ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
//               onChanged: (value) {
//                 selectedValue.value = value; // 👈 store into RxnString
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _headingTitle() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//       child: Row(
//         children: [
//           Image.asset('assets/headingImg.png', width: 210, height: 30),
//           const SizedBox(width: 12),
//         ],
//       ),
//     );
//   }

//   Widget _buildRegisterButton() {
//     return ElevatedButton(
//       onPressed: () async {
//         File? driverImage;
//         if (_pickedImages.isNotEmpty && _pickedImages.first.path != null) {
//           driverImage = File(_pickedImages.first.path!);
//         }

//         final model = ProfessionalSignupmodel(
//           email: _emailController.text.trim(),
//           password: _passwordController.text.trim(),
//           fatherName: _fatherNameController.text.trim(),
//           professionalType: selectedProfessionalType.value,
//           mobileNo: _phoneController.text.trim(),
//           fullName: _fullNameController.text.trim(),
//           dob: _dobController.text,
//           state: selectedState.value,
//           city: selectedCity.value,
//           driverImage: driverImage,
//         );

//         final success = await controller.registerProfessional(model);
//       },
//       style: ElevatedButton.styleFrom(
//         backgroundColor: AppColors.buttonBg,
//         minimumSize: const Size(double.infinity, 50),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//       child: const Text("Register", style: TextStyle(color: Colors.white)),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:wheelboard/constants/apps_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import '../controllers/professional_signup_controller.dart';
import '../models/professional_signupmodel.dart';
import 'dart:io' show File; // only available on mobile

class ProfessionalRegisterScreen extends StatefulWidget {
  const ProfessionalRegisterScreen({super.key});

  @override
  State<ProfessionalRegisterScreen> createState() =>
      _ProfessionalRegisterScreenState();
}

class _ProfessionalRegisterScreenState
    extends State<ProfessionalRegisterScreen> {
  final ProfessionalController controller = Get.put(ProfessionalController());

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final RxnString selectedProfessionalType = RxnString();
  final RxnString selectedState = RxnString();
  final RxnString selectedCity = RxnString();

  List<PlatformFile> _pickedImages = [];

  Future<void> _pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true, // ensures bytes available on web
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _pickedImages = result.files;
      });
    }
  }

  // @override
  // void dispose() {
  //   _emailController.dispose();
  //   _passwordController.dispose();
  //   _fullNameController.dispose();
  //   _fatherNameController.dispose();
  //   _dobController.dispose();
  //   _phoneController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final padding = width * 0.08;

    return Scaffold(
      backgroundColor: const Color(0xFFFDECEC),
      appBar: null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _headingTitle(),

              Container(
                padding: const EdgeInsets.fromLTRB(16, 5, 16, 0),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      iconSize: 28,
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      "Register as Professional",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text("Already have an account? "),
                        GestureDetector(
                          onTap: () {},
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Input fields
                    _buildTextField("Email", controller: _emailController),
                    _buildTextField(
                      "Password",
                      controller: _passwordController,
                    ),
                    _buildTextField(
                      "Full Name",
                      controller: _fullNameController,
                    ),
                    _buildTextField(
                      "Father’s name",
                      controller: _fatherNameController,
                    ),

                    // DOB (readOnly + fix context menu)
                    _buildTextField(
                      "Birth of date",
                      suffixIcon: Icons.calendar_today,
                      controller: _dobController,
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime(2000),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _dobController.text =
                                "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                          });
                        }
                      },
                    ),

                    _buildTextField(
                      "Phone Number",
                      hint: "Enter Phone Number",
                      controller: _phoneController,
                    ),

                    const SizedBox(height: 12),
                    _buildDropdown(
                      "Professional Type",
                      Icons.work,
                      selectedProfessionalType,
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown("Select State", Icons.map, selectedState),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      "Select City",
                      Icons.location_city,
                      selectedCity,
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      "Upload Driver Image*",
                      style: TextStyle(color: AppColors.buttonBg),
                    ),
                    const SizedBox(height: 8),

                    // Image picker UI
                    GestureDetector(
                      onTap: _pickImages,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.camera_alt,
                              color: Colors.redAccent,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _pickedImages.isNotEmpty
                                    ? _pickedImages
                                          .map((e) => e.name)
                                          .join(", ")
                                    : "No Image Uploaded.",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: _pickedImages.isNotEmpty
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (_pickedImages.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _pickedImages.map((file) {
                          return Chip(
                            label: Text(
                              file.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                            deleteIcon: const Icon(Icons.close),
                            onDeleted: () {
                              setState(() {
                                _pickedImages.remove(file);
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],

                    const SizedBox(height: 30),
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

  // 🔹 TextField builder with fix for readOnly context menu
  Widget _buildTextField(
    String label, {
    String? hint,
    IconData? suffixIcon,
    TextEditingController? controller,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.buttonBg)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: onTap != null,
          onTap: onTap,
          contextMenuBuilder: (context, editableTextState) {
            // Prevent crash on readOnly fields
            if (onTap != null) return const SizedBox.shrink();
            return AdaptiveTextSelectionToolbar.editableText(
              editableTextState: editableTextState,
            );
          },
          decoration: InputDecoration(
            hintText: hint ?? 'Enter $label',
            suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDropdown(String label, IconData icon, RxnString selectedValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label*", style: const TextStyle(color: AppColors.buttonBg)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Obx(
            () => DropdownButtonFormField<String>(
              value: selectedValue.value,
              hint: Text(label),
              decoration: const InputDecoration(border: InputBorder.none),
              icon: const Icon(Icons.keyboard_arrow_down),
              items: [
                'kolkata',
                'Gujarat',
                'Rajasthan',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (value) => selectedValue.value = value,
            ),
          ),
        ),
      ],
    );
  }

  Widget _headingTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Image.asset('assets/headingImg.png', width: 210, height: 30),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: () async {
        File? driverImage;

        // Mobile: get File path
        if (_pickedImages.isNotEmpty && _pickedImages.first.path != null) {
          driverImage = File(_pickedImages.first.path!);
        }

        // Web: can use _pickedImages.first.bytes if needed

        final model = ProfessionalSignupmodel(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          fatherName: _fatherNameController.text.trim(),
          professionalType: selectedProfessionalType.value,
          mobileNo: _phoneController.text.trim(),
          fullName: _fullNameController.text.trim(),
          dob: _dobController.text,
          state: selectedState.value,
          city: selectedCity.value,
          driverImage: driverImage,
        );

        await controller.registerProfessional(model);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.buttonBg,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Text("Register", style: TextStyle(color: Colors.white)),
    );
  }
}
