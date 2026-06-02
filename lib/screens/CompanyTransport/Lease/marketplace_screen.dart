import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../controllers/Transport/lease_controller.dart';
import '../../../models/fleet_models.dart';
import '../../../widgets/custom_loader.dart';
import 'marketplace_detail_screen.dart';

const _primary = Color(0xFFF36969);
const _primaryLight = Color(0xFFFFF1F1);
const _bg = Color(0xFFF9FAFB);
const _card = Colors.white;
const _textDark = Color(0xFF111827);
const _textGrey = Color(0xFF6B7280);
const _border = Color(0xFFE5E7EB);

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final LeaseController _ctrl = Get.find<LeaseController>();
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  String _selectedCategory = '';
  String _sortBy = 'createdAt';
  String _sortOrder = 'desc';
  double? _priceMin;
  double? _priceMax;
  bool _showFilters = false;
  final _priceMinCtrl = TextEditingController();
  final _priceMaxCtrl = TextEditingController();

  static const _categories = ['', 'Shipment', 'Construction', 'Mining', 'Others'];

  @override
  void initState() {
    super.initState();
    _ctrl.fetchMarketplace();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    _priceMinCtrl.dispose();
    _priceMaxCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      final hasMore = _ctrl.marketplaceListings.length < _ctrl.marketplacePaginationTotal.value;
      if (hasMore && !_ctrl.isMarketplaceLoading.value) {
        _ctrl.fetchMarketplace(
          page: _ctrl.marketplacePage.value + 1,
          category: _selectedCategory,
          priceMin: _priceMin,
          priceMax: _priceMax,
          location: _searchCtrl.text.trim(),
          sortBy: _sortBy,
          sortOrder: _sortOrder,
          reset: false,
        );
      }
    }
  }

  void _applyFilters() {
    _priceMin = _priceMinCtrl.text.isNotEmpty ? double.tryParse(_priceMinCtrl.text) : null;
    _priceMax = _priceMaxCtrl.text.isNotEmpty ? double.tryParse(_priceMaxCtrl.text) : null;
    _ctrl.fetchMarketplace(
      category: _selectedCategory,
      priceMin: _priceMin,
      priceMax: _priceMax,
      location: _searchCtrl.text.trim(),
      sortBy: _sortBy,
      sortOrder: _sortOrder,
    );
    setState(() => _showFilters = false);
  }

  void _clearFilters() {
    _searchCtrl.clear();
    _priceMinCtrl.clear();
    _priceMaxCtrl.clear();
    setState(() {
      _selectedCategory = '';
      _sortBy = 'createdAt';
      _sortOrder = 'desc';
      _priceMin = null;
      _priceMax = null;
    });
    _ctrl.fetchMarketplace();
  }

  bool get _hasActiveFilters =>
      _selectedCategory.isNotEmpty ||
      _priceMin != null ||
      _priceMax != null ||
      _searchCtrl.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          if (_showFilters) _buildFilterPanel(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  AppBar _buildAppBar() => AppBar(
        backgroundColor: _card,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: _border,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: _textDark),
          onPressed: () => Get.back(),
        ),
        title: const Text('Lease Marketplace',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _textDark, fontFamily: 'Poppins')),
        actions: [
          Obx(() {
            if (_ctrl.isMarketplaceLoading.value) {
              return const Padding(
                padding: EdgeInsets.all(14),
                child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: _primary)),
              );
            }
            return IconButton(
              icon: Icon(Iconsax.refresh, size: 20, color: _textGrey),
              onPressed: _applyFilters,
            );
          }),
        ],
      );

  Widget _buildSearchBar() {
    return Container(
      color: _card,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border),
              ),
              child: TextField(
                controller: _searchCtrl,
                onSubmitted: (_) => _applyFilters(),
                decoration: const InputDecoration(
                  hintText: 'Search by location…',
                  hintStyle: TextStyle(fontSize: 13, color: _textGrey, fontFamily: 'Poppins'),
                  prefixIcon: Icon(Iconsax.search_normal, size: 18, color: _textGrey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 13),
                ),
                style: const TextStyle(fontSize: 13, color: _textDark, fontFamily: 'Poppins'),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => setState(() => _showFilters = !_showFilters),
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: (_showFilters || _hasActiveFilters) ? _primary : _bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: (_showFilters || _hasActiveFilters) ? _primary : _border),
              ),
              child: Icon(
                Iconsax.setting_4,
                size: 20,
                color: (_showFilters || _hasActiveFilters) ? Colors.white : _textGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel() {
    return Container(
      color: _card,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: _border, height: 1),
          const SizedBox(height: 12),
          const Text('Category', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textGrey, fontFamily: 'Poppins')),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((c) {
                final label = c.isEmpty ? 'All' : c;
                final active = _selectedCategory == c;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = c),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: active ? _primary : _bg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: active ? _primary : _border),
                    ),
                    child: Text(label,
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600,
                            color: active ? Colors.white : _textGrey,
                            fontFamily: 'Poppins')),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _FilterField('Min price', _priceMinCtrl, keyboard: TextInputType.number),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _FilterField('Max price', _priceMaxCtrl, keyboard: TextInputType.number),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _sortDropdown('Sort by',
                    [('createdAt', 'Newest'), ('price', 'Price')], _sortBy,
                    (v) => setState(() => _sortBy = v)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _sortDropdown('Order',
                    [('desc', 'High → Low'), ('asc', 'Low → High')], _sortOrder,
                    (v) => setState(() => _sortOrder = v)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _clearFilters,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                ),
                child: const Text('Clear', style: TextStyle(color: _textGrey, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  elevation: 0,
                ),
                child: const Text('Apply Filters', style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Obx(() {
      if (_ctrl.isMarketplaceLoading.value && _ctrl.marketplaceListings.isEmpty) {
        return const Center(child: CustomLoader());
      }
      if (_ctrl.marketplaceListings.isEmpty) return _buildEmpty();

      return RefreshIndicator(
        color: _primary,
        onRefresh: () => _ctrl.fetchMarketplace(
          category: _selectedCategory,
          priceMin: _priceMin,
          priceMax: _priceMax,
          location: _searchCtrl.text.trim(),
          sortBy: _sortBy,
          sortOrder: _sortOrder,
        ),
        child: CustomScrollView(
          controller: _scrollCtrl,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    Text(
                      '${_ctrl.marketplacePaginationTotal.value} vehicles available',
                      style: const TextStyle(fontSize: 13, color: _textGrey, fontFamily: 'Poppins'),
                    ),
                    const Spacer(),
                    if (_hasActiveFilters)
                      GestureDetector(
                        onTap: _clearFilters,
                        child: const Text('Clear filters',
                            style: TextStyle(fontSize: 12, color: _primary, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    if (i < _ctrl.marketplaceListings.length) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _MarketplaceCard(listing: _ctrl.marketplaceListings[i]),
                      );
                    }
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator(color: _primary, strokeWidth: 2)),
                    );
                  },
                  childCount: _ctrl.marketplaceListings.length +
                      (_ctrl.marketplaceListings.length < _ctrl.marketplacePaginationTotal.value ? 1 : 0),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildEmpty() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80, height: 80,
                decoration: const BoxDecoration(color: _primaryLight, shape: BoxShape.circle),
                child: const Icon(Iconsax.shop, size: 36, color: _primary),
              ),
              const SizedBox(height: 16),
              const Text('No vehicles available',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark, fontFamily: 'Poppins')),
              const SizedBox(height: 6),
              const Text('Try adjusting your filters or check back later',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: _textGrey, fontFamily: 'Poppins')),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Iconsax.filter_remove, size: 16),
                label: const Text('Clear Filters'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primary,
                  side: const BorderSide(color: _primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _sortDropdown(String label, List<(String, String)> items, String value, ValueChanged<String> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: _textGrey, fontFamily: 'Poppins')),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: _border)),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            style: const TextStyle(fontSize: 12, color: _textDark, fontFamily: 'Poppins'),
            items: items.map((i) => DropdownMenuItem(value: i.$1, child: Text(i.$2))).toList(),
            onChanged: (v) { if (v != null) onChanged(v); },
          ),
        ),
      ],
    );
  }
}

class _FilterField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final TextInputType? keyboard;
  const _FilterField(this.label, this.ctrl, {this.keyboard});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: _textGrey, fontFamily: 'Poppins')),
          const SizedBox(height: 4),
          TextField(
            controller: ctrl,
            keyboardType: keyboard,
            decoration: InputDecoration(
              hintText: '₹ Amount',
              hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF), fontFamily: 'Poppins'),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              filled: true, fillColor: _bg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _primary, width: 1.5)),
            ),
            style: const TextStyle(fontSize: 12, color: _textDark, fontFamily: 'Poppins'),
          ),
        ],
      );
}

// ── Marketplace listing card ───────────────────────────────────────────────────

class _MarketplaceCard extends StatelessWidget {
  final LeaseListing listing;
  const _MarketplaceCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => MarketplaceDetailScreen(listingId: listing.id, listing: listing)),
      child: Container(
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _border),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  child: listing.vehicleImage != null
                      ? Image.network(
                          listing.vehicleImage!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(),
                        )
                      : _placeholder(),
                ),
                // Category badge
                if (listing.vehicleCategory != null)
                  Positioned(
                    top: 12, left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(listing.vehicleCategory!,
                          style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                    ),
                  ),
                // Price badge
                Positioned(
                  top: 12, right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      listing.pricingType == 'on_request'
                          ? 'On Request'
                          : '₹${_fmtAmount(listing.priceAmount)}/${_unitLabel(listing.priceUnit)}',
                      style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700, fontFamily: 'Poppins'),
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
                  if (listing.vehicleName != null || listing.vehicleYear != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      [listing.vehicleName, listing.vehicleYear?.toString()].whereType<String>().join(' · '),
                      style: const TextStyle(fontSize: 12, color: _textGrey, fontFamily: 'Poppins'),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(children: [
                    if (listing.pickupLocation?.isNotEmpty == true) ...[
                      const Icon(Iconsax.location, size: 13, color: _textGrey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(listing.pickupLocation!,
                            style: const TextStyle(fontSize: 12, color: _textGrey, fontFamily: 'Poppins'),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    ] else
                      const Spacer(),
                    const SizedBox(width: 8),
                    _miniStat(Iconsax.eye, '${listing.views}'),
                    const SizedBox(width: 12),
                    _miniStat(Iconsax.receipt_1, '${listing.bookingsCount}'),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: _infoChip(
                        Iconsax.calendar,
                        listing.minDurationDays != null ? 'Min ${listing.minDurationDays}d' : 'Flexible',
                        const Color(0xFF3B82F6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _infoChip(
                        Iconsax.truck_fast,
                        listing.deliveryAvailable ? 'Delivery' : 'Pickup only',
                        listing.deliveryAvailable ? const Color(0xFF22C55E) : _textGrey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Iconsax.arrow_right_3, size: 13, color: Colors.white),
                            SizedBox(width: 4),
                            Text('Book', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Poppins')),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(IconData icon, String val) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: _textGrey),
          const SizedBox(width: 3),
          Text(val, style: const TextStyle(fontSize: 11, color: _textGrey, fontFamily: 'Poppins')),
        ],
      );

  Widget _infoChip(IconData icon, String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Flexible(child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color, fontFamily: 'Poppins'), maxLines: 1, overflow: TextOverflow.ellipsis)),
          ],
        ),
      );

  Widget _placeholder() => Container(
        height: 180, width: double.infinity,
        color: const Color(0xFFF3F4F6),
        child: const Center(child: Icon(Iconsax.truck, size: 44, color: _textGrey)),
      );

  String _fmtAmount(double? v) {
    if (v == null) return '0';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toStringAsFixed(0);
  }

  String _unitLabel(String? unit) {
    switch (unit) {
      case 'daily': return 'day';
      case 'weekly': return 'wk';
      case 'monthly': return 'mo';
      default: return 'day';
    }
  }
}
