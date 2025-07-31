import 'package:flutter/material.dart';
import 'package:wheelboard/constants/apps_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NetworkPostScreen extends StatefulWidget {
  const NetworkPostScreen({super.key});

  @override
  State<NetworkPostScreen> createState() => _NetworkPostScreenState();
}

class _NetworkPostScreenState extends State<NetworkPostScreen> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
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
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () {
              // Handle close button press
            },
          ),
        ],
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
                      child: const TextField(
                        maxLines: null, // Allows multiline input
                        expands: true, // Allows content to expand vertically
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          hintText: 'Share your thoughts...',
                          fillColor: Color(0xFFF9FAFB),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(12.0),
                        ),
                      ),
                    ),
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
            const SizedBox(height: 16.0),

            // Action Buttons
            Row(
              children: <Widget>[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Handle upload pictures
                    },
                    label: const Text(
                      'Upload Pictures (optional)',
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Handle browse file
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Browse File'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400], // Example color
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              children: <Widget>[
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle cancel
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
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Handle post
                    },
                    icon: const Icon(Icons.send, size: 18),
                    label: const Text('Post'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400], // Example color
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
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
      groupValue: _selectedCategory,
      onChanged: (String? newValue) {
        setState(() {
          _selectedCategory = newValue;
        });
      },
      activeColor: Colors.blueGrey,
      controlAffinity: ListTileControlAffinity.trailing,
      contentPadding: EdgeInsets.zero,
    );
  }
}
