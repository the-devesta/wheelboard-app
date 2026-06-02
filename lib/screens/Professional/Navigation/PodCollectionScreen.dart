import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_exception.dart';
import '../../../controllers/Professional/trip_navigation_controller.dart';
import '../../../widgets/custom_snackbar.dart';
import 'TripCompletedScreen.dart';

class PodCollectionScreen extends StatefulWidget {
  final String tripId;
  const PodCollectionScreen({super.key, required this.tripId});

  @override
  State<PodCollectionScreen> createState() => _PodCollectionScreenState();
}

class _PodCollectionScreenState extends State<PodCollectionScreen> {
  final _recipientNameController = TextEditingController();
  final _recipientPhoneController = TextEditingController();
  final _deliveryNotesController = TextEditingController();

  final List<File> _photos = [];
  bool _isUploading = false;
  String? _uploadError;

  final _picker = ImagePicker();

  @override
  void dispose() {
    _recipientNameController.dispose();
    _recipientPhoneController.dispose();
    _deliveryNotesController.dispose();
    super.dispose();
  }

  // ── photo picking ────────────────────────────────────────────────────
  Future<void> _pickFromCamera() async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (picked != null) setState(() => _photos.add(File(picked.path)));
  }

  Future<void> _pickFromGallery() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isNotEmpty) {
      setState(() => _photos.addAll(picked.map((x) => File(x.path))));
    }
  }

  void _removePhoto(int index) => setState(() => _photos.removeAt(index));

  // ── validation + upload ──────────────────────────────────────────────
  bool get _canSubmit =>
      _photos.isNotEmpty &&
      _recipientNameController.text.trim().isNotEmpty &&
      _recipientPhoneController.text.trim().isNotEmpty;

  Future<void> _submit() async {
    setState(() {
      _isUploading = true;
      _uploadError = null;
    });

    try {
      // Build multipart form data (Dio's FormData, not get's)
      final formData = dio.FormData();

      for (final photo in _photos) {
        final filename = photo.path.split(Platform.pathSeparator).last;
        formData.files.add(MapEntry(
          'photos',
          await dio.MultipartFile.fromFile(photo.path, filename: filename),
        ));
      }

      formData.fields
        ..add(MapEntry('recipientName', _recipientNameController.text.trim()))
        ..add(MapEntry('recipientPhone', _recipientPhoneController.text.trim()));

      if (_deliveryNotesController.text.trim().isNotEmpty) {
        formData.fields.add(
          MapEntry('deliveryNotes', _deliveryNotesController.text.trim()));
      }

      // POST /trips/:tripId/pod  (mirrors the web navigate page)
      await ApiClient.instance.post(
        ApiEndpoints.trips.podUpload(widget.tripId),
        data: formData,
      );

      // Mark step as completed in navigation controller
      if (Get.isRegistered<TripNavigationController>()) {
        Get.find<TripNavigationController>().currentStep.value =
            TripStep.completed;
      }

      SnackBarHelper.success('Proof of delivery uploaded successfully!');

      if (mounted) {
        Get.off(
          () => TripCompletedScreen(tripId: widget.tripId),
          transition: Transition.rightToLeft,
        );
      }
    } on dio.DioException catch (e) {
      final msg = e.error is ApiException
          ? (e.error as ApiException).message
          : (e.response?.data?['message'] as String?) ??
              'Failed to upload proof of delivery.';
      if (mounted) setState(() => _uploadError = msg);
    } catch (e) {
      if (mounted) setState(() => _uploadError = 'Unexpected error. Please try again.');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFFF5E5E)),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          'Proof of Delivery',
          style: GoogleFonts.poppins(
            fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF1F2937)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── header banner ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.assignment_turned_in, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Delivery Confirmation',
                      style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                    Text(
                      'Take photos and enter recipient details to complete the trip.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.85))),
                  ],
                )),
              ]),
            ),
            const SizedBox(height: 24),

            // ── delivery photos ─────────────────────────────────────────
            _sectionTitle('Delivery Photos *', Icons.camera_alt),
            const SizedBox(height: 12),
            _photos.isEmpty ? _emptyPhotoPlaceholder() : _photoGrid(),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _iconButton(
                icon: Icons.camera_alt,
                label: 'Camera',
                onTap: _pickFromCamera,
              )),
              const SizedBox(width: 12),
              Expanded(child: _iconButton(
                icon: Icons.photo_library,
                label: 'Gallery',
                onTap: _pickFromGallery,
              )),
            ]),
            const SizedBox(height: 24),

            // ── recipient details ───────────────────────────────────────
            _sectionTitle('Recipient Details', Icons.person_outline),
            const SizedBox(height: 12),
            _inputField(
              controller: _recipientNameController,
              label: 'Recipient Name *',
              hint: 'Enter recipient full name',
              icon: Icons.person,
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 12),
            _inputField(
              controller: _recipientPhoneController,
              label: 'Contact Number *',
              hint: 'Enter recipient phone number',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            _inputField(
              controller: _deliveryNotesController,
              label: 'Delivery Notes (optional)',
              hint: 'Any notes about the delivery...',
              icon: Icons.note,
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // ── error banner ────────────────────────────────────────────
            if (_uploadError != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(children: [
                  Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_uploadError!,
                    style: GoogleFonts.poppins(
                      fontSize: 12, color: Colors.red[700]))),
                ]),
              ),

            // ── submit button ───────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (_canSubmit && !_isUploading) ? _submit : null,
                icon: _isUploading
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.check_circle, size: 20),
                label: Text(
                  _isUploading ? 'Uploading...' : 'Submit Proof of Delivery',
                  style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  disabledBackgroundColor: Colors.grey[300],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),

            if (!_canSubmit && !_isUploading)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _photos.isEmpty
                      ? 'Please add at least one delivery photo.'
                      : 'Please fill in recipient name and contact number.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 11, color: Colors.grey[500]),
                ),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── sub-widgets ───────────────────────────────────────────────────────
  Widget _sectionTitle(String title, IconData icon) {
    return Row(children: [
      Icon(icon, size: 18, color: const Color(0xFF7C3AED)),
      const SizedBox(width: 8),
      Text(title, style: GoogleFonts.poppins(
        fontSize: 14, fontWeight: FontWeight.w600,
        color: const Color(0xFF1F2937))),
    ]);
  }

  Widget _emptyPhotoPlaceholder() {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1.5),
      ),
      child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey[400]),
        const SizedBox(height: 8),
        Text('No photos added yet',
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[400])),
      ])),
    );
  }

  Widget _photoGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
      itemCount: _photos.length,
      itemBuilder: (_, i) => Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(_photos[i], fit: BoxFit.cover),
          ),
          Positioned(
            top: 4, right: 4,
            child: GestureDetector(
              onTap: () => _removePhoto(i),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.close, size: 14, color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.4)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 18, color: const Color(0xFF7C3AED)),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.poppins(
            fontSize: 13, fontWeight: FontWeight.w600,
            color: const Color(0xFF7C3AED))),
        ]),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.poppins(
        fontSize: 12, fontWeight: FontWeight.w500,
        color: Colors.grey[600])),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: GoogleFonts.poppins(
          fontSize: 14, color: const Color(0xFF1F2937)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[400]),
          prefixIcon: maxLines == 1
              ? Icon(icon, size: 18, color: Colors.grey[400])
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[200]!)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[200]!)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF7C3AED), width: 1.5)),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16, vertical: maxLines > 1 ? 14 : 0),
        ),
      ),
    ]);
  }
}
