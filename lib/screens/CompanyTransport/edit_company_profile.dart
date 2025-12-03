import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wheelboard/controllers/company_profile_controller.dart';
import '../../utils/placeservices.dart';

class EditCompanyProfileScreen extends StatefulWidget {
  const EditCompanyProfileScreen({super.key});

  @override
  State<EditCompanyProfileScreen> createState() => _EditCompanyProfileScreenState();
}

class _EditCompanyProfileScreenState extends State<EditCompanyProfileScreen> {
  final CompanyProfileController controller =
      Get.put(CompanyProfileController());
  
  final PlacesService placesService = PlacesService(
    apiKey: "AIzaSyDD1jdzyCZ_QhA4QpsL9qFRg38phVn8mPI",
  );
  
  List<Suggestion> locationSuggestions = [];
  final FocusNode _locationFocusNode = FocusNode();
  Worker? _savingWorker;

  @override
  void initState() {
    super.initState();
    _locationFocusNode.addListener(() {
      if (!_locationFocusNode.hasFocus) {
        setState(() {
          locationSuggestions = [];
        });
      }
    });
    
    // Listen to isSaving to detect when save completes successfully
    _savingWorker = ever(controller.isSaving, (bool saving) async {
      if (!saving) {
        // Save completed, wait a bit then navigate back
        await Future.delayed(const Duration(milliseconds: 1200));
        if (mounted) {
          try {
            if (Navigator.canPop(context)) {
              Navigator.pop(context, true);
              print("✅ Navigation: Navigator.pop() called from screen");
            } else {
              Get.back(result: true);
              print("✅ Navigation: Get.back() called from screen");
            }
          } catch (e) {
            print("⚠️ Navigation error from screen: $e");
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _savingWorker?.dispose();
    _locationFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF4E3E3),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 91,
        backgroundColor: Colors.white,
        elevation: 0,
        shape: const Border(
          bottom: BorderSide(color: Color(0xFFFCD2D2), width: 1),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E1E1E)),
          onPressed: () => Get.back(),
        ),
        title: const Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text(
            'EDIT Your Profile',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E1E1E),
              letterSpacing: -0.14,
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF1E1E1E)),
            onPressed: () => Get.back(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              const SizedBox(height: 12),
              _buildFormCard(controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(CompanyProfileController controller) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildLogoPicker(controller),
          const SizedBox(height: 24),
          _buildTextField(
            label: "Company Name",
            controller: controller.companyNameController,
            hint: "Enter Company name",
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: "Full Name",
            controller: controller.fullNameController,
            hint: "Enter your name",
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: "Email",
            controller: controller.emailController,
            hint: "Enter your email",
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: "Enter Business Category",
            controller: controller.businessCategoryController,
            hint: "Enter Business...",
          ),
          const SizedBox(height: 16),
          _buildLocationField(controller),
          const SizedBox(height: 16),
          _buildTextField(
            label: "Fleet Size",
            controller: controller.fleetSizeController,
            hint: "No of vehicles",
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: "Company GST (Optional)",
            controller: controller.gstController,
            hint: "Company GST(Optional)",
          ),
          const SizedBox(height: 24),
          _buildSaveButton(controller),
        ],
      ),
    );
  }

  Widget _buildSaveButton(CompanyProfileController controller) {
    return Obx(
      () => GestureDetector(
        onTap: controller.isSaving.value ? null : controller.saveProfile,
        child: Container(
          height: 48,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white, width: 0.8),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFF8B8B),
                Color(0xFFF25C5C),
              ],
            ),
          ),
          child: Center(
            child: controller.isSaving.value
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Save Now',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: -0.14,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoPicker(CompanyProfileController controller) {
    return Obx(() {
      ImageProvider? imageProvider;
      if (controller.logoFile != null) {
        imageProvider = FileImage(controller.logoFile!);
      } else if (controller.existingLogoUrl != null &&
          controller.existingLogoUrl!.isNotEmpty) {
        imageProvider = NetworkImage(controller.existingLogoUrl!);
      }

      return Center(
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            GestureDetector(
              onTap: controller.pickLogo,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFF36969), width: 4),
                  color: Colors.grey.shade200,
                  image: imageProvider != null
                      ? DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) {
                            // Handle image load error
                          },
                        )
                      : null,
                ),
                child: imageProvider == null
                    ? const Icon(Icons.business, size: 40, color: Colors.grey)
                    : null,
              ),
            ),
            Positioned(
              bottom: 6,
              right: 8,
              child: GestureDetector(
                onTap: controller.pickLogo,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF36969),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty)
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6C7278),
                letterSpacing: -0.24,
              ),
            ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6C7278),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFEDF1F3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFEDF1F3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFF36969)),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationField(CompanyProfileController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Location",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6C7278),
              letterSpacing: -0.24,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller.locationController,
            focusNode: _locationFocusNode,
            decoration: InputDecoration(
              hintText: "Search location...",
              hintStyle: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6C7278),
              ),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF6C7278)),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFEDF1F3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFEDF1F3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFF36969)),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) async {
              if (value.isNotEmpty && value.length > 2) {
                try {
                  final results = await placesService.fetchSuggestions(value);
                  if (mounted) {
                    setState(() {
                      locationSuggestions = results;
                    });
                  }
                } catch (e) {
                  print("Error fetching suggestions: $e");
                  if (mounted) {
                    setState(() {
                      locationSuggestions = [];
                    });
                  }
                }
              } else {
                if (mounted) {
                  setState(() {
                    locationSuggestions = [];
                  });
                }
              }
            },
            onTap: () {
              // Clear suggestions when tapping the field again
              if (locationSuggestions.isNotEmpty) {
                setState(() {
                  locationSuggestions = [];
                });
              }
            },
          ),
          if (locationSuggestions.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFEDF1F3)),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: locationSuggestions.length > 5 ? 5 : locationSuggestions.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final suggestion = locationSuggestions[index];
                  return ListTile(
                    dense: true,
                    leading: const Icon(
                      Icons.location_on,
                      color: Color(0xFFF36969),
                      size: 20,
                    ),
                    title: Text(
                      suggestion.description,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: suggestion.subTitle.isNotEmpty
                        ? Text(
                            suggestion.subTitle,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6C7278),
                            ),
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        controller.locationController.text = suggestion.description;
                        locationSuggestions = [];
                      });
                      // Hide keyboard and remove focus
                      _locationFocusNode.unfocus();
                      FocusScope.of(context).unfocus();
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
