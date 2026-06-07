import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../models/lr_model.dart';
import '../../../services/lr_service.dart';

// ── Design tokens (match Trips / Fleet / Share sheet) ──────────────────────────
const _primary = Color(0xFFF36969);
const _bg = Color(0xFFF9FAFB);
const _textDark = Color(0xFF111827);
const _textGrey = Color(0xFF6B7280);
const _border = Color(0xFFE5E7EB);
const _green = Color(0xFF22C55E);
const _orange = Color(0xFFF59E0B);
const _blue = Color(0xFF3B82F6);
const _danger = Color(0xFFEF4444);

/// Driver-facing Lorry Receipt review & confirmation sheet.
///
/// Mirrors the web `LRConfirmationModal` but corrected against the backend:
/// only the two *working* verification methods are offered — Simple (checkbox)
/// and OTP. (Backend photo verification is an unimplemented stub.)
///
/// Returns `true` from [show] when the LR was confirmed or rejected (i.e. the
/// trip status changed and the caller should refresh).
class LrConfirmationSheet extends StatefulWidget {
  final String tripId;
  const LrConfirmationSheet({super.key, required this.tripId});

  static Future<bool?> show(BuildContext context, {required String tripId}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LrConfirmationSheet(tripId: tripId),
    );
  }

  @override
  State<LrConfirmationSheet> createState() => _LrConfirmationSheetState();
}

class _LrConfirmationSheetState extends State<LrConfirmationSheet> {
  final _service = LrService();
  final _money = NumberFormat.decimalPattern('en_IN');

  LrDetails? _lr;
  bool _loading = true;
  String? _error;

  String _method = 'checkbox'; // checkbox | otp
  bool _checkboxConfirmed = false;
  bool _otpRequested = false;
  String? _devOtp;
  final _otpCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final lr = await _service.getLR(widget.tripId);
      if (mounted) {
        setState(() {
          _lr = lr;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  void _toast(String msg, {Color color = _green}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _confirmCheckbox() async {
    if (!_checkboxConfirmed || _submitting) return;
    setState(() => _submitting = true);
    try {
      await _service.confirmCheckbox(widget.tripId);
      _toast('LR confirmed successfully');
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      _toast(e.toString().replaceFirst('Exception: ', ''), color: _danger);
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _requestOtp() async {
    setState(() => _submitting = true);
    try {
      final otp = await _service.requestOtp(widget.tripId);
      if (mounted) {
        setState(() {
          _otpRequested = true;
          _devOtp = otp;
          _submitting = false;
        });
        _toast('OTP sent to your registered mobile number');
      }
    } catch (e) {
      _toast(e.toString().replaceFirst('Exception: ', ''), color: _danger);
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpCtrl.text.trim();
    if (otp.length != 6) {
      _toast('Please enter the 6-digit OTP', color: _orange);
      return;
    }
    setState(() => _submitting = true);
    try {
      await _service.verifyOtp(widget.tripId, otp);
      _toast('LR confirmed with OTP verification');
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      _toast(e.toString().replaceFirst('Exception: ', ''), color: _danger);
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _reject() async {
    final reason = await _showRejectDialog();
    if (reason == null || reason.trim().isEmpty) return;
    setState(() => _submitting = true);
    try {
      await _service.reject(widget.tripId, reason.trim());
      _toast('LR rejected — the fleet owner will be notified', color: _orange);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      _toast(e.toString().replaceFirst('Exception: ', ''), color: _danger);
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<String?> _showRejectDialog() {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Reject LR',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: _textDark)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tell the fleet owner what needs to be corrected.',
                style: GoogleFonts.poppins(fontSize: 13, color: _textGrey)),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              maxLines: 3,
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'e.g. Cargo weight is incorrect',
                hintStyle: GoogleFonts.poppins(fontSize: 13, color: _textGrey),
                filled: true,
                fillColor: _bg,
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
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: _textGrey, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: _danger,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Reject', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: _border, borderRadius: BorderRadius.circular(10)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 12, 8),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: _primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Iconsax.document_text, size: 18, color: _primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Confirm Lorry Receipt',
                    style: GoogleFonts.poppins(
                        fontSize: 17, fontWeight: FontWeight.w700, color: _textDark)),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: _textGrey),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ]),
          ),
          const Divider(height: 1, color: _border),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _loading
                  ? _loadingState()
                  : _error != null
                      ? _errorState()
                      : _content(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingState() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator(color: _primary)),
      );

  Widget _errorState() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_error!,
              style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFFB91C1C))),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _load,
            child: Text('Try again',
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _primary,
                    decoration: TextDecoration.underline)),
          ),
        ]),
      );

  Widget _content() {
    final lr = _lr!;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _infoBanner(),
      const SizedBox(height: 16),
      _lrSummaryCard(lr),
      const SizedBox(height: 20),
      Text('VERIFICATION METHOD',
          style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: _textGrey,
              letterSpacing: 1)),
      const SizedBox(height: 10),
      _methodTile(
        value: 'checkbox',
        icon: Iconsax.tick_circle,
        color: _green,
        title: 'Simple Confirmation',
        subtitle: 'Confirm that all LR details are correct',
      ),
      const SizedBox(height: 10),
      _methodTile(
        value: 'otp',
        icon: Iconsax.lock,
        color: _blue,
        title: 'OTP Verification',
        subtitle: 'Verify using an OTP sent to your mobile',
      ),
      const SizedBox(height: 16),
      if (_method == 'checkbox') _checkboxSection() else _otpSection(),
      const SizedBox(height: 20),
      _actionButtons(),
      const SizedBox(height: 12),
    ]);
  }

  Widget _infoBanner() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _blue.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _blue.withValues(alpha: 0.2)),
        ),
        child: Row(children: [
          const Icon(Iconsax.info_circle, size: 18, color: _blue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Review the Lorry Receipt details below, then confirm to accept the trip — or reject it if something is wrong.',
              style: GoogleFonts.poppins(
                  fontSize: 12, color: const Color(0xFF1E3A8A), height: 1.4),
            ),
          ),
        ]),
      );

  Widget _lrSummaryCard(LrDetails lr) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Iconsax.receipt_text, size: 16, color: _primary),
          const SizedBox(width: 8),
          Text(lr.lrNumber.isNotEmpty ? lr.lrNumber : 'Lorry Receipt',
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w700, color: _textDark)),
        ]),
        if (lr.consignor != null) ...[
          const SizedBox(height: 14),
          _partyRow('Consignor', lr.consignor!),
        ],
        if (lr.consignee != null) ...[
          const SizedBox(height: 12),
          _partyRow('Consignee', lr.consignee!),
        ],
        if (lr.cargo != null) ...[
          const SizedBox(height: 12),
          const Divider(height: 1, color: _border),
          const SizedBox(height: 12),
          _kv('Goods', lr.cargo!.description),
          _kv('Weight', '${_money.format(lr.cargo!.totalWeight)} kg'),
          if (lr.cargo!.totalQuantity != null)
            _kv('Quantity', _money.format(lr.cargo!.totalQuantity!)),
        ],
        if (lr.charges != null) ...[
          const SizedBox(height: 12),
          const Divider(height: 1, color: _border),
          const SizedBox(height: 12),
          _kv('Freight', '₹${_money.format(lr.charges!.freightAmount)}'),
          _kv('GST', '₹${_money.format(lr.charges!.gst)}'),
          if (lr.charges!.otherCharges != null && lr.charges!.otherCharges! > 0)
            _kv('Other charges', '₹${_money.format(lr.charges!.otherCharges!)}'),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Total',
                style: GoogleFonts.poppins(
                    fontSize: 13, fontWeight: FontWeight.w700, color: _textDark)),
            Text('₹${_money.format(lr.charges!.totalAmount)}',
                style: GoogleFonts.poppins(
                    fontSize: 15, fontWeight: FontWeight.w800, color: _primary)),
          ]),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(_paymentModeLabel(lr.charges!.paymentMode),
                style: GoogleFonts.poppins(fontSize: 11, color: _textGrey)),
          ),
        ],
      ]),
    );
  }

  Widget _partyRow(String role, LrParty p) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(role.toUpperCase(),
          style: GoogleFonts.poppins(
              fontSize: 10, fontWeight: FontWeight.w700, color: _textGrey, letterSpacing: 0.5)),
      const SizedBox(height: 2),
      Text(p.name,
          style: GoogleFonts.poppins(
              fontSize: 13, fontWeight: FontWeight.w600, color: _textDark)),
      if (p.address.isNotEmpty)
        Text(p.address,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(fontSize: 12, color: _textGrey)),
    ]);
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            width: 110,
            child: Text(k, style: GoogleFonts.poppins(fontSize: 12, color: _textGrey)),
          ),
          Expanded(
            child: Text(v,
                style: GoogleFonts.poppins(
                    fontSize: 12, fontWeight: FontWeight.w600, color: _textDark)),
          ),
        ]),
      );

  Widget _methodTile({
    required String value,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    final selected = _method == value;
    return GestureDetector(
      onTap: _submitting
          ? null
          : () => setState(() {
                _method = value;
                _otpRequested = false;
                _devOtp = null;
                _otpCtrl.clear();
                _checkboxConfirmed = false;
              }),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected ? color : _border, width: selected ? 1.5 : 1),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: GoogleFonts.poppins(
                      fontSize: 13, fontWeight: FontWeight.w600, color: _textDark)),
              Text(subtitle,
                  style: GoogleFonts.poppins(fontSize: 11, color: _textGrey)),
            ]),
          ),
          Icon(selected ? Iconsax.tick_circle5 : Iconsax.record,
              size: 20, color: selected ? color : _border),
        ]),
      ),
    );
  }

  Widget _checkboxSection() {
    return GestureDetector(
      onTap: _submitting
          ? null
          : () => setState(() => _checkboxConfirmed = !_checkboxConfirmed),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
        ),
        child: Row(children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: _checkboxConfirmed ? _green : Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                  color: _checkboxConfirmed ? _green : _textGrey, width: 1.5),
            ),
            child: _checkboxConfirmed
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text('I confirm all Lorry Receipt details are correct.',
                style: GoogleFonts.poppins(
                    fontSize: 13, fontWeight: FontWeight.w500, color: _textDark)),
          ),
        ]),
      ),
    );
  }

  Widget _otpSection() {
    if (!_otpRequested) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _submitting ? null : _requestOtp,
          icon: const Icon(Iconsax.sms, size: 18),
          label: Text('Request OTP',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
          style: OutlinedButton.styleFrom(
            foregroundColor: _blue,
            side: const BorderSide(color: _blue),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      TextField(
        controller: _otpCtrl,
        keyboardType: TextInputType.number,
        maxLength: 6,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        // Re-evaluate the Confirm button as the OTP is typed.
        onChanged: (_) => setState(() {}),
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
            fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 8, color: _textDark),
        decoration: InputDecoration(
          counterText: '',
          hintText: '••••••',
          hintStyle: GoogleFonts.poppins(
              fontSize: 22, letterSpacing: 8, color: _border),
          filled: true,
          fillColor: _bg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _blue),
          ),
        ),
      ),
      const SizedBox(height: 6),
      Row(children: [
        if (_devOtp != null && _devOtp!.isNotEmpty)
          Expanded(
            child: Text('Demo OTP: $_devOtp',
                style: GoogleFonts.poppins(fontSize: 11, color: _orange, fontWeight: FontWeight.w600)),
          )
        else
          Expanded(
            child: Text('OTP sent to your registered mobile number',
                style: GoogleFonts.poppins(fontSize: 11, color: _textGrey)),
          ),
        GestureDetector(
          onTap: _submitting ? null : _requestOtp,
          child: Text('Resend',
              style: GoogleFonts.poppins(
                  fontSize: 12, fontWeight: FontWeight.w700, color: _blue)),
        ),
      ]),
    ]);
  }

  Widget _actionButtons() {
    final canConfirm = _method == 'checkbox'
        ? _checkboxConfirmed
        : (_otpRequested && _otpCtrl.text.trim().length == 6);
    final onConfirm = _method == 'checkbox' ? _confirmCheckbox : _verifyOtp;

    return Column(children: [
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: (_submitting || !canConfirm) ? null : onConfirm,
          icon: _submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Iconsax.tick_circle, size: 18),
          label: Text('Confirm LR',
              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700)),
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: _primary.withValues(alpha: 0.4),
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
        ),
      ),
      const SizedBox(height: 10),
      SizedBox(
        width: double.infinity,
        child: TextButton.icon(
          onPressed: _submitting ? null : _reject,
          icon: const Icon(Iconsax.close_circle, size: 18, color: _danger),
          label: Text('Reject LR',
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w700, color: _danger)),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    ]);
  }

  String _paymentModeLabel(String mode) {
    switch (mode) {
      case 'paid':
        return 'Payment: Paid';
      case 'to-be-billed':
        return 'Payment: To be billed';
      case 'to-pay':
      default:
        return 'Payment: To pay';
    }
  }
}
