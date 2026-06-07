import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../models/assigned_trip_model.dart';
import '../../../models/lr_model.dart';
import '../../../services/lr_service.dart';
import '../../../theme/design_system.dart';

/// Driver-facing Lorry Receipt review & OTP confirmation.
///
/// Shows a complete trip context card + LR details + 6-cell OTP input before
/// the driver can confirm. All backend calls are identical to the previous
/// version — only the presentation is improved.
///
/// Returns `true` when the LR was confirmed or rejected (caller should refresh).
class LrConfirmationSheet extends StatefulWidget {
  final String tripId;
  final AssignedTrip? trip;

  const LrConfirmationSheet({super.key, required this.tripId, this.trip});

  static Future<bool?> show(
    BuildContext context, {
    required String tripId,
    AssignedTrip? trip,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => LrConfirmationSheet(tripId: tripId, trip: trip),
    );
  }

  @override
  State<LrConfirmationSheet> createState() => _LrConfirmationSheetState();
}

class _LrConfirmationSheetState extends State<LrConfirmationSheet>
    with SingleTickerProviderStateMixin {
  final _service = LrService();
  final _money = NumberFormat.decimalPattern('en_IN');

  LrDetails? _lr;
  bool _loading = true;
  String? _error;

  // OTP is the primary method; checkbox is secondary.
  String _method = 'otp';
  bool _checkboxConfirmed = false;
  bool _otpRequested = false;
  String? _devOtp;

  // 6-cell OTP
  final List<TextEditingController> _otpCtrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFoci = List.generate(6, (_) => FocusNode());

  bool _submitting = false;
  bool _confirmed = false;

  late final AnimationController _successAnim;

  @override
  void initState() {
    super.initState();
    _successAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    for (final fn in _otpFoci) {
      fn.addListener(() => setState(() {}));
    }
    _load();
  }

  @override
  void dispose() {
    _successAnim.dispose();
    for (final c in _otpCtrls) {
      c.dispose();
    }
    for (final fn in _otpFoci) {
      fn.dispose();
    }
    super.dispose();
  }

  // ── data ──────────────────────────────────────────────────────────────────
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

  // ── helpers ───────────────────────────────────────────────────────────────
  String get _otpValue => _otpCtrls.map((c) => c.text).join();

  void _toast(String msg, {Color color = AppPalette.green}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: AppText.label.on(Colors.white)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  Future<void> _showSuccess(String msg) async {
    HapticFeedback.mediumImpact();
    _toast(msg, color: AppPalette.green);
    setState(() => _confirmed = true);
    _successAnim.forward();
    await Future.delayed(const Duration(milliseconds: 1400));
    if (mounted) Navigator.of(context).pop(true);
  }

  // ── actions ───────────────────────────────────────────────────────────────
  Future<void> _confirmCheckbox() async {
    if (!_checkboxConfirmed || _submitting) return;
    setState(() => _submitting = true);
    try {
      await _service.confirmCheckbox(widget.tripId);
      await _showSuccess('LR confirmed successfully');
    } catch (e) {
      _toast(e.toString().replaceFirst('Exception: ', ''),
          color: AppPalette.danger);
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
      _toast(e.toString().replaceFirst('Exception: ', ''),
          color: AppPalette.danger);
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpValue;
    if (otp.length != 6) {
      _toast('Please fill all 6 digits', color: AppPalette.amber);
      return;
    }
    setState(() => _submitting = true);
    try {
      await _service.verifyOtp(widget.tripId, otp);
      await _showSuccess('LR confirmed via OTP verification');
    } catch (e) {
      _toast(e.toString().replaceFirst('Exception: ', ''),
          color: AppPalette.danger);
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _reject() async {
    final reason = await _showRejectDialog();
    if (reason == null || reason.trim().isEmpty) return;
    setState(() => _submitting = true);
    try {
      await _service.reject(widget.tripId, reason.trim());
      _toast('LR rejected — fleet owner will be notified',
          color: AppPalette.amber);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      _toast(e.toString().replaceFirst('Exception: ', ''),
          color: AppPalette.danger);
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<String?> _showRejectDialog() {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Reject Lorry Receipt', style: AppText.h3),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Tell the fleet owner what needs to be corrected.',
              style: AppText.bodySm),
          const SizedBox(height: 14),
          TextField(
            controller: ctrl,
            maxLines: 3,
            style: AppText.body,
            decoration: InputDecoration(
              hintText: 'e.g. Cargo weight is incorrect',
              hintStyle: AppText.bodySm.on(AppPalette.textFaint),
              filled: true,
              fillColor: AppPalette.bg,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppPalette.border)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppPalette.border)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: AppPalette.primary, width: 1.5)),
            ),
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel',
                style: AppText.label
                    .on(AppPalette.textGrey)
                    .weight(FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPalette.danger,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Reject', style: AppText.label.on(Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
      decoration: const BoxDecoration(
        color: AppPalette.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: _confirmed ? _successOverlay() : _sheetContent(),
    );
  }

  Widget _sheetContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        // Drag handle
        Container(
          width: 44,
          height: 4,
          decoration: BoxDecoration(
              color: AppPalette.border, borderRadius: BorderRadius.circular(10)),
        ),
        // Header row
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 12, 10),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                  color: AppPalette.primaryLight,
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(Iconsax.document_text,
                  size: 18, color: AppPalette.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Lorry Receipt Confirmation', style: AppText.h3),
                Text('Review details before starting your trip',
                    style: AppText.caption),
              ]),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: AppPalette.textGrey, size: 22),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ]),
        ),
        const Divider(height: 1, color: AppPalette.border),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Column(children: [
              // Trip context card — shows immediately even before LR loads.
              if (widget.trip != null) ...[
                _tripContextCard(widget.trip!),
                const SizedBox(height: 18),
              ],
              // LR details section (async load)
              if (_loading)
                _lrLoadingState()
              else if (_error != null)
                _errorState()
              else if (_lr != null)
                _lrSummaryCard(_lr!),
              const SizedBox(height: 22),
              // Verification section
              _sectionLabel('VERIFICATION METHOD'),
              const SizedBox(height: 10),
              _methodTile(
                value: 'otp',
                icon: Iconsax.lock,
                color: AppPalette.primary,
                title: 'OTP Verification',
                subtitle: 'Enter the 6-digit OTP sent to your mobile',
                recommended: true,
              ),
              const SizedBox(height: 8),
              _methodTile(
                value: 'checkbox',
                icon: Iconsax.tick_circle,
                color: AppPalette.green,
                title: 'Simple Confirmation',
                subtitle: 'Confirm that all LR details are correct',
              ),
              const SizedBox(height: 18),
              // Active method input
              if (_method == 'otp') _otpSection() else _checkboxSection(),
              const SizedBox(height: 22),
              // Action buttons
              _actionButtons(),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ],
    );
  }

  // ── trip context card ─────────────────────────────────────────────────────
  Widget _tripContextCard(AssignedTrip trip) {
    final fmt = DateFormat('d MMM yyyy');
    final payStr = trip.payRange.isNotEmpty ? trip.payRange : '—';
    final distStr = trip.distance?.isNotEmpty == true ? trip.distance! : null;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF334155)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: [
        // Trip ID bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppPalette.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                trip.tripCode.isNotEmpty ? trip.tripCode : trip.tripId,
                style: AppText.micro
                    .on(AppPalette.primary)
                    .weight(FontWeight.w700),
              ),
            ),
            const Spacer(),
            if (trip.vehicleNumber.isNotEmpty) ...[
              const Icon(Iconsax.truck, size: 13, color: Colors.white54),
              const SizedBox(width: 5),
              Text(trip.vehicleNumber,
                  style: AppText.caption
                      .on(Colors.white70)
                      .weight(FontWeight.w600)),
              if (trip.vehicleType.isNotEmpty) ...[
                const SizedBox(width: 6),
                Text('• ${trip.vehicleType}',
                    style: AppText.caption.on(Colors.white38)),
              ],
            ],
          ]),
        ),
        // Route
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppPalette.green,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 2,
                  height: 26,
                  color: Colors.white24,
                ),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppPalette.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppPalette.primary.withValues(alpha: 0.4),
                        width: 3),
                  ),
                ),
              ]),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.pickupLocation.isNotEmpty
                          ? trip.pickupLocation
                          : 'Pickup Location',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.subtitle
                          .on(Colors.white)
                          .size(13),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      trip.deliveryLocation.isNotEmpty
                          ? trip.deliveryLocation
                          : 'Destination',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.subtitle
                          .on(Colors.white70)
                          .size(13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Stats row
        Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(children: [
            _ctxStat(Iconsax.calendar, fmt.format(trip.pickupDate)),
            if (trip.pickupTime.isNotEmpty) ...[
              _ctxDivider(),
              _ctxStat(Iconsax.clock, trip.pickupTime),
            ],
            _ctxDivider(),
            _ctxStat(Iconsax.money, payStr),
            if (distStr != null) ...[
              _ctxDivider(),
              _ctxStat(Iconsax.routing, '$distStr km'),
            ],
          ]),
        ),
      ]),
    );
  }

  Widget _ctxStat(IconData icon, String value) => Expanded(
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 12, color: Colors.white54),
          const SizedBox(width: 5),
          Flexible(
            child: Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.micro
                    .on(Colors.white70)
                    .weight(FontWeight.w600)),
          ),
        ]),
      );

  Widget _ctxDivider() => Container(
        width: 1,
        height: 16,
        color: Colors.white12,
        margin: const EdgeInsets.symmetric(horizontal: 4),
      );

  // ── LR section ────────────────────────────────────────────────────────────
  Widget _lrLoadingState() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppPalette.bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppPalette.border),
        ),
        child: Column(children: [
          _shimmer(height: 14, width: 120),
          const SizedBox(height: 10),
          _shimmer(height: 12, width: double.infinity),
          const SizedBox(height: 8),
          _shimmer(height: 12, width: 200),
          const SizedBox(height: 8),
          _shimmer(height: 12, width: 160),
        ]),
      );

  Widget _shimmer({required double height, required double width}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.4, end: 0.9),
      duration: const Duration(milliseconds: 700),
      builder: (_, v, __) => Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: AppPalette.border.withValues(alpha: v),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      onEnd: () => setState(() {}),
    );
  }

  Widget _errorState() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppPalette.dangerBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppPalette.danger.withValues(alpha: 0.25)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Iconsax.warning_2, size: 18, color: AppPalette.danger),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_error!,
                  style: AppText.bodySm.on(const Color(0xFFB91C1C))),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _load,
                child: Text('Retry',
                    style: AppText.label
                        .on(AppPalette.primary)
                        .weight(FontWeight.w700)),
              ),
            ]),
          ),
        ]),
      );

  Widget _lrSummaryCard(LrDetails lr) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppPalette.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Iconsax.receipt_text, size: 16, color: AppPalette.primary),
          const SizedBox(width: 8),
          Text(
            lr.lrNumber.isNotEmpty ? lr.lrNumber : 'Lorry Receipt',
            style: AppText.subtitle.on(AppPalette.textDark),
          ),
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
          const Divider(height: 1, color: AppPalette.border),
          const SizedBox(height: 12),
          _kv('Goods', lr.cargo!.description),
          _kv('Weight', '${_money.format(lr.cargo!.totalWeight)} kg'),
          if (lr.cargo!.totalQuantity != null)
            _kv('Quantity', _money.format(lr.cargo!.totalQuantity!)),
        ],
        if (lr.charges != null) ...[
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppPalette.border),
          const SizedBox(height: 12),
          _kv('Freight', '₹${_money.format(lr.charges!.freightAmount)}'),
          _kv('GST', '₹${_money.format(lr.charges!.gst)}'),
          if (lr.charges!.otherCharges != null &&
              lr.charges!.otherCharges! > 0)
            _kv('Other charges',
                '₹${_money.format(lr.charges!.otherCharges!)}'),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Total Amount',
                style: AppText.subtitle.on(AppPalette.textDark)),
            Text(
              '₹${_money.format(lr.charges!.totalAmount)}',
              style: AppText.h3.on(AppPalette.primary),
            ),
          ]),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(_paymentModeLabel(lr.charges!.paymentMode),
                style: AppText.caption),
          ),
        ],
      ]),
    );
  }

  Widget _partyRow(String role, LrParty p) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(role.toUpperCase(),
          style: AppText.micro),
      const SizedBox(height: 2),
      Text(p.name, style: AppText.subtitle.on(AppPalette.textDark)),
      if (p.address.isNotEmpty)
        Text(p.address,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppText.caption.on(AppPalette.textGrey)),
    ]);
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            width: 110,
            child: Text(k, style: AppText.caption),
          ),
          Expanded(
            child: Text(v,
                style: AppText.label.on(AppPalette.textDark)),
          ),
        ]),
      );

  // ── verification method tiles ─────────────────────────────────────────────
  Widget _sectionLabel(String label) => Text(label, style: AppText.micro);

  Widget _methodTile({
    required String value,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    bool recommended = false,
  }) {
    final selected = _method == value;
    return GestureDetector(
      onTap: _submitting
          ? null
          : () => setState(() {
                _method = value;
                _otpRequested = false;
                _devOtp = null;
                for (final c in _otpCtrls) {
                  c.clear();
                }
                _checkboxConfirmed = false;
              }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.06)
              : AppPalette.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : AppPalette.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(title, style: AppText.label.on(AppPalette.textDark)),
                if (recommended) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppPalette.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Recommended',
                        style: AppText.micro.on(AppPalette.primary)),
                  ),
                ],
              ]),
              const SizedBox(height: 2),
              Text(subtitle, style: AppText.caption),
            ]),
          ),
          const SizedBox(width: 8),
          Icon(
            selected ? Iconsax.tick_circle5 : Iconsax.record,
            size: 20,
            color: selected ? color : AppPalette.border,
          ),
        ]),
      ),
    );
  }

  // ── OTP section with 6 individual digit boxes ─────────────────────────────
  Widget _otpSection() {
    if (!_otpRequested) {
      return Column(children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppPalette.blueBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: AppPalette.blue.withValues(alpha: 0.2)),
          ),
          child: Row(children: [
            const Icon(Iconsax.info_circle,
                size: 16, color: AppPalette.blue),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'An OTP will be sent to your registered mobile number to verify this Lorry Receipt.',
                style: AppText.caption.on(const Color(0xFF1E3A8A)),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _submitting ? null : _requestOtp,
            icon: _submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Iconsax.sms, size: 18),
            label: Text('Send OTP',
                style: AppText.subtitle.on(Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPalette.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ]);
    }

    return Column(children: [
      if (_devOtp != null && _devOtp!.isNotEmpty)
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppPalette.amberBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(children: [
            const Icon(Iconsax.information, size: 14, color: AppPalette.amber),
            const SizedBox(width: 8),
            Text('Demo OTP: $_devOtp',
                style:
                    AppText.label.on(AppPalette.amber).weight(FontWeight.w700)),
          ]),
        ),
      _sixCellOtp(),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(
          child: Text('OTP sent to your registered mobile number',
              style: AppText.caption),
        ),
        GestureDetector(
          onTap: _submitting ? null : _requestOtp,
          child: Text('Resend',
              style: AppText.label
                  .on(AppPalette.primary)
                  .weight(FontWeight.w700)),
        ),
      ]),
    ]);
  }

  Widget _sixCellOtp() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (i) {
        final filled = _otpCtrls[i].text.isNotEmpty;
        return SizedBox(
          width: 46,
          height: 56,
          child: TextField(
            controller: _otpCtrls[i],
            focusNode: _otpFoci[i],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: AppText.h2.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppPalette.primary,
            ),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: filled
                  ? AppPalette.primaryLight
                  : AppPalette.bg,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: filled ? AppPalette.primary : AppPalette.border,
                  width: filled ? 1.5 : 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: AppPalette.primary, width: 2),
              ),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (val) {
              if (val.isNotEmpty) {
                if (i < 5) {
                  FocusScope.of(context).requestFocus(_otpFoci[i + 1]);
                } else {
                  _otpFoci[i].unfocus();
                }
              } else if (val.isEmpty && i > 0) {
                FocusScope.of(context).requestFocus(_otpFoci[i - 1]);
              }
              setState(() {});
            },
            onTap: () {
              // Clear cell on re-tap to allow re-entry
              if (_otpCtrls[i].text.isNotEmpty) {
                _otpCtrls[i].clear();
                setState(() {});
              }
            },
          ),
        );
      }),
    );
  }

  // ── checkbox section ──────────────────────────────────────────────────────
  Widget _checkboxSection() {
    return GestureDetector(
      onTap: _submitting
          ? null
          : () => setState(() => _checkboxConfirmed = !_checkboxConfirmed),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _checkboxConfirmed
              ? AppPalette.greenBg
              : AppPalette.bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _checkboxConfirmed ? AppPalette.green : AppPalette.border,
            width: _checkboxConfirmed ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color:
                  _checkboxConfirmed ? AppPalette.green : Colors.white,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: _checkboxConfirmed
                    ? AppPalette.green
                    : AppPalette.textGrey,
                width: 1.5,
              ),
            ),
            child: _checkboxConfirmed
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('I confirm all LR details are correct',
                  style: AppText.subtitle.on(AppPalette.textDark)),
              const SizedBox(height: 2),
              Text(
                  'Consignor, consignee, cargo, weight, and freight are verified.',
                  style: AppText.caption),
            ]),
          ),
        ]),
      ),
    );
  }

  // ── action buttons ────────────────────────────────────────────────────────
  Widget _actionButtons() {
    final canConfirm = _method == 'checkbox'
        ? _checkboxConfirmed
        : (_otpRequested && _otpValue.length == 6);
    final onConfirm =
        _method == 'checkbox' ? _confirmCheckbox : _verifyOtp;

    return Column(children: [
      SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: (_submitting || !canConfirm) ? null : onConfirm,
          icon: _submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Icon(Iconsax.tick_circle, size: 18),
          label: Text('Confirm LR',
              style: AppText.subtitle.on(Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppPalette.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor:
                AppPalette.primary.withValues(alpha: 0.38),
            disabledForegroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
      const SizedBox(height: 10),
      SizedBox(
        width: double.infinity,
        height: 48,
        child: TextButton.icon(
          onPressed: _submitting ? null : _reject,
          icon: const Icon(Iconsax.close_circle, size: 17,
              color: AppPalette.danger),
          label: Text('Reject LR',
              style:
                  AppText.subtitle.on(AppPalette.danger)),
          style: TextButton.styleFrom(
            foregroundColor: AppPalette.danger,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
    ]);
  }

  // ── success overlay ───────────────────────────────────────────────────────
  Widget _successOverlay() {
    return Container(
      height: 320,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            builder: (_, v, __) => Transform.scale(
              scale: v,
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppPalette.greenBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Iconsax.tick_circle5,
                    size: 40, color: AppPalette.green),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('LR Confirmed!', style: AppText.h2.on(AppPalette.green)),
          const SizedBox(height: 8),
          Text('You can now start the trip.',
              style: AppText.bodySm.on(AppPalette.textGrey)),
          const SizedBox(height: 20),
          const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
                strokeWidth: 2.5, color: AppPalette.primary),
          ),
        ],
      ),
    );
  }

  String _paymentModeLabel(String mode) {
    switch (mode) {
      case 'paid':
        return 'Payment: Paid';
      case 'to-be-billed':
        return 'Payment: To be billed';
      default:
        return 'Payment: To pay';
    }
  }
}
