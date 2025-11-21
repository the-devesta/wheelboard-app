import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../../controllers/job_controller.dart';
import '../../models/job_model.dart';
import '../../widgets/custom_snackbar.dart';
import '../../enums/job_enums.dart';

class PostJobScreen extends StatefulWidget {
  final JobModel? jobToEdit; // For editing existing job

  const PostJobScreen({super.key, this.jobToEdit});

  @override
  _PostJobScreenState createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final JobController jobController = Get.put(JobController());
  
  JobDuration? selectedJobDuration;
  JobType? selectedJobType;

  final TextEditingController openingController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  List<PlatformFile> uploadedFiles = <PlatformFile>[];
  List<File> imageFiles = <File>[];
  JobRole selectedRole = JobRole.driver;
  bool isEditMode = false;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    isEditMode = widget.jobToEdit != null;
    
    if (isEditMode && widget.jobToEdit != null) {
      final job = widget.jobToEdit!;
      selectedRole = JobRole.fromString(job.role);
      
      // Map API jobDuration to enum
      selectedJobDuration = JobDuration.fromString(job.jobDuration);
      
      // Map API jobType to enum
      selectedJobType = JobType.fromString(job.jobType);
      
      openingController.text = job.openings.toString();
      salaryController.text = job.salary.toString();
      cityController.text = job.city;
      descriptionController.text = job.description;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4E3E3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text(
          isEditMode ? "Edit Job" : "Post a Job",
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
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
            // Job Details heading and Step indicator - outside card
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Step 1 of 2",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6C7278).withOpacity(0.87),
                      letterSpacing: -0.24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Job Details",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6C7278),
                      letterSpacing: -0.28,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Center(
        child: Container(
                margin: const EdgeInsets.only(top: 0),
                width: 343,
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
          decoration: BoxDecoration(
            color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
          ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                    // Job Role Selection Buttons - 3 buttons (Driver, Technician, Helper)
                Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildJobTypeButton(JobRole.driver, Icons.person),
                        const SizedBox(width: 12),
                    _buildJobTypeButton(JobRole.technician, Icons.build),
                        const SizedBox(width: 12),
                    _buildJobTypeButton(JobRole.helper, Icons.person_outline),
                  ],
                ),
                    const SizedBox(height: 39),

                // Job Duration - Dropdown
                _buildLabel("Job duration"),
                const SizedBox(height: 2),
                _buildDropdownField(
                  "Select Job Duration",
                  selectedJobDuration?.value,
                  (value) {
                  setState(() {
                    selectedJobDuration = value != null ? JobDuration.fromString(value) : null;
                  });
                  },
                ),
                    const SizedBox(height: 31),

                // Opening and Salary Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Openeing"),
                          const SizedBox(height: 2),
                          _buildTextField(
                            "No. of Openings",
                            controller: openingController,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 11),
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
                    const SizedBox(height: 31),

                // City
                _buildLabel("City"),
                const SizedBox(height: 2),
                _buildTextField(
                  "Enter city",
                  controller: cityController,
                ),
                    const SizedBox(height: 31),

                // Type of Job
                _buildLabel("Type of Job"),
                const SizedBox(height: 8),
                _buildDropdownField(
                  "Select job type",
                  selectedJobType?.value,
                  (value) {
                  setState(() {
                    selectedJobType = value != null ? JobType.fromString(value) : null;
                  });
                  },
                ),
                    const SizedBox(height: 31),

                // Description
                _buildDescriptionField(descriptionController),
                    const SizedBox(height: 31),

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
                              style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                                color: const Color(0xFF6C7278).withOpacity(0.87),
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
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                    // Uploaded files list - inside white card
                    if (uploadedFiles.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: uploadedFiles.asMap().entries.map((entry) {
                          final index = entry.key;
                          final file = entry.value;
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index < uploadedFiles.length - 1 ? 8 : 0,
                            ),
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF6C7278).withOpacity(0.87),
                                  letterSpacing: -0.24,
                                  height: 1.6,
                                ),
                                children: [
                                  TextSpan(text: "${file.name}            "),
                                  TextSpan(
                                    text: "uploaded successfully",
                                    style: GoogleFonts.poppins(
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
                    ],
                    const SizedBox(height: 31),

                // Save Button
                    Obx(
                      () => Center(
                  child: SizedBox(
                    width: 295,
                    height: 48,
                    child: ElevatedButton(
                            onPressed: jobController.isLoading.value || isSubmitting
                                ? null
                                : () async {
                                    // Validate fields
                                    if (selectedJobDuration == null) {
                                      SnackBarHelper.error("Please select job duration");
                                      return;
                                    }
                                    if (selectedJobType == null) {
                                      SnackBarHelper.error("Please select job type");
                                      return;
                                    }
                                    if (openingController.text.trim().isEmpty) {
                                      SnackBarHelper.error("Please enter number of openings");
                                      return;
                                    }
                                    if (salaryController.text.trim().isEmpty) {
                                      SnackBarHelper.error("Please enter salary");
                                      return;
                                    }
                                    if (cityController.text.trim().isEmpty) {
                                      SnackBarHelper.error("Please enter city");
                                      return;
                                    }
                                    if (descriptionController.text.trim().isEmpty) {
                                      SnackBarHelper.error("Please enter description");
                                      return;
                                    }
                                    if (imageFiles.isEmpty && !isEditMode) {
                                      SnackBarHelper.error("Please upload at least one image");
                                      return;
                                    }

                                    final openings = int.tryParse(openingController.text.trim()) ?? 0;
                                    final salary = int.tryParse(salaryController.text.trim()) ?? 0;

                                    setState(() {
                                      isSubmitting = true;
                                    });

                                    try {
                                      if (isEditMode) {
                                        // Update existing job
                                        if (widget.jobToEdit != null) {
                                          final success =
                                              await jobController.updateJob(
                                            jobId: widget.jobToEdit!.jobId,
                                            role: selectedRole.value,
                                            jobDuration:
                                                selectedJobDuration!.value,
                                            openings: openings,
                                            salary: salary,
                                            city: cityController.text.trim(),
                                            jobType: selectedJobType!.value,
                                            description: descriptionController
                                                .text
                                                .trim(),
                                            newImages: imageFiles,
                                          );
                                          if (success) {
                                            await jobController.refreshJobs();
                                            if (mounted) {
                                              Navigator.of(context).pop();
                                            }
                                          }
                                        }
                                      } else {
                                        // Add new job
                                        final success =
                                            await jobController.addJob(
                                          role: selectedRole.value,
                                          jobDuration:
                                              selectedJobDuration!.value,
                                          openings: openings,
                                          salary: salary,
                                          city: cityController.text.trim(),
                                          jobType: selectedJobType!.value,
                                          description:
                                              descriptionController.text.trim(),
                                          images: imageFiles,
                                        );

                                        if (success) {
                                          // Refresh jobs list before going back
                                          await jobController.refreshJobs();
                                          if (mounted) {
                                            Navigator.of(context).pop();
                                          }
                                        }
                                      }
                                    } finally {
                                      if (mounted) {
                                        setState(() {
                                          isSubmitting = false;
                                        });
                                      }
                                    }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSubmitting
                            ? Colors.grey // Disabled color
                            : const Color(0xFFF36C6C),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                              elevation: 0,
                      ),
                            child: jobController.isLoading.value || isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    isEditMode ? "Update Now!" : "Save Now!",
                                    style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.white,
                          letterSpacing: -0.14,
                                    ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobTypeButton(JobRole role, IconData icon) {
    final isSelected = selectedRole == role;
    return SizedBox(
      width: 85,
      height: 29,
      child: isSelected
          ? ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedRole = role;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF36969),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 12,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    role.value,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          : OutlinedButton(
              onPressed: () {
                setState(() {
                  selectedRole = role;
                });
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: Color(0xFFF36969),
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
                    color: const Color(0xFFF36969),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    role.value,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFF36969),
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
      style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF6C7278),
        letterSpacing: -0.24,
        height: 1.6,
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
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF6C7278),
          letterSpacing: -0.14,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(
        fontSize: 14,
            fontWeight: FontWeight.w400,
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
    // Define dropdown items based on hint using enums
    List<String> items = [];
    if (hint.contains("Duration")) {
      items = JobDuration.allValues;
    } else if (hint.contains("job type")) {
      items = JobType.allValues;
    }

    // Validate selectedValue - if it's not in the items list, set to null
    String? validValue = selectedValue;
    if (selectedValue != null && !items.contains(selectedValue)) {
      validValue = null;
    }

    return Stack(
      children: [
        Container(
          height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFEDF1F3), width: 1),
      ),
      child: DropdownButtonFormField<String>(
            value: validValue,
            items: items
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    ))
                .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
              hintStyle: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFB3B3B3),
            letterSpacing: 0.1,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
          ),
        ),
            icon: const SizedBox.shrink(),
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: validValue != null 
                  ? const Color(0xFF1F2937) 
                  : const Color(0xFFB3B3B3),
              letterSpacing: 0.1,
            ),
          ),
        ),
        Positioned(
          right: 12,
          top: 11,
          child: Transform.rotate(
            angle: 3.14159, // 180 degrees
            child: const Icon(
              Icons.keyboard_arrow_up,
          size: 24,
              color: Color(0xFF6C7278),
            ),
        ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField(TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Description",
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF6C7278),
          ),
        ),
        const SizedBox(height: 8),
        Container(
      constraints: const BoxConstraints(minHeight: 80),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD9D9D9), width: 1),
      ),
          child: Stack(
            children: [
              TextField(
      controller: controller,
        maxLines: null,
        minLines: 3,
                style: GoogleFonts.inter(
          fontSize: 16,
                  fontWeight: FontWeight.w400,
          color: const Color(0xFFB3B3B3),
        ),
      decoration: InputDecoration(
        hintText: "Description",
                  hintStyle: GoogleFonts.inter(
            fontSize: 16,
                    fontWeight: FontWeight.w400,
            color: const Color(0xFFB3B3B3),
          ),
          border: InputBorder.none,
                  contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
                ),
              ),
              Positioned(
                bottom: 6,
                right: 6,
                child: Container(
                  width: 6.627,
                  height: 6.627,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB3B3B3),
                    borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
            ],
          ),
        ),
      ],
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
        // Convert PlatformFile to File
        imageFiles = result.files
            .where((file) => file.path != null)
            .map((file) => File(file.path!))
            .toList();
      });
    }
  }
}
