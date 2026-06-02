import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../controllers/Transport/lease_controller.dart';
import '../../../models/fleet_models.dart';
import 'lease_listing_bookings_screen.dart';

const _primary = Color(0xFFF36969);
const _bg = Color(0xFFF9FAFB);
const _card = Colors.white;
const _textDark = Color(0xFF111827);
const _textGrey = Color(0xFF6B7280);
const _border = Color(0xFFE5E7EB);

class LeaseListingDetailScreen extends StatefulWidget {
  final LeaseListing listing;
  final LeaseController ctrl;
  const LeaseListingDetailScreen({super.key, required this.listing, required this.ctrl});

  @override
  State<LeaseListingDetailScreen> createState() => _LeaseListingDetailScreenState();
}

class _LeaseListingDetailScreenState extends State<LeaseListingDetailScreen> {
  late LeaseListing _listing;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _listing = widget.listing;
  }

  Future<void> _changeStatus(String newStatus) async {
    setState(() => _loading = true);
    final ok = await widget.ctrl.updateListingStatus(_listing.id, newStatus);
    if (ok) {
      // Reload from controller
      final updated = widget.ctrl.myListings.firstWhereOrNull((l) => l.id == _listing.id);
      if (updated != null) setState(() => _listing = updated);
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        slivers: [
          _buildSliverHeader(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusBadge(),
                  const SizedBox(height: 16),
                  _buildQuickStats(),
                  const SizedBox(height: 16),
                  if (_listing.description?.isNotEmpty == true) ...[
                    _buildSection('Description', _listing.description!),
                    const SizedBox(height: 16),
                  ],
                  if (_listing.terms?.isNotEmpty == true) ...[
                    _buildTermsCard(),
                    const SizedBox(height: 16),
                  ],
                  _buildPricingCard(),
                  const SizedBox(height: 16),
                  _buildLocationCard(),
                  const SizedBox(height: 16),
                  _buildAvailabilityCard(),
                  const SizedBox(height: 16),
                  _buildActionsCard(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverHeader() {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      backgroundColor: _card,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: _textDark),
        onPressed: () => Get.back(),
      ),
      actions: [
        TextButton.icon(
          onPressed: () => Get.to(() => LeaseListingBookingsScreen(listingId: _listing.id, ctrl: widget.ctrl)),
          icon: const Icon(Iconsax.receipt_1, size: 16, color: _primary),
          label: Text('Bookings (${_listing.bookingsCount})',
              style: const TextStyle(fontSize: 12, color: _primary, fontFamily: 'Poppins')),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _listing.vehicleImage != null
            ? Image.network(_listing.vehicleImage!, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _Placeholder())
            : _Placeholder(),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final color = _statusColor(_listing.status);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(_listing.status.capitalizeFirst ?? _listing.status,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color, fontFamily: 'Poppins')),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(_listing.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _textDark, fontFamily: 'Poppins'),
              maxLines: 2, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(16), border: Border.all(color: _border)),
      child: Row(
        children: [
          _qs(Iconsax.eye, '${_listing.views}', 'Views', const Color(0xFF3B82F6)),
          _div(),
          _qs(Iconsax.receipt_1, '${_listing.bookingsCount}', 'Bookings', const Color(0xFF22C55E)),
          _div(),
          _qs(Iconsax.calendar_1, '${_listing.minDurationDays ?? 1}–${_listing.maxDurationDays ?? 90}', 'Days', const Color(0xFFF59E0B)),
          _div(),
          _qs(Iconsax.speedometer, '${_listing.odometerReading ?? 0}', 'Km', _textGrey),
        ],
      ),
    );
  }

  Widget _qs(IconData icon, String val, String label, Color color) => Expanded(
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 4),
            Text(val, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color, fontFamily: 'Poppins')),
            Text(label, style: const TextStyle(fontSize: 10, color: _textGrey, fontFamily: 'Poppins')),
          ],
        ),
      );

  Widget _div() => Container(width: 1, height: 40, color: _border);

  Widget _buildSection(String title, String content) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textDark, fontFamily: 'Poppins')),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 13, color: _textGrey, fontFamily: 'Poppins', height: 1.5)),
        ],
      );

  Widget _buildTermsCard() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFF59E0B))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Iconsax.info_circle, size: 18, color: Color(0xFFF59E0B)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Terms & Conditions', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF92400E), fontFamily: 'Poppins')),
                  const SizedBox(height: 4),
                  Text(_listing.terms!, style: const TextStyle(fontSize: 12, color: Color(0xFF92400E), fontFamily: 'Poppins')),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildPricingCard() => _card_(
        icon: Iconsax.wallet_3,
        color: _primary,
        title: 'Pricing',
        children: [
          _row('Price', _listing.formattedPrice),
          if (_listing.securityDeposit != null && _listing.securityDeposit! > 0)
            _row('Security Deposit', '₹${_listing.securityDeposit!.toStringAsFixed(0)}'),
          _row('Delivery', _listing.deliveryAvailable ? 'Available' : 'Not available'),
          if (_listing.deliveryAvailable && _listing.deliveryRadius != null)
            _row('Delivery Radius', '${_listing.deliveryRadius!.toStringAsFixed(0)} km'),
          if (_listing.deliveryAvailable && _listing.deliveryFee != null)
            _row('Delivery Fee', '₹${_listing.deliveryFee!.toStringAsFixed(0)}'),
        ],
      );

  Widget _buildLocationCard() => _card_(
        icon: Iconsax.location,
        color: const Color(0xFF3B82F6),
        title: 'Pickup Location',
        children: [
          Text(_listing.pickupLocation ?? 'Not specified',
              style: const TextStyle(fontSize: 14, color: _textDark, fontFamily: 'Poppins')),
        ],
      );

  Widget _buildAvailabilityCard() => _card_(
        icon: Iconsax.calendar,
        color: const Color(0xFF22C55E),
        title: 'Availability',
        children: [
          if (_listing.availableFrom != null) _row('From', _fmtDate(_listing.availableFrom!)),
          if (_listing.availableUntil != null) _row('Until', _fmtDate(_listing.availableUntil!)),
          _row('Min Duration', '${_listing.minDurationDays ?? 1} days'),
          _row('Max Duration', '${_listing.maxDurationDays ?? 90} days'),
        ],
      );

  Widget _buildActionsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(16), border: Border.all(color: _border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Actions', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textDark, fontFamily: 'Poppins')),
          const SizedBox(height: 14),
          if (_loading)
            const Center(child: CircularProgressIndicator(color: _primary))
          else ...[
            if (_listing.isActive)
              _actionBtn(Iconsax.pause, 'Pause Listing', const Color(0xFFF59E0B), () => _changeStatus('paused')),
            if (_listing.isPaused)
              _actionBtn(Iconsax.play, 'Resume Listing', const Color(0xFF22C55E), () => _changeStatus('active')),
            if (_listing.isDraft)
              _actionBtn(Iconsax.send_1, 'Publish Listing', const Color(0xFF3B82F6), () => _changeStatus('active')),
            const SizedBox(height: 8),
            _actionBtn(Iconsax.trash, 'Remove Listing', const Color(0xFFEF4444), _confirmRemove),
          ],
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, String label, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 16, color: color),
          label: Text(label, style: TextStyle(color: color, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: color, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  void _confirmRemove() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Listing', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
        content: const Text('This will remove the listing from the marketplace.', style: TextStyle(fontFamily: 'Poppins')),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel', style: TextStyle(color: _textGrey))),
          ElevatedButton(
            onPressed: () { Get.back(); _changeStatus('removed'); },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _card_({required IconData icon, required Color color, required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(16), border: Border.all(color: _border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 34, height: 34, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(9)), child: Icon(icon, size: 18, color: color)),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textDark, fontFamily: 'Poppins')),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, color: _textGrey, fontFamily: 'Poppins')),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textDark, fontFamily: 'Poppins')),
          ],
        ),
      );

  Color _statusColor(String s) {
    switch (s) {
      case 'active': return const Color(0xFF22C55E);
      case 'paused': return const Color(0xFFF59E0B);
      case 'draft': return const Color(0xFF6B7280);
      default: return _textGrey;
    }
  }

  String _fmtDate(String raw) {
    try {
      final d = DateTime.parse(raw).toLocal();
      const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${d.day} ${m[d.month - 1]} ${d.year}';
    } catch (_) { return raw; }
  }
}

class _Placeholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(color: const Color(0xFFF3F4F6),
      child: const Center(child: Icon(Iconsax.truck, size: 48, color: _textGrey)));
}
