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

class MyBookedLeasesScreen extends StatefulWidget {
  const MyBookedLeasesScreen({super.key});

  @override
  State<MyBookedLeasesScreen> createState() => _MyBookedLeasesScreenState();
}

class _MyBookedLeasesScreenState extends State<MyBookedLeasesScreen> {
  final LeaseController _ctrl = Get.find<LeaseController>();
  String _tab = 'upcoming';

  @override
  void initState() {
    super.initState();
    _ctrl.fetchMyBookings();
  }

  List<LeaseBooking> get _filtered {
    final all = _ctrl.myBookings;
    switch (_tab) {
      case 'upcoming':
        return all
            .where((b) => b.status == 'pending_approval' || b.status == 'approved')
            .toList();
      case 'active':
        return all.where((b) => b.isActive).toList();
      case 'completed':
        return all.where((b) => b.isCompleted).toList();
      case 'cancelled':
        return all.where((b) => b.isCancelled).toList();
      default:
        return all.toList();
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: _textDark),
          onPressed: () => Get.back(),
        ),
        title: const Text('My Leased Vehicles',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _textDark, fontFamily: 'Poppins')),
      ),
      body: Obx(() {
        if (_ctrl.isMyBookingsLoading.value && _ctrl.myBookings.isEmpty) {
          return const Center(child: CustomLoader());
        }
        return Column(
          children: [
            _buildStats(),
            _buildTabs(),
            Expanded(
              child: RefreshIndicator(
                color: _primary,
                onRefresh: _ctrl.fetchMyBookings,
                child: _filtered.isEmpty
                    ? _emptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => _BookingCard(
                          booking: _filtered[i],
                          ctrl: _ctrl,
                        ),
                      ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStats() {
    return Obx(() {
      final all = _ctrl.myBookings;
      final upcoming = all.where((b) => b.status == 'pending_approval' || b.status == 'approved').length;
      final active = all.where((b) => b.isActive).length;
      final completed = all.where((b) => b.isCompleted).length;
      final cancelled = all.where((b) => b.isCancelled).length;
      return Container(
        color: _card,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(children: [
          _stat('$upcoming', 'Upcoming', const Color(0xFF3B82F6)),
          _vd(),
          _stat('$active', 'Active', const Color(0xFF22C55E)),
          _vd(),
          _stat('$completed', 'Completed', const Color(0xFF8B5CF6)),
          _vd(),
          _stat('$cancelled', 'Cancelled', const Color(0xFF6B7280)),
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

  Widget _buildTabs() {
    const tabs = [
      ('upcoming', 'Upcoming'),
      ('active', 'Active'),
      ('completed', 'Completed'),
      ('cancelled', 'Cancelled'),
    ];
    return Container(
      color: _card,
      child: Row(
        children: tabs.map((t) {
          final active = _tab == t.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _tab = t.$1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(
                    color: active ? _primary : Colors.transparent,
                    width: 2,
                  )),
                ),
                child: Text(t.$2,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                        color: active ? _primary : _textGrey,
                        fontFamily: 'Poppins')),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _emptyState() {
    final msgs = {
      'upcoming': 'No upcoming leases.\nBrowse the marketplace to book a vehicle.',
      'active': 'No active leases right now.',
      'completed': 'No completed leases yet.',
      'cancelled': 'No cancelled leases.',
    };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Iconsax.shopping_cart, size: 48, color: _textGrey),
          const SizedBox(height: 12),
          Text(msgs[_tab] ?? 'No leases found',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: _textGrey, fontFamily: 'Poppins')),
        ]),
      ),
    );
  }
}

// ── Booking card ──────────────────────────────────────────────────────────────

class _BookingCard extends StatelessWidget {
  final LeaseBooking booking;
  final LeaseController ctrl;
  const _BookingCard({required this.booking, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final b = booking;
    final sc = _statusColor(b.status);

    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vehicle image
          if (b.vehicleImage != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(b.vehicleImage!, height: 140, width: double.infinity, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(height: 80, color: const Color(0xFFF3F4F6),
                      child: const Center(child: Icon(Iconsax.truck, size: 32, color: _textGrey)))),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row
                Row(children: [
                  Expanded(
                    child: Text(b.listingTitle ?? b.vehicleName ?? 'Lease Booking',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textDark, fontFamily: 'Poppins'),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: sc.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                    child: Text(b.statusLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: sc, fontFamily: 'Poppins')),
                  ),
                ]),
                const SizedBox(height: 10),

                // 4-column grid: dates, duration, cost
                Row(children: [
                  _col('Start', _fmtDate(b.startDate)),
                  _col('End', _fmtDate(b.endDate)),
                  _col('Duration', b.durationDays != null ? '${b.durationDays} days' : '—'),
                  _col('Total', b.totalPrice != null ? '₹${b.totalPrice!.toStringAsFixed(0)}' : '—'),
                ]),

                // Price breakdown
                if (b.basePrice != null || b.deliveryFee != null || b.securityDeposit != null) ...[
                  const Divider(color: _border, height: 20),
                  Row(children: [
                    if (b.basePrice != null) _priceChip('Base', b.basePrice!),
                    if (b.deliveryFee != null && b.deliveryFee! > 0) _priceChip('Delivery', b.deliveryFee!),
                    if (b.securityDeposit != null && b.securityDeposit! > 0) _priceChip('Deposit', b.securityDeposit!),
                  ]),
                ],

                // Rejection / cancellation reason
                if ((b.rejectionReason?.isNotEmpty == true) || (b.cancellationReason?.isNotEmpty == true)) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(10)),
                    child: Text(b.rejectionReason ?? b.cancellationReason ?? '',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF991B1B), fontFamily: 'Poppins')),
                  ),
                ],

                // Cancel button for pending/approved
                if (b.status == 'pending_approval' || b.status == 'approved') ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showCancelDialog(context),
                      icon: const Icon(Iconsax.close_circle, size: 15, color: Color(0xFFEF4444)),
                      label: const Text('Cancel Booking', style: TextStyle(color: Color(0xFFEF4444), fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFEF4444)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _col(String label, String value) => Expanded(
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: _textGrey, fontFamily: 'Poppins')),
            const SizedBox(height: 3),
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textDark, fontFamily: 'Poppins'),
                textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      );

  Widget _priceChip(String label, num amount) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: _border)),
          child: Text('$label: ₹${amount.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 10, color: _textGrey, fontFamily: 'Poppins')),
        ),
      );

  void _showCancelDialog(BuildContext context) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Booking', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Please provide a reason for cancellation:', style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
          const SizedBox(height: 10),
          TextField(
            controller: reasonCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'e.g. Change of plans…',
              hintStyle: const TextStyle(fontSize: 13, color: _textGrey, fontFamily: 'Poppins'),
              filled: true, fillColor: _bg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
            ),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Keep It', style: TextStyle(color: _textGrey, fontFamily: 'Poppins'))),
          ElevatedButton(
            onPressed: () async {
              final reason = reasonCtrl.text.trim();
              if (reason.isEmpty) return;
              Get.back();
              await ctrl.cancelBooking(booking.id, reason: reason);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Cancel Booking', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
  }

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

  String _fmtDate(String? raw) {
    if (raw == null) return '—';
    try {
      final d = DateTime.parse(raw).toLocal();
      const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${d.day} ${m[d.month - 1]}';
    } catch (_) { return raw; }
  }
}
