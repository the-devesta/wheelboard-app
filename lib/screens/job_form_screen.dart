import 'package:flutter/material.dart';

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Job Details"),
                    _roleButton("Technician"),
                    SizedBox(width: 12),
                    _roleButton("Helper"),
                  ],
                ),
                SizedBox(height: 20),

                _label("Job duration"),
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
                      child: _textField("No. of Openings", openingController),
                    ),
                    SizedBox(width: 12),
                    Expanded(child: _textField("Salary", salaryController)),
                  ],
                ),

                SizedBox(height: 16),
                _label("City"),
                _textField("Enter city", cityController),

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
                ElevatedButton(
                  onPressed: () {
                    // Upload logic
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 5,
                    shadowColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text("Upload"),
                ),

                SizedBox(height: 8),
                for (var file in uploadedFiles)
                  Text(
                    "$file uploaded successfully",
                    style: TextStyle(color: Colors.green, fontSize: 13),
                  ),

                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Save logic
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Colors.redAccent),
                      ),
                    ),
                    child: Text("Save Now!", style: TextStyle(fontSize: 16)),
                  ),
                ),
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
        side: BorderSide(color: Colors.redAccent),
        backgroundColor: isSelected ? Colors.redAccent : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(
        role,
        style: TextStyle(color: isSelected ? Colors.white : Colors.redAccent),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
}
