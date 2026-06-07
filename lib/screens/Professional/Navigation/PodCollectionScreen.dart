import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_exception.dart';
import '../../../controllers/Professional/trip_navigation_controller.dart';
import '../../../theme/design_system.dart';
import '../../../widgets/custom_snackbar.dart';
import 'TripCompletedScreen.dart';

/// Proof-of-delivery capture (camera/gallery + recipient details) → uploads to
/// `POST /trips/:id/pod` as multipart, then advances the step machine to
/// completed. Upload logic is unchanged; only the presentation is modernized.
class PodCollectionScreen extends StatefulWidget {
  final String tripId;
  const PodCollectionScreen({super.key, required this.tripId});

  @override
  State<PodCollectionScreen> createState() => _PodCollectionScreenState();
}

class _PodCollectionScreenState extends State<PodCollectionScreen> {
  static const _accent = AppPalette.purple;

  final _recipientNameController = TextEditingController();
  final _recipientPhoneController = TextEditingController();
  final _deliveryNotesController = TextEditingController();

  static const _maxPhotos = 6;

  final List<File> _photos = [];
  bool _isUploading = false;
  String? _uploadError;
  double _uploadProgress = 0.0;
  Timer? _progressTimer;

  final _picker = ImagePicker();

  @override
  void dispose() {
    _progressTimer?.cancel();
    _recipientNameController.dispose();
    _recipientPhoneController.dispose();
    _deliveryNotesController.dispose();
    super.dispose();
  }

  // ── photo picking ────────────────────────────────────────────────────
  Future<void> _pickFromCamera() async {
    if (_photos.length >= _maxPhotos) {
      _showMaxPhotoSnack();
      return;
    }
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (picked != null) setState(() => _photos.add(File(picked.path)));
  }

  Future<void> _pickFromGallery() async {
    if (_photos.length >= _maxPhotos) {
      _showMaxPhotoSnack();
      return;
    }
    final remaining = _maxPhotos - _photos.length;
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isNotEmpty) {
      setState(() => _photos.addAll(
            picked.take(remaining).map((x) => File(x.path)),
          ));
      if (picked.length > remaining && mounted) _showMaxPhotoSnack();
    }
  }

  void _showMaxPhotoSnack() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Maximum $_maxPhotos photos allowed.',
          style: AppText.label.on(Colors.white)),
      backgroundColor: AppPalette.amber,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _removePhoto(int index) => setState(() => _photos.removeAt(index));

  // ── validation + upload ──────────────────────────────────────────────
  bool get _canSubmit =>
      _photos.isNotEmpty &&
      _recipientNameController.text.trim().isNotEmpty &&
      _recipientPhoneController.text.trim().isNotEmpty;

  void _startProgressAnimation() {
    _uploadProgress = 0.0;
    // Simulate upload progress: ramp to 85% quickly, hold until real success.
    _progressTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      if (!mounted) {
        _progressTimer?.cancel();
        return;
      }
      final target = _uploadProgress < 0.5 ? 0.5 : 0.85;
      final step = _uploadProgress < 0.5 ? 0.04 : 0.008;
      if (_uploadProgress < target) {
        setState(() => _uploadProgress =
            (_uploadProgress + step).clamp(0.0, target));
      } else {
        _progressTimer?.cancel();
      }
    });
  }

  Future<void> _submit() async {
    setState(() {
      _isUploading = true;
      _uploadError = null;
      _uploadProgress = 0.0;
    });
    _startProgressAnimation();

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

      // Snap progress to 100% and fire haptic before navigating.
      _progressTimer?.cancel();
      if (mounted) setState(() => _uploadProgress = 1.0);
      HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 400));

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
      if (mounted) {
        setState(() => _uploadError = 'Unexpected error. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.bg,
      appBar: AppBar(
        backgroundColor: AppPalette.card,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: AppPalette.textDark),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text('Proof of Delivery', style: AppText.h3),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _banner(),
            AppSpacing.vGapXl,

            _sectionTitleWithBadge(
              'Delivery Photos *',
              Iconsax.camera,
              '${_photos.length}/$_maxPhotos',
              _photos.isNotEmpty,
            ),
            AppSpacing.vGapMd,
            _photos.isEmpty ? _emptyPhotoPlaceholder() : _photoGrid(),
            AppSpacing.vGapMd,
            Row(children: [
              Expanded(
                  child: _pickButton(
                      icon: Iconsax.camera,
                      label: 'Camera',
                      onTap: _pickFromCamera)),
              AppSpacing.hGapMd,
              Expanded(
                  child: _pickButton(
                      icon: Iconsax.gallery,
                      label: 'Gallery',
                      onTap: _pickFromGallery)),
            ]),
            AppSpacing.vGapXl,

            _sectionTitle('Recipient Details', Iconsax.user),
            AppSpacing.vGapMd,
            _inputField(
              controller: _recipientNameController,
              label: 'Recipient Name *',
              hint: 'Enter recipient full name',
              icon: Iconsax.user,
              keyboardType: TextInputType.name,
            ),
            AppSpacing.vGapMd,
            _inputField(
              controller: _recipientPhoneController,
              label: 'Contact Number *',
              hint: 'Enter recipient phone number',
              icon: Iconsax.call,
              keyboardType: TextInputType.phone,
            ),
            AppSpacing.vGapMd,
            _inputField(
              controller: _deliveryNotesController,
              label: 'Delivery Notes (optional)',
              hint: 'Any notes about the delivery…',
              icon: Iconsax.note_1,
              maxLines: 3,
            ),
            AppSpacing.vGapXl,

            if (_uploadError != null) ...[
              AppBanner(
                text: _uploadError!,
                icon: Iconsax.warning_2,
                color: AppPalette.danger,
                background: AppPalette.dangerBg,
                borderColor: const Color(0x33EF4444),
              ),
              AppSpacing.vGapLg,
            ],

            // Upload progress bar — visible while uploading.
            if (_isUploading) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _uploadProgress,
                  minHeight: 6,
                  backgroundColor: AppPalette.border,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(_accent),
                ),
              ),
              AppSpacing.vGapSm,
              Text(
                _uploadProgress >= 1.0
                    ? 'Upload complete!'
                    : 'Uploading ${(_uploadProgress * 100).toStringAsFixed(0)}%…',
                textAlign: TextAlign.center,
                style: AppText.caption.on(_accent).weight(FontWeight.w600),
              ),
              AppSpacing.vGapMd,
            ],

            AppPrimaryButton(
              label: _isUploading ? 'Uploading…' : 'Submit Proof of Delivery',
              icon: _isUploading ? null : Iconsax.tick_circle,
              color: _accent,
              loading: _isUploading,
              onPressed: _canSubmit ? _submit : null,
            ),

            if (!_canSubmit && !_isUploading)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(
                  _photos.isEmpty
                      ? 'Please add at least one delivery photo.'
                      : 'Please fill in recipient name and contact number.',
                  textAlign: TextAlign.center,
                  style: AppText.caption,
                ),
              ),
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }

  // ── sub-widgets ───────────────────────────────────────────────────────
  Widget _banner() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
        ),
        borderRadius: AppRadius.rXl,
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: AppRadius.rLg),
          child: const Icon(Iconsax.task_square, color: Colors.white, size: 26),
        ),
        AppSpacing.hGapLg,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Delivery Confirmation',
                  style: AppText.subtitle.on(Colors.white).size(16)),
              Text(
                'Take photos and enter recipient details to complete the trip.',
                style: AppText.caption.on(Colors.white.withValues(alpha: 0.88)),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(children: [
      Icon(icon, size: 18, color: _accent),
      AppSpacing.hGapSm,
      Text(title, style: AppText.subtitle),
    ]);
  }

  Widget _sectionTitleWithBadge(
    String title,
    IconData icon,
    String badge,
    bool showBadge,
  ) {
    return Row(children: [
      Icon(icon, size: 18, color: _accent),
      AppSpacing.hGapSm,
      Text(title, style: AppText.subtitle),
      const Spacer(),
      if (showBadge)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: _accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(badge,
              style: AppText.micro.on(_accent).weight(FontWeight.w700)),
        ),
    ]);
  }

  Widget _emptyPhotoPlaceholder() {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: AppPalette.card,
        borderRadius: AppRadius.rXl,
        border: Border.all(color: AppPalette.border, width: 1.5),
      ),
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Iconsax.gallery_add, size: 38, color: AppPalette.textFaint),
          AppSpacing.vGapSm,
          Text('No photos added yet', style: AppText.caption),
        ]),
      ),
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
            borderRadius: AppRadius.rLg,
            child: Image.file(_photos[i], fit: BoxFit.cover),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removePhoto(i),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child:
                    const Icon(Icons.close, size: 14, color: AppPalette.danger),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pickButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppPalette.card,
          borderRadius: AppRadius.rLg,
          border: Border.all(color: _accent.withValues(alpha: 0.4)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 18, color: _accent),
          AppSpacing.hGapSm,
          Text(label, style: AppText.subtitle.on(_accent).size(13)),
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
      Text(label, style: AppText.label),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: (_) => setState(() {}), // refresh submit-button enablement
        style: AppText.body.on(AppPalette.textDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppText.bodySm.on(AppPalette.textFaint),
          prefixIcon: maxLines == 1
              ? Icon(icon, size: 18, color: AppPalette.textFaint)
              : null,
          filled: true,
          fillColor: AppPalette.card,
          border: OutlineInputBorder(
              borderRadius: AppRadius.rLg,
              borderSide: const BorderSide(color: AppPalette.border)),
          enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.rLg,
              borderSide: const BorderSide(color: AppPalette.border)),
          focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.rLg,
              borderSide: const BorderSide(color: _accent, width: 1.5)),
          contentPadding: EdgeInsets.symmetric(
              horizontal: 16, vertical: maxLines > 1 ? 14 : 0),
        ),
      ),
    ]);
  }
}
