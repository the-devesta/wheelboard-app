// import 'dart:io' show File;
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:wheelboard/constants/apps_colors.dart';

// class AddVehicleScreen extends StatefulWidget {
//   const AddVehicleScreen({super.key});

//   @override
//   State<AddVehicleScreen> createState() => _AddVehicleScreenState();
// }

// class _AddVehicleScreenState extends State<AddVehicleScreen> {
//   // Hold selected images
//   List<PlatformFile> _pickedImages = [];

//   Future<void> _pickImages() async {
//     final result = await FilePicker.platform.pickFiles(
//       type: FileType.image,
//       allowMultiple: true,
//       withData: true, // important for Web thumbnails
//     );
//     if (result != null && result.files.isNotEmpty) {
//       setState(() => _pickedImages = result.files);
//       // TODO: If you also need to upload to a server, do it here,
//       // then update UI as "uploaded successfully" based on the result.
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFDECEC),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: Text(
//           "Add new Vehicle",
//           style: GoogleFonts.poppins(
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//             color: Colors.black,
//           ),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Container(
//           width: double.infinity,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: Text(
//                   "Vehicle Details",
//                   style: GoogleFonts.poppins(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.grey[800],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),

//               // Vehicle Model
//               _buildTextField(
//                 "Vehicle Model",
//                 "Tata-5218",
//                 suffix: const Icon(Icons.local_shipping, color: Colors.red),
//               ),

//               // Vehicle Number
//               _buildTextField("Vehicle Number:", "DD Q9 1644"),

//               // Manufacturing Year + Ownership Row
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Expanded(
//                     child: _buildTextField(
//                       "Vehicle Manufacturing Year",
//                       "1999",
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "Ownership",
//                           style: GoogleFonts.poppins(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                             color: Colors.grey[700],
//                           ),
//                         ),
//                         Row(
//                           children: [
//                             Checkbox(value: true, onChanged: (_) {}),
//                             Text(
//                               "Owned",
//                               style: GoogleFonts.poppins(fontSize: 14),
//                             ),
//                           ],
//                         ),
//                         Row(
//                           children: [
//                             Checkbox(value: false, onChanged: (_) {}),
//                             Text(
//                               "Attached",
//                               style: GoogleFonts.poppins(fontSize: 14),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 8),
//               Text(
//                 "Select Vehicle type",
//                 style: GoogleFonts.poppins(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.grey[700],
//                 ),
//               ),
//               const SizedBox(height: 6),
//               DropdownButtonFormField<String>(
//                 items: const [
//                   DropdownMenuItem(value: "truck", child: Text("Truck")),
//                   DropdownMenuItem(value: "bus", child: Text("Bus")),
//                 ],
//                 onChanged: (value) {},
//                 decoration: InputDecoration(
//                   hintText: "Select type of vehicle",
//                   hintStyle: GoogleFonts.poppins(color: Colors.grey),
//                   filled: true,
//                   fillColor: Colors.white,
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 12,
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(
//                       color: Colors.grey.withOpacity(0.5),
//                       width: 1.5,
//                     ),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: const BorderSide(
//                       color: Colors.deepPurpleAccent,
//                       width: 2,
//                     ),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 16),
//               Text(
//                 "Description",
//                 style: GoogleFonts.poppins(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.grey[700],
//                 ),
//               ),
//               const SizedBox(height: 6),
//               TextField(
//                 maxLines: 3,
//                 decoration: InputDecoration(
//                   hintText: "Description",
//                   hintStyle: GoogleFonts.poppins(color: Colors.grey),
//                   filled: true,
//                   fillColor: Colors.white,
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(
//                       color: Colors.grey.withOpacity(0.5),
//                       width: 1.5,
//                     ),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: const BorderSide(
//                       color: Colors.deepPurpleAccent,
//                       width: 2.0,
//                     ),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       "By adding this you are explicitly entitled to submit the information and is correct.",
//                       style: GoogleFonts.poppins(
//                         fontSize: 12,
//                         color: Colors.black87,
//                       ),
//                     ),
//                   ),
//                   Switch(value: false, onChanged: (_) {}),
//                 ],
//               ),

//               const SizedBox(height: 16),
//               Text(
//                 "Upload Images of vehicles or Job Poster",
//                 style: GoogleFonts.poppins(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.grey[700],
//                 ),
//               ),
//               const SizedBox(height: 8),

//               // Upload button (keeps your gradient container)
//               ElevatedButton.icon(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFFF5C5C),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     side: const BorderSide(
//                       // 👈 border color and width
//                       color: Colors.white,
//                       width: 2,
//                     ),
//                   ),
//                   elevation: 4,
//                 ),
//                 onPressed: _pickImages,
//                 label: const Text(
//                   "Upload",
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),

//               // File name list with "uploaded successfully"
//               if (_pickedImages.isNotEmpty) const SizedBox(height: 12),
//               ..._pickedImages.map(
//                 (f) => Padding(
//                   padding: const EdgeInsets.only(bottom: 4),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           f.name,
//                           style: GoogleFonts.poppins(
//                             fontSize: 13,
//                             color: Colors.grey[800],
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         "uploaded successfully",
//                         style: GoogleFonts.poppins(
//                           color: Colors.green,
//                           fontSize: 12,
//                           fontStyle: FontStyle.italic,
//                         ),
//                       ),
//                       IconButton(
//                         tooltip: 'Remove',
//                         onPressed: () =>
//                             setState(() => _pickedImages.remove(f)),
//                         icon: const Icon(
//                           Icons.close,
//                           size: 18,
//                           color: Colors.redAccent,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               // Tiny preview grid
//               if (_pickedImages.isNotEmpty) const SizedBox(height: 8),
//               if (_pickedImages.isNotEmpty)
//                 GridView.builder(
//                   itemCount: _pickedImages.length,
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 3,
//                     mainAxisSpacing: 8,
//                     crossAxisSpacing: 8,
//                   ),
//                   itemBuilder: (context, i) {
//                     final file = _pickedImages[i];
//                     Widget img;
//                     if (kIsWeb) {
//                       img = Image.memory(file.bytes!, fit: BoxFit.cover);
//                     } else {
//                       img = Image.file(File(file.path!), fit: BoxFit.cover);
//                     }
//                     return ClipRRect(
//                       borderRadius: BorderRadius.circular(8),
//                       child: Stack(
//                         fit: StackFit.expand,
//                         children: [
//                           img,
//                           Positioned(
//                             right: 4,
//                             top: 4,
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 color: Colors.black54,
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: const Icon(
//                                 Icons.image,
//                                 size: 14,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),

//               const SizedBox(height: 20),
//               Container(
//                 width: double.infinity,
//                 decoration: BoxDecoration(),
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.buttonBg,
//                     shadowColor: Colors.transparent,
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   onPressed: () {
//                     // Submit payload that includes: _pickedImages
//                   },
//                   child: Text(
//                     "Add Now",
//                     style: GoogleFonts.poppins(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField(String label, String hint, {Widget? suffix}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: GoogleFonts.poppins(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//             color: Colors.grey[700],
//           ),
//         ),
//         const SizedBox(height: 6),
//         TextField(
//           decoration: InputDecoration(
//             hintText: hint,
//             hintStyle: GoogleFonts.poppins(color: Colors.grey),
//             suffixIcon: suffix,
//             filled: true,
//             fillColor: Colors.white,
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(
//                 color: Colors.grey.withOpacity(0.5),
//                 width: 1.5,
//               ),
//             ),
//             focusedBorder: const OutlineInputBorder(
//               borderRadius: BorderRadius.all(Radius.circular(12)),
//               borderSide: BorderSide(
//                 color: Colors.deepPurpleAccent,
//                 width: 2.0,
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 16),
//       ],
//     );
//   }
// }

import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart'; // ✅ for controller
import 'package:wheelboard/constants/apps_colors.dart';
import '../models/add_new_vehicle_model.dart';
import '../controllers/add_new_vehicle_controller.dart';
import '../utils/session_manager.dart';

class AddVehicleScreen extends StatefulWidget {
  final VehicleModel? vehicleData; // ✅ For edit mode
  final bool isEditMode; // ✅ To determine if it's add or edit
  
  const AddVehicleScreen({
    super.key,
    this.vehicleData,
    this.isEditMode = false,
  });

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  // Controllers for input fields
  final TextEditingController _vehicleModelController = TextEditingController();
  final TextEditingController _vehicleNumberController =
      TextEditingController();
  final TextEditingController _manufacturingYearController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _ownershipType = "Owned";
  String? _vehicleType;
  bool _isDeclarationAccepted = false;

  // Hold selected images
  List<PlatformFile> _pickedImages = [];

  // GetX Controller
  final AddVehicleController _vehicleController = Get.put(
    AddVehicleController(),
  );

  @override
  void initState() {
    super.initState();
    // ✅ Populate fields if in edit mode
    if (widget.isEditMode && widget.vehicleData != null) {
      final vehicle = widget.vehicleData!;
      _vehicleModelController.text = vehicle.vehicleModel ?? '';
      _vehicleNumberController.text = vehicle.vehicleNumber ?? '';
      _manufacturingYearController.text = vehicle.manufacturingYear?.toString() ?? '';
      _descriptionController.text = vehicle.description ?? '';
      _ownershipType = vehicle.ownershipType ?? "Owned";
      _vehicleType = vehicle.vehicleType;
      _isDeclarationAccepted = vehicle.isDeclarationAccepted ?? false;
    }
  }

  Future<void> _pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true, // needed for web thumbnails
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _pickedImages = result.files);
    }
  }

  Future<void> _submitVehicle() async {
    // Convert PlatformFile → File (only for mobile/desktop, not web)
    final sessionManager = SessionManager();
    final token = await sessionManager.getString("authToken") ?? "";
    final userId = await sessionManager.getString("userId") ?? "";
    final List<File> files = [];
    if (!kIsWeb) {
      for (final p in _pickedImages) {
        if (p.path != null) files.add(File(p.path!));
      }
    }

    // Build model
    final vehicleModel = VehicleModel(
      userId: userId,
      vehicleId: widget.isEditMode ? widget.vehicleData?.vehicleId : null,
      vehicleModel: _vehicleModelController.text,
      vehicleNumber: _vehicleNumberController.text,
      manufacturingYear: int.tryParse(_manufacturingYearController.text),
      ownershipType: _ownershipType,
      vehicleType: _vehicleType,
      description: _descriptionController.text,
      isDeclarationAccepted: _isDeclarationAccepted,
      images: files,
    );

    bool success;
    if (widget.isEditMode) {
      success = await _vehicleController.updateVehicle(vehicleModel, token);
    } else {
      success = await _vehicleController.addVehicle(vehicleModel, token);
    }

    if (success) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDECEC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.isEditMode ? "Edit Vehicle" : "Add new Vehicle",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Obx(() {
        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "Vehicle Details",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Vehicle Model
                    _buildTextField(
                      "Vehicle Model",
                      "Tata-5218",
                      controller: _vehicleModelController,
                      suffix: const Icon(
                        Icons.local_shipping,
                        color: Colors.red,
                      ),
                    ),

                    // Vehicle Number
                    _buildTextField(
                      "Vehicle Number:",
                      "DD Q9 1644",
                      controller: _vehicleNumberController,
                    ),

                    // Manufacturing Year + Ownership Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildTextField(
                            "Vehicle Manufacturing Year",
                            "1999",
                            controller: _manufacturingYearController,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Ownership",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Row(
                                children: [
                                  Checkbox(
                                    value: _ownershipType == "Owned",
                                    onChanged: (v) => setState(() {
                                      _ownershipType = "Owned";
                                    }),
                                  ),
                                  Text(
                                    "Owned",
                                    style: GoogleFonts.poppins(fontSize: 14),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Checkbox(
                                    value: _ownershipType == "Attached",
                                    onChanged: (v) => setState(() {
                                      _ownershipType = "Attached";
                                    }),
                                  ),
                                  Text(
                                    "Attached",
                                    style: GoogleFonts.poppins(fontSize: 14),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    Text(
                      "Select Vehicle type",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      items: const [
                        DropdownMenuItem(value: "truck", child: Text("Truck")),
                        DropdownMenuItem(value: "bus", child: Text("Bus")),
                      ],
                      onChanged: (value) =>
                          setState(() => _vehicleType = value),
                      decoration: InputDecoration(
                        hintText: "Select type of vehicle",
                        hintStyle: GoogleFonts.poppins(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    Text(
                      "Description",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Description",
                        hintStyle: GoogleFonts.poppins(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "By adding this you are explicitly entitled to submit the information and is correct.",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Switch(
                          value: _isDeclarationAccepted,
                          onChanged: (v) =>
                              setState(() => _isDeclarationAccepted = v),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    Text(
                      "Upload Images of vehicles or Job Poster",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),

                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5C5C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.white, width: 2),
                        ),
                        elevation: 4,
                      ),
                      onPressed: _pickImages,
                      label: const Text(
                        "Upload",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                    if (_pickedImages.isNotEmpty) const SizedBox(height: 12),
                    ..._pickedImages.map(
                      (f) => Row(
                        children: [
                          Expanded(
                            child: Text(
                              f.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "uploaded successfully",
                            style: TextStyle(color: Colors.green),
                          ),
                          IconButton(
                            tooltip: 'Remove',
                            onPressed: () =>
                                setState(() => _pickedImages.remove(f)),
                            icon: const Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_pickedImages.isNotEmpty) const SizedBox(height: 8),
                    if (_pickedImages.isNotEmpty)
                      GridView.builder(
                        itemCount: _pickedImages.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                            ),
                        itemBuilder: (context, i) {
                          final file = _pickedImages[i];
                          Widget img;
                          if (kIsWeb) {
                            img = Image.memory(file.bytes!, fit: BoxFit.cover);
                          } else {
                            img = Image.file(
                              File(file.path!),
                              fit: BoxFit.cover,
                            );
                          }
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: img,
                          );
                        },
                      ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonBg,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _submitVehicle,
                        child: Text(
                          "Add Now",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Show loader overlay
            if (_vehicleController.isLoading.value)
              const Center(child: CircularProgressIndicator()),
          ],
        );
      }),
    );
  }

  Widget _buildTextField(
    String label,
    String hint, {
    Widget? suffix,
    TextEditingController? controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffix,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.5),
                width: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
