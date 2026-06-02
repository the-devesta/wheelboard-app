import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../controllers/Professional/assigned_trip_controller.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class TripCompletedScreen extends StatefulWidget {
  final String tripId;
  const TripCompletedScreen({super.key, required this.tripId});

  @override
  State<TripCompletedScreen> createState() => _TripCompletedScreenState();
}

class _TripCompletedScreenState extends State<TripCompletedScreen> {
  Map<String, dynamic>? _tripData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      final res = await ApiClient.instance.get(
        ApiEndpoints.trips.details(widget.tripId),
      );
      if (mounted) {
        setState(() {
          _tripData = res.data is Map<String, dynamic>
              ? res.data as Map<String, dynamic>
              : null;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  double _earnings() {
    if (_tripData == null) return 0;
    final fin = _tripData!['financial'] as Map<String, dynamic>?;
    return ((fin?['driverEarnings'] ?? fin?['tripCost'] ?? 0) as num)
        .toDouble();
  }

  double _distance() {
    if (_tripData == null) return 0;
    final route = _tripData!['route'] as Map<String, dynamic>?;
    return ((route?['plannedDistance'] ?? 0) as num).toDouble();
  }

  String _duration() {
    if (_tripData == null) return 'N/A';
    final route = _tripData!['route'] as Map<String, dynamic>?;
    final secs = (route?['plannedDuration'] as num?)?.toInt() ?? 0;
    if (secs <= 0) return 'N/A';
    final h = secs ~/ 3600;
    final m = (secs % 3600) ~/ 60;
    return h > 0 ? '${h}h ${m}m' : '${m}m';
  }

  String _from() {
    if (_tripData == null) return '';
    return (_tripData!['route']?['startLocation']?['address'] as String?) ?? '';
  }

  String _to() {
    if (_tripData == null) return '';
    return (_tripData!['route']?['endLocation']?['address'] as String?) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF27AE60)))
            : SingleChildScrollView(
                child: Column(
                  children: [
                    // ── celebration header ───────────────────────────
                    _buildHeader(),
                    const SizedBox(height: 24),

                    // ── earnings card ────────────────────────────────
                    _buildEarningsCard(),
                    const SizedBox(height: 16),

                    // ── trip stats ───────────────────────────────────
                    _buildStatsRow(),
                    const SizedBox(height: 16),

                    // ── route summary ────────────────────────────────
                    if (_from().isNotEmpty || _to().isNotEmpty)
                      _buildRouteCard(),

                    const SizedBox(height: 32),

                    // ── CTA buttons ──────────────────────────────────
                    _buildActions(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF27AE60), Color(0xFF2ECC71)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle, color: Colors.white, size: 48),
          ),
          const SizedBox(height: 16),
          Text('Trip Completed! 🎉',
            style: GoogleFonts.poppins(
              fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 8),
          Text('Great job! Your delivery has been confirmed.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14, color: Colors.white.withValues(alpha: 0.9))),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.tripId.toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: Colors.white, letterSpacing: 1.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsCard() {
    final earnings = _earnings();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.currency_rupee, color: Color(0xFF27AE60), size: 32),
        ),
        const SizedBox(width: 20),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trip Earnings',
              style: GoogleFonts.poppins(
                fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
            Text(
              earnings > 0
                ? '₹${earnings.toStringAsFixed(0)}'
                : 'Processing...',
              style: GoogleFonts.poppins(
                fontSize: 32, fontWeight: FontWeight.w800,
                color: const Color(0xFF27AE60)),
            ),
            Text('Earnings credited to your account',
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500])),
          ],
        )),
      ]),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(children: [
        Expanded(child: _statCard(
          icon: Icons.straighten,
          value: _distance() > 0 ? '${_distance().toStringAsFixed(0)} km' : 'N/A',
          label: 'Distance',
          color: const Color(0xFF3B82F6),
        )),
        const SizedBox(width: 12),
        Expanded(child: _statCard(
          icon: Icons.timer_outlined,
          value: _duration(),
          label: 'Duration',
          color: const Color(0xFF8B5CF6),
        )),
      ]),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 8),
        Text(value, style: GoogleFonts.poppins(
          fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937))),
        Text(label, style: GoogleFonts.poppins(
          fontSize: 11, color: Colors.grey[500])),
      ]),
    );
  }

  Widget _buildRouteCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.route, size: 18, color: Color(0xFFFF5E5E)),
            const SizedBox(width: 8),
            Text('Trip Route', style: GoogleFonts.poppins(
              fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1F2937))),
          ]),
          const SizedBox(height: 16),
          _routePoint(_from(), const Color(0xFF27AE60), isStart: true),
          const SizedBox(height: 12),
          _routePoint(_to(), const Color(0xFFFF5E5E), isStart: false),
        ],
      ),
    );
  }

  Widget _routePoint(String address, Color color, {required bool isStart}) {
    return Row(children: [
      Column(children: [
        Container(
          width: 12, height: 12,
          decoration: BoxDecoration(
            color: color, shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.3), width: 4)),
        ),
        if (isStart)
          Container(width: 2, height: 20, color: Colors.grey[200]),
      ]),
      const SizedBox(width: 12),
      Expanded(child: Text(
        address.isEmpty ? 'N/A' : address,
        maxLines: 2, overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(
          fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF374151)),
      )),
    ]);
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _goHome,
            icon: const Icon(Icons.home_outlined, size: 20),
            label: Text('Back to Home',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF27AE60),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _goHome,
            icon: const Icon(Icons.local_shipping_outlined, size: 20),
            label: Text('View All Trips',
              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF27AE60),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              side: const BorderSide(color: Color(0xFF27AE60)),
            ),
          ),
        ),
      ]),
    );
  }

  void _goHome() {
    // Refresh assigned trips so smart router picks up the new state
    if (Get.isRegistered<AssignedTripController>()) {
      Get.find<AssignedTripController>().fetchAssignedTrips();
    }
    // Pop back to the root professional shell
    Get.until((route) => route.isFirst);
  }
}
