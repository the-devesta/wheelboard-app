import 'dart:typed_data';
import 'dart:io' show File;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wheelboard/constants/apps_colors.dart';
import 'package:get/get.dart';
import '../controllers/add_driver_controller.dart';
import '../models/add_drivermodel.dart';
import '../models/driver_license_model.dart';
import '../utils/session_manager.dart';
import '../apihelperclass/api_helper.dart';
import '../widgets/custom_snackbar.dart';

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
  final TextEditingController vehicleNumberController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController partnerIdController = TextEditingController();
  
  // ✅ Driver License Search Fields
  final TextEditingController licenseNumberController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  String? selectedVehicleType;
  bool isDeclarationAccepted = false;
  bool _isSearchingDriver = false; // ✅ For driver search loading
  XFile? _pickedImage; // ✅ Single image only

  @override
  void initState() {
    super.initState();
    // ✅ Populate fields if in edit mode
    if (widget.isEditMode && widget.driverData != null) {
      final driver = widget.driverData!;
      driverNameController.text = driver.fullName ?? '';
      contactNumberController.text = driver.contactNumber ?? '';
      vehicleNumberController.text = driver.vehicleNumber ?? '';
      descriptionController.text = driver.description ?? '';
      partnerIdController.text = driver.partnerId?.toString() ?? '';
      selectedVehicleType = driver.vehicleType;
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

  /// Search driver license details by license number and DOB
  Future<void> _searchDriverLicense() async {
    final licenseNumber = licenseNumberController.text.trim();
    final dob = dobController.text.trim();
    
    if (licenseNumber.isEmpty || dob.isEmpty) {
      SnackBarHelper.warning("Please enter both license number and date of birth");
      return;
    }

    setState(() {
      _isSearchingDriver = true;
    });

    try {
      SnackBarHelper.loading("Searching driver license details...");
      
      final response = await HttpHelper.getLicenseDetails(
        number: licenseNumber,
        dob: dob,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['code'] == 200 && data['result'] != null) {
          final licenseDetails = DriverLicenseModel.fromJson(data);
          
          // ✅ Auto-fill the form with fetched data
          driverNameController.text = licenseDetails.detailsOfDrivingLicence.name;
          
          // Extract vehicle types from badge details
          if (licenseDetails.badgeDetails.isNotEmpty) {
            final vehicleClasses = licenseDetails.badgeDetails.first.classOfVehicle;
            if (vehicleClasses.isNotEmpty) {
              selectedVehicleType = vehicleClasses.first; // Use first vehicle class
            }
          }
          
          setState(() {}); // Refresh UI
          
          SnackBarHelper.success("Driver license details fetched successfully!");
          print("👤 Driver License Details Fetched:");
          print("👤 Name: ${licenseDetails.detailsOfDrivingLicence.name}");
          print("👤 Father Name: ${licenseDetails.detailsOfDrivingLicence.fatherOrHusbandName}");
          print("👤 Vehicle Classes: ${licenseDetails.badgeDetails.isNotEmpty ? licenseDetails.badgeDetails.first.classOfVehicle : 'None'}");
          print("👤 Address: ${licenseDetails.detailsOfDrivingLicence.address}");
        } else {
          SnackBarHelper.error("Driver license details not found");
        }
      } else {
        SnackBarHelper.error("Failed to fetch driver license details");
      }
    } catch (e) {
      print("❌ Error fetching driver license details: $e");
      SnackBarHelper.error("Error fetching driver license details: $e");
    } finally {
      setState(() {
        _isSearchingDriver = false;
      });
    }
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

    print("👉 Using Token: $token");
    print("👉 Using UserId: $userId");

    final File? imageFile = _pickedImage != null && !kIsWeb
        ? File(_pickedImage!.path)
        : null;

    final partnerId = int.tryParse(partnerIdController.text.trim());

    final driverModel = DriverModel(
      userId: userId,
      driverId: widget.isEditMode ? widget.driverData?.driverId : null,
      fullName: driverNameController.text.trim(),
      contactNumber: contactNumberController.text.trim(),
      vehicleType: selectedVehicleType,
      vehicleNumber: vehicleNumberController.text.trim(),
      description: descriptionController.text.trim(),
      isDeclarationAccepted: isDeclarationAccepted,
      image: imageFile, // ✅ single file
      partnerId: partnerId, // ✅ integer
      modifiedUserId: userId, // ✅ For update operations
    );

    // 🔹 Add small delay (ensures async values + file stream ready)
    await Future.delayed(const Duration(milliseconds: 200));

    bool isSuccess;
    if (widget.isEditMode) {
      isSuccess = await addDriverController.updateDriver(driverModel, token);
    } else {
      isSuccess = await addDriverController.addDriver(driverModel, token);
    }

    if (isSuccess) {
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.isEditMode ? "Edit Driver" : "Add new Driver",
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
        if (addDriverController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.deepPurpleAccent),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Driver Details",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ✅ Driver License Search Section - Fixed Layout
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.shade200, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.search, color: Colors.blue.shade700, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          "Quick License Search",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Enter license details to auto-fill driver info",
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.blue.shade600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // License Number Field - Full Width
                    Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        controller: licenseNumberController,
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.center,
                        style: GoogleFonts.poppins(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: "License Number (e.g., HR-2620140187259)",
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Date of Birth Field - Full Width
                    Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        controller: dobController,
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.center,
                        style: GoogleFonts.poppins(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: "Date of Birth (DD/MM/YYYY)",
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Search Button - Full Width
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _isSearchingDriver ? null : _searchDriverLicense,
                        icon: _isSearchingDriver 
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.search, size: 20),
                        label: Text(
                          _isSearchingDriver ? "Searching..." : "Search License Details",
                          style: GoogleFonts.poppins(fontSize: 15),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),

              _buildTextField(
                "Driver Name",
                "Enter Driver Name",
                controller: driverNameController,
              ),
              _buildTextField(
                "Contact Number",
                "Enter Number",
                controller: contactNumberController,
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
                    setState(() => selectedVehicleType = value),
                decoration: InputDecoration(
                  hintText: "Select type of vehicle",
                  hintStyle: GoogleFonts.poppins(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.deepPurpleAccent,
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              _buildTextField(
                "Enter Vehicle Number",
                "Enter Vehicle Number",
                controller: vehicleNumberController,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                "Description",
                "Enter Description",
                controller: descriptionController,
                maxLines: 3,
              ),
              _buildTextField(
                "Partner Id",
                "Enter Partner Id",
                controller: partnerIdController,
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
                    value: isDeclarationAccepted,
                    onChanged: (value) =>
                        setState(() => isDeclarationAccepted = value),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Text(
                "Upload Vehicle / Driver Image",
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
                onPressed: _pickImage,
                icon: const Icon(Icons.upload, color: Colors.white),
                label: const Text(
                  "Upload",
                  style: TextStyle(color: Colors.white),
                ),
              ),

              if (_pickedImage != null) ...[
                const SizedBox(height: 12),
                FutureBuilder<Uint8List>(
                  future: _pickedImage!.readAsBytes(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
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
                        Image.memory(
                          snapshot.data!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
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
                                color: Colors.red,
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
                  onPressed: _submitForm,
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
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(
                color: Colors.deepPurpleAccent,
                width: 2.0,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
