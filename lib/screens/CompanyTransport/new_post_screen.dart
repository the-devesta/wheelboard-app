import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wheelboard/constants/apps_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/Transport/post_controller.dart';
import 'package:wheelboard/core/auth/auth_service.dart';
import '../../widgets/custom_snackbar.dart';

class NetworkPostScreen extends StatefulWidget {
  const NetworkPostScreen({super.key});

  @override
  State<NetworkPostScreen> createState() => _NetworkPostScreenState();
}

class _NetworkPostScreenState extends State<NetworkPostScreen> {
  final PostController postController = Get.put(PostController());
  final TextEditingController _contentController = TextEditingController();
  String? _selectedCategory;
  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    // Check if user is professional
    if (AuthService.to.isProfessional) {
      return Scaffold(
        appBar: AppBar(title: const Text('Access Denied')),
        body: const Center(child: Text('Professionals cannot create posts.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.primary, // Light grey background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // No shadow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Network Post',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Create a Post Card
            Card(
              color: Colors.white,
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Create a Post',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF535353),
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _contentController,
                        maxLines: null, // Allows multiline input
                        expands: true, // Allows content to expand vertically
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                          hintText: 'Share your thoughts...',
                          fillColor: Color(0xFFF9FAFB),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(12.0),
                        ),
                      ),
                    ),
                    // Display selected images
                    if (_selectedImages.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedImages.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: FileImage(_selectedImages[index]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedImages.removeAt(index);
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
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // Select Category Card
            Card(
              color: Colors.white,
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: RadioGroup<String>(
                  groupValue: _selectedCategory,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  },
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Select Category',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF535353),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    _buildCategoryRadioTile(
                      iconPath: 'assets/tips.svg',
                      title: 'Tips',
                      value: 'Tips',
                    ),
                    _buildCategoryRadioTile(
                      iconPath: 'assets/promotion.svg',
                      title: 'Services',
                      value: 'Services',
                    ),
                    _buildCategoryRadioTile(
                      iconPath: 'assets/services.svg',
                      title: 'Promotions',
                      value: 'Promotions',
                    ),
                  ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // Single Add Photo Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showImagePickerOptions();
                },
                icon: const Icon(Icons.add_a_photo, size: 18),
                label: Text(
                  _selectedImages.isEmpty
                      ? 'Add Photo'
                      : '${_selectedImages.length} Photo(s) Selected',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: <Widget>[
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black54,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Color(0xFF374151)),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Obx(
                    () => ElevatedButton.icon(
                      onPressed: postController.isCreatingPost.value
                          ? null
                          : () async {
                              if (_contentController.text.trim().isEmpty) {
                                SnackBarHelper.error("Please enter post content");
                                return;
                              }
                              if (_selectedCategory == null) {
                                SnackBarHelper.error("Please select a category");
                                return;
                              }

                              final success = await postController.createPost(
                                content: _contentController.text.trim(),
                                category: _selectedCategory!,
                                images: _selectedImages.isNotEmpty
                                    ? _selectedImages
                                    : null,
                              );

                              if (success) {
                                _resetFormState();
                                if (context.mounted) {
                                  Navigator.of(context).pop(true);
                                }
                              }
                            },
                      icon: postController.isCreatingPost.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.send, size: 18),
                      label: Text(
                        postController.isCreatingPost.value
                            ? 'Posting...'
                            : 'Post',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[400],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _resetFormState() {
    _contentController.clear();
    _selectedCategory = null;
    setState(() {
      _selectedImages.clear();
    });
  }

  Widget _buildCategoryRadioTile({
    required String iconPath, // Path to your SVG file
    required String title,
    required String value,
  }) {
    return RadioListTile<String>(
      title: Row(
        children: [
          SvgPicture.asset(
            iconPath, // Path to your SVG image
            width: 50.0, // Set the width of the SVG image
            height: 50.0, // Set the height of the SVG image
            // Color of the SVG image, optional
          ),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      value: value,
      activeColor: Colors.blueGrey,
      controlAffinity: ListTileControlAffinity.trailing,
      contentPadding: EdgeInsets.zero,
    );
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(imageQuality: 80);

      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(
            images.map((xFile) => File(xFile.path)).toList(),
          );
        });
      }
    } catch (e) {
      SnackBarHelper.error("Failed to pick images: $e");
    }
  }

  Future<void> _showImagePickerOptions() async {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Take Photo"),
              onTap: () async {
                Get.back();
                try {
                  final XFile? photo = await _picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (photo != null) {
                    setState(() {
                      _selectedImages.add(File(photo.path));
                    });
                  }
                } catch (e) {
                  SnackBarHelper.error("Failed to take photo: $e");
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Get.back();
                _pickImages();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }
}
