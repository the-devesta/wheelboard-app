import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/policy_service.dart';

// Design tokens
const _primary = Color(0xFFF36969);
const _bg = Color(0xFFF9FAFB);
const _card = Colors.white;
const _textDark = Color(0xFF111827);
const _textGrey = Color(0xFF6B7280);
const _border = Color(0xFFE5E7EB);

/// Legal content screen — mirrors `/privacy-policy` and `/terms-of-service` on web.
///
/// Fetches policy text from the backend (`GET /settings/policies/public`).
/// Falls back to opening the web URL in the browser if fetch fails.
///
/// Usage:
/// ```dart
/// Get.to(() => const LegalScreen(type: LegalType.privacyPolicy));
/// Get.to(() => const LegalScreen(type: LegalType.termsOfService));
/// ```
enum LegalType { privacyPolicy, termsOfService }

class LegalScreen extends StatefulWidget {
  final LegalType type;

  const LegalScreen({super.key, required this.type});

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> {
  final _service = PolicyService();
  String? _content;
  bool _loading = true;
  String? _error;

  String get _title => widget.type == LegalType.privacyPolicy
      ? 'Privacy Policy'
      : 'Terms of Service';

  // Fallback web URLs — adjust domain as needed
  static const _webBase = 'https://wheelboard.in';
  String get _webUrl => widget.type == LegalType.privacyPolicy
      ? '$_webBase/privacy-policy'
      : '$_webBase/terms-of-service';

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final policies = await _service.getPolicies();
      if (!mounted) return;
      setState(() {
        _content = widget.type == LegalType.privacyPolicy
            ? policies.privacyPolicy
            : policies.termsOfService;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _openInBrowser() async {
    final uri = Uri.parse(_webUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _card,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: _border,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: _textDark, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          _title,
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser_rounded,
                color: _textGrey, size: 22),
            tooltip: 'Open in browser',
            onPressed: _openInBrowser,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _primary))
          : _error != null
              ? _fallbackView()
              : _contentView(),
    );
  }

  Widget _contentView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF36969), Color(0xFFFF8C8C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(
              widget.type == LegalType.privacyPolicy
                  ? Icons.shield_outlined
                  : Icons.gavel_rounded,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              _title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Please read this document carefully.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ]),
        ),
        // Policy text
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
          ),
          child: SelectableText(
            _content ?? '',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: _textDark,
              height: 1.7,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Browser fallback button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _openInBrowser,
            icon: const Icon(Icons.open_in_browser_rounded,
                size: 18, color: _primary),
            label: Text(
              'Open in browser',
              style: GoogleFonts.poppins(
                color: _primary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _primary),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _fallbackView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              widget.type == LegalType.privacyPolicy
                  ? Icons.shield_outlined
                  : Icons.gavel_rounded,
              color: _primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _title,
            style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _textDark),
          ),
          const SizedBox(height: 8),
          Text(
            'Could not load content. Tap below to read in your browser.',
            style: GoogleFonts.poppins(fontSize: 13, color: _textGrey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _openInBrowser,
            icon: const Icon(Icons.open_in_browser_rounded,
                color: Colors.white, size: 18),
            label: Text(
              'Open in Browser',
              style: GoogleFonts.poppins(
                  color: Colors.white, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _fetch,
            child: Text(
              'Try again',
              style:
                  GoogleFonts.poppins(color: _textGrey, fontSize: 13),
            ),
          ),
        ]),
      ),
    );
  }
}
