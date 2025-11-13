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
  final String userId = Get.arguments["userId"];

  String? selectedBusinessType;
  List<String> selectedServices = [];
  List<PlatformFile> _pickedImages = [];

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
                      ),
                      const SizedBox(height: 16),
                      // GST No.
                      _buildFieldLabel("GST No.", optional: true),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: gstController,
                        hintText: "E.g. 22AAAAA0000A1Z5",
                      ),
                      const SizedBox(height: 16),
                      // Business Type
                      _buildFieldLabel("Business Type", required: true),
                      const SizedBox(height: 12),
                      _buildBusinessTypeButtons(),
                      const SizedBox(height: 16),
                      // Services Offered
                      _buildFieldLabel("What kind of services do you offer?"),
                      const SizedBox(height: 12),
                      _buildServicesButtons(),
                      const SizedBox(height: 16),
                      // Business Address
                      _buildFieldLabel("Business Address", required: true),
                      const SizedBox(height: 6),
                      _buildTextArea(
                        controller: addressController,
                        hintText: "Enter full business address",
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      // City
                      _buildFieldLabel("City", required: true),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: cityController,
                        hintText: "Select city",
                      ),
                      const SizedBox(height: 16),
                      // Phone Number
                      _buildFieldLabel("Phone Number", required: true),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: phoneController,
                        hintText: "Enter your phone number",
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 6),
                      _buildHelperText("We'll send notifications to this number."),
                      const SizedBox(height: 16),
                      // Email Address
                      _buildFieldLabel("Email Address", required: true),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: emailController,
                        hintText: "Enter your email address",
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 6),
                      _buildHelperText("For important business updates."),
                      const SizedBox(height: 16),
                      // WhatsApp
                      _buildFieldLabel("WhatsApp", optional: true),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: whatsappController,
                        hintText: "WhatsApp number for updates",
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 6),
                      _buildHelperText("We'll send updates to this number if provided."),
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
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
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

  Widget _buildFieldLabel(String text, {bool required = false, bool optional = false}) {
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
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildTextArea({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 3,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
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
            });
          },
          child: Container(
            height: 40.5,
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 7.65),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF00B894) : const Color(0xFFF1F3F6),
              border: Border.all(
                color: const Color(0xFFE0E0E0),
                width: 1,
              ),
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
            });
          },
          child: Container(
            height: 40.5,
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 7.65),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF00B894) : const Color(0xFFF1F3F6),
              border: Border.all(
                color: const Color(0xFFE0E0E0),
                width: 1,
              ),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6.65),
                decoration: BoxDecoration(
                  color: const Color(0xFFF36969),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.upload,
                      color: Colors.white,
                      size: 15,
                    ),
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
          child: TextField(
            controller: descriptionController,
            maxLines: 3,
            maxLength: 400,
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
          border: Border(
            top: BorderSide(color: Color(0xFFE0E0E0), width: 1),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: controller.isLoading.value
                ? null
                : () async {
                    if (_formKey.currentState!.validate()) {
                      File? businessLogo;
                      if (_pickedImages.isNotEmpty &&
                          _pickedImages.first.path != null) {
                        businessLogo = File(_pickedImages.first.path!);
                      }

                      final serviceProvider = ServiceProviderModel(
                        userId: userId,
                        businessName: businessNameController.text.trim(),
                        gstNumber: gstController.text.trim(),
                        businessType: selectedBusinessType ?? "",
                        servicesOffered: selectedServices,
                        businessAddress: addressController.text.trim(),
                        city: cityController.text.trim(),
                        phoneNumber: phoneController.text.trim(),
                        email: emailController.text.trim(),
                        whatsappNumber: whatsappController.text.trim(),
                        businessLogo: businessLogo,
                        description: descriptionController.text.trim(),
                      );

                      await controller.completeServiceProvider(
                        serviceProvider,
                      );
                    }
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
