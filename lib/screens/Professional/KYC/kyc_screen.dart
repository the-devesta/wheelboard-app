import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

import 'package:wheelboard/core/auth/auth_service.dart';
import '../../../models/kyc_model.dart';
import '../../../services/kyc_service.dart';
import '../../../services/media_service.dart';

// ── Design tokens ──────────────────────────────────────────────────────────────
const _primary = Color(0xFFF36969);
const _primaryLt = Color(0xFFFFF1F1);
const _bg = Color(0xFFF9FAFB);
const _card = Colors.white;
const _textDark = Color(0xFF111827);
const _textGrey = Color(0xFF6B7280);
const _border = Color(0xFFE5E7EB);
const _green = Color(0xFF22C55E);
const _amber = Color(0xFFF59E0B);
const _danger = Color(0xFFEF4444);
const _blue = Color(0xFF3B82F6);

/// Role-aware KYC verification screen — wired to the backend (mirrors web
/// `/professional/kyc-verification`). The backend resolves `professionalType`
/// from the caller's role, so this one screen serves Professional (driver),
/// Business (transport) and Service Provider alike.
class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  final _service = KycService();
  final _panCtrl = TextEditingController();
  final _dlCtrl = TextEditingController();

  Kyc? _kyc;
  RequiredDocuments? _required;
  KycCompleteness? _completeness;
  DateTime? _dob;
  bool _loading = true;
  String? _error;
  bool _verifying = false;
  String? _uploadingType; // document type currently being uploaded

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _panCtrl.dispose();
    _dlCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final kyc = await _service.getMyKyc();
      final results = await Future.wait([
        _service.getRequiredDocuments(kyc.professionalType),
        _service.checkCompleteness(),
      ]);
      if (!mounted) return;
      setState(() {
        _kyc = kyc;
        _required = results[0] as RequiredDocuments;
        _completeness = results[1] as KycCompleteness?;
        if ((_panCtrl.text.isEmpty) && (kyc.panNumber?.isNotEmpty ?? false)) {
          _panCtrl.text = kyc.panNumber!;
        }
        if ((_dlCtrl.text.isEmpty) && (kyc.dlNumber?.isNotEmpty ?? false)) {
          _dlCtrl.text = kyc.dlNumber!;
        }
        if (_dob == null && (kyc.dateOfBirth?.isNotEmpty ?? false)) {
          _dob = DateTime.tryParse(kyc.dateOfBirth!);
        }
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

  void _toast(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  Future<void> _verifyPan() async {
    final pan = _panCtrl.text.trim().toUpperCase();
    if (pan.length != 10) {
      _toast('Enter a valid 10-character PAN number', _amber);
      return;
    }
    setState(() => _verifying = true);
    try {
      await _service.verifyPan(pan);
      _toast('PAN submitted for verification', _green);
      await _fetch();
    } catch (e) {
      _toast(e.toString().replaceFirst('Exception: ', ''), _danger);
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _verifyDl() async {
    final dl = _dlCtrl.text.trim().toUpperCase();
    if (dl.isEmpty || _dob == null) {
      _toast('Enter your DL number and date of birth', _amber);
      return;
    }
    setState(() => _verifying = true);
    try {
      final result = await _service.verifyDl(dl, _fmtApiDate(_dob!));
      _toast(
        result.verified ? 'Driving License verified!' : 'DL submitted',
        result.verified ? _green : _amber,
      );
      await _fetch();
    } catch (e) {
      _toast(e.toString().replaceFirst('Exception: ', ''), _danger);
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  // ── Document image upload (PAN card / DL / profile photo / others) ──────────
  // Mirrors web `/professional/kyc/upload`: pick an image → base64 data URL →
  // POST /kyc/upload/document. `documentNumber` is required by the backend, so
  // we generate the same `<PREFIX>-<userId8>-<ts>` reference the web uses.
  Future<void> _uploadDoc(String type) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Iconsax.camera, color: _primary),
            title: Text('Take photo', style: GoogleFonts.poppins(fontSize: 14)),
            onTap: () => Navigator.pop(ctx, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Iconsax.gallery, color: _primary),
            title: Text('Choose from gallery',
                style: GoogleFonts.poppins(fontSize: 14)),
            onTap: () => Navigator.pop(ctx, ImageSource.gallery),
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
    if (source == null) return;

    final XFile? file = await ImagePicker()
        .pickImage(source: source, imageQuality: 70, maxWidth: 1600);
    if (file == null) return;

    setState(() => _uploadingType = type);
    try {
      // Upload via the unified /media endpoint and send the hosted URL (the
      // backend stores the URL as-is — no base64 round-trip).
      final media =
          await MediaService.upload(File(file.path), folder: 'kyc-documents');
      final fileUrl = media?.url ?? '';
      if (fileUrl.isEmpty) {
        throw Exception('Upload failed. Please try again.');
      }
      final uid = AuthService.to.currentUserId;
      final shortId = uid.length > 8 ? uid.substring(0, 8) : uid;
      final ref =
          '${_docPrefix(type)}-$shortId-${DateTime.now().millisecondsSinceEpoch}';
      await _service.uploadDocument(
        documentType: type,
        documentNumber: ref,
        documentName: KycDocType.label(type),
        fileUrl: fileUrl,
        autoVerify: false,
      );
      _toast('${KycDocType.label(type)} uploaded', _green);
      await _fetch();
    } catch (e) {
      _toast(e.toString().replaceFirst('Exception: ', ''), _danger);
    } finally {
      if (mounted) setState(() => _uploadingType = null);
    }
  }

  String _docPrefix(String type) {
    switch (type) {
      case KycDocType.pan:
        return 'PAN';
      case KycDocType.drivingLicense:
        return 'DL';
      case KycDocType.profilePhoto:
        return 'PHOTO';
      case KycDocType.aadhar:
        return 'AADHAR';
      default:
        return 'DOC';
    }
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 25),
      firstDate: DateTime(1940),
      lastDate: now,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: _primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  // ── progress ──
  int get _progress {
    final k = _kyc;
    final req = _required;
    if (k == null) return 0;
    if (req != null && req.mandatory.isNotEmpty) {
      final verified = req.mandatory
          .where((t) => k.statusForType(t) == KycStatus.verified)
          .length;
      return ((verified / req.mandatory.length) * 100).round();
    }
    return k.isVerified ? 100 : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        bottom: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: _primary))
            : _error != null
                ? _errorState()
                : _content(),
      ),
    );
  }

  Widget _errorState() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Iconsax.warning_2, size: 44, color: _primary),
            const SizedBox(height: 12),
            Text(_error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 14, color: _textGrey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetch,
              style: ElevatedButton.styleFrom(
                  backgroundColor: _primary, foregroundColor: Colors.white, elevation: 0),
              child: Text('Try again',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            ),
          ]),
        ),
      );

  Widget _content() {
    final k = _kyc!;
    return Column(children: [
      _header(k),
      Expanded(
        child: RefreshIndicator(
          color: _primary,
          onRefresh: _fetch,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
            children: [
              _progressCard(),
              const SizedBox(height: 14),
              _infoBanner(),
              const SizedBox(height: 14),
              _panCard(k),
              const SizedBox(height: 14),
              _dlCard(k),
              const SizedBox(height: 14),
              _requiredDocsCard(k),
              const SizedBox(height: 14),
              _overallStatusCard(k),
            ],
          ),
        ),
      ),
    ]);
  }

  Widget _header(Kyc k) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 14),
      color: _card,
      child: Row(children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: _textDark),
          onPressed: () => Get.back(),
        ),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('KYC Verification',
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.w700, color: _textDark)),
            Text('Verify your identity to activate your account',
                style: GoogleFonts.poppins(fontSize: 12, color: _textGrey)),
          ]),
        ),
        if (k.isVerified)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
                color: _green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Iconsax.tick_circle, size: 14, color: _green),
              const SizedBox(width: 4),
              Text('Verified',
                  style: GoogleFonts.poppins(
                      fontSize: 12, fontWeight: FontWeight.w700, color: _green)),
            ]),
          ),
      ]),
    );
  }

  Widget _progressCard() {
    final p = _progress;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Verification Progress',
              style: GoogleFonts.poppins(
                  fontSize: 13, fontWeight: FontWeight.w600, color: _textDark)),
          Text('$p%',
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w800, color: _primary)),
        ]),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: p / 100,
            minHeight: 8,
            backgroundColor: _border,
            valueColor: const AlwaysStoppedAnimation(_primary),
          ),
        ),
        if (p == 100) ...[
          const SizedBox(height: 10),
          Text('✓ Your account is verified — all features unlocked.',
              style: GoogleFonts.poppins(fontSize: 12, color: _green)),
        ] else if (_completeness?.missing.isNotEmpty ?? false) ...[
          const SizedBox(height: 10),
          Text(
            'Pending: ${_completeness!.missing.map(KycDocType.label).join(', ')}',
            style: GoogleFonts.poppins(fontSize: 12, color: _textGrey),
          ),
        ],
      ]),
    );
  }

  Widget _infoBanner() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _blue.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _blue.withValues(alpha: 0.2)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Iconsax.info_circle, size: 18, color: _blue),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Automated Verification',
                  style: GoogleFonts.poppins(
                      fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF1E3A8A))),
              const SizedBox(height: 2),
              Text(
                'Documents are verified against government databases. Once all mandatory documents are verified, your account activates automatically.',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: const Color(0xFF1E40AF), height: 1.4),
              ),
            ]),
          ),
        ]),
      );

  // ── PAN ──
  Widget _panCard(Kyc k) {
    final status = k.panStatus;
    final verified = status == KycStatus.verified;
    final mandatory = _required?.mandatory.contains(KycDocType.pan) ?? false;
    return _verifyCard(
      icon: Iconsax.card,
      title: 'PAN Card Verification',
      mandatory: mandatory,
      status: status,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _field(
          controller: _panCtrl,
          label: 'PAN Number',
          hint: 'ABCDE1234F',
          enabled: !verified,
          maxLength: 10,
          upper: true,
        ),
        if (k.panName?.isNotEmpty ?? false) ...[
          const SizedBox(height: 6),
          Text('Name: ${k.panName}',
              style: GoogleFonts.poppins(fontSize: 12, color: _textGrey)),
        ],
        if (!verified) ...[
          const SizedBox(height: 12),
          _verifyButton('Verify PAN Card', _verifyPan),
        ],
      ]),
    );
  }

  // ── DL ──
  Widget _dlCard(Kyc k) {
    final status = k.dlStatus;
    final verified = status == KycStatus.verified;
    final mandatory =
        _required?.mandatory.contains(KycDocType.drivingLicense) ?? false;
    return _verifyCard(
      icon: Iconsax.document_text,
      title: 'Driving License Verification',
      mandatory: mandatory,
      status: status,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _field(
          controller: _dlCtrl,
          label: 'DL Number',
          hint: 'MH1420110012345',
          enabled: !verified,
          upper: true,
        ),
        const SizedBox(height: 12),
        Text('Date of Birth',
            style: GoogleFonts.poppins(fontSize: 12, color: _textGrey)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: verified ? null : _pickDob,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _border),
            ),
            child: Row(children: [
              const Icon(Iconsax.calendar_1, size: 16, color: _textGrey),
              const SizedBox(width: 10),
              Text(_dob != null ? _fmtDisplayDate(_dob!) : 'Select date of birth',
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: _dob != null ? _textDark : _textGrey)),
            ]),
          ),
        ),
        if (k.dlName?.isNotEmpty ?? false) ...[
          const SizedBox(height: 6),
          Text('Name: ${k.dlName}${k.dlValidUpto != null ? ' · Valid till ${k.dlValidUpto}' : ''}',
              style: GoogleFonts.poppins(fontSize: 12, color: _textGrey)),
        ],
        if (!verified) ...[
          const SizedBox(height: 12),
          _verifyButton('Verify Driving License', _verifyDl),
        ],
      ]),
    );
  }

  Widget _verifyCard({
    required IconData icon,
    required String title,
    required bool mandatory,
    required String? status,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: _primaryLt, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: _primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: GoogleFonts.poppins(
                      fontSize: 14, fontWeight: FontWeight.w700, color: _textDark)),
              Text(mandatory ? 'Required' : 'Optional',
                  style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: mandatory ? _primary : _textGrey)),
            ]),
          ),
          if (status != null) _statusBadge(status),
        ]),
        const SizedBox(height: 14),
        child,
      ]),
    );
  }

  // ── Required documents checklist ──
  Widget _requiredDocsCard(Kyc k) {
    final req = _required;
    if (req == null || (req.mandatory.isEmpty && req.optional.isEmpty)) {
      return const SizedBox.shrink();
    }
    final rows = <Widget>[];
    for (final t in req.mandatory) {
      rows.add(_docRow(t, k.statusForType(t), mandatory: true));
    }
    for (final t in req.optional) {
      rows.add(_docRow(t, k.statusForType(t), mandatory: false));
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Required Documents',
            style: GoogleFonts.poppins(
                fontSize: 14, fontWeight: FontWeight.w700, color: _textDark)),
        const SizedBox(height: 4),
        Text('Based on your account type · tap upload to attach a photo',
            style: GoogleFonts.poppins(fontSize: 11, color: _textGrey)),
        const SizedBox(height: 12),
        ...rows,
      ]),
    );
  }

  Widget _docRow(String type, String? status, {required bool mandatory}) {
    final verified = status == KycStatus.verified;
    final uploading = _uploadingType == type;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Icon(
          status == KycStatus.verified
              ? Iconsax.tick_circle5
              : (status == KycStatus.rejected
                  ? Iconsax.close_circle5
                  : Iconsax.document),
          size: 18,
          color: status == KycStatus.verified
              ? _green
              : (status == KycStatus.rejected ? _danger : _textGrey),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(KycDocType.label(type),
              style: GoogleFonts.poppins(
                  fontSize: 13, fontWeight: FontWeight.w500, color: _textDark)),
        ),
        if (mandatory && status != KycStatus.verified)
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Text('Required',
                style: GoogleFonts.poppins(
                    fontSize: 10, fontWeight: FontWeight.w600, color: _primary)),
          ),
        _statusBadge(status ?? 'not_submitted'),
        const SizedBox(width: 4),
        uploading
            ? const SizedBox(
                width: 18,
                height: 18,
                child:
                    CircularProgressIndicator(strokeWidth: 2, color: _primary))
            : IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                tooltip: verified ? 'Replace document' : 'Upload document',
                icon: Icon(
                  verified ? Iconsax.gallery_tick : Iconsax.gallery_add,
                  size: 20,
                  color: verified ? _green : _primary,
                ),
                onPressed: () => _uploadDoc(type),
              ),
      ]),
    );
  }

  Widget _overallStatusCard(Kyc k) {
    final s = k.overallStatus;
    Color c;
    String msg;
    switch (s) {
      case KycStatus.verified:
        c = _green;
        msg = 'Your KYC is complete and your account is active.';
        break;
      case KycStatus.pending:
        c = _amber;
        msg = 'Some documents are pending verification. You will be notified once verified.';
        break;
      case KycStatus.rejected:
        c = _danger;
        msg = 'Some documents were rejected. Please re-submit or contact support.';
        break;
      default:
        c = _textGrey;
        msg = 'Complete all required verifications to activate your account.';
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.withValues(alpha: 0.25)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(
            s == KycStatus.verified
                ? Iconsax.tick_circle
                : (s == KycStatus.rejected
                    ? Iconsax.close_circle
                    : Iconsax.clock),
            size: 20,
            color: c),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Overall Status: ${s.toUpperCase()}',
                style: GoogleFonts.poppins(
                    fontSize: 13, fontWeight: FontWeight.w700, color: _textDark)),
            const SizedBox(height: 2),
            Text(msg,
                style: GoogleFonts.poppins(
                    fontSize: 12, color: _textGrey, height: 1.4)),
          ]),
        ),
      ]),
    );
  }

  // ── shared widgets ──
  Widget _statusBadge(String status) {
    Color c;
    String label;
    switch (status) {
      case KycStatus.verified:
        c = _green;
        label = 'Verified';
        break;
      case KycStatus.pending:
        c = _amber;
        label = 'Pending';
        break;
      case KycStatus.rejected:
        c = _danger;
        label = 'Rejected';
        break;
      default:
        c = _textGrey;
        label = 'Not submitted';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withValues(alpha: 0.3)),
      ),
      child: Text(label,
          style: GoogleFonts.poppins(
              fontSize: 10, fontWeight: FontWeight.w600, color: c)),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool enabled = true,
    int? maxLength,
    bool upper = false,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.poppins(fontSize: 12, color: _textGrey)),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        enabled: enabled,
        maxLength: maxLength,
        textCapitalization:
            upper ? TextCapitalization.characters : TextCapitalization.none,
        inputFormatters: upper
            ? [_UpperCaseFormatter(), if (maxLength != null) LengthLimitingTextInputFormatter(maxLength)]
            : null,
        style: GoogleFonts.poppins(
            fontSize: 14, fontWeight: FontWeight.w600, color: _textDark),
        decoration: InputDecoration(
          counterText: '',
          hintText: hint,
          hintStyle: GoogleFonts.poppins(fontSize: 14, color: _border),
          filled: true,
          fillColor: enabled ? _bg : const Color(0xFFF1F1F1),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _border),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _primary, width: 1.4),
          ),
        ),
      ),
    ]);
  }

  Widget _verifyButton(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _verifying ? null : onTap,
        icon: _verifying
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Iconsax.shield_tick, size: 18),
        label: Text(label,
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _primary.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
      ),
    );
  }

  String _fmtApiDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _fmtDisplayDate(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day.toString().padLeft(2, '0')} ${m[d.month - 1]} ${d.year}';
  }
}

/// Forces input to uppercase (for PAN / DL numbers).
class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
