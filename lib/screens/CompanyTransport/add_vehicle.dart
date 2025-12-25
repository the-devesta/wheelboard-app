
import 'dart:io' show File;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'package:get/get.dart'; // ✅ for controller
import '../../models/add_new_vehicle_model.dart';
import '../../models/vehicle_details_model.dart';
import '../../controllers/add_new_vehicle_controller.dart';
import '../../controllers/fleet_controller.dart';
import '../../utils/session_manager.dart';
import '../../apihelperclass/api_helper.dart';
import '../../widgets/custom_snackbar.dart';
import '../../widgets/custom_loader.dart';
import '../../utils/app_logger.dart';

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
  bool _isSearchingVehicle = false; // ✅ For vehicle search loading

  // Valid vehicle types for dropdown
  static const List<String> validVehicleTypes = [
    "Shipment",
    "Construction",
    "Mining",
    "Others",
  ];

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
      // ✅ Only set _vehicleType if it's in the valid list
      final vehicleType = vehicle.vehicleType;
      if (vehicleType != null && validVehicleTypes.contains(vehicleType)) {
        _vehicleType = vehicleType;
      } else {
        _vehicleType = null; // Set to null if not in valid list
      }
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

  /// Search vehicle details by vehicle number
  Future<void> _searchVehicleDetails() async {
    final vehicleNumber = _vehicleNumberController.text.trim();
    
    if (vehicleNumber.isEmpty) {
      SnackBarHelper.warning("Please enter vehicle number first");
      return;
    }

    setState(() {
      _isSearchingVehicle = true;
    });

    try {
      SnackBarHelper.info("Searching vehicle details...");
      
      AppLogger.d("🔍 Searching for vehicle: $vehicleNumber");
      
      final response = await HttpHelper.getVehicleDetails(
        vehicleNumber: vehicleNumber,
      );

      AppLogger.d("📡 API Response Status: ${response.statusCode}");
      AppLogger.d("📡 API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        AppLogger.d("📊 Parsed Response: $data");
        
        if (data['code'] == 200 && data['result'] != null) {
          try {
            final vehicleDetails = VehicleDetailsModel.fromJson(data);
            
            // ✅ Auto-fill the form with fetched data
            _vehicleModelController.text = vehicleDetails.model;
            _manufacturingYearController.text = vehicleDetails.vehicleManufacturingMonthYear.split('/').last; // Extract year
            // Map vehicle category to our dropdown options
            final category = vehicleDetails.vehicleCategory.toLowerCase();
            if (category.contains('construction')) {
              _vehicleType = 'Construction';
            } else if (category.contains('mining')) {
              _vehicleType = 'Mining';
            } else {
              _vehicleType = 'Shipment'; // Default to Shipment
            }
            
            setState(() {}); // Refresh UI
            
            SnackBarHelper.success("Vehicle details fetched successfully!");
            AppLogger.d("🚗 Vehicle Details Fetched:");
            AppLogger.d("🚗 Model: ${vehicleDetails.model}");
            AppLogger.d("🚗 Manufacturer: ${vehicleDetails.vehicleManufacturerName}");
            AppLogger.d("🚗 Category: ${vehicleDetails.vehicleCategory}");
            AppLogger.d("🚗 Manufacturing Year: ${vehicleDetails.vehicleManufacturingMonthYear}");
          } catch (parseError) {
            AppLogger.d("❌ Error parsing vehicle details: $parseError");
            SnackBarHelper.error("Error parsing vehicle details. Please try again.");
          }
        } else {
          AppLogger.d("❌ API returned error or no result");
          SnackBarHelper.error("Vehicle details not found for this number");
        }
      } else {
        AppLogger.d("❌ API request failed with status: ${response.statusCode}");
        SnackBarHelper.error("Failed to fetch vehicle details. Please try again.");
      }
    } catch (e) {
      AppLogger.d("❌ Error fetching vehicle details: $e");
      SnackBarHelper.error("Error fetching vehicle details: $e");
    } finally {
      setState(() {
        _isSearchingVehicle = false;
      });
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
      // Auto-refresh fleet data
      try {
        final fleetController = Get.find<DriverController>();
        final sessionManager = SessionManager();
        final refreshToken = await sessionManager.getString("authToken");
        final refreshUserId = await sessionManager.getString("userId");
        
        if (refreshToken != null && refreshUserId != null) {
          await fleetController.fetchVehicles(refreshUserId, refreshToken);
        }
      } catch (e) {
        AppLogger.d("⚠️ Could not refresh fleet data: $e");
      }
      
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4E3E3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.isEditMode ? "Edit Vehicle" : "Add new Vehicle",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: const Color(0xFF1E1E1E),
            letterSpacing: -0.14,
          ),
        ),
        leading: const BackButton(color: Colors.black),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.close, color: Colors.black, size: 20),
          ),
        ],
        shape: const Border(
          bottom: BorderSide(
            color: Color(0xFFFCD2D2),
            width: 1,
          ),
        ),
      ),
      body: Obx(() {
        final children = <Widget>[
            SingleChildScrollView(
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
                            "Vehicle Details",
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

                      // ✅ Vehicle Search Section
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFA5D6A7), width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.search, color: Color(0xFF388E3C), size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  "Quick Vehicle Search",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins',
                                    color: const Color(0xFF388E3C),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Enter vehicle number to auto-fill vehicle info",
                              style: TextStyle(
                                fontSize: 11,
                                fontFamily: 'Poppins',
                                color: const Color(0xFF2E7D32),
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            // Vehicle Number Field
                            Container(
                              width: double.infinity,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFEDF1F3), width: 1),
                              ),
                              child: TextField(
                                controller: _vehicleNumberController,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                  color: const Color(0xFF6C7278),
                                ),
                                decoration: InputDecoration(
                                  hintText: "Vehicle Number (e.g., UP16AF0785)",
                                  hintStyle: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Poppins',
                                    color: const Color(0xFF6C7278),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            // Search Button
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                onPressed: _isSearchingVehicle ? null : _searchVehicleDetails,
                                icon: _isSearchingVehicle 
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
                                  _isSearchingVehicle ? "Searching..." : "Search Vehicle Details",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF388E3C),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 17),

                      // Vehicle Model
                      _buildTextField(
                        "Vehicle Model",
                        "Tata-5218",
                        controller: _vehicleModelController,
                        suffix: const Icon(
                          Icons.local_shipping,
                          color: Color(0xFFF25C5C),
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 17),

                      // Vehicle Number
                      _buildTextField(
                        "Vehicle Number",
                        "DD Q9 1644",
                        controller: _vehicleNumberController,
                      ),
                      const SizedBox(height: 17),

                      // Manufacturing Year + Ownership Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildTextField(
                              "Manufacturing Year",
                              "1999",
                              controller: _manufacturingYearController,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Ownership",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Plus Jakarta Sans',
                                    color: const Color(0xFF6C7278),
                                    letterSpacing: -0.24,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  constraints: const BoxConstraints(minHeight: 46),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFEDF1F3), width: 1),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: _ownershipType == "Owned",
                                            onChanged: (v) => setState(() {
                                              _ownershipType = "Owned";
                                            }),
                                            activeColor: const Color(0xFFF25C5C),
                                          ),
                                          Text(
                                            "Owned",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              color: const Color(0xFF6C7278),
                                            ),
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
                                            activeColor: const Color(0xFFF25C5C),
                                          ),
                                          Text(
                                            "Attached",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              color: const Color(0xFF6C7278),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
                          border: Border.all(color: const Color(0xFFEDF1F3), width: 1),
                        ),
                        child: DropdownButtonFormField<String>(
                          initialValue: _vehicleType,
                          items: const [
                            DropdownMenuItem(value: "Shipment", child: Text("Shipment")),
                            DropdownMenuItem(value: "Construction", child: Text("Construction")),
                            DropdownMenuItem(value: "Mining", child: Text("Mining")),
                            DropdownMenuItem(value: "Others", child: Text("Others (specify)")),
                          ],
                          onChanged: (value) =>
                              setState(() => _vehicleType = value),
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

                      // Description
                      _buildTextField(
                        "Description",
                        "Enter Description",
                        controller: _descriptionController,
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
                            value: _isDeclarationAccepted,
                            onChanged: (v) =>
                                setState(() => _isDeclarationAccepted = v),
                            activeThumbColor: const Color(0xFFF25C5C),
                          ),
                        ],
                      ),
                      const SizedBox(height: 17),

                      // Upload Images Section
                      Text(
                        "Upload Images of vehicles or Job Poster",
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
                          onPressed: _pickImages,
                          icon: const Icon(Icons.upload, color: Colors.white, size: 20),
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

                      if (_pickedImages.isNotEmpty) const SizedBox(height: 12),
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
                            return Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: img,
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: InkWell(
                                    onTap: () =>
                                        setState(() => _pickedImages.removeAt(i)),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFFF25C5C),
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: const Icon(
                                        Icons.close,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                      const SizedBox(height: 24),

                      // Submit Button
                      Center(
                        child: SizedBox(
                          width: 295,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF25C5C),
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _submitVehicle,
                            child: Text(
                              widget.isEditMode ? "Update Vehicle" : "Add Now",
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
          ),
        ];

        // Add loader overlay if loading
        if (_vehicleController.isLoading.value) {
          children.add(const CustomLoader.small());
        }

        return Stack(children: children);
      }),
    );
  }

  Widget _buildTextField(
    String label,
    String hint, {
    Widget? suffix,
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
            suffixIcon: suffix,
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

