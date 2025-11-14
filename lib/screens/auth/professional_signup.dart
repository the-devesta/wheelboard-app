
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
  final RxBool obscurePassword = true.obs;
  DateTime? _selectedDateOfBirth;

  // Professional Type Options
  final List<String> professionalTypes = ['Driver', 'Technician', 'Helper'];

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
    return Scaffold(
      backgroundColor: AppColors.primary, // #F4E3E3
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: AppBar(elevation: 0, backgroundColor: Colors.transparent),
      ),
      body: SafeArea(
        child: Stack(
            children: [
            // Background with logo and title
            Column(
              children: [
                const SizedBox(height: 42),
                Center(
                  child: Image.asset(
                    'assets/headingImg.png',
                    width: 211,
                    height: 49,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 200),
                Text(
                  "Register as",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF535353),
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
            // White card container
            Center(
              child: Container(
                width: 343,
                constraints: const BoxConstraints(maxHeight: 750),
                margin: const EdgeInsets.only(top: 100),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      const SizedBox(height: 22),
                      // Back button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 24,
                          height: 24,
                          child: Icon(
                            Icons.arrow_back,
                            size: 20,
                            color: const Color(0xFF1A1C1E),
                          ),
                        ),
                    ),
                      const SizedBox(height: 12),
                      // Title
                      Text(
                      "Register as Professional",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF535353),
                          letterSpacing: -0.48,
                          fontFamily: 'Poppins',
                          height: 1.3,
                      ),
                    ),
                      const SizedBox(height: 12),
                      // Login link
                    Row(
                      children: [
                          Text(
                            "Already have an account?",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF6C7278),
                              height: 1.4,
                              letterSpacing: -0.12,
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(width: 6),
                        GestureDetector(
                            onTap: () {
                              // Navigate to login
                            },
                            child: Text(
                            "Login",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFF26262),
                                height: 1.4,
                                letterSpacing: -0.12,
                                fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ],
                    ),
                      const SizedBox(height: 24),
                      // Form fields
                      // Email field
                    _buildTextField(
                        "Email",
                        hint: "Enter your email",
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      // Password field
                      Obx(
                        () => _buildTextField(
                      "Password",
                          hint: "Enter your password",
                      controller: _passwordController,
                          obscureText: obscurePassword.value,
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: 16,
                              color: const Color(0xFFACB5BB),
                            ),
                            onPressed: () {
                              obscurePassword.value = !obscurePassword.value;
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    _buildTextField(
                      "Full Name",
                        hint: "Enter your full name",
                      controller: _fullNameController,
                    ),
                      const SizedBox(height: 16),
                    _buildTextField(
                        "Father's name",
                        hint: "Enter father's name",
                      controller: _fatherNameController,
                    ),
                      const SizedBox(height: 16),
                    _buildTextField(
                      "Birth of date",
                        hint: "DD/MM/YYYY",
                        suffixIconData: Icons.calendar_today,
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
                              _selectedDateOfBirth = pickedDate;
                            _dobController.text =
                                "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                          });
                        }
                      },
                    ),
                      const SizedBox(height: 16),
                    _buildTextField(
                      "Phone Number",
                        hint: "Eg.(+91) 98734 9864",
                      controller: _phoneController,
                        keyboardType: TextInputType.phone,
                    ),
                      const SizedBox(height: 16),
                    _buildProfessionalTypeDropdown(),
                      const SizedBox(height: 16),
                    _buildStateDropdown(),
                      const SizedBox(height: 16),
                    _buildCityDropdown(),
                    const SizedBox(height: 20),
                      _buildImageUploadSection(),
                    const SizedBox(height: 30),
                    _buildRegisterButton(),
                      const SizedBox(height: 24),
                  ],
                ),
              ),
          ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 TextField builder matching Figma design
  Widget _buildTextField(
    String label, {
    String? hint,
    IconData? suffixIconData,
    Widget? suffixIcon,
    TextEditingController? controller,
    VoidCallback? onTap,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFF36969),
            height: 1.6,
            letterSpacing: -0.24,
            fontFamily: 'Plus Jakarta Sans',
          ),
        ),
        const SizedBox(height: 2),
        // Input field
        Container(
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFEDF1F3)),
          ),
          child: TextField(
          controller: controller,
          readOnly: onTap != null,
          onTap: onTap,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: const Color(0xFF1A1C1E),
              height: 1.4,
              letterSpacing: -0.14,
              fontFamily: 'Inter',
            ),
          contextMenuBuilder: (context, editableTextState) {
            if (onTap != null) return const SizedBox.shrink();
            return AdaptiveTextSelectionToolbar.editableText(
              editableTextState: editableTextState,
            );
          },
          decoration: InputDecoration(
            hintText: hint ?? 'Enter $label',
              hintStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: const Color(0xFF6C7278),
                height: 1.4,
                letterSpacing: -0.14,
                fontFamily: 'Inter',
              ),
              suffixIcon: suffixIcon != null
                  ? suffixIcon
                  : (suffixIconData != null
                      ? Icon(
                          suffixIconData,
                          size: 16,
                          color: const Color(0xFFACB5BB),
                        )
                      : null),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
            ),
          ),
        ),
        ),
      ],
    );
  }

  // State Dropdown matching Figma design
  Widget _buildStateDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Select State",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFF36969),
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              "*",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFFF5E5E),
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 51,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E5E5)),
          ),
          child: Obx(
            () => DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedState.value,
                hint: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 18,
                        color: const Color(0xFFF36969),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Select state",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: const Color(0xFF6C7278),
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
                icon: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 15,
                    color: const Color(0xFFF36969),
                  ),
                ),
                isExpanded: true,
                items: states.map((state) {
                return DropdownMenuItem(
                    value: state,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        state,
                        style: TextStyle(
                          fontSize: 15,
                          color: const Color(0xFF1A1C1E),
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                );
              }).toList(),
              onChanged: (value) {
                  selectedState.value = value;
                  selectedCity.value = null;
              },
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Professional Type Dropdown matching Figma design
  Widget _buildProfessionalTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Professional Type",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFF36969),
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              "*",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFFF5E5E),
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 51,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E5E5)),
          ),
          child: Obx(
            () => DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedProfessionalType.value,
                hint: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    "Select Professional Type",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                      color: const Color(0xFF6C7278),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                icon: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 15,
                    color: const Color(0xFFF36969),
                  ),
                ),
                isExpanded: true,
                items: professionalTypes.map((type) {
                return DropdownMenuItem(
                    value: type,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        type,
                        style: TextStyle(
                          fontSize: 15,
                          color: const Color(0xFF1A1C1E),
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                );
              }).toList(),
              onChanged: (value) {
                  selectedProfessionalType.value = value;
              },
              ),
            ),
          ),
        ),
      ],
    );
  }

  // City Dropdown matching Figma design
  Widget _buildCityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Select City",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFF36969),
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              "*",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFFF5E5E),
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 51,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E5E5)),
          ),
          child: Obx(
            () => DropdownButtonHideUnderline(
              child: DropdownButton<String>(
              value: selectedCity.value,
                hint: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.business,
                        size: 18,
                        color: const Color(0xFFF36969),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        selectedState.value == null
                  ? "Select State first" 
                            : "Select City",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: const Color(0xFF6C7278),
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
                icon: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 15,
                    color: const Color(0xFFF36969),
                  ),
                ),
                isExpanded: true,
              items: citiesForSelectedState.map((city) {
                return DropdownMenuItem(
                  value: city,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        city,
                        style: TextStyle(
                          fontSize: 15,
                          color: const Color(0xFF1A1C1E),
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
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
        ),
      ],
    );
  }

  // Image Upload Section matching Figma design
  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Upload Driver Image",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFF36969),
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              "*",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFFF5E5E),
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "JPG/PNG, max 2MB",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: const Color(0xFF888888),
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImages,
      child: Row(
        children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5E5E5)),
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: 24,
                  color: const Color(0xFFF36969),
                ),
              ),
          const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 37,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE5E5E5)),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _selectedImage != null
                          ? _selectedImage!.path.split('/').last
                          : "No Image Uploaded.",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: const Color(0xFF888888),
                        fontFamily: 'Poppins',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
        ],
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
      ],
    );
  }

  Widget _buildRegisterButton() {
    return Obx(
      () => SizedBox(
        width: 295,
        height: 48,
        child: ElevatedButton(
          onPressed: controller.isLoading.value
              ? null // Disable button when loading
              : () async {
                  // ✅ Prevent multiple taps - check if already loading
                  if (controller.isLoading.value) {
                    return;
                  }

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

                  if (_dobController.text.trim().isEmpty || _selectedDateOfBirth == null) {
                    SnackBarHelper.error("Please select date of birth");
                    return;
                  }

                  if (_phoneController.text.trim().isEmpty) {
                    SnackBarHelper.error("Please enter phone number");
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

                  // Format DateOfBirth as ISO 8601 string (date-time format)
                  String? dobFormatted;
                  if (_selectedDateOfBirth != null) {
                    dobFormatted = _selectedDateOfBirth!.toIso8601String();
                  } else if (_dobController.text.isNotEmpty) {
                    // Try to parse DD/MM/YYYY format if date picker wasn't used
                    try {
                      final parts = _dobController.text.split('/');
                      if (parts.length == 3) {
                        final day = int.parse(parts[0]);
                        final month = int.parse(parts[1]);
                        final year = int.parse(parts[2]);
                        final date = DateTime(year, month, day);
                        dobFormatted = date.toIso8601String();
                      }
                    } catch (e) {
                      dobFormatted = _dobController.text;
                    }
                  }

        final model = ProfessionalSignupmodel(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          fatherName: _fatherNameController.text.trim(),
          professionalType: selectedProfessionalType.value,
          mobileNo: _phoneController.text.trim(),
          fullName: _fullNameController.text.trim(),
                    dob: dobFormatted,
          state: selectedState.value,
          city: selectedCity.value,
          driverImage: driverImage,
        );

        await controller.registerProfessional(model);
      },
      style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF25C5C),
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
            disabledBackgroundColor: const Color(0xFFF25C5C).withOpacity(0.6),
      ),
          child: controller.isLoading.value
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  "Register",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    letterSpacing: -0.14,
                    fontFamily: 'Poppins',
                  ),
                ),
        ),
      ),
    );
  }
}
