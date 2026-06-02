import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../../controllers/Professional/assigned_trip_controller.dart';
import '../../../controllers/Professional/trip_dashboard_controller.dart';
import '../../../models/assigned_trip_model.dart';
import '../TripDetails/TripDetailsScreen.dart';
import '../TrackTrip/TrackTripScreen.dart';
import '../TripProgress/TripProgressScreen.dart';
import '../../../widgets/custom_loader.dart';
import '../../../utils/format_utils.dart';
import '../../../utils/call_utils.dart';

// ── Design tokens (match Home & Fleet exactly) ────────────────────────────────
const _primary   = Color(0xFFF36969);
const _primaryLt = Color(0xFFFFF1F1);
const _bg        = Color(0xFFF9FAFB);
const _card      = Colors.white;
const _textDark  = Color(0xFF111827);
const _textMid   = Color(0xFF374151);
const _textGrey  = Color(0xFF6B7280);
const _border    = Color(0xFFE5E7EB);

class TripDashboardScreen extends StatefulWidget {
  const TripDashboardScreen({super.key});

  @override
  State<TripDashboardScreen> createState() => _TripDashboardScreenState();
}

class _TripDashboardScreenState extends State<TripDashboardScreen>
    with SingleTickerProviderStateMixin {
  String _chartType = 'Trips';

  final AssignedTripController _tripCtrl = Get.find<AssignedTripController>();
  final TripDashboardController _dashCtrl = Get.put(TripDashboardController());

  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    WidgetsBinding.instance.addPostFrameCallback((_) => _fadeCtrl.forward());
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: Obx(() {
            if (_dashCtrl.isLoading.value) {
              return const Center(child: CustomLoader(message: 'Loading dashboard…'));
            }
            final data = _dashCtrl.dashboardData.value;
            if (data == null) {
              return _buildEmptyState();
            }
            return RefreshIndicator(
              color: _primary,
              onRefresh: () async {
                await _dashCtrl.fetchDashboardData();
                await _tripCtrl.fetchAssignedTrips();
              },
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildSliverHeader(),
                  SliverToBoxAdapter(
                    child: Column(children: [
                      const SizedBox(height: 20),
                      _buildStatsStrip(data),
                      const SizedBox(height: 24),
                      _buildChartSection(data.weeklyTrend),
                      const SizedBox(height: 24),
                      _buildActiveSection(),
                      _buildCompletedSection(),
                      const SizedBox(height: 80),
                    ]),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  // ── sliver app bar ────────────────────────────────────────────────────────
  Widget _buildSliverHeader() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: _card,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: _border,
      automaticallyImplyLeading: false,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: _primaryLt, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Iconsax.routing_2, color: _primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Trips Dashboard',
                  style: GoogleFonts.poppins(
                    fontSize: 17, fontWeight: FontWeight.w700,
                    color: _textDark, letterSpacing: -0.2)),
                Text('Your journey summary',
                  style: GoogleFonts.poppins(fontSize: 11, color: _textGrey)),
              ],
            )),
          ]),
        ),
      ),
    );
  }

  // ── stats strip ───────────────────────────────────────────────────────────
  Widget _buildStatsStrip(dynamic data) {
    final cells = [
      _StatCell(
        icon: Iconsax.tick_circle,
        color: const Color(0xFF22C55E), bg: const Color(0xFFF0FDF4),
        label: 'Completed', value: '${data.summary.completedTrips}'),
      _StatCell(
        icon: Iconsax.wallet_3,
        color: const Color(0xFF22C55E), bg: const Color(0xFFF0FDF4),
        label: 'Earnings', value: FormatUtils.formatAmount(data.summary.monthlyEarnings)),
      _StatCell(
        icon: Iconsax.star_1,
        color: const Color(0xFFF59E0B), bg: const Color(0xFFFFFBEB),
        label: 'Rating', value: data.summary.avgRating.toStringAsFixed(1)),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: cells.map((s) => Expanded(child: Padding(
          padding: EdgeInsets.only(right: s == cells.last ? 0 : 10),
          child: _buildStatCard(s),
        ))).toList(),
      ),
    );
  }

  Widget _buildStatCard(_StatCell s) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: _card, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.04), blurRadius: 6,
          offset: const Offset(0, 2))],
      ),
      child: Column(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: s.bg, borderRadius: BorderRadius.circular(10)),
          child: Icon(s.icon, size: 18, color: s.color)),
        const SizedBox(height: 8),
        Text(s.value, style: GoogleFonts.poppins(
          fontSize: 15, fontWeight: FontWeight.w700, color: _textDark)),
        const SizedBox(height: 2),
        Text(s.label, textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 9, color: _textGrey,
            fontWeight: FontWeight.w500),
          maxLines: 1, overflow: TextOverflow.ellipsis),
      ]),
    );
  }

  // ── trend chart ───────────────────────────────────────────────────────────
  Widget _buildChartSection(List<dynamic> trend) {
    List<double> pts;
    Color chartColor;
    String yPre = '', ySuf = '';

    if (_chartType == 'Earnings') {
      pts = trend.map((e) => (e.earnings as num).toDouble()).toList();
      yPre = '₹'; chartColor = const Color(0xFF22C55E);
    } else if (_chartType == 'Distance') {
      pts = trend.map((e) => (e.distance as num).toDouble()).toList();
      ySuf = 'km'; chartColor = _primary;
    } else {
      pts = trend.map((e) => (e.trips as num).toDouble()).toList();
      chartColor = const Color(0xFF3B82F6);
    }

    double maxV = pts.fold(5.0, (p, e) => e > p ? e : p);
    maxV = ((maxV / 5).ceil() * 5.0).clamp(5.0, double.infinity);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _card, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
          boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.04), blurRadius: 8,
            offset: const Offset(0, 2))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Iconsax.chart_2, size: 17, color: Color(0xFF3B82F6))),
            const SizedBox(width: 10),
            Text('Weekly Trend', style: GoogleFonts.poppins(
              fontSize: 14, fontWeight: FontWeight.w700, color: _textDark)),
            const Spacer(),
            ..._chartTypes.map((t) => GestureDetector(
              onTap: () => setState(() => _chartType = t),
              child: Container(
                margin: const EdgeInsets.only(left: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _chartType == t ? _chartTypeColor(t) : _bg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _chartType == t ? _chartTypeColor(t) : _border)),
                child: Text(t, style: GoogleFonts.poppins(
                  fontSize: 10, fontWeight: FontWeight.w600,
                  color: _chartType == t ? Colors.white : _textGrey))),
            )),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: Row(children: [
              // Y-axis labels
              SizedBox(width: 38, child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) {
                  final v = maxV - i * maxV / 5;
                  final label = v >= 1000 ? '${(v/1000).toStringAsFixed(1)}k' : v.toStringAsFixed(0);
                  return Text('$yPre$label$ySuf',
                    style: GoogleFonts.inter(fontSize: 9, color: _textGrey));
                }),
              )),
              const SizedBox(width: 6),
              Expanded(child: Stack(children: [
                // Grid
                Column(children: List.generate(6, (i) => Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6)))),
                  )))),
                // Line
                CustomPaint(
                  size: const Size(double.infinity, double.infinity),
                  painter: _LinePainter(pts, maxV, chartColor)),
              ])),
            ]),
          ),
          const SizedBox(height: 10),
          // X-axis labels
          Padding(
            padding: const EdgeInsets.only(left: 44),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: trend.map((e) => Text(
                (e.dayName as String).substring(0, 3),
                style: GoogleFonts.inter(fontSize: 10, color: _textGrey))).toList(),
            ),
          ),
        ]),
      ),
    );
  }

  static const _chartTypes = ['Trips', 'Earnings', 'Distance'];
  Color _chartTypeColor(String t) {
    if (t == 'Earnings') return const Color(0xFF22C55E);
    if (t == 'Distance') return _primary;
    return const Color(0xFF3B82F6);
  }

  // ── active trips section ──────────────────────────────────────────────────
  Widget _buildActiveSection() {
    return Obx(() {
      final active = _tripCtrl.assignedTrips.where((t) {
        final s = t.tripStatus.toLowerCase();
        return s == 'upcoming' || s == 'active' || s == 'in progress' ||
            s == 'in-progress' || s == 'scheduled' || s == 'draft' ||
            s == 'pending-lr-confirmation' || s == 'awaiting-lr-confirmation' ||
            s == 'lr-confirmed' || s == 'en-route-to-pickup' ||
            s == 'arrived-at-pickup' || s == 'awaiting-pod' || s == 'arrived';
      }).toList();

      if (active.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sectionHeader(Iconsax.routing, 'Active & Upcoming Trips',
            color: _primary),
          const SizedBox(height: 12),
          ...active.map((t) => _TripCard(trip: t, isCompleted: false)),
          const SizedBox(height: 24),
        ]),
      );
    });
  }

  // ── completed trips section ───────────────────────────────────────────────
  Widget _buildCompletedSection() {
    return Obx(() {
      final done = _tripCtrl.assignedTrips.where((t) {
        final s = t.tripStatus.toLowerCase();
        return s == 'completed' || s == 'done' || s == 'finished' || s.contains('complete');
      }).toList();

      if (done.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sectionHeader(Iconsax.tick_circle, 'Recently Completed',
            color: const Color(0xFF22C55E)),
          const SizedBox(height: 12),
          ...done.map((t) => _TripCard(trip: t, isCompleted: true)),
          const SizedBox(height: 24),
        ]),
      );
    });
  }

  Widget _sectionHeader(IconData icon, String title, {required Color color}) {
    return Row(children: [
      Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(9)),
        child: Icon(icon, size: 16, color: color)),
      const SizedBox(width: 10),
      Text(title, style: GoogleFonts.poppins(
        fontSize: 14, fontWeight: FontWeight.w700, color: _textDark)),
    ]);
  }

  Widget _buildEmptyState() {
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 80, height: 80,
        decoration: BoxDecoration(
          color: _primaryLt, borderRadius: BorderRadius.circular(24)),
        child: const Icon(Iconsax.routing_2, color: _primary, size: 36)),
      const SizedBox(height: 20),
      Text('No trip data yet', style: GoogleFonts.poppins(
        fontSize: 18, fontWeight: FontWeight.w700, color: _textDark)),
      const SizedBox(height: 8),
      Text('Accept a trip to see your dashboard.',
        style: GoogleFonts.poppins(fontSize: 13, color: _textGrey)),
    ]));
  }
}

// ── Trip card ─────────────────────────────────────────────────────────────────
class _TripCard extends StatelessWidget {
  final AssignedTrip trip;
  final bool isCompleted;
  const _TripCard({required this.trip, required this.isCompleted});

  bool get _isInProgress {
    final s = trip.tripStatus.toLowerCase();
    return s == 'in progress' || s == 'in-progress' || s == 'active' ||
        s == 'ongoing' || s == 'en-route-to-pickup' || s == 'arrived-at-pickup' ||
        s == 'awaiting-pod' || s == 'arrived';
  }

  Color get _statusColor {
    if (isCompleted)    return const Color(0xFF22C55E);
    if (_isInProgress)  return const Color(0xFF3B82F6);
    return const Color(0xFFF59E0B);
  }
  Color get _statusBg {
    if (isCompleted)    return const Color(0xFFF0FDF4);
    if (_isInProgress)  return const Color(0xFFEFF6FF);
    return const Color(0xFFFFFBEB);
  }
  String get _statusLabel {
    if (isCompleted)    return 'Completed';
    if (_isInProgress)  return 'In Progress';
    return 'Upcoming';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(children: [
        // route
        Row(children: [
          Column(children: [
            _dot(const Color(0xFF22C55E)),
            Container(width: 1.5, height: 20, color: _border),
            _dot(_primary),
          ]),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_short(trip.pickupLocation),
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: _textDark),
                maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 12),
              Text(_short(trip.deliveryLocation),
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: _textDark),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          )),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _statusBg, borderRadius: BorderRadius.circular(16)),
              child: Text(_statusLabel, style: GoogleFonts.poppins(
                fontSize: 10, fontWeight: FontWeight.w700, color: _statusColor))),
            const SizedBox(height: 4),
            Text(trip.tripCode, style: GoogleFonts.poppins(
              fontSize: 10, color: _textGrey)),
          ]),
        ]),
        const SizedBox(height: 12),
        const Divider(color: _border, height: 1),
        const SizedBox(height: 10),

        // meta + actions
        Row(children: [
          if (trip.companyName?.isNotEmpty ?? false)
            Expanded(child: Row(children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: _primaryLt, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Iconsax.building, size: 14, color: _primary)),
              const SizedBox(width: 8),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(trip.companyName!, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 11, fontWeight: FontWeight.w600, color: _textMid)),
                  if (trip.companyMobileNo?.isNotEmpty ?? false)
                    Text(trip.companyMobileNo!,
                      style: GoogleFonts.poppins(fontSize: 10, color: _textGrey)),
                ],
              )),
            ])),
          if (!isCompleted) ...[
            if (trip.companyMobileNo?.isNotEmpty ?? false) ...[
              _iconAction(
                icon: Iconsax.call,
                color: const Color(0xFF3B82F6),
                bg: const Color(0xFFEFF6FF),
                onTap: () => CallUtils.makeCall(trip.companyMobileNo!)),
              const SizedBox(width: 8),
            ],
            _textAction(
              label: _isInProgress ? 'Track' : 'Start Trip',
              color: _isInProgress ? const Color(0xFF3B82F6) : _primary,
              bg: _isInProgress ? const Color(0xFFEFF6FF) : _primaryLt,
              onTap: () {
                if (_isInProgress) {
                  Get.to(() => TrackTripScreen(tripId: trip.tripId));
                } else {
                  Get.to(() => TripProgressScreen(trip: trip));
                }
              }),
          ] else
            _textAction(
              label: 'Details',
              color: _textMid,
              bg: _bg,
              onTap: () => Get.to(() => TripDetailsScreen(trip: trip))),
        ]),
      ]),
    );
  }

  Widget _dot(Color c) => Container(
    width: 10, height: 10,
    decoration: BoxDecoration(color: c, shape: BoxShape.circle,
      border: Border.all(color: c.withValues(alpha: 0.3), width: 3)));

  String _short(String addr) =>
      addr.isEmpty ? 'N/A' : addr.split(',').first.trim();

  Widget _iconAction({required IconData icon, required Color color,
      required Color bg, required VoidCallback onTap}) {
    return GestureDetector(onTap: onTap,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(9)),
        child: Icon(icon, size: 15, color: color)));
  }

  Widget _textAction({required String label, required Color color,
      required Color bg, required VoidCallback onTap}) {
    return GestureDetector(onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(9),
          border: Border.all(color: _border)),
        child: Text(label, style: GoogleFonts.poppins(
          fontSize: 11, fontWeight: FontWeight.w700, color: color))));
  }
}

// ── Line chart painter ────────────────────────────────────────────────────────
class _LinePainter extends CustomPainter {
  final List<double> pts;
  final double maxV;
  final Color color;
  const _LinePainter(this.pts, this.maxV, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (pts.isEmpty) return;
    final linePaint = Paint()
      ..color = color ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke ..strokeCap = StrokeCap.round;
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.25), color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final spacing = pts.length > 1 ? size.width / (pts.length - 1) : 0.0;
    final path = Path(), fill = Path();

    for (var i = 0; i < pts.length; i++) {
      final x = pts.length > 1 ? i * spacing : size.width / 2;
      final y = size.height - (pts[i] / maxV) * size.height;
      if (i == 0) { path.moveTo(x, y); fill.moveTo(x, size.height); fill.lineTo(x, y); }
      else        { path.lineTo(x, y); fill.lineTo(x, y); }
    }
    fill.lineTo(size.width, size.height); fill.close();
    canvas.drawPath(fill, fillPaint);
    canvas.drawPath(path, linePaint);

    for (var i = 0; i < pts.length; i++) {
      final x = pts.length > 1 ? i * spacing : size.width / 2;
      final y = size.height - (pts[i] / maxV) * size.height;
      canvas.drawCircle(Offset(x, y), 4, Paint()..color = Colors.white..style = PaintingStyle.fill);
      canvas.drawCircle(Offset(x, y), 4, linePaint);
    }
  }

  @override
  bool shouldRepaint(_LinePainter o) => o.pts != pts || o.color != color;
}

// ── Data models ───────────────────────────────────────────────────────────────
class _StatCell {
  final IconData icon;
  final Color color, bg;
  final String label, value;
  const _StatCell({required this.icon, required this.color, required this.bg,
    required this.label, required this.value});
}
