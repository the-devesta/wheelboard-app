import 'package:flutter/material.dart';
import 'package:wheelboard/constants/apps_colors.dart';
import 'package:wheelboard/CommonWidget/app_textfield.dart';

class PostJobScreen extends StatefulWidget {
  @override
  _PostJobScreenState createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  String? selectedJobDuration;
  String? selectedJobType;

  final TextEditingController openingController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  List<String> uploadedFiles = ['exampleImage.png', 'ExampleImage.jpg'];
  String selectedRole = 'Technician';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFEEEEE),
      appBar: AppBar(
        leading: BackButton(),
        title: Text("Post a Job", style: TextStyle(color: Colors.black)),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Role Selection
                Center(
                  child: Text(
                    "Job Details",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6C7278),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _roleButton("Driver"),
                    SizedBox(width: 8),
                    _roleButton("Technician"),
                    SizedBox(width: 8),
                    _roleButton("Helper"),
                  ],
                ),
                SizedBox(height: 20),

                _label("Job duration"),
                SizedBox(height: 5),
                _dropdownField("Select Job Duration", selectedJobDuration, (
                  value,
                ) {
                  setState(() {
                    selectedJobDuration = value;
                  });
                }),

                SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: openingController,
                        hintText: 'No. of Openings',
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        controller: salaryController,
                        hintText: 'Salary',
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),
                _label("City"),
                AppTextField(
                  controller: cityController,
                  hintText: 'Enter city',
                ),

                SizedBox(height: 16),
                _label("Type of Job"),
                _dropdownField("Select job type", selectedJobType, (value) {
                  setState(() {
                    selectedJobType = value;
                  });
                }),

                SizedBox(height: 16),
                _label("Description"),
                _descriptionField(descriptionController),

                SizedBox(height: 16),
                _label("Upload Images of vehicles or Job Poster"),

                SizedBox(height: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5C5C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(
                        // 👈 border color and width
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    elevation: 4,
                  ),
                  onPressed: () {},
                  label: const Text(
                    "Upload",
                    style: TextStyle(color: Colors.white),
                  ),
                ),

                // ElevatedButton(
                //   onPressed: () {
                //     // Upload logic
                //   },
                //   style: ElevatedButton.styleFrom(
                //     elevation: 5,
                //     shadowColor: Colors.grey,
                //     backgroundColor: AppColors.buttonBg,
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(12),
                //     ),
                //   ),
                // child: Text("Upload"),
                // ),
                SizedBox(height: 8),
                for (var file in uploadedFiles)
                  Text(
                    "$file uploaded successfully",
                    style: TextStyle(color: Colors.green, fontSize: 13),
                  ),

                SizedBox(height: 20),
                _SaveButton(280),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleButton(String role) {
    final bool isSelected = selectedRole == role;

    return OutlinedButton(
      onPressed: () {
        setState(() {
          selectedRole = role;
        });
      },
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: isSelected ? Colors.redAccent : AppColors.buttonBg,
        ),
        backgroundColor: isSelected
            ? Colors.redAccent
            : Colors.transparent, // Change the background color when selected
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 0,
        ), // Adjust padding for better look
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.build, // You can replace this with your desired icon
            color: isSelected ? Colors.white : Colors.redAccent,
            size: 20, // Adjust the icon size
          ),
          SizedBox(width: 8), // Space between icon and text
          Text(
            role,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.redAccent,
              fontWeight: FontWeight.w500, // Bold text as in the image
              fontSize: 14, // Adjust font size if necessary
            ),
          ),
        ],
      ),
    );
  }

  // Widget _roleButton(String role) {
  //   final bool isSelected = selectedRole == role;
  //   return OutlinedButton(
  //     onPressed: () {
  //       setState(() {
  //         selectedRole = role;
  //       });
  //     },
  //     style: OutlinedButton.styleFrom(
  //       side: BorderSide(color: AppColors.buttonBg),
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //     ),
  //     child: Text(
  //       role,
  //       style: TextStyle(color: isSelected ? Colors.white : Colors.redAccent),
  //     ),
  //   );
  // }

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 14,
        color: Color(0xFF6C7278),
      ),
    );
  }

  Widget _dropdownField(
    String hint,
    String? selectedValue,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      items: [
        'One Day',
        'One Week',
        'One Month',
      ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey,
          ), // Grey border color when not focused
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey,
          ), // Grey border color when focused
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  Widget _textField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  Widget _descriptionField(TextEditingController controller) {
    return TextField(
      controller: controller,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: "Description",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: EdgeInsets.all(16),
      ),
    );
  }

  Widget _SaveButton(double screenWidth) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Get.to(() => BottomNavScreen()); // Replace with home screen
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonBg,
          padding: EdgeInsets.symmetric(vertical: screenWidth * 0.045),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          "Save now",
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
