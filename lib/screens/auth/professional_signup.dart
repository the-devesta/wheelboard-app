
import 'package:flutter/material.dart';
import 'package:wheelboard/constants/apps_colors.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' show File, Directory; // only available on mobile
import '../../controllers/professional_signup_controller.dart';
import '../../models/professional_signupmodel.dart';
import '../../widgets/custom_snackbar.dart';

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

  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;

  // Professional Type Options
  final List<String> professionalTypes = ['Driver', 'Mechanical', 'Helper'];

  // State Options (Indian States)
  final List<String> states = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
    'Delhi',
    'Jammu and Kashmir',
    'Ladakh',
  ];

  // City Options (Major cities - can be expanded)
  final Map<String, List<String>> stateCities = {
    'Andhra Pradesh': ['Visakhapatnam', 'Vijayawada', 'Guntur', 'Nellore', 'Kurnool'],
    'Arunachal Pradesh': ['Itanagar', 'Naharlagun', 'Tawang'],
    'Assam': ['Guwahati', 'Silchar', 'Dibrugarh', 'Jorhat', 'Nagaon'],
    'Bihar': ['Patna', 'Gaya', 'Bhagalpur', 'Muzaffarpur', 'Purnia'],
    'Chhattisgarh': ['Raipur', 'Bhilai', 'Bilaspur', 'Durg', 'Korba'],
    'Goa': ['Panaji', 'Margao', 'Vasco da Gama', 'Mapusa'],
    'Gujarat': ['Ahmedabad', 'Surat', 'Vadodara', 'Rajkot', 'Bhavnagar', 'Jamnagar'],
    'Haryana': ['Gurgaon', 'Faridabad', 'Panipat', 'Ambala', 'Karnal'],
    'Himachal Pradesh': ['Shimla', 'Mandi', 'Dharamshala', 'Solan'],
    'Jharkhand': ['Ranchi', 'Jamshedpur', 'Dhanbad', 'Bokaro', 'Hazaribagh'],
    'Karnataka': ['Bangalore', 'Mysore', 'Hubli', 'Mangalore', 'Belgaum'],
    'Kerala': ['Kochi', 'Thiruvananthapuram', 'Kozhikode', 'Thrissur', 'Kollam'],
    'Madhya Pradesh': ['Bhopal', 'Indore', 'Gwalior', 'Jabalpur', 'Ujjain'],
    'Maharashtra': ['Mumbai', 'Pune', 'Nagpur', 'Nashik', 'Aurangabad'],
    'Manipur': ['Imphal', 'Thoubal', 'Bishnupur'],
    'Meghalaya': ['Shillong', 'Tura', 'Jowai'],
    'Mizoram': ['Aizawl', 'Lunglei', 'Saiha'],
    'Nagaland': ['Kohima', 'Dimapur', 'Mokokchung'],
    'Odisha': ['Bhubaneswar', 'Cuttack', 'Rourkela', 'Berhampur'],
    'Punjab': ['Ludhiana', 'Amritsar', 'Jalandhar', 'Patiala', 'Bathinda'],
    'Rajasthan': ['Jaipur', 'Jodhpur', 'Kota', 'Bikaner', 'Ajmer', 'Udaipur'],
    'Sikkim': ['Gangtok', 'Namchi', 'Mangan'],
    'Tamil Nadu': ['Chennai', 'Coimbatore', 'Madurai', 'Tiruchirappalli', 'Salem'],
    'Telangana': ['Hyderabad', 'Warangal', 'Nizamabad', 'Karimnagar'],
    'Tripura': ['Agartala', 'Udaipur', 'Dharmanagar'],
    'Uttar Pradesh': ['Lucknow', 'Kanpur', 'Agra', 'Varanasi', 'Allahabad', 'Noida'],
    'Uttarakhand': ['Dehradun', 'Haridwar', 'Roorkee', 'Haldwani'],
    'West Bengal': ['Kolkata', 'Howrah', 'Durgapur', 'Asansol', 'Siliguri'],
    'Delhi': ['New Delhi', 'Delhi'],
    'Jammu and Kashmir': ['Srinagar', 'Jammu', 'Anantnag'],
    'Ladakh': ['Leh', 'Kargil'],
  };

  // Get cities for selected state
  List<String> get citiesForSelectedState {
    if (selectedState.value == null) return [];
    return stateCities[selectedState.value!] ?? [];
  }

  Future<void> _pickImages() async {
    try {
      // Show bottom sheet to choose camera or gallery
      final ImageSource? source = await showModalBottomSheet<ImageSource>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (BuildContext context) {
          return SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.redAccent),
                  title: const Text('Take Photo'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Colors.redAccent),
                  title: const Text('Choose from Gallery'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.cancel, color: Colors.grey),
                  title: const Text('Cancel'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        },
      );

      if (source != null) {
        // Use pickImage with proper error handling
        final XFile? pickedFile = await _imagePicker.pickImage(
          source: source,
          imageQuality: 80, // Compress image to 80% quality
          maxWidth: 1920, // Limit image width
          maxHeight: 1920, // Limit image height
        ).catchError((error) {
          print("Image picker error: $error");
          SnackBarHelper.error("Failed to pick image. Please try again.");
          return null;
        });

        if (pickedFile != null) {
          // Copy image to permanent location to avoid cache deletion issues
          try {
            final Directory appDocDir = await getApplicationDocumentsDirectory();
            final String fileName = 'profile_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
            final String permanentPath = '${appDocDir.path}/$fileName';
            
            // Copy the file to permanent location
            final File permanentFile = await File(pickedFile.path).copy(permanentPath);
            
            setState(() {
              _selectedImage = permanentFile;
            });
            SnackBarHelper.success("Image selected successfully");
          } catch (e) {
            print("Error copying image: $e");
            // Fallback to original path if copy fails
            setState(() {
              _selectedImage = File(pickedFile.path);
            });
            SnackBarHelper.success("Image selected successfully");
          }
        }
      }
    } catch (e) {
      print("Image picker exception: $e");
      SnackBarHelper.error("Failed to pick image: ${e.toString()}");
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
                    _buildProfessionalTypeDropdown(),
                    const SizedBox(height: 12),
                    _buildStateDropdown(),
                    const SizedBox(height: 12),
                    _buildCityDropdown(),

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
                                _selectedImage != null
                                    ? _selectedImage!.path.split('/').last
                                    : "No Image Uploaded.",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: _selectedImage != null
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (_selectedImage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedImage = null;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 30),
                    _buildRegisterButton(),
                    const SizedBox(height: 100), // Bottom padding to prevent cut off
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

  // Professional Type Dropdown
  Widget _buildProfessionalTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Professional Type*", style: TextStyle(color: AppColors.buttonBg)),
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
              value: selectedProfessionalType.value,
              hint: const Text("Select Professional Type"),
              decoration: const InputDecoration(border: InputBorder.none),
              icon: const Icon(Icons.keyboard_arrow_down),
              items: professionalTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                selectedProfessionalType.value = value;
              },
            ),
          ),
        ),
      ],
    );
  }

  // State Dropdown
  Widget _buildStateDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select State*", style: TextStyle(color: AppColors.buttonBg)),
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
              value: selectedState.value,
              hint: const Text("Select State"),
              decoration: const InputDecoration(border: InputBorder.none),
              icon: const Icon(Icons.keyboard_arrow_down),
              items: states.map((state) {
                return DropdownMenuItem(
                  value: state,
                  child: Text(state),
                );
              }).toList(),
              onChanged: (value) {
                selectedState.value = value;
                // Reset city when state changes
                selectedCity.value = null;
              },
            ),
          ),
        ),
      ],
    );
  }

  // City Dropdown (depends on selected state)
  Widget _buildCityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select City*", style: TextStyle(color: AppColors.buttonBg)),
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
              value: selectedCity.value,
              hint: Text(selectedState.value == null 
                  ? "Select State first" 
                  : "Select City"),
              decoration: const InputDecoration(border: InputBorder.none),
              icon: const Icon(Icons.keyboard_arrow_down),
              items: citiesForSelectedState.map((city) {
                return DropdownMenuItem(
                  value: city,
                  child: Text(city),
                );
              }).toList(),
              onChanged: selectedState.value == null 
                  ? null 
                  : (value) {
                      selectedCity.value = value;
                    },
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
        // ✅ Validate ProfileImage before submitting
        if (_selectedImage == null) {
          SnackBarHelper.error("Please upload driver image (ProfileImage is required)");
          return;
        }

        // ✅ Validate other required fields
        if (_emailController.text.trim().isEmpty) {
          SnackBarHelper.error("Please enter email");
          return;
        }

        if (_passwordController.text.trim().isEmpty) {
          SnackBarHelper.error("Please enter password");
          return;
        }

        if (_fullNameController.text.trim().isEmpty) {
          SnackBarHelper.error("Please enter full name");
          return;
        }

        if (selectedProfessionalType.value == null) {
          SnackBarHelper.error("Please select professional type");
          return;
        }

        if (selectedState.value == null) {
          SnackBarHelper.error("Please select state");
          return;
        }

        if (selectedCity.value == null) {
          SnackBarHelper.error("Please select city");
          return;
        }

        File? driverImage = _selectedImage;

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
