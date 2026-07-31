import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/verification_service.dart';

// ── Design tokens (match the KYC screen) ────────────────────────────────────
const _primary = Color(0xFFF36969);
const _textDark = Color(0xFF111827);
const _textGrey = Color(0xFF6B7280);
const _border = Color(0xFFE5E7EB);
const _green = Color(0xFF22C55E);
const _amber = Color(0xFFF59E0B);
const _danger = Color(0xFFEF4444);

/// Driving Licence verification.
///
/// Built around the current provider contract: the licence is read by OCR from
/// the licence DOCUMENT, so the flow is capture/pick → preview → verify. There
/// is no licence-number + date-of-birth form, because that is not how the
/// current API works.
///
/// UX guarantees this widget is responsible for:
///   • Verification runs only when the user taps Verify — never on open, never
///     from `build`, never from a rebuild.
///   • One in-flight request at a time. Rapid taps cannot fan out into repeated
///     backend calls and repeated paid provider calls.
///   • The chosen document survives a failed attempt — the user never re-picks
///     their licence because our request failed.
///   • No raw technical error ever reaches the screen.
///   • A provider outage offers Try Again / Continue Manually and never claims
///     the licence is invalid.
///   • Nothing is shown as Verified before the backend confirms it.
class DrivingLicenceVerificationCard extends StatefulWidget {
  /// Stored state, so the card opens correctly without a provider call.
  final VerificationResult<DrivingLicenceData>? initialState;

  /// Called whenever the verification state settles, so the host screen can
  /// refresh its own KYC summary.
  final void Function(VerificationResult<DrivingLicenceData> result)?
      onStateChange;

  const DrivingLicenceVerificationCard({
    super.key,
    this.initialState,
    this.onStateChange,
  });

  @override
  State<DrivingLicenceVerificationCard> createState() =>
      _DrivingLicenceVerificationCardState();
}

/// Explicit UI lifecycle, rather than a set of independent booleans that could
/// represent contradictory states (loading AND verified AND errored).
enum _Phase {
  idle,
  verifying,
  verified,
  notVerified,
  temporarilyUnavailable,
  manualForm,
  submittingManual,
  pending,
  rejected,
}

class _DrivingLicenceVerificationCardState
    extends State<DrivingLicenceVerificationCard> {
  final _service = VerificationService();
  final _manualCtrl = TextEditingController();

  _Phase _phase = _Phase.idle;
  VerificationResult<DrivingLicenceData>? _result;
  File? _document;
  String? _fileError;

  /// Synchronous re-entry guard.
  ///
  /// A disabled button is a rendering concern and lags a burst of rapid taps by
  /// a frame; this flag is checked at the top of the handler, so a second
  /// request can never start while the first is in flight.
  bool _inFlight = false;

  @override
  void initState() {
    super.initState();
    // Adopt the stored state passed in by the host. No network call here —
    // opening this card must never cost a provider request.
    final initial = widget.initialState;
    if (initial != null) {
      _result = initial;
      _phase = _phaseFor(initial);
    }
  }

  @override
  void didUpdateWidget(covariant DrivingLicenceVerificationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final incoming = widget.initialState;
    // Only adopt a newly-arrived stored state while the user is not mid-flow,
    // so a parent rebuild cannot wipe a document they just picked.
    if (incoming != null &&
        !identical(incoming, oldWidget.initialState) &&
        !_inFlight &&
        (_phase == _Phase.idle ||
            _phase == _Phase.verified ||
            _phase == _Phase.pending ||
            _phase == _Phase.rejected)) {
      setState(() {
        _result = incoming;
        _phase = _phaseFor(incoming);
      });
    }
  }

  @override
  void dispose() {
    _manualCtrl.dispose();
    super.dispose();
  }

  static _Phase _phaseFor(VerificationResult<DrivingLicenceData> r) {
    switch (r.state) {
      case VerificationState.verified:
        return _Phase.verified;
      case VerificationState.pending:
        return _Phase.pending;
      case VerificationState.rejected:
        return _Phase.rejected;
      case VerificationState.temporarilyUnavailable:
        return _Phase.temporarilyUnavailable;
      case VerificationState.notVerified:
        return _Phase.notVerified;
    }
  }

  void _publish(VerificationResult<DrivingLicenceData> result) {
    // `mounted` is checked by every caller before this runs; navigating away
    // mid-request must never produce a setState-after-dispose.
    setState(() {
      _result = result;
      _phase = _phaseFor(result);
    });
    widget.onStateChange?.call(result);
  }

  // ── Document selection ────────────────────────────────────────────────────

  Future<void> _pickDocument() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                'Add your Driving Licence',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _textDark,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Iconsax.camera, color: _primary),
              title: Text(
                'Take a photo',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Iconsax.gallery, color: _primary),
              title: Text(
                'Choose from gallery',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    // Downscale on the way in: a 12 MP camera capture is far larger than the
    // OCR needs, and shipping it whole is slow on a mobile network and can
    // exceed the upload limit.
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 2000,
    );
    if (picked == null || !mounted) return;

    final file = File(picked.path);
    final error = validateDocumentFile(file);
    if (error != null) {
      setState(() => _fileError = error);
      return;
    }

    setState(() {
      _document = file;
      _fileError = null;
      // A newly chosen document clears a previous failed verdict, but never an
      // established Verified/Pending state.
      if (_phase == _Phase.notVerified ||
          _phase == _Phase.temporarilyUnavailable) {
        _phase = _Phase.idle;
      }
    });
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _verify() async {
    if (_inFlight) return;
    final document = _document;
    if (document == null) {
      setState(() => _fileError = 'Add a photo of your licence first.');
      return;
    }

    _inFlight = true;
    setState(() {
      _phase = _Phase.verifying;
      _fileError = null;
    });

    try {
      final result = await _service.verifyDrivingLicence(document);
      if (!mounted) return;
      _publish(result);
    } finally {
      // Always released, so a failure can never leave a permanent loader.
      _inFlight = false;
    }
  }

  Future<void> _submitManually() async {
    if (_inFlight) return;
    final dlNumber = _manualCtrl.text.trim().toUpperCase();
    if (dlNumber.isEmpty) return;

    _inFlight = true;
    setState(() => _phase = _Phase.submittingManual);

    try {
      final result = await _service.submitDrivingLicenceManually(
        dlNumber: dlNumber,
      );
      if (!mounted) return;
      _publish(result);
    } finally {
      _inFlight = false;
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    switch (_phase) {
      case _Phase.verified:
        return _verifiedCard();
      case _Phase.pending:
        return _pendingCard();
      case _Phase.manualForm:
      case _Phase.submittingManual:
        return _manualForm();
      default:
        return _uploadFlow();
    }
  }

  Widget _verifiedCard() {
    final data = _result?.data;
    return _statusPanel(
      color: _green,
      icon: Iconsax.tick_circle,
      title: 'Driving Licence Verified',
      child: data == null
          ? null
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data.licenseNumber != null)
                  _detail('Licence number', data.licenseNumber!),
                if (data.name != null) _detail('Name', data.name!),
                if (data.expiryDate != null)
                  _detail('Valid until', data.expiryDate!),
                if (data.issuingAuthority != null)
                  _detail('Issuing authority', data.issuingAuthority!),
                if (data.bloodGroup != null)
                  _detail('Blood group', data.bloodGroup!),
                if (data.vehicleClasses != null &&
                    data.vehicleClasses!.isNotEmpty)
                  _detail('Vehicle classes', data.vehicleClasses!.join(', ')),
              ],
            ),
    );
  }

  Widget _pendingCard() => _statusPanel(
        color: _amber,
        icon: Iconsax.clock,
        title: 'Verification Pending',
        child: Text(
          _result?.message ??
              'Your Driving Licence has been submitted and is pending '
                  'verification.',
          style: GoogleFonts.poppins(fontSize: 12.5, color: _textGrey),
        ),
      );

  Widget _uploadFlow() {
    final busy = _phase == _Phase.verifying;
    final failed = _phase == _Phase.notVerified ||
        _phase == _Phase.temporarilyUnavailable;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_phase == _Phase.rejected && _result != null) ...[
          _inlineBanner(
            color: _danger,
            icon: Iconsax.close_circle,
            title: 'Verification Rejected',
            message: '${_result!.message}\n'
                'Please add a corrected photo of your licence below.',
          ),
          const SizedBox(height: 12),
        ],

        Text(
          'Upload your Driving Licence',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Photograph the front of your licence. Make sure the licence number, '
          'name and dates are readable.',
          style: GoogleFonts.poppins(fontSize: 12, color: _textGrey),
        ),
        const SizedBox(height: 12),

        _documentTile(busy: busy),

        if (_fileError != null) ...[
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Iconsax.info_circle, size: 15, color: _danger),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _fileError!,
                  style: GoogleFonts.poppins(fontSize: 12, color: _danger),
                ),
              ),
            ],
          ),
        ],

        if (failed && _result != null) ...[
          const SizedBox(height: 12),
          _inlineBanner(
            color: _phase == _Phase.temporarilyUnavailable ? _amber : _danger,
            icon: Iconsax.info_circle,
            // The message comes from the backend and is always user-safe.
            message: _result!.message,
          ),
        ],

        const SizedBox(height: 14),

        SizedBox(
          width: double.infinity,
          // 48dp keeps the primary action a comfortable touch target.
          height: 48,
          child: ElevatedButton.icon(
            onPressed: busy || _document == null ? null : _verify,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              disabledBackgroundColor: const Color(0xFFE5E7EB),
              foregroundColor: Colors.white,
              disabledForegroundColor: _textGrey,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: busy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(failed ? Iconsax.refresh : Iconsax.shield_tick, size: 18),
            label: Text(
              busy
                  ? 'Verifying Driving Licence...'
                  : failed
                      ? 'Try Again'
                      : 'Verify Driving Licence',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        // Manual verification is offered only when the backend says the manual
        // path is open — never as a way around a working automatic check.
        if (!busy && failed && (_result?.canContinueManually ?? false)) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _manualCtrl.text = _result?.data?.licenseNumber ?? '';
                  _phase = _Phase.manualForm;
                });
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: _textDark,
                side: const BorderSide(color: _border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Continue Manually',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _documentTile({required bool busy}) {
    final document = _document;

    if (document == null) {
      return InkWell(
        onTap: busy ? null : _pickDocument,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 26),
          decoration: BoxDecoration(
            border: Border.all(color: _border, style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFFAFAFA),
          ),
          child: Column(
            children: [
              const Icon(Iconsax.document_upload, color: _primary, size: 26),
              const SizedBox(height: 8),
              Text(
                'Take a photo or choose a file',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'JPG, PNG or HEIC, up to 5 MB',
                style: GoogleFonts.poppins(fontSize: 11, color: _textGrey),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              document,
              width: 74,
              height: 52,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 74,
                height: 52,
                color: const Color(0xFFF3F4F6),
                child: const Icon(Iconsax.document, color: _textGrey, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  documentBasename(document.path),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: _textDark,
                  ),
                ),
                Text(
                  '${(document.lengthSync() / 1024).round()} KB',
                  style: GoogleFonts.poppins(fontSize: 11, color: _textGrey),
                ),
              ],
            ),
          ),
          if (!busy)
            TextButton(
              onPressed: _pickDocument,
              style: TextButton.styleFrom(
                foregroundColor: _primary,
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              child: Text(
                'Replace',
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _manualForm() {
    final busy = _phase == _Phase.submittingManual;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Manual verification',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _textDark,
                  ),
                ),
              ),
              if (!busy)
                IconButton(
                  onPressed: () => setState(() => _phase = _Phase.notVerified),
                  icon: const Icon(Iconsax.close_circle, size: 20),
                  color: _textGrey,
                  tooltip: 'Back',
                ),
            ],
          ),
          Text(
            'Enter your licence number. Our team will verify it against the '
            'document you uploaded, usually within one business day.',
            style: GoogleFonts.poppins(fontSize: 12, color: _textGrey),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _manualCtrl,
            enabled: !busy,
            textCapitalization: TextCapitalization.characters,
            autocorrect: false,
            // Surfaces the alphanumeric keyboard without hiding the field
            // behind the keyboard — the host screen scrolls.
            keyboardType: TextInputType.visiblePassword,
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: InputDecoration(
              labelText: 'Driving Licence number',
              hintText: 'MH1420110012345',
              labelStyle: GoogleFonts.poppins(fontSize: 13, color: _textGrey),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _primary),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed:
                  busy || _manualCtrl.text.trim().isEmpty ? null : _submitManually,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                disabledBackgroundColor: const Color(0xFFE5E7EB),
                foregroundColor: Colors.white,
                disabledForegroundColor: _textGrey,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Submit for Manual Verification',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Small presentational pieces ───────────────────────────────────────────

  Widget _statusPanel({
    required Color color,
    required IconData icon,
    required String title,
    Widget? child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _textDark,
                  ),
                ),
              ),
            ],
          ),
          if (child != null) ...[const SizedBox(height: 10), child],
        ],
      ),
    );
  }

  Widget _inlineBanner({
    required Color color,
    required IconData icon,
    String? title,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _textDark,
                    ),
                  ),
                Text(
                  message,
                  style: GoogleFonts.poppins(fontSize: 12.5, color: _textGrey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detail(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 118,
              child: Text(
                label,
                style: GoogleFonts.poppins(fontSize: 12, color: _textGrey),
              ),
            ),
            Expanded(
              child: Text(
                value,
                // Long provider values wrap rather than overflow, and are never
                // shrunk to unreadable text.
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _textDark,
                ),
              ),
            ),
          ],
        ),
      );
}
