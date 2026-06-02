import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../controllers/Transport/lease_controller.dart';
import '../../../models/fleet_models.dart';
import '../../../widgets/custom_loader.dart';
import 'create_lease_wizard.dart';
import 'lease_listing_detail_screen.dart';
import 'incoming_bookings_screen.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
const _primary = Color(0xFFF36969);
const _bg = Color(0xFFF9FAFB);
const _card = Colors.white;
const _textDark = Color(0xFF111827);
const _textGrey = Color(0xFF6B7280);
const _border = Color(0xFFE5E7EB);

class LeaseListingsScreen extends StatefulWidget {
  const LeaseListingsScreen({super.key});

  @override
  State<LeaseListingsScreen> createState() => _LeaseListingsScreenState();
}

class _LeaseListingsScreenState extends State<LeaseListingsScreen> {
  final LeaseController _ctrl = Get.find<LeaseController>();
  String _tab = 'all'; // all | active | paused | draft
  String? _menuOpen;

  @override
  void initState() {
    super.initState();
    _ctrl.fetchMyListings();
  }

  List<LeaseListing> get _filtered {
    final all = _ctrl.visibleListings;
    if (_tab == 'all') return all;
    return all.where((l) => l.status == _tab).toList();
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
        title: const Text('My Lease Listings',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _textDark, fontFamily: 'Poppins')),
        actions: [
          TextButton.icon(
            onPressed: () => Get.to(() => const IncomingBookingsScreen()),
            icon: const Icon(Iconsax.document_download, size: 16, color: _primary),
            label: const Text('Incoming', style: TextStyle(fontSize: 12, color: _primary, fontFamily: 'Poppins')),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const CreateLeaseWizard()),
        backgroundColor: _primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('List Vehicle', style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
      ),
      body: Obx(() {
        if (_ctrl.isListingsLoading.value && _ctrl.myListings.isEmpty) {
          return const Center(child: CustomLoader());
        }
        final all = _ctrl.visibleListings;
        return Column(
          children: [
            _buildStats(all),
            _buildTabs(),
            Expanded(
              child: RefreshIndicator(
                color: _primary,
                onRefresh: _ctrl.fetchMyListings,
                child: _filtered.isEmpty
                    ? _buildEmpty()
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => _ListingCard(
                          listing: _filtered[i],
                          ctrl: _ctrl,
                          menuOpen: _menuOpen == _filtered[i].id,
                          onMenuToggle: () => setState(() =>
                              _menuOpen = _menuOpen == _filtered[i].id ? null : _filtered[i].id),
                        ),
                      ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStats(List<LeaseListing> all) {
    final active = all.where((l) => l.isActive).length;
    final totalViews = all.fold<int>(0, (s, l) => s + l.views);
    final totalBookings = all.fold<int>(0, (s, l) => s + l.bookingsCount);

    return Container(
      color: _card,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          _stat('${all.length}', 'Total', const Color(0xFF6B7280)),
          _vDiv(),
          _stat('$active', 'Active', const Color(0xFF22C55E)),
          _vDiv(),
          _stat('$totalViews', 'Views', const Color(0xFF3B82F6)),
          _vDiv(),
          _stat('$totalBookings', 'Bookings', _primary),
        ],
      ),
    );
  }

  Widget _stat(String val, String label, Color color) => Expanded(
        child: Column(
          children: [
            Text(val,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color, fontFamily: 'Poppins')),
            Text(label, style: const TextStyle(fontSize: 10, color: _textGrey, fontFamily: 'Poppins')),
          ],
        ),
      );

  Widget _vDiv() => Container(width: 1, height: 32, color: _border);

  Widget _buildTabs() {
    const tabs = [
      ('all', 'All'),
      ('active', 'Active'),
      ('paused', 'Paused'),
      ('draft', 'Draft'),
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
                  border: Border(
                    bottom: BorderSide(
                      color: active ? _primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(t.$2,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13,
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

  Widget _buildEmpty() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Iconsax.receipt_text, size: 48, color: _textGrey),
            const SizedBox(height: 12),
            const Text('No listings found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark, fontFamily: 'Poppins')),
            const SizedBox(height: 6),
            const Text('List your first vehicle to start earning', style: TextStyle(fontSize: 13, color: _textGrey, fontFamily: 'Poppins')),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Get.to(() => const CreateLeaseWizard()),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('List Vehicle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      );
}

// ── Listing Card ──────────────────────────────────────────────────────────────

class _ListingCard extends StatelessWidget {
  final LeaseListing listing;
  final LeaseController ctrl;
  final bool menuOpen;
  final VoidCallback onMenuToggle;

  const _ListingCard({
    required this.listing,
    required this.ctrl,
    required this.menuOpen,
    required this.onMenuToggle,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(listing.status);

    return GestureDetector(
      onTap: () => Get.to(() => LeaseListingDetailScreen(listing: listing, ctrl: ctrl)),
      child: Container(
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image + status
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: listing.vehicleImage != null
                      ? Image.network(listing.vehicleImage!, height: 160, width: double.infinity, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _ImgPlaceholder())
                      : _ImgPlaceholder(),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 6, height: 6, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        Text(listing.status.capitalizeFirst ?? listing.status,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Poppins')),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onMenuToggle,
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)]),
                      child: const Icon(Icons.more_vert_rounded, size: 18, color: _textDark),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(listing.title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textDark, fontFamily: 'Poppins'),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (listing.vehicleName != null) ...[
                    const SizedBox(height: 3),
                    Text('${listing.vehicleName}${listing.vehicleYear != null ? ' · ${listing.vehicleYear}' : ''}',
                        style: const TextStyle(fontSize: 12, color: _textGrey, fontFamily: 'Poppins')),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(listing.formattedPrice,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _primary, fontFamily: 'Poppins')),
                      const Spacer(),
                      _miniStat(Iconsax.eye, '${listing.views}'),
                      const SizedBox(width: 12),
                      _miniStat(Iconsax.receipt_1, '${listing.bookingsCount} bookings'),
                    ],
                  ),
                ],
              ),
            ),

            // Action menu (inline)
            if (menuOpen) _ActionMenu(listing: listing, ctrl: ctrl),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(IconData icon, String val) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: _textGrey),
          const SizedBox(width: 3),
          Text(val, style: const TextStyle(fontSize: 11, color: _textGrey, fontFamily: 'Poppins')),
        ],
      );

  Color _statusColor(String s) {
    switch (s) {
      case 'active': return const Color(0xFF22C55E);
      case 'paused': return const Color(0xFFF59E0B);
      case 'draft': return const Color(0xFF6B7280);
      case 'removed': return const Color(0xFFEF4444);
      default: return _textGrey;
    }
  }
}

class _ImgPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        height: 160, width: double.infinity,
        color: const Color(0xFFF3F4F6),
        child: const Center(child: Icon(Iconsax.truck, size: 40, color: _textGrey)),
      );
}

class _ActionMenu extends StatelessWidget {
  final LeaseListing listing;
  final LeaseController ctrl;
  const _ActionMenu({required this.listing, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        border: Border(top: BorderSide(color: _border)),
      ),
      child: Column(
        children: [
          _item(Iconsax.eye, 'View Details', _textDark,
              () => Get.to(() => LeaseListingDetailScreen(listing: listing, ctrl: ctrl))),
          if (listing.isActive)
            _item(Iconsax.pause, 'Pause Listing', const Color(0xFFF59E0B),
                () => ctrl.updateListingStatus(listing.id, 'paused')),
          if (listing.isPaused)
            _item(Iconsax.play, 'Resume Listing', const Color(0xFF22C55E),
                () => ctrl.updateListingStatus(listing.id, 'active')),
          if (listing.isDraft)
            _item(Iconsax.send_1, 'Publish Listing', const Color(0xFF3B82F6),
                () => ctrl.updateListingStatus(listing.id, 'active')),
          _item(Iconsax.trash, 'Remove Listing', const Color(0xFFEF4444),
              () => _confirmRemove(context, listing, ctrl),
              divider: false),
        ],
      ),
    );
  }

  Widget _item(IconData icon, String label, Color color, VoidCallback onTap, {bool divider = true}) {
    return Column(
      children: [
        if (divider) const Divider(height: 1, color: _border),
        ListTile(
          dense: true,
          leading: Icon(icon, size: 18, color: color),
          title: Text(label, style: TextStyle(fontSize: 13, color: color, fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
          onTap: onTap,
        ),
      ],
    );
  }

  void _confirmRemove(BuildContext ctx, LeaseListing l, LeaseController ctrl) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Listing', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to remove "${l.title}"?', style: const TextStyle(fontFamily: 'Poppins')),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel', style: TextStyle(color: _textGrey))),
          ElevatedButton(
            onPressed: () { Get.back(); ctrl.updateListingStatus(l.id, 'removed'); },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
