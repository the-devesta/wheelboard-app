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

class LeaseListingBookingsScreen extends StatefulWidget {
  final String listingId;
  final LeaseController ctrl;
  const LeaseListingBookingsScreen({super.key, required this.listingId, required this.ctrl});

  @override
  State<LeaseListingBookingsScreen> createState() => _LeaseListingBookingsScreenState();
}

class _LeaseListingBookingsScreenState extends State<LeaseListingBookingsScreen> {
  String _tab = 'all';
  String? _respondingTo;
  final _noteCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.ctrl.fetchListingBookings(widget.listingId);
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  List<LeaseBooking> get _filtered {
    final all = widget.ctrl.listingBookings;
    switch (_tab) {
      case 'pending': return all.where((b) => b.isPending).toList();
      case 'approved': return all.where((b) => b.isApproved).toList();
      case 'active': return all.where((b) => b.isActive).toList();
      case 'completed': return all.where((b) => b.isCompleted).toList();
      default: return all.toList();
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
        title: const Text('Listing Bookings',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _textDark, fontFamily: 'Poppins')),
      ),
      body: Obx(() {
        if (widget.ctrl.isDetailLoading.value && widget.ctrl.listingBookings.isEmpty) {
          return const Center(child: CustomLoader());
        }
        final all = widget.ctrl.listingBookings;
        return Column(
          children: [
            _buildStats(all),
            _buildTabs(),
            Expanded(
              child: RefreshIndicator(
                color: _primary,
                onRefresh: () => widget.ctrl.fetchListingBookings(widget.listingId),
                child: _filtered.isEmpty
                    ? _empty()
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => _BookingCard(
                          booking: _filtered[i],
                          ctrl: widget.ctrl,
                          isResponding: _respondingTo == _filtered[i].id,
                          noteCtrl: _noteCtrl,
                          reasonCtrl: _reasonCtrl,
                          onRespond: (id) => setState(() {
                            _respondingTo = _respondingTo == id ? null : id;
                          }),
                          onApprove: (b) async {
                            await widget.ctrl.confirmBooking(b.id, ownerNote: _noteCtrl.text.trim());
                            setState(() { _respondingTo = null; _noteCtrl.clear(); });
                          },
                          onReject: (b) async {
                            if (_reasonCtrl.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Provide a reason for rejection')));
                              return;
                            }
                            await widget.ctrl.rejectBooking(b.id, reason: _reasonCtrl.text.trim());
                            setState(() { _respondingTo = null; _reasonCtrl.clear(); });
                          },
                        ),
                      ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStats(List<LeaseBooking> all) {
    return Container(
      color: _card,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          _s('${all.length}', 'Total', _textGrey),
          _div(),
          _s('${all.where((b) => b.isPending).length}', 'Pending', const Color(0xFFF59E0B)),
          _div(),
          _s('${all.where((b) => b.isActive).length}', 'Active', const Color(0xFF22C55E)),
          _div(),
          _s('${all.where((b) => b.isCompleted).length}', 'Done', const Color(0xFF3B82F6)),
        ],
      ),
    );
  }

  Widget _s(String v, String l, Color c) => Expanded(
        child: Column(children: [
          Text(v, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: c, fontFamily: 'Poppins')),
          Text(l, style: const TextStyle(fontSize: 10, color: _textGrey, fontFamily: 'Poppins')),
        ]),
      );

  Widget _div() => Container(width: 1, height: 32, color: _border);

  Widget _buildTabs() {
    const tabs = [('all','All'),('pending','Pending'),('approved','Approved'),('active','Active'),('completed','Done')];
    return Container(
      color: _card,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: tabs.map((t) {
            final active = _tab == t.$1;
            return GestureDetector(
              onTap: () => setState(() => _tab = t.$1),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: active ? _primary : _bg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: active ? _primary : _border),
                ),
                child: Text(t.$2, style: TextStyle(
                    fontSize: 12, fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active ? Colors.white : _textGrey, fontFamily: 'Poppins')),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _empty() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Iconsax.receipt_disscount, size: 48, color: _textGrey),
      const SizedBox(height: 12),
      const Text('No bookings in this category', style: TextStyle(fontSize: 14, color: _textGrey, fontFamily: 'Poppins')),
    ]),
  );
}

class _BookingCard extends StatelessWidget {
  final LeaseBooking booking;
  final LeaseController ctrl;
  final bool isResponding;
  final TextEditingController noteCtrl;
  final TextEditingController reasonCtrl;
  final void Function(String) onRespond;
  final void Function(LeaseBooking) onApprove;
  final void Function(LeaseBooking) onReject;

  const _BookingCard({
    required this.booking,
    required this.ctrl,
    required this.isResponding,
    required this.noteCtrl,
    required this.reasonCtrl,
    required this.onRespond,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final sc = _statusColor(booking.status);
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: booking.isPending ? const Color(0xFFF59E0B).withValues(alpha: 0.4) : _border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: sc.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                child: Text(booking.statusLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: sc, fontFamily: 'Poppins')),
              ),
              const Spacer(),
              Text('ID: ${booking.id.length > 8 ? booking.id.substring(booking.id.length - 8) : booking.id}',
                  style: const TextStyle(fontSize: 10, color: _textGrey, fontFamily: 'Poppins')),
            ]),
            const SizedBox(height: 10),
            if (booking.lesseeName != null)
              Text(booking.lesseeName!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textDark, fontFamily: 'Poppins')),
            if (booking.lesseeCompany != null && booking.lesseeCompany != booking.lesseeName)
              Text(booking.lesseeCompany!, style: const TextStyle(fontSize: 12, color: _textGrey, fontFamily: 'Poppins')),
            const SizedBox(height: 8),
            _row('Dates', booking.formattedDates),
            if (booking.durationDays != null) _row('Duration', '${booking.durationDays} days'),
            if (booking.totalPrice != null) _row('Total', '₹${booking.totalPrice!.toStringAsFixed(0)}'),
            if (booking.requestMessage?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(10)),
                child: Text('"${booking.requestMessage}"',
                    style: const TextStyle(fontSize: 12, color: _textGrey, fontFamily: 'Poppins', fontStyle: FontStyle.italic)),
              ),
            ],
            if (booking.isPending) ...[
              const SizedBox(height: 12),
              if (!isResponding)
                Row(children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => onRespond('reject_${booking.id}'),
                      icon: const Icon(Iconsax.close_circle, size: 15, color: Color(0xFFEF4444)),
                      label: const Text('Reject', style: TextStyle(color: Color(0xFFEF4444), fontFamily: 'Poppins')),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFEF4444)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => onApprove(booking),
                      icon: const Icon(Iconsax.tick_circle, size: 15, color: Colors.white),
                      label: const Text('Approve', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22C55E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    ),
                  ),
                ])
              else ...[
                TextField(
                  controller: reasonCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Reason for rejection (required)…',
                    hintStyle: const TextStyle(fontSize: 12, color: _textGrey, fontFamily: 'Poppins'),
                    filled: true, fillColor: _bg,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5)),
                  ),
                ),
                const SizedBox(height: 8),
                Row(children: [
                  TextButton(onPressed: () => onRespond(booking.id), child: const Text('Cancel', style: TextStyle(color: _textGrey))),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => onReject(booking),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: const Text('Confirm Reject', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
                  ),
                ]),
              ],
            ],
            if (booking.isApproved) ...[
              const SizedBox(height: 10),
              SizedBox(width: double.infinity, child: ElevatedButton.icon(
                onPressed: () => ctrl.startLease(booking.id),
                icon: const Icon(Iconsax.play, size: 15, color: Colors.white),
                label: const Text('Start Lease', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              )),
            ],
            if (booking.isActive) ...[
              const SizedBox(height: 10),
              SizedBox(width: double.infinity, child: ElevatedButton.icon(
                onPressed: () => ctrl.completeLease(booking.id),
                icon: const Icon(Iconsax.tick_circle, size: 15, color: Colors.white),
                label: const Text('Complete Lease', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22C55E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(String l, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Row(children: [
          Text('$l: ', style: const TextStyle(fontSize: 12, color: _textGrey, fontFamily: 'Poppins')),
          Expanded(child: Text(v, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textDark, fontFamily: 'Poppins'))),
        ]),
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
