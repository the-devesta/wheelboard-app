import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:wheelboard/core/auth/auth_service.dart';
import '../../controllers/Transport/post_controller.dart';
import '../../widgets/smart_image.dart';
import '../../widgets/ui/app_ui.dart';

/// Create Post — a minimal, social-media-style composer.
///
/// 1:1 with the web `CreatePostModal` (wheelboard-fe/src/components/company):
/// same 5 categories, same upload-on-select flow (image → `/media` → hosted
/// URL, then the post carries that URL), same 5MB/type validation, same
/// disabled-until-content Post button. Shared by the Transport Company and
/// Service Provider (business) personas.
class NetworkPostScreen extends StatefulWidget {
  const NetworkPostScreen({super.key});

  @override
  State<NetworkPostScreen> createState() => _NetworkPostScreenState();
}

class _NetworkPostScreenState extends State<NetworkPostScreen> {
  final PostController _controller = Get.isRegistered<PostController>()
      ? Get.find<PostController>()
      : Get.put(PostController());
  final TextEditingController _contentCtrl = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  // Same five categories, in the same order, as the web CreatePostModal.
  static const _categories = <_Category>[
    _Category(FeedCategory.tip, 'Tips', Icons.lightbulb_outline_rounded),
    _Category(FeedCategory.services, 'Services', Icons.layers_outlined),
    _Category(FeedCategory.promotions, 'Promotions', Icons.campaign_outlined),
    _Category(FeedCategory.question, 'Question', Icons.help_outline_rounded),
    _Category(FeedCategory.general, 'General', Icons.public_rounded),
  ];

  String _selectedCategory = FeedCategory.tip; // web default: 'tip'
  String? _uploadedImageUrl;
  bool _uploading = false;
  String? _error;

  static const _maxImageBytes = 5 * 1024 * 1024;

  @override
  void initState() {
    super.initState();
    _contentCtrl.addListener(() => setState(() {})); // live-enable Post button
  }

  @override
  void dispose() {
    _contentCtrl.dispose();
    super.dispose();
  }

  bool get _canPost =>
      _contentCtrl.text.trim().isNotEmpty && !_uploading;

  // ── Image upload (on select, exactly like the web) ────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 85);
      if (picked == null) return;
      final file = File(picked.path);

      final size = await file.length();
      if (size > _maxImageBytes) {
        setState(() => _error = 'Image size must be less than 5MB');
        return;
      }

      setState(() {
        _error = null;
        _uploading = true;
      });

      final url = await _controller.uploadImage(file);
      if (!mounted) return;
      if (url == null || url.isEmpty) {
        setState(() {
          _uploading = false;
          _error = 'Failed to upload image. Please try again.';
        });
        return;
      }
      setState(() {
        _uploadedImageUrl = url;
        _uploading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _uploading = false;
        _error = 'Failed to upload image. Please try again.';
      });
    }
  }

  void _showImageSourceSheet() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: AppUi.accent),
                title: const Text('Take Photo'),
                onTap: () {
                  Get.back();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppUi.accent),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Get.back();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  Future<void> _post() async {
    if (!_canPost) return;
    setState(() => _error = null);

    final ok = await _controller.createPost(
      content: _contentCtrl.text.trim(),
      category: _selectedCategory,
      imageUrl: _uploadedImageUrl,
    );

    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
    }
    // On failure the controller shows the real backend message via snackbar.
  }

  @override
  Widget build(BuildContext context) {
    // Professionals cannot create posts (mirrors the web role gate).
    if (AuthService.to.isProfessional) {
      return Scaffold(
        appBar: AppBar(title: const Text('Access Denied')),
        body: const Center(child: Text('Professionals cannot create posts.')),
      );
    }

    return Scaffold(
      backgroundColor: AppUi.scaffold,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppUi.textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Create Post', style: AppUi.title),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _composerCard(),
          const SizedBox(height: 16),
          _categoryCard(),
          const SizedBox(height: 16),
          if (_error != null) ...[
            _errorBox(_error!),
            const SizedBox(height: 16),
          ],
          _imageSection(),
          const SizedBox(height: 24),
          _actions(),
        ],
      ),
    );
  }

  Widget _composerCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _authorAvatar(),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  AuthService.to.currentUser.value?.displayName ?? 'You',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700, color: AppUi.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _contentCtrl,
            maxLines: 5,
            minLines: 4,
            style: const TextStyle(fontSize: 15, color: AppUi.textPrimary, height: 1.4),
            decoration: InputDecoration(
              hintText: 'Share your thoughts…',
              hintStyle: const TextStyle(color: AppUi.textTertiary, fontSize: 15),
              filled: true,
              fillColor: AppUi.scaffold,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppUi.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppUi.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppUi.accent, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _authorAvatar() {
    final logo = AuthService.to.currentUser.value?.profile['companyLogo']?.toString() ??
        AuthService.to.currentUser.value?.profile['logo']?.toString();
    const radius = 20.0;
    if (logo != null && logo.trim().isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: SmartImage(
            source: logo,
            width: radius * 2, height: radius * 2, fit: BoxFit.cover,
            placeholder: _initialsAvatar(radius)),
      );
    }
    return _initialsAvatar(radius);
  }

  Widget _initialsAvatar(double radius) {
    final name = AuthService.to.currentUser.value?.displayName ?? 'U';
    final initials = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'U';
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppUi.accentSoft,
      child: Text(initials,
          style: const TextStyle(color: AppUi.accent, fontWeight: FontWeight.w700)),
    );
  }

  Widget _categoryCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Category', style: AppUi.title),
          const SizedBox(height: 12),
          ..._categories.map(_categoryTile),
        ],
      ),
    );
  }

  Widget _categoryTile(_Category cat) {
    final selected = _selectedCategory == cat.value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _selectedCategory = cat.value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? AppUi.accentSoft : AppUi.scaffold,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppUi.accent : AppUi.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: selected ? AppUi.accent : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: selected ? null : Border.all(color: AppUi.border),
                ),
                child: Icon(cat.icon,
                    size: 20, color: selected ? Colors.white : AppUi.textSecondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(cat.label,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: selected ? AppUi.accentDark : AppUi.textPrimary)),
              ),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? AppUi.accent : Colors.white,
                  border: Border.all(
                      color: selected ? AppUi.accent : AppUi.textTertiary, width: 2),
                ),
                child: selected
                    ? const Center(
                        child: Icon(Icons.circle, size: 8, color: Colors.white))
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageSection() {
    return Column(
      children: [
        if (_uploading)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppUi.blue)),
                SizedBox(width: 10),
                Text('Uploading image…', style: TextStyle(color: AppUi.blue)),
              ],
            ),
          )
        else if (_uploadedImageUrl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              children: [
                SmartImage(
                  source: _uploadedImageUrl,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  placeholder: Container(
                    height: 220,
                    width: double.infinity,
                    color: const Color(0xFFF3F4F6),
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image_outlined,
                        color: AppUi.textTertiary, size: 40),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => setState(() => _uploadedImageUrl = null),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _uploading ? null : _showImageSourceSheet,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: AppUi.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppUi.border, width: 1.5, style: BorderStyle.solid),
            ),
            child: Column(
              children: [
                const Icon(Icons.upload_rounded, color: AppUi.textSecondary),
                const SizedBox(height: 6),
                Text(
                  _uploadedImageUrl != null
                      ? 'Change Image (optional)'
                      : 'Upload Image (optional)',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600, color: AppUi.textSecondary),
                ),
                const SizedBox(height: 4),
                const Text('Max file size: 5MB. Supports JPG, PNG, GIF',
                    style: TextStyle(fontSize: 11, color: AppUi.textTertiary)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _errorBox(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Text(message,
          style: const TextStyle(color: AppUi.red, fontSize: 13)),
    );
  }

  Widget _actions() {
    return Row(
      children: [
        Expanded(
          child: SecondaryButton(
            label: 'Cancel',
            color: AppUi.textSecondary,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Obx(() => PrimaryButton(
                label: 'Post',
                icon: Icons.send_rounded,
                loading: _controller.isCreatingPost.value,
                onPressed: _canPost ? _post : null,
              )),
        ),
      ],
    );
  }
}

class _Category {
  final String value;
  final String label;
  final IconData icon;
  const _Category(this.value, this.label, this.icon);
}
