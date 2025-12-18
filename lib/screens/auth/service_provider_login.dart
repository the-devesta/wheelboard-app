import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io' show File;
import '../../controllers/service_provider_controller.dart';
import '../../models/service_provider_signup.dart';

class AlliedBusinessRegistrationScreen extends StatefulWidget {
  const AlliedBusinessRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<AlliedBusinessRegistrationScreen> createState() =>
      _AlliedBusinessRegistrationScreenState();
}

class _AlliedBusinessRegistrationScreenState
    extends State<AlliedBusinessRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final ServiceProviderController controller = Get.put(
    ServiceProviderController(),
  );
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController gstController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  late final String userId;

  String? selectedBusinessType;
  List<String> selectedServices = [];
  List<PlatformFile> _pickedImages = [];
  bool _hasAttemptedValidation = false;

  final List<String> businessTypes = [
    "Dealer",
    "Manufacturer",
    "Garage",
    "Workshop",
    "Other",
    "Service Provider",
  ];

  final List<String> services = [
    "Tyre Services",
    "Vehicle Services",
    "Tyre Retreader",
    "Other",
  ];

  @override
  void initState() {
    super.initState();
    // ✅ Get userId from arguments - more robust extraction
    final arguments = Get.arguments;
    if (arguments != null && arguments is Map) {
      userId = arguments["userId"]?.toString() ?? "";
    } else {
      userId = "";
    }

    // ✅ Pre-fill data from registration if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final registrationData = Get.arguments;
      if (registrationData != null && registrationData is Map) {
        // Pre-fill business name from company name
        if (registrationData["companyName"] != null &&
            registrationData["companyName"].toString().isNotEmpty) {
          businessNameController.text = registrationData["companyName"]
              .toString();
        }
        // Pre-fill email
        if (registrationData["email"] != null &&
            registrationData["email"].toString().isNotEmpty) {
          emailController.text = registrationData["email"].toString();
        }
        // Pre-fill phone number
        if (registrationData["mobileNo"] != null &&
            registrationData["mobileNo"].toString().isNotEmpty) {
          phoneController.text = registrationData["mobileNo"].toString();
        }
      }
    });
  }

  @override
  void dispose() {
    businessNameController.dispose();
    gstController.dispose();
    addressController.dispose();
    cityController.dispose();
    phoneController.dispose();
    emailController.dispose();
    whatsappController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _pickedImages = result.files;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            // Progress Bar
            _buildProgressBar(),
            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      // Business Name
                      _buildFieldLabel("Business Name", required: true),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: businessNameController,
                        hintText: "Enter your business name",
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Business name is required';
                          }
                          if (value.trim().length < 2) {
                            return 'Business name must be at least 2 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // GST No. - Optional, no validation
                      _buildFieldLabel("GST No.", optional: true),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: gstController,
                        hintText: "E.g. 22AAAAA0000A1Z5",
                        isOptional: true,
                      ),
                      const SizedBox(height: 16),
                      // Business Type
                      _buildFieldLabel("Business Type", required: true),
                      const SizedBox(height: 12),
                      _buildBusinessTypeButtons(),
                      // Error message for Business Type
                      if (_hasAttemptedValidation && selectedBusinessType == null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Please select a business type',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFFFF5A5F),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      // Services Offered
                      _buildFieldLabel("What kind of services do you offer?", required: true),
                      const SizedBox(height: 12),
                      _buildServicesButtons(),
                      // Error message for Services
                      if (_hasAttemptedValidation && selectedServices.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Please select at least one service',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFFFF5A5F),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      // Business Address
                      _buildFieldLabel("Business Address", required: true),
                      const SizedBox(height: 6),
                      _buildTextArea(
                        controller: addressController,
                        hintText: "Enter full business address",
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Business address is required';
                          }
                          if (value.trim().length < 10) {
                            return 'Please enter a complete address (at least 10 characters)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // City
                      _buildFieldLabel("City", required: true),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: cityController,
                        hintText: "Select city",
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'City is required';
                          }
                          if (value.trim().length < 2) {
                            return 'Please enter a valid city name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Phone Number
                      _buildFieldLabel("Phone Number", required: true),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: phoneController,
                        hintText: "Enter your phone number",
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Phone number is required';
                          }
                          // Remove spaces and special characters for validation
                          final phoneDigits = value.replaceAll(RegExp(r'[^\d]'), '');
                          if (phoneDigits.length < 10) {
                            return 'Please enter a valid 10-digit phone number';
                          }
                          if (phoneDigits.length > 15) {
                            return 'Phone number is too long';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 6),
                      _buildHelperText(
                        "We'll send notifications to this number.",
                      ),
                      const SizedBox(height: 16),
                      // Email Address
                      _buildFieldLabel("Email Address", required: true),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: emailController,
                        hintText: "Enter your email address",
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email address is required';
                          }
                          final emailRegex = RegExp(
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                          );
                          if (!emailRegex.hasMatch(value.trim())) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 6),
                      _buildHelperText("For important business updates."),
                      const SizedBox(height: 16),
                      // WhatsApp - Optional, but validate if provided
                      _buildFieldLabel("WhatsApp", optional: true),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: whatsappController,
                        hintText: "WhatsApp number for updates",
                        keyboardType: TextInputType.phone,
                        isOptional: true,
                        validator: (value) {
                          // Only validate if value is provided (optional field)
                          if (value != null && value.trim().isNotEmpty) {
                            final phoneDigits = value.replaceAll(RegExp(r'[^\d]'), '');
                            if (phoneDigits.length < 10) {
                              return 'Please enter a valid 10-digit WhatsApp number';
                            }
                            if (phoneDigits.length > 15) {
                              return 'WhatsApp number is too long';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 6),
                      _buildHelperText(
                        "We'll send updates to this number if provided.",
                      ),
                      const SizedBox(height: 16),
                      // Upload Business Logo
                      _buildFieldLabel("Upload Business Logo"),
                      const SizedBox(height: 12),
                      _buildLogoUpload(),
                      const SizedBox(height: 16),
                      // Business Description
                      _buildFieldLabel("Business Description", required: true),
                      const SizedBox(height: 6),
                      _buildDescriptionField(),
                      const SizedBox(height: 100), // Space for bottom button
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // Bottom Continue Button
      bottomNavigationBar: _buildContinueButton(),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 52,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1C1E)),
            onPressed: () => Get.back(),
          ),
          Expanded(
            child: Text(
              "Allied Business Registration",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1C1E),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline, color: Color(0xFF1A1C1E)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3F6),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.5,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF00B894),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "Step 2 of 2",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF828282),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(
    String text, {
    bool required = false,
    bool optional = false,
  }) {
    return RichText(
      text: TextSpan(
        text: text,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF828282),
        ),
        children: [
          if (required)
            const TextSpan(
              text: " *",
              style: TextStyle(color: Color(0xFFFF5A5F)),
            ),
          if (optional)
            TextSpan(
              text: " (Optional)",
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF9CA3AF),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool isOptional = false,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF1A1C1E),
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: const Color(0xFFADAEBC),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          errorStyle: GoogleFonts.poppins(
            fontSize: 12,
            color: const Color(0xFFFF5A5F),
          ),
        ),
      ),
    );
  }

  Widget _buildTextArea({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 3,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF1A1C1E),
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: const Color(0xFFADAEBC),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(12),
          errorStyle: GoogleFonts.poppins(
            fontSize: 12,
            color: const Color(0xFFFF5A5F),
          ),
        ),
      ),
    );
  }

  Widget _buildBusinessTypeButtons() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: businessTypes.map((type) {
        final isSelected = selectedBusinessType == type;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedBusinessType = type;
              // Clear error when user selects
              if (_hasAttemptedValidation) {
                _hasAttemptedValidation = false;
              }
            });
          },
          child: Container(
            height: 40.5,
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 7.65),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF00B894)
                  : const Color(0xFFF1F3F6),
              border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Center(
              child: Text(
                type,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF1A1C1E),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildServicesButtons() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: services.map((service) {
        final isSelected = selectedServices.contains(service);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedServices.remove(service);
              } else {
                selectedServices.add(service);
              }
              // Clear error when user selects
              if (_hasAttemptedValidation && selectedServices.isNotEmpty) {
                _hasAttemptedValidation = false;
              }
            });
          },
          child: Container(
            height: 40.5,
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 7.65),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF00B894)
                  : const Color(0xFFF1F3F6),
              border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Center(
              child: Text(
                service,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF1A1C1E),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHelperText(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF828282),
      ),
    );
  }

  Widget _buildLogoUpload() {
    return Row(
      children: [
        // Logo preview container
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F3F6),
            border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _pickedImages.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(_pickedImages.first.path!),
                    fit: BoxFit.cover,
                  ),
                )
              : const Icon(
                  Icons.image_outlined,
                  color: Color(0xFFF36969),
                  size: 30,
                ),
        ),
        const SizedBox(width: 12),
        // Upload button and text
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _pickImages,
              child: Container(
                height: 38.5,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6.65,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF36969),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.upload, color: Colors.white, size: 15),
                    const SizedBox(width: 8),
                    Text(
                      "Upload",
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              ".jpg or .png, Max 2MB",
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF828282),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Stack(
      children: [
        Container(
          height: 85.5,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextFormField(
            controller: descriptionController,
            maxLines: 3,
            maxLength: 400,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Business description is required';
              }
              if (value.trim().length < 10) {
                return 'Please provide a more detailed description (at least 10 characters)';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {}); // Update character count
            },
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF1A1C1E),
            ),
            decoration: InputDecoration(
              hintText: "Briefly describe your business (max 400 chars)",
              hintStyle: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFADAEBC),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(12),
              counterText: '',
              errorStyle: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFFFF5A5F),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          right: 12,
          child: Text(
            "${descriptionController.text.length}/400",
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF828282),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: controller.isLoading.value
                ? null
                : () async {
                    // ✅ Prevent multiple taps
                    if (controller.isLoading.value) {
                      return;
                    }

                    // Mark that validation has been attempted
                    setState(() {
                      _hasAttemptedValidation = true;
                    });

                    // Validate form fields first
                    if (!_formKey.currentState!.validate()) {
                      // Scroll to first error
                      Scrollable.ensureVisible(
                        _formKey.currentContext!,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                      return;
                    }

                    // Validate Business Type
                    if (selectedBusinessType == null || selectedBusinessType!.isEmpty) {
                      Get.snackbar(
                        'Validation Error',
                        'Please select a business type',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: const Color(0xFFFF5A5F),
                        colorText: Colors.white,
                        margin: const EdgeInsets.all(16),
                      );
                      return;
                    }

                    // Validate Services
                    if (selectedServices.isEmpty) {
                      Get.snackbar(
                        'Validation Error',
                        'Please select at least one service',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: const Color(0xFFFF5A5F),
                        colorText: Colors.white,
                        margin: const EdgeInsets.all(16),
                      );
                      return;
                    }

                    // All validations passed, proceed with submission
                    File? businessLogo;
                    if (_pickedImages.isNotEmpty &&
                        _pickedImages.first.path != null) {
                      businessLogo = File(_pickedImages.first.path!);
                    }

                    final serviceProvider = ServiceProviderModel(
                      userId: userId,
                      businessName: businessNameController.text.trim(),
                      gstNumber: gstController.text.trim().isEmpty
                          ? null
                          : gstController.text.trim(), // GST is optional
                      businessType: selectedBusinessType!,
                      servicesOffered: selectedServices,
                      businessAddress: addressController.text.trim(),
                      city: cityController.text.trim(),
                      phoneNumber: phoneController.text.trim(),
                      email: emailController.text.trim(),
                      whatsappNumber: whatsappController.text.trim().isEmpty
                          ? null
                          : whatsappController.text.trim(), // WhatsApp is optional
                      businessLogo: businessLogo,
                      description: descriptionController.text.trim(),
                    );

                    await controller.completeServiceProvider(serviceProvider);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5A5F),
              disabledBackgroundColor: const Color(0xFFFF5A5F).withOpacity(0.6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: controller.isLoading.value
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : Text(
                    "Continue",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
