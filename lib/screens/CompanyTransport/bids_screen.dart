import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'driver/view_driver_screen.dart';
import 'trip/assign_trip_screen.dart';
import '../../controllers/Transport/trip_bids_controller.dart';
import '../../models/trip_bid_model.dart';

class BidsScreen extends StatefulWidget {
  final String tripId;
  const BidsScreen({super.key, required this.tripId});

  @override
  State<BidsScreen> createState() => _BidsScreenState();
}

class _BidsScreenState extends State<BidsScreen> {
  final TripBidsController bidsController = Get.put(TripBidsController());
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    bidsController.fetchTripBids(widget.tripId);
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFFF5E5E)),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          'Trip Bids',
          style: GoogleFonts.poppins(
            fontSize: 18, fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFFF5E5E)),
            onPressed: () => bidsController.refreshBids(widget.tripId),
          ),
        ],
      ),
      body: Obx(() {
        if (bidsController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF5E5E)));
        }

        // Sort bids by amount ascending (cheapest = Best Value)
        final allBids = List<TripBid>.from(bidsController.bids)
          ..sort((a, b) => a.bidAmount.compareTo(b.bidAmount));

        final filteredBids = _searchQuery.isEmpty
            ? allBids
            : allBids.where((b) =>
                b.name.toLowerCase().contains(_searchQuery) ||
                b.contactNumber.contains(_searchQuery)).toList();

        return CustomScrollView(
          slivers: [
            // ── analytics banner ────────────────────────────────────
            SliverToBoxAdapter(
              child: _buildAnalyticsBanner(allBids),
            ),

            // ── search bar ───────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: _buildSearchBar(),
              ),
            ),

            // ── heading ──────────────────────────────────────────────
            if (filteredBids.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Row(children: [
                    Text('${filteredBids.length} Bid${filteredBids.length == 1 ? '' : 's'} Received',
                      style: GoogleFonts.poppins(
                        fontSize: 14, fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937))),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(10)),
                      child: Text('Sorted by lowest',
                        style: GoogleFonts.poppins(
                          fontSize: 10, fontWeight: FontWeight.w500,
                          color: const Color(0xFF059669))),
                    ),
                  ]),
                ),
              ),

            // ── bids list ────────────────────────────────────────────
            if (filteredBids.isEmpty)
              SliverFillRemaining(
                child: _buildEmptyState(allBids.isEmpty),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildBidCard(
                        bid: filteredBids[i],
                        rank: allBids.indexOf(filteredBids[i]) + 1,
                        isBestValue: allBids.indexOf(filteredBids[i]) == 0,
                      ),
                    ),
                    childCount: filteredBids.length,
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  // ── analytics banner ─────────────────────────────────────────────────
  Widget _buildAnalyticsBanner(List<TripBid> bids) {
    if (bids.isEmpty) return const SizedBox.shrink();

    final lowest = bids.first.bidAmount;
    final highest = bids.last.bidAmount;
    final avg = bids.map((b) => b.bidAmount).reduce((a, b) => a + b) /
        bids.length;
    final spread = highest - lowest;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF5E5E), Color(0xFFE83E3E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF5E5E).withValues(alpha: 0.3),
            blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12)),
              child: const Icon(
                Icons.analytics_outlined,
                color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bid Analytics',
                  style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w700,
                    color: Colors.white)),
                Text('${bids.length} bid${bids.length == 1 ? '' : 's'} received · sorted lowest first',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.85))),
              ],
            )),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _statPill(
              '₹${lowest.toStringAsFixed(0)}',
              'Lowest Bid',
              Icons.arrow_downward,
              Colors.white,
            )),
            const SizedBox(width: 8),
            Expanded(child: _statPill(
              '₹${avg.toStringAsFixed(0)}',
              'Average Bid',
              Icons.show_chart,
              Colors.white,
            )),
            const SizedBox(width: 8),
            Expanded(child: _statPill(
              '₹${spread.toStringAsFixed(0)}',
              'Spread',
              Icons.swap_vert,
              Colors.white,
            )),
          ]),
        ],
      ),
    );
  }

  Widget _statPill(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 4),
        Text(value,
          style: GoogleFonts.poppins(
            fontSize: 14, fontWeight: FontWeight.w700, color: color)),
        Text(label,
          style: GoogleFonts.poppins(
            fontSize: 9, color: color.withValues(alpha: 0.85))),
      ]),
    );
  }

  // ── search bar ────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by driver name or contact...',
          hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[400], size: 18),
                  onPressed: () => _searchController.clear())
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  // ── empty state ───────────────────────────────────────────────────────
  Widget _buildEmptyState(bool noBidsAtAll) {
    return Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          noBidsAtAll ? Icons.inbox_outlined : Icons.search_off,
          size: 64, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text(
          noBidsAtAll ? 'No bids yet' : 'No matching bids',
          style: GoogleFonts.poppins(
            fontSize: 16, fontWeight: FontWeight.w600,
            color: Colors.grey[600])),
        const SizedBox(height: 8),
        Text(
          noBidsAtAll
              ? 'Professionals haven\'t placed any bids yet.'
              : 'Try adjusting your search.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[400])),
      ],
    ));
  }

  // ── bid card ──────────────────────────────────────────────────────────
  Widget _buildBidCard({
    required TripBid bid,
    required int rank,
    required bool isBestValue,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isBestValue
            ? Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4), width: 1.5)
            : Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── photo header ─────────────────────────────────────────
          Stack(children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: SizedBox(
                height: 180, width: double.infinity,
                child: _driverImage(bid),
              ),
            ),
            // Rank badge
            Positioned(
              top: 12, left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20)),
                child: Text('Rank #$rank',
                  style: GoogleFonts.poppins(
                    fontSize: 11, fontWeight: FontWeight.w700,
                    color: Colors.white)),
              ),
            ),
            // Best value badge
            if (isBestValue)
              Positioned(
                top: 12, right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(20)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.star, color: Colors.white, size: 13),
                    const SizedBox(width: 4),
                    Text('Best Value',
                      style: GoogleFonts.poppins(
                        fontSize: 11, fontWeight: FontWeight.w700,
                        color: Colors.white)),
                  ]),
                ),
              ),
          ]),

          // ── body ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Driver name + bid amount
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Flexible(child: Text(bid.name.isNotEmpty ? bid.name : 'Driver',
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.w700,
                              color: const Color(0xFF1F2937)))),
                          if (bid.isVerified) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.verified, size: 15, color: Color(0xFF3B82F6)),
                          ],
                        ]),
                        const SizedBox(height: 2),
                        // rating · trips · experience
                        Row(children: [
                          const Icon(Icons.star, size: 13, color: Color(0xFFF59E0B)),
                          const SizedBox(width: 3),
                          Text(bid.rating.toStringAsFixed(1),
                            style: GoogleFonts.poppins(
                              fontSize: 12, fontWeight: FontWeight.w600,
                              color: Colors.grey[700])),
                          const SizedBox(width: 8),
                          Text('${bid.totalTrips} trips',
                            style: GoogleFonts.poppins(
                              fontSize: 11, color: Colors.grey[500])),
                        ]),
                        if (bid.contactNumber.isNotEmpty &&
                            bid.contactNumber != 'Not available')
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Row(children: [
                              Icon(Icons.phone, size: 12, color: Colors.grey[400]),
                              const SizedBox(width: 4),
                              Text(bid.contactNumber,
                                style: GoogleFonts.poppins(
                                  fontSize: 12, color: Colors.grey[500])),
                            ]),
                          ),
                      ],
                    )),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Bid Amount',
                          style: GoogleFonts.poppins(
                            fontSize: 10, color: Colors.grey[400])),
                        Text(
                          '₹${bid.bidAmount.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(
                            fontSize: 22, fontWeight: FontWeight.w800,
                            color: const Color(0xFFFF5E5E))),
                      ],
                    ),
                  ],
                ),

                // Description
                if (bid.bidDescription.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[100]!)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.format_quote, size: 16,
                          color: Colors.grey[400]),
                        const SizedBox(width: 8),
                        Expanded(child: Text(bid.bidDescription,
                          style: GoogleFonts.poppins(
                            fontSize: 12, color: Colors.grey[600]))),
                      ],
                    ),
                  ),
                ],

                // Date
                if (bid.dateEntered != null) ...[
                  const SizedBox(height: 8),
                  Row(children: [
                    Icon(Icons.access_time, size: 12, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(
                      'Bid placed ${_formatDate(bid.dateEntered!)}',
                      style: GoogleFonts.poppins(
                        fontSize: 11, color: Colors.grey[400])),
                  ]),
                ],

                const SizedBox(height: 16),

                // Action buttons
                Row(children: [
                  Expanded(child: OutlinedButton.icon(
                    onPressed: () => Get.to(() => ViewDriverScreen(
                      driverId: bid.driverId,
                      tripId: widget.tripId,
                      bidId: bid.bidId,
                      isProfessional: true,
                    )),
                    icon: const Icon(Icons.person_search_outlined, size: 16),
                    label: Text('View Profile',
                      style: GoogleFonts.poppins(
                        fontSize: 12, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFF5E5E),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFFFF5E5E)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    ),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: ElevatedButton.icon(
                    onPressed: () => Get.to(() => AssignTripScreen(
                      tripId: bid.tripId.isNotEmpty
                          ? bid.tripId
                          : widget.tripId,
                      bidId: bid.bidId,
                    )),
                    icon: const Icon(
                      Icons.assignment_turned_in_outlined, size: 16),
                    label: Text('Assign Trip',
                      style: GoogleFonts.poppins(
                        fontSize: 12, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5E5E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  )),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── helpers ───────────────────────────────────────────────────────────
  Widget _driverImage(TripBid bid) {
    if (bid.avatar.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: bid.avatar,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          color: Colors.grey[100],
          child: const Center(child: CircularProgressIndicator(
            strokeWidth: 1.5, color: Color(0xFFFF5E5E)))),
        errorWidget: (_, __, ___) => _initialsPlaceholder(bid.name),
      );
    }
    return _initialsPlaceholder(bid.name);
  }

  Widget _initialsPlaceholder(String name) {
    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').map((n) => n.isNotEmpty ? n[0] : '')
            .take(2).join().toUpperCase()
        : 'DR';
    return Container(
      color: const Color(0xFFEBF4FF),
      child: Center(child: Text(initials,
        style: const TextStyle(
          fontSize: 64, fontWeight: FontWeight.bold,
          color: Color(0xFF2F80ED), letterSpacing: 2))),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
