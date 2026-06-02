import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../services/share_navigation_service.dart';

// ── Design tokens (match Home & Fleet) ────────────────────────────────────────
const _primary  = Color(0xFFF36969);
const _bg       = Color(0xFFF9FAFB);
const _textDark = Color(0xFF111827);
const _textGrey = Color(0xFF6B7280);
const _border   = Color(0xFFE5E7EB);
const _green    = Color(0xFF22C55E);
const _orange   = Color(0xFFF59E0B);
const _blue     = Color(0xFF3B82F6);

/// Bottom sheet that mirrors the web `ShareNavigationModal`:
/// generates a share link (OTP + navigation URL) and lets the company share it
/// via WhatsApp or the native share sheet.
class ShareNavigationSheet extends StatefulWidget {
  final String tripId;
  final String from;
  final String to;
  final String? vehicleNumber;

  const ShareNavigationSheet({
    super.key,
    required this.tripId,
    required this.from,
    required this.to,
    this.vehicleNumber,
  });

  /// Convenience opener.
  static Future<void> show(
    BuildContext context, {
    required String tripId,
    required String from,
    required String to,
    String? vehicleNumber,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ShareNavigationSheet(
        tripId: tripId, from: from, to: to, vehicleNumber: vehicleNumber),
    );
  }

  @override
  State<ShareNavigationSheet> createState() => _ShareNavigationSheetState();
}

class _ShareNavigationSheetState extends State<ShareNavigationSheet> {
  final _service = ShareNavigationService();
  ShareLink? _data;
  bool _loading = true;
  String? _error;
  bool _copiedOtp = false;
  bool _copiedLink = false;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  Future<void> _generate() async {
    setState(() { _loading = true; _error = null; });
    try {
      final link = await _service.generateShareLink(widget.tripId);
      if (mounted) setState(() { _data = link; _loading = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          String errStr = e.toString().replaceFirst('Exception: ', '');
          if (errStr.toLowerCase().contains('internal server error') || errStr.contains('500')) {
             _error = 'Unable to generate link. This usually happens if the trip is not yet assigned or the ID is invalid.';
          } else {
             _error = errStr;
          }
        });
      }
    }
  }

  String get _shareText {
    final d = _data;
    if (d == null) return '';
    return '🚚 Trip Navigation\n\n'
        'From: ${widget.from.isNotEmpty ? widget.from : 'Pickup'}\n'
        'To: ${widget.to.isNotEmpty ? widget.to : 'Drop'}\n\n'
        '🔐 OTP: ${d.otp}\n\n'
        '📍 Navigation Link:\n${d.shareUrl}';
  }

  Future<void> _copy(String value, {required bool isOtp}) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    setState(() {
      if (isOtp) {
        _copiedOtp = true;
      } else {
        _copiedLink = true;
      }
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() { _copiedOtp = false; _copiedLink = false; });
    });
  }

  Future<void> _shareNative() async {
    if (_data == null) return;
    await Share.share(_shareText, subject: 'Trip Navigation');
  }

  Future<void> _shareWhatsApp() async {
    if (_data == null) return;
    final msg = Uri.encodeComponent(
      '🚚 *Trip Navigation*\n\n'
      'From: ${widget.from.isNotEmpty ? widget.from : 'Pickup'}\n'
      'To: ${widget.to.isNotEmpty ? widget.to : 'Drop'}\n\n'
      '🔐 *OTP:* ${_data!.otp}\n\n'
      '📍 *Navigation Link:*\n${_data!.shareUrl}',
    );
    final uri = Uri.parse('https://wa.me/?text=$msg');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      await _shareNative();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // grabber + header
          const SizedBox(height: 10),
          Container(width: 40, height: 4,
            decoration: BoxDecoration(
              color: _border, borderRadius: BorderRadius.circular(10))),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 12, 8),
            child: Row(children: [
              Expanded(child: Text('Share Navigation',
                style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.w700, color: _textDark))),
              IconButton(
                icon: const Icon(Icons.close, color: _textGrey),
                onPressed: () => Navigator.of(context).pop()),
            ]),
          ),
          const Divider(height: 1, color: _border),

          Flexible(child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _routeCard(),
              const SizedBox(height: 20),
              if (_loading) _loadingState()
              else if (_error != null) _errorState()
              else if (_data != null) _dataState(),
            ]),
          )),
        ],
      ),
    );
  }

  // ── route card ──
  Widget _routeCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _bg, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('ROUTE', style: GoogleFonts.poppins(
          fontSize: 10, fontWeight: FontWeight.w600,
          color: _textGrey, letterSpacing: 1)),
        const SizedBox(height: 10),
        Row(children: [
          Container(width: 9, height: 9, decoration: const BoxDecoration(
            color: _green, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(child: Text(widget.from.isNotEmpty ? widget.from : 'Pickup',
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 13, fontWeight: FontWeight.w600, color: _textDark))),
        ]),
        Padding(padding: const EdgeInsets.only(left: 4),
          child: Container(width: 1, height: 16, color: _border)),
        Row(children: [
          Container(width: 9, height: 9, decoration: const BoxDecoration(
            color: _primary, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(child: Text(widget.to.isNotEmpty ? widget.to : 'Drop',
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 13, fontWeight: FontWeight.w600, color: _textDark))),
        ]),
        if (widget.vehicleNumber?.isNotEmpty ?? false) ...[
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Iconsax.truck, size: 14, color: _textGrey),
            const SizedBox(width: 6),
            Text('Vehicle: ${widget.vehicleNumber}', style: GoogleFonts.poppins(
              fontSize: 12, color: _textGrey)),
          ]),
        ],
      ]),
    );
  }

  // ── loading / error ──
  Widget _loadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(children: [
        const CircularProgressIndicator(color: _primary),
        const SizedBox(height: 16),
        Text('Generating share link…',
          style: GoogleFonts.poppins(fontSize: 13, color: _textGrey)),
      ]),
    );
  }

  Widget _errorState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_error!, style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFFB91C1C))),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _generate,
          child: Text('Try again', style: GoogleFonts.poppins(
            fontSize: 13, fontWeight: FontWeight.w600,
            color: _primary, decoration: TextDecoration.underline))),
      ]),
    );
  }

  // ── data state ──
  Widget _dataState() {
    final d = _data!;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // OTP
      Row(children: [
        Container(padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _orange.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10)),
          child: const Icon(Iconsax.key, size: 18, color: _orange)),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Navigation OTP', style: GoogleFonts.poppins(
            fontSize: 13, fontWeight: FontWeight.w600, color: _textDark)),
          Text('Share this code with the driver', style: GoogleFonts.poppins(
            fontSize: 11, color: _textGrey)),
        ]),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: _orange.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _orange.withValues(alpha: 0.3))),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            for (final ch in d.otp.split(''))
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 30, height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _orange.withValues(alpha: 0.25))),
                child: Text(ch, style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.w800, color: _orange))),
          ]),
        )),
        const SizedBox(width: 10),
        _copyButton(
          copied: _copiedOtp, color: _orange,
          onTap: () => _copy(d.otp, isOtp: true)),
      ]),
      const SizedBox(height: 20),

      // Link
      Row(children: [
        Container(padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _blue.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10)),
          child: const Icon(Iconsax.link, size: 18, color: _blue)),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Navigation Link', style: GoogleFonts.poppins(
            fontSize: 13, fontWeight: FontWeight.w600, color: _textDark)),
          Text('Direct link to live navigation', style: GoogleFonts.poppins(
            fontSize: 11, color: _textGrey)),
        ]),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: _blue.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _blue.withValues(alpha: 0.3))),
          child: Text(d.shareUrl, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 12, fontWeight: FontWeight.w500,
              color: const Color(0xFF1E3A8A))))),
        const SizedBox(width: 10),
        _copyButton(
          copied: _copiedLink, color: _blue,
          onTap: () => _copy(d.shareUrl, isOtp: false)),
      ]),
      if (d.expiresAt != null) ...[
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Iconsax.clock, size: 13, color: _textGrey),
          const SizedBox(width: 5),
          Text('Expires: ${_fmtDate(d.expiresAt!)}',
            style: GoogleFonts.poppins(fontSize: 11, color: _textGrey)),
        ]),
      ],
      const SizedBox(height: 24),

      // Share buttons
      Row(children: [
        Expanded(child: ElevatedButton.icon(
          onPressed: _shareWhatsApp,
          icon: const Icon(Icons.chat, size: 18),
          label: Text('WhatsApp', style: GoogleFonts.poppins(
            fontSize: 14, fontWeight: FontWeight.w700)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF25D366), foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0))),
        const SizedBox(width: 12),
        Expanded(child: ElevatedButton.icon(
          onPressed: _shareNative,
          icon: const Icon(Iconsax.share, size: 18),
          label: Text('Share', style: GoogleFonts.poppins(
            fontSize: 14, fontWeight: FontWeight.w700)),
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary, foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0))),
      ]),
      const SizedBox(height: 12),
    ]);
  }

  Widget _copyButton({
    required bool copied,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12)),
        child: Icon(copied ? Icons.check : Iconsax.copy,
          size: 18, color: copied ? _green : color)),
    );
  }

  String _fmtDate(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[d.month - 1]} ${d.day}, ${d.year}';
  }
}
