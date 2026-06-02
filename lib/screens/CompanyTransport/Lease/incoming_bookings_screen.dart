import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../controllers/Transport/lease_controller.dart';
import '../../../models/fleet_models.dart';
import '../../../widgets/custom_loader.dart';

const _primary = Color(0xFFF36969);
const _bg = Color(0xFFF9FAFB);
const _card = Colors.white;
const _textDark = Color(0xFF111827);
const _textGrey = Color(0xFF6B7280);
const _border = Color(0xFFE5E7EB);

class IncomingBookingsScreen extends StatefulWidget {
  const IncomingBookingsScreen({super.key});

  @override
  State<IncomingBookingsScreen> createState() => _IncomingBookingsScreenState();
}

class _IncomingBookingsScreenState extends State<IncomingBookingsScreen> {
  final LeaseController _ctrl = Get.find<LeaseController>();
  final Map<String, TextEditingController> _reasonCtrls = {};

  @override
  void initState() {
    super.initState();
    _ctrl.fetchIncomingBookings();
  }

  @override
  void dispose() {
    for (final c in _reasonCtrls.values) { c.dispose(); }
    super.dispose();
  }

  TextEditingController _reasonFor(String id) =>
      _reasonCtrls.putIfAbsent(id, () => TextEditingController());

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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: _textDark),
          onPressed: () => Get.back(),
        ),
        title: const Text('Incoming Bookings',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _textDark, fontFamily: 'Poppins')),
      ),
      body: Obx(() {
        if (_ctrl.isIncomingLoading.value && _ctrl.incomingBookings.isEmpty) {
          return const Center(child: CustomLoader());
        }
        return RefreshIndicator(
          color: _primary,
          onRefresh: _ctrl.fetchIncomingBookings,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildStatsRow()),
              if (_ctrl.pendingIncoming.isNotEmpty) ...[
                _sectionHeader('Pending Approval', _ctrl.pendingIncoming.length,
                    const Color(0xFFF59E0B)),
                _bookingList(_ctrl.pendingIncoming, showActions: true),
              ],
              if (_ctrl.readyToStart.isNotEmpty) ...[
                _sectionHeader('Ready to Start', _ctrl.readyToStart.length,
                    const Color(0xFF3B82F6)),
                _bookingList(_ctrl.readyToStart, canStart: true),
              ],
              if (_ctrl.activeLeases.isNotEmpty) ...[
                _sectionHeader('Active Leases', _ctrl.activeLeases.length,
                    const Color(0xFF22C55E)),
                _bookingList(_ctrl.activeLeases, canComplete: true),
              ],
              if (_ctrl.pastBookings.isNotEmpty) ...[
                _sectionHeader('Past Bookings', _ctrl.pastBookings.length, _textGrey),
                _bookingList(_ctrl.pastBookings),
              ],
              if (_ctrl.incomingBookings.isEmpty)
                SliverFillRemaining(child: _emptyState()),
              const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatsRow() {
    return Obx(() {
      final pending = _ctrl.pendingIncoming.length;
      final confirmed = _ctrl.readyToStart.length;
      final active = _ctrl.activeLeases.length;
      final earnings = _ctrl.totalEarnings;

      return Container(
        color: _card,
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(children: [
          _stat('$pending', 'Pending', const Color(0xFFF59E0B)),
          _vd(),
          _stat('$confirmed', 'Confirmed', const Color(0xFF3B82F6)),
          _vd(),
          _stat('$active', 'Active', const Color(0xFF22C55E)),
          _vd(),
          _stat('₹${earnings.toStringAsFixed(0)}', 'Earned', _primary),
        ]),
      );
    });
  }

  Widget _stat(String v, String l, Color c) => Expanded(
        child: Column(children: [
          Text(v, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: c, fontFamily: 'Poppins')),
          Text(l, style: const TextStyle(fontSize: 10, color: _textGrey, fontFamily: 'Poppins')),
        ]),
      );

  Widget _vd() => Container(width: 1, height: 32, color: _border);

  Widget _sectionHeader(String title, int count, Color color) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: Row(children: [
          Container(
            width: 4, height: 18,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textDark, fontFamily: 'Poppins')),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: Text('$count', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color, fontFamily: 'Poppins')),
          ),
        ]),
      ),
    );
  }

  SliverList _bookingList(List<LeaseBooking> bookings,
      {bool showActions = false, bool canStart = false, bool canComplete = false}) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, i) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: _BookingTile(
            booking: bookings[i],
            ctrl: _ctrl,
            showActions: showActions,
            canStart: canStart,
            canComplete: canComplete,
            reasonCtrl: showActions ? _reasonFor(bookings[i].id) : null,
          ),
        ),
        childCount: bookings.length,
      ),
    );
  }

  Widget _emptyState() => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(color: const Color(0xFFFFF1F1), shape: BoxShape.circle),
            child: const Icon(Iconsax.document_download, size: 32, color: _primary),
          ),
          const SizedBox(height: 16),
          const Text('No incoming bookings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark, fontFamily: 'Poppins')),
          const SizedBox(height: 6),
          const Text('Bookings from lessees will appear here', style: TextStyle(fontSize: 13, color: _textGrey, fontFamily: 'Poppins')),
        ]),
      );
}

// ── Booking tile ──────────────────────────────────────────────────────────────

class _BookingTile extends StatefulWidget {
  final LeaseBooking booking;
  final LeaseController ctrl;
  final bool showActions;
  final bool canStart;
  final bool canComplete;
  final TextEditingController? reasonCtrl;

  const _BookingTile({
    required this.booking,
    required this.ctrl,
    this.showActions = false,
    this.canStart = false,
    this.canComplete = false,
    this.reasonCtrl,
  });

  @override
  State<_BookingTile> createState() => _BookingTileState();
}

class _BookingTileState extends State<_BookingTile> {
  bool _showReject = false;
  bool _actionBusy = false;

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;
    final sc = _statusColor(b.status);

    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: b.isPending ? const Color(0xFFF59E0B).withValues(alpha: 0.4) : _border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          // Vehicle image strip
          if (b.vehicleImage != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(b.vehicleImage!, height: 120, width: double.infinity, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink()),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  if (b.vehicleName != null)
                    Expanded(
                      child: Text(b.vehicleName!,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textDark, fontFamily: 'Poppins'),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: sc.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                    child: Text(b.statusLabel,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: sc, fontFamily: 'Poppins')),
                  ),
                ]),
                const SizedBox(height: 6),
                if (b.lesseeName != null)
                  Row(children: [
                    const Icon(Iconsax.people, size: 13, color: _textGrey),
                    const SizedBox(width: 5),
                    Text(b.lesseeName!, style: const TextStyle(fontSize: 12, color: _textGrey, fontFamily: 'Poppins')),
                  ]),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Iconsax.calendar, size: 13, color: _textGrey),
                  const SizedBox(width: 5),
                  Text(b.formattedDates, style: const TextStyle(fontSize: 12, color: _textGrey, fontFamily: 'Poppins')),
                  if (b.durationDays != null) ...[
                    const SizedBox(width: 10),
                    Text('${b.durationDays} days', style: const TextStyle(fontSize: 12, color: _textGrey, fontFamily: 'Poppins')),
                  ],
                ]),
                if (b.totalPrice != null) ...[
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Iconsax.wallet_3, size: 13, color: _primary),
                    const SizedBox(width: 5),
                    Text('₹${b.totalPrice!.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _primary, fontFamily: 'Poppins')),
                  ]),
                ],
                if (b.requestMessage?.isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(10)),
                    child: Text('"${b.requestMessage}"',
                        style: const TextStyle(fontSize: 12, color: _textGrey, fontFamily: 'Poppins', fontStyle: FontStyle.italic)),
                  ),
                ],

                // ── Actions ──────────────────────────────────────────────────
                if (widget.showActions && b.isPending) ...[
                  const SizedBox(height: 12),
                  if (!_showReject)
                    Row(children: [
                      Expanded(child: _outlineBtn('Reject', const Color(0xFFEF4444),
                          () => setState(() => _showReject = true))),
                      const SizedBox(width: 10),
                      Expanded(child: _solidBtn('Approve', const Color(0xFF22C55E),
                          () => _approve())),
                    ])
                  else ...[
                    TextField(
                      controller: widget.reasonCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Reason for rejection…',
                        hintStyle: const TextStyle(fontSize: 12, color: _textGrey, fontFamily: 'Poppins'),
                        filled: true, fillColor: _bg,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(children: [
                      TextButton(
                        onPressed: () => setState(() => _showReject = false),
                        child: const Text('Cancel', style: TextStyle(color: _textGrey, fontFamily: 'Poppins')),
                      ),
                      const Spacer(),
                      _solidBtn('Confirm Reject', const Color(0xFFEF4444), () => _reject()),
                    ]),
                  ],
                ],

                if (widget.canStart) ...[
                  const SizedBox(height: 10),
                  SizedBox(width: double.infinity,
                      child: _solidBtn('Start Lease', const Color(0xFF3B82F6), () => _start())),
                ],

                if (widget.canComplete) ...[
                  const SizedBox(height: 10),
                  SizedBox(width: double.infinity,
                      child: _solidBtn('Complete Lease', const Color(0xFF22C55E), () => _complete())),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _approve() async {
    setState(() => _actionBusy = true);
    await widget.ctrl.confirmBooking(widget.booking.id);
    setState(() => _actionBusy = false);
  }

  Future<void> _reject() async {
    final reason = widget.reasonCtrl?.text.trim() ?? '';
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a reason')));
      return;
    }
    setState(() => _actionBusy = true);
    await widget.ctrl.rejectBooking(widget.booking.id, reason: reason);
    widget.reasonCtrl?.clear();
    setState(() { _actionBusy = false; _showReject = false; });
  }

  Future<void> _start() async {
    setState(() => _actionBusy = true);
    await widget.ctrl.startLease(widget.booking.id);
    setState(() => _actionBusy = false);
  }

  Future<void> _complete() async {
    setState(() => _actionBusy = true);
    await widget.ctrl.completeLease(widget.booking.id);
    setState(() => _actionBusy = false);
  }

  Widget _solidBtn(String label, Color bg, VoidCallback onTap) =>
      ElevatedButton(
        onPressed: _actionBusy ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 11),
        ),
        child: _actionBusy
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(label, style: const TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 13)),
      );

  Widget _outlineBtn(String label, Color color, VoidCallback onTap) =>
      OutlinedButton(
        onPressed: _actionBusy ? null : onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 11),
        ),
        child: Text(label, style: TextStyle(color: color, fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 13)),
      );

  Color _statusColor(String s) {
    switch (s) {
      case 'pending_approval': return const Color(0xFFF59E0B);
      case 'approved': return const Color(0xFF3B82F6);
      case 'active': return const Color(0xFF22C55E);
      case 'completed': return const Color(0xFF8B5CF6);
      case 'rejected': case 'cancelled': return const Color(0xFFEF4444);
      default: return _textGrey;
    }
  }
}
