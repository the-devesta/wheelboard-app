import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

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

  List<PlatformFile> uploadedFiles = <PlatformFile>[];
  String selectedRole = 'Driver';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4E3E3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text(
          "Post a Job",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: const Color(0xFF1E1E1E),
            letterSpacing: -0.14,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ],
        shape: const Border(
          bottom: BorderSide(
            color: Color(0xFFFCD2D2),
            width: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
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
                // Step indicator
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Step 1 of 2",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                      color: const Color(0xFF6C7278),
                      letterSpacing: -0.24,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Job Details heading
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Job Details",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      color: const Color(0xFF6C7278),
                      letterSpacing: -0.28,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Job Type Selection Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildJobTypeButton("Driver", Icons.person),
                    _buildJobTypeButton("Technician", Icons.build),
                    _buildJobTypeButton("Helper", Icons.person_outline),
                  ],
                ),
                const SizedBox(height: 24),

                // Job Duration
                _buildLabel("Job duration"),
                const SizedBox(height: 2),
                _buildDropdownField(
                  "Select Job Duration",
                  selectedJobDuration,
                  (value) {
                  setState(() {
                    selectedJobDuration = value;
                  });
                  },
                ),
                const SizedBox(height: 17),

                // Opening and Salary Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Opening"),
                          const SizedBox(height: 2),
                          _buildTextField(
                            "No. of Openings",
                        controller: openingController,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Salary"),
                          const SizedBox(height: 2),
                          _buildTextField(
                            "Salary",
                        controller: salaryController,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 17),

                // City
                _buildLabel("City"),
                const SizedBox(height: 2),
                _buildTextField(
                  "Enter city",
                  controller: cityController,
                ),
                const SizedBox(height: 17),

                // Type of Job
                _buildLabel("Type of Job"),
                const SizedBox(height: 8),
                _buildDropdownField(
                  "Select job type",
                  selectedJobType,
                  (value) {
                  setState(() {
                    selectedJobType = value;
                  });
                  },
                ),
                const SizedBox(height: 17),

                // Description
                _buildLabel("Description"),
                const SizedBox(height: 8),
                _buildDescriptionField(descriptionController),
                const SizedBox(height: 17),

                // Upload Images Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "Upload Images of vehicles or Job Poster",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                            color: const Color(0xFF6C7278),
                            letterSpacing: -0.24,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 77,
                      height: 27,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF36C6C),
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 3,
                            offset: const Offset(3, 3),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _pickImages,
                          borderRadius: BorderRadius.circular(50),
                          child: Center(
                            child: Text(
                              "Upload",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Save Button
                Center(
                  child: SizedBox(
                    width: 295,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        // Save logic
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF25C5C),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Save Now!",
                        style: TextStyle(
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
            // Uploaded files list - positioned outside white card
            if (uploadedFiles.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 53, top: 20, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: uploadedFiles.asMap().entries.map((entry) {
                    final index = entry.key;
                    final file = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index < uploadedFiles.length - 1 ? 4 : 0,
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                            color: const Color(0xFF6C7278).withOpacity(0.87),
                            letterSpacing: -0.24,
                          ),
                          children: [
                            TextSpan(text: "${file.name}            "),
                            TextSpan(
                              text: "uploaded successfully",
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: const Color(0xFF10E445),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobTypeButton(String role, IconData icon) {
    final bool isSelected = selectedRole == role;
    return SizedBox(
      width: 85,
      height: 29,
      child: OutlinedButton(
      onPressed: () {
        setState(() {
          selectedRole = role;
        });
      },
      style: OutlinedButton.styleFrom(
        side: BorderSide(
            color: isSelected
                ? const Color(0xFFF36363)
                : const Color(0xFFF36969),
            width: 1,
        ),
          backgroundColor: Colors.white,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
              icon,
              size: 12,
              color: isSelected
                  ? const Color(0xFFF36666)
                  : const Color(0xFFF36969),
          ),
            const SizedBox(width: 8),
            Text(
              role,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: isSelected
                    ? const Color(0xFFF36666)
                    : const Color(0xFFF36969),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        fontFamily: 'Poppins',
        color: const Color(0xFF6C7278),
        letterSpacing: -0.24,
      ),
    );
  }

  Widget _buildTextField(String hint, {TextEditingController? controller}) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEDF1F3), width: 1),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(
          fontSize: 14,
          fontFamily: 'Inter',
          color: const Color(0xFF6C7278),
          letterSpacing: -0.14,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
        fontSize: 14,
            fontFamily: 'Inter',
            color: const Color(0xFF6C7278),
            letterSpacing: -0.14,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    String hint,
    String? selectedValue,
    Function(String?) onChanged,
  ) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD9D9D9), width: 1),
      ),
      child: DropdownButtonFormField<String>(
      value: selectedValue,
      items: [
          if (hint.contains("Duration"))
            ...['One Day', 'One Week', 'One Month']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
          if (hint.contains("job type"))
            ...['Full-time', 'Part-time', 'Contract']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
        ],
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
          hintStyle: TextStyle(
            fontSize: 14,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
            color: const Color(0xFFB3B3B3),
            letterSpacing: 0.1,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: Color(0xFF006FFD),
          size: 24,
        ),
        style: TextStyle(
          fontSize: 14,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w500,
          color: const Color(0xFFB3B3B3),
        ),
      ),
    );
  }

  Widget _buildDescriptionField(TextEditingController controller) {
    return Container(
      constraints: const BoxConstraints(minHeight: 80),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD9D9D9), width: 1),
      ),
      child: TextField(
      controller: controller,
        maxLines: null,
        minLines: 3,
        style: TextStyle(
          fontSize: 16,
          fontFamily: 'Inter',
          color: const Color(0xFFB3B3B3),
        ),
      decoration: InputDecoration(
        hintText: "Description",
          hintStyle: TextStyle(
            fontSize: 16,
            fontFamily: 'Inter',
            color: const Color(0xFFB3B3B3),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Future<void> _pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        uploadedFiles = List<PlatformFile>.from(result.files);
      });
    }
  }
}
