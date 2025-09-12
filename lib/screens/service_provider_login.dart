import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io' show File;
import '../commonwidget/app_textfield.dart';
import 'package:wheelboard/constants/apps_colors.dart';
import '../controllers/service_provider_controller.dart';
import '../models/service_provider_signup.dart';

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
      allowMultiple: false, // Allow only one image for upload
      withData: true, // Useful for previews/thumbnails on Web
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
      appBar: AppBar(
        title: Text(
          "Allied Business Registration",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Container(
        color: AppColors.white, // Set background color for the entire screen
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white, // Set background color for the form
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Business Name", required: true),
                  AppTextField(
                    controller: businessNameController,
                    hintText: "Enter your business name",
                  ),
                  const SizedBox(height: 16),

                  _buildLabel("GST No. (Optional)"),
                  AppTextField(
                    controller: gstController,
                    hintText: "E.g. 22AAAAA0000A1Z5",
                  ),
                  const SizedBox(height: 16),

                  _buildLabel("Business Type", required: true),
                  Wrap(
                    spacing: 8,
                    children: businessTypes.map((type) {
                      return ChoiceChip(
                        label: Text(type),
                        selected: selectedBusinessType == type,
                        selectedColor: Colors.redAccent.withOpacity(0.2),
                        backgroundColor: Colors.grey.shade200,
                        onSelected: (selected) {
                          setState(() {
                            selectedBusinessType = type;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  const Text("What kind of services do you offer?"),
                  Wrap(
                    spacing: 8,
                    children: services.map((service) {
                      return FilterChip(
                        label: Text(service),
                        selected: selectedServices.contains(service),
                        onSelected: (selected) {
                          setState(() {
                            selected
                                ? selectedServices.add(service)
                                : selectedServices.remove(service);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  _buildLabel("Business Address", required: true),
                  AppTextField(
                    controller: addressController,
                    hintText: "Enter full business address",
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  _buildLabel("City", required: true),
                  AppTextField(
                    controller: cityController,
                    hintText: "Enter city",
                  ),
                  const SizedBox(height: 16),

                  _buildLabel("Phone Number", required: true),
                  AppTextField(
                    controller: phoneController,
                    hintText: "Enter your phone number",
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  _buildLabel("Email Address", required: true),
                  AppTextField(
                    controller: emailController,
                    hintText: "Enter your email address",
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  _buildLabel("WhatsApp (Optional)"),
                  AppTextField(
                    controller: whatsappController,
                    hintText: "WhatsApp number for updates",
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  _buildLabel("Upload Business Logo"),
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
                          const Icon(Icons.camera_alt, color: Colors.redAccent),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _pickedImages.isNotEmpty
                                  ? _pickedImages.map((e) => e.name).join(", ")
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
                  const SizedBox(height: 16),

                  _buildLabel("Business Description", required: true),
                  AppTextField(
                    controller: descriptionController,
                    hintText: "Briefly describe your business (max 400 chars)",
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          File? businessLogo;
                          if (_pickedImages.isNotEmpty &&
                              _pickedImages.first.path != null) {
                            businessLogo = File(_pickedImages.first.path!);
                          }

                          final serviceProvider = ServiceProviderModel(
                            userId: userId, // Replace with actual userId
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
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Continue",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          children: [
            if (required)
              const TextSpan(
                text: " *",
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
