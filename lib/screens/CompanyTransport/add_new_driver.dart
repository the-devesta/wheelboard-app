import 'dart:typed_data';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import '../../controllers/Transport/add_driver_controller.dart';
import '../../controllers/Transport/fleet_controller.dart';
import '../../models/add_drivermodel.dart';
import '../../utils/session_manager.dart';
import '../../utils/app_logger.dart';

class AddNewDriverScreen extends StatefulWidget {
  final DriverModel? driverData; // ✅ For edit mode
  final bool isEditMode; // ✅ To determine if it's add or edit

  const AddNewDriverScreen({
    super.key,
    this.driverData,
    this.isEditMode = false,
  });

  @override
  State<AddNewDriverScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddNewDriverScreen> {
  final AddDriverController addDriverController = Get.put(
    AddDriverController(),
  );

  final TextEditingController driverNameController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // ✅ Driver License Search Fields
  final TextEditingController licenseNumberController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  String? selectedVehicleType;
  bool isDeclarationAccepted = false;
  XFile? _pickedImage; // ✅ Single image only
  DateTime? _selectedDob; // ✅ For date of birth

  // Valid vehicle types for dropdown
  static const List<String> validVehicleTypes = [
    "Shipment",
    "Construction",
    "Mining",
    "Others",
  ];

  @override
  void initState() {
    super.initState();
    // ✅ Populate fields if in edit mode
    if (widget.isEditMode && widget.driverData != null) {
      final driver = widget.driverData!;
      driverNameController.text = driver.fullName ?? '';
      contactNumberController.text = driver.contactNumber ?? '';
      descriptionController.text = driver.description ?? '';
      licenseNumberController.text = driver.dlNo ?? '';
      _selectedDob = driver.dateOfBirth;
      String dob = _formatDate(_selectedDob!);
      debugPrint('$dob dob===>>>');
      dobController.text = dob;
      // ✅ Only set selectedVehicleType if it's in the valid list
      final vehicleType = driver.vehicleType;
      if (vehicleType != null && validVehicleTypes.contains(vehicleType)) {
        selectedVehicleType = vehicleType;
      } else {
        selectedVehicleType = null; // Set to null if not in valid list
      }
      isDeclarationAccepted = driver.isDeclarationAccepted ?? false;
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
    }
  }

  /// Select Date of Birth
  Future<void> _selectDateOfBirth() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate:
          _selectedDob ??
          DateTime.now().subtract(
            const Duration(days: 365 * 18),
          ), // Default to 18 years ago
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(
        const Duration(days: 365 * 18),
      ), // Must be at least 18 years old
      helpText: 'Select Date of Birth',
      cancelText: 'Cancel',
      confirmText: 'Select',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1976D2), // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1976D2), // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDob = pickedDate;
        dobController.text = _formatDate(pickedDate);
      });
    }
  }

  /// Format date to DD/MM/YYYY
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _submitForm() async {
    final sessionManager = SessionManager();

    // 🔹 Load values with safety checks
    final token = await sessionManager.getString("authToken");
    final userId = await sessionManager.getString("userId");

    if (token == null || token.isEmpty) {
      Get.snackbar("Error", "Authentication token not found. Please log in.");
      return;
    }

    if (userId == null || userId.isEmpty) {
      Get.snackbar("Error", "UserId not found. Please log in again.");
      return;
    }
    if (dobController.text.isEmpty) {
      Get.snackbar("Error", "Please select dob");
      return;
    }
    if (licenseNumberController.text.isEmpty) {
      Get.snackbar("Error", "Please enter license no.");
      return;
    }

    AppLogger.d("👉 Using Token: $token");
    AppLogger.d("👉 Using UserId: $userId");

    final File? imageFile = _pickedImage != null && !kIsWeb
        ? File(_pickedImage!.path)
        : null;

    final driverModel = DriverModel(
      userId: userId,
      driverId: widget.isEditMode ? widget.driverData?.driverId : null,
      fullName: driverNameController.text.trim(),
      contactNumber: contactNumberController.text.trim(),
      vehicleType: selectedVehicleType,
      vehicleNumber: null, // ✅ Removed vehicle number field
      description: descriptionController.text.trim(),
      isDeclarationAccepted: isDeclarationAccepted,
      image: imageFile, // ✅ single file
      partnerId: null, // ✅ Removed partner ID field
      modifiedUserId: userId, // ✅ For update operations
      dlNo: licenseNumberController.text.trim(), // ✅ Driver License Number
      dateOfBirth: _selectedDob, // ✅ Date of Birth
    );

    AppLogger.d("Driver Fields Payload => ${driverModel.toJsonFields()}");
    AppLogger.d("Driver Image Path => ${driverModel.image?.path}");

    // 🔹 Add small delay (ensures async values + file stream ready)
    await Future.delayed(const Duration(milliseconds: 200));

    bool isSuccess;
    if (widget.isEditMode) {
      isSuccess = await addDriverController.updateDriver(driverModel, token);
    } else {
      isSuccess = await addDriverController.addDriver(driverModel, token);
    }

    if (isSuccess) {
      // Auto-refresh fleet data
      try {
        final fleetController = Get.find<DriverController>();
        final sessionManager = SessionManager();
        final refreshToken = await sessionManager.getString("authToken");
        final refreshUserId = await sessionManager.getString("userId");

        if (refreshToken != null && refreshUserId != null) {
          await fleetController.fetchDrivers();
        }
      } catch (e) {
        AppLogger.d("⚠️ Could not refresh fleet data: $e");
      }

      Navigator.of(context).pop();
    }
  }

  // void _submitForm() async {
  //   final sessionManager = SessionManager();
  //   final token = await sessionManager.getString("authToken");
  //   final userId = await sessionManager.getString("userId");

  //   if (token == null) {
  //     Get.snackbar("Error", "Authentication token not found. Please log in.");
  //     return;
  //   }

  //   final File? imageFile = _pickedImage != null && !kIsWeb
  //       ? File(_pickedImage!.path)
  //       : null;

  //   final partnerId = int.tryParse(partnerIdController.text.trim());

  //   final driverModel = DriverModel(
  //     userId: userId,
  //     fullName: driverNameController.text.trim(),
  //     contactNumber: contactNumberController.text.trim(),
  //     vehicleType: selectedVehicleType,
  //     vehicleNumber: vehicleNumberController.text.trim(),
  //     description: descriptionController.text.trim(),
  //     isDeclarationAccepted: isDeclarationAccepted,
  //     image: imageFile, // ✅ single file
  //     partnerId: partnerId, // ✅ integer
  //   );

  //   bool isSuccess = await addDriverController.addDriver(driverModel, token);

  //   if (isSuccess) {
  //     Navigator.of(context).pop();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4E3E3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.isEditMode ? "Edit Driver" : "Add new Driver",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: const Color(0xFF1E1E1E),
            letterSpacing: -0.14,
          ),
        ),
        leading: const BackButton(color: Colors.black),

        shape: const Border(
          bottom: BorderSide(color: Color(0xFFFCD2D2), width: 1),
        ),
      ),
      body: Obx(() {
        if (addDriverController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFF25C5C)),
          );
        }

        return SingleChildScrollView(
          child: Center(
            child: Container(
              margin: const EdgeInsets.only(top: 24),
              width: 343,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        "Driver Details",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: const Color(0xFF6C7278),
                          letterSpacing: -0.32,
                        ),
                      ),
                    ),
                  ),

                  // ✅ Driver License Search Section
                  // Container(
                  //   padding: const EdgeInsets.all(12),
                  //   decoration: BoxDecoration(
                  //     color: const Color(0xFFE3F2FD),
                  //     borderRadius: BorderRadius.circular(10),
                  //     border: Border.all(
                  //       color: const Color(0xFF90CAF9),
                  //       width: 1,
                  //     ),
                  //   ),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Row(
                  //         children: [
                  //           const Icon(
                  //             Icons.search,
                  //             color: Color(0xFF1976D2),
                  //             size: 18,
                  //           ),
                  //           const SizedBox(width: 6),
                  //           Text(
                  //             "Quick License Search",
                  //             style: TextStyle(
                  //               fontSize: 14,
                  //               fontWeight: FontWeight.w600,
                  //               fontFamily: 'Poppins',
                  //               color: const Color(0xFF1976D2),
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //       const SizedBox(height: 8),
                  //       Text(
                  //         "Enter license details to auto-fill driver info",
                  //         style: TextStyle(
                  //           fontSize: 11,
                  //           fontFamily: 'Poppins',
                  //           color: const Color(0xFF1565C0),
                  //         ),
                  //       ),
                  //       const SizedBox(height: 12),

                  //       // License Number Field
                  //       Container(
                  //         width: double.infinity,
                  //         height: 48,
                  //         decoration: BoxDecoration(
                  //           color: Colors.white,
                  //           borderRadius: BorderRadius.circular(10),
                  //           border: Border.all(
                  //             color: const Color(0xFFEDF1F3),
                  //             width: 1,
                  //           ),
                  //         ),
                  //         child: TextField(
                  //           controller: licenseNumberController,
                  //           textAlign: TextAlign.left,
                  //           style: TextStyle(
                  //             fontSize: 14,
                  //             fontFamily: 'Poppins',
                  //             color: const Color(0xFF6C7278),
                  //           ),
                  //           decoration: InputDecoration(
                  //             hintText:
                  //                 "License Number (e.g., HR-2620140187259)",
                  //             hintStyle: TextStyle(
                  //               fontSize: 14,
                  //               fontFamily: 'Poppins',
                  //               color: const Color(0xFF6C7278),
                  //             ),
                  //             border: InputBorder.none,
                  //             contentPadding: const EdgeInsets.symmetric(
                  //               horizontal: 14,
                  //               vertical: 14,
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //       const SizedBox(height: 8),

                  //       // Date of Birth Field with Calendar
                  //       GestureDetector(
                  //         onTap: _selectDateOfBirth,
                  //         child: Container(
                  //           width: double.infinity,
                  //           height: 48,
                  //           decoration: BoxDecoration(
                  //             color: Colors.white,
                  //             borderRadius: BorderRadius.circular(10),
                  //             border: Border.all(
                  //               color: const Color(0xFFEDF1F3),
                  //               width: 1,
                  //             ),
                  //           ),
                  //           child: Row(
                  //             children: [
                  //               const SizedBox(width: 14),
                  //               Expanded(
                  //                 child: Text(
                  //                   _selectedDob != null
                  //                       ? _formatDate(_selectedDob!)
                  //                       : "Date of Birth (DD/MM/YYYY)",
                  //                   style: TextStyle(
                  //                     fontSize: 14,
                  //                     fontFamily: 'Poppins',
                  //                     color: _selectedDob != null
                  //                         ? const Color(0xFF1E1E1E)
                  //                         : const Color(0xFF6C7278),
                  //                   ),
                  //                 ),
                  //               ),
                  //               const Padding(
                  //                 padding: EdgeInsets.only(right: 14),
                  //                 child: Icon(
                  //                   Icons.calendar_today,
                  //                   size: 18,
                  //                   color: Color(0xFF1976D2),
                  //                 ),
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //       ),
                  //       const SizedBox(height: 12),

                  //       // Search Button
                  //       SizedBox(
                  //         width: double.infinity,
                  //         height: 48,
                  //         child: ElevatedButton.icon(
                  //           onPressed: _isSearchingDriver
                  //               ? null
                  //               : _searchDriverLicense,
                  //           icon: _isSearchingDriver
                  //               ? const SizedBox(
                  //                   width: 18,
                  //                   height: 18,
                  //                   child: CircularProgressIndicator(
                  //                     strokeWidth: 2,
                  //                     valueColor: AlwaysStoppedAnimation<Color>(
                  //                       Colors.white,
                  //                     ),
                  //                   ),
                  //                 )
                  //               : const Icon(Icons.search, size: 20),
                  //           label: Text(
                  //             _isSearchingDriver
                  //                 ? "Searching..."
                  //                 : "Search License Details",
                  //             style: TextStyle(
                  //               fontSize: 14,
                  //               fontFamily: 'Poppins',
                  //               fontWeight: FontWeight.w600,
                  //             ),
                  //           ),
                  //           style: ElevatedButton.styleFrom(
                  //             backgroundColor: const Color(0xFF1976D2),
                  //             foregroundColor: Colors.white,
                  //             shape: RoundedRectangleBorder(
                  //               borderRadius: BorderRadius.circular(10),
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  const SizedBox(height: 17),
                  _buildTextField(
                    "Driver Name",
                    "Enter Driver Name",
                    controller: driverNameController,
                  ),
                  const SizedBox(height: 17),
                  _buildTextField(
                    "License No.",
                    "Enter License No.",
                    controller: licenseNumberController,
                  ),
                  const SizedBox(height: 17),
                  Text(
                    "Select DOB",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Plus Jakarta Sans',
                      color: const Color(0xFF6C7278),
                      letterSpacing: -0.24,
                    ),
                  ),

                  const SizedBox(height: 2),
                  GestureDetector(
                    onTap: _selectDateOfBirth,
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFEDF1F3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              _selectedDob != null
                                  ? _formatDate(_selectedDob!)
                                  : "Date of Birth (DD/MM/YYYY)",
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                color: _selectedDob != null
                                    ? const Color(0xFF1E1E1E)
                                    : const Color(0xFF6C7278),
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(right: 14),
                            child: Icon(
                              Icons.calendar_today,
                              size: 18,
                              color: Color(0xFF1976D2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 17),

                  _buildTextField(
                    "Contact Number",
                    "Enter Number",
                    controller: contactNumberController,
                  ),
                  const SizedBox(height: 17),

                  // Vehicle Type Dropdown
                  Text(
                    "Select Vehicle type",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Poppins',
                      color: const Color(0xFF535353),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFEDF1F3),
                        width: 1,
                      ),
                    ),
                    child: DropdownButtonFormField<String>(
                      initialValue: selectedVehicleType,
                      items: const [
                        DropdownMenuItem(
                          value: "Shipment",
                          child: Text("Shipment"),
                        ),
                        DropdownMenuItem(
                          value: "Construction",
                          child: Text("Construction"),
                        ),
                        DropdownMenuItem(
                          value: "Mining",
                          child: Text("Mining"),
                        ),
                        DropdownMenuItem(
                          value: "Others",
                          child: Text("Others (specify)"),
                        ),
                      ],
                      onChanged: (value) =>
                          setState(() => selectedVehicleType = value),
                      decoration: InputDecoration(
                        hintText: "Select type of vehicle",
                        hintStyle: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          color: const Color(0xFF6C7278),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                      icon: const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: Color(0xFF006FFD),
                          size: 20,
                        ),
                      ),
                      dropdownColor: Colors.white,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        color: const Color(0xFF1E1E1E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 17),

                  _buildTextField(
                    "Description",
                    "Enter Description",
                    controller: descriptionController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 17),

                  // Declaration Switch
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "By adding this you are explicitly entitled to submit the information and is correct.",
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            color: const Color(0xFF1E1E1E),
                          ),
                        ),
                      ),
                      Switch(
                        value: isDeclarationAccepted,
                        onChanged: (value) =>
                            setState(() => isDeclarationAccepted = value),
                        activeThumbColor: const Color(0xFFF25C5C),
                      ),
                    ],
                  ),
                  const SizedBox(height: 17),

                  // Upload Image Section
                  Text(
                    "Upload Vehicle / Driver Image",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Plus Jakarta Sans',
                      color: const Color(0xFF6C7278),
                      letterSpacing: -0.24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF25C5C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _pickImage,
                      icon: const Icon(
                        Icons.upload,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: Text(
                        "Upload",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  if (_pickedImage != null) ...[
                    const SizedBox(height: 12),
                    FutureBuilder<Uint8List>(
                      future: _pickedImage!.readAsBytes(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox(
                            width: 100,
                            height: 100,
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        }
                        if (!snapshot.hasData) {
                          return const SizedBox(
                            width: 100,
                            height: 100,
                            child: Center(child: Icon(Icons.error)),
                          );
                        }
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(
                                snapshot.data!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: -8,
                              right: -8,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _pickedImage = null;
                                  });
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFF25C5C),
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Submit Button
                  Center(
                    child: SizedBox(
                      width: 295,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF25C5C),
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 24,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _submitForm,
                        child: Text(
                          widget.isEditMode ? "Update Driver" : "Add Now",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            letterSpacing: -0.14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTextField(
    String label,
    String hint, {
    TextEditingController? controller,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            fontFamily: 'Plus Jakarta Sans',
            color: const Color(0xFF6C7278),
            letterSpacing: -0.24,
          ),
        ),
        const SizedBox(height: 2),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: _inputDecoration(
            hint: hint,
            borderColor: const Color(0xFFEDF1F3),
            height: 46,
          ),
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Inter',
            color: const Color(0xFF6C7278),
            letterSpacing: -0.14,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    String? hint,
    Widget? suffixIcon,
    Color? borderColor,
    double? height,
  }) {
    final color = borderColor ?? const Color(0xFFEDF1F3);

    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      suffixIcon: suffixIcon,
      hintStyle: TextStyle(
        fontSize: 14,
        fontFamily: 'Inter',
        color: const Color(0xFF6C7278),
        letterSpacing: -0.14,
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 14,
        vertical: height != null ? (height - 21) / 2 : 12.5,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color, width: 1),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color, width: 1),
      ),
      constraints: height != null ? BoxConstraints(minHeight: height) : null,
    );
  }
}
