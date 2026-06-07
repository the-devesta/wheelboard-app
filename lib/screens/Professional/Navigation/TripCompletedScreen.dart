import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../controllers/Professional/assigned_trip_controller.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../theme/design_system.dart';

/// Post-trip celebration + summary for professionals.
///
/// Logic is unchanged except a fetch fix: `ApiClient.get` returns the decoded
/// body directly, so the previous `res.data` always threw and the summary
/// silently showed "Processing…". We now read the body directly.
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
      final res = await ApiClient.instance.get<dynamic>(
        ApiEndpoints.trips.details(widget.tripId),
      );
      if (mounted) {
        setState(() {
          _tripData = res is Map<String, dynamic> ? res : null;
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
      backgroundColor: AppPalette.bg,
      body: _loading
          ? const AppLoading(message: 'Wrapping up your trip…')
          : SingleChildScrollView(
              child: Column(
                children: [
                  _header(),
                  AppSpacing.vGapXl,
                  _earningsCard(),
                  AppSpacing.vGapLg,
                  _statsRow(),
                  AppSpacing.vGapLg,
                  if (_from().isNotEmpty || _to().isNotEmpty) _routeCard(),
                  const SizedBox(height: AppSpacing.xxxl),
                  _actions(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 44, 24, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF16A34A), Color(0xFF22C55E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                shape: BoxShape.circle),
            child: const Icon(Iconsax.tick_circle, color: Colors.white, size: 46),
          ),
          AppSpacing.vGapLg,
          Text('Trip Completed! 🎉',
              style: AppText.h1.on(Colors.white).size(26).weight(FontWeight.w800)),
          const SizedBox(height: 6),
          Text('Great job! Your delivery has been confirmed.',
              textAlign: TextAlign.center,
              style: AppText.bodySm.on(Colors.white.withValues(alpha: 0.92))),
          AppSpacing.vGapMd,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: AppRadius.rPill),
            child: Text(widget.tripId.toUpperCase(),
                style: AppText.label
                    .on(Colors.white)
                    .weight(FontWeight.w600)
                    .copyWith(letterSpacing: 1.2)),
          ),
        ],
      ),
    );
  }

  Widget _earningsCard() {
    final earnings = _earnings();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: AppPalette.greenBg, borderRadius: AppRadius.rXl),
            child:
                const Icon(Iconsax.money_recive, color: AppPalette.green, size: 30),
          ),
          AppSpacing.hGapLg,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Trip Earnings', style: AppText.label),
                Text(
                  earnings > 0 ? '₹${earnings.toStringAsFixed(0)}' : 'Processing…',
                  style: AppText.h1
                      .on(AppPalette.green)
                      .size(30)
                      .weight(FontWeight.w800),
                ),
                Text('Earnings credited to your account',
                    style: AppText.caption),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _statsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(children: [
        Expanded(
          child: _statCard(
            icon: Iconsax.routing,
            value: _distance() > 0 ? '${_distance().toStringAsFixed(0)} km' : 'N/A',
            label: 'Distance',
            color: AppPalette.blue,
          ),
        ),
        AppSpacing.hGapMd,
        Expanded(
          child: _statCard(
            icon: Iconsax.timer_1,
            value: _duration(),
            label: 'Duration',
            color: AppPalette.purple,
          ),
        ),
      ]),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 22),
        ),
        AppSpacing.vGapSm,
        Text(value, style: AppText.h3),
        Text(label, style: AppText.caption),
      ]),
    );
  }

  Widget _routeCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Iconsax.routing, size: 18, color: AppPalette.primary),
              AppSpacing.hGapSm,
              Text('Trip Route', style: AppText.subtitle),
            ]),
            AppSpacing.vGapLg,
            _routePoint(_from(), AppPalette.green, isStart: true),
            AppSpacing.vGapMd,
            _routePoint(_to(), AppPalette.danger, isStart: false),
          ],
        ),
      ),
    );
  }

  Widget _routePoint(String address, Color color, {required bool isStart}) {
    return Row(children: [
      Column(children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.3), width: 4)),
        ),
        if (isStart) Container(width: 2, height: 20, color: AppPalette.border),
      ]),
      AppSpacing.hGapMd,
      Expanded(
        child: Text(address.isEmpty ? 'N/A' : address,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppText.bodySm.on(AppPalette.textMid)),
      ),
    ]);
  }

  Widget _actions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(children: [
        AppPrimaryButton(
          label: 'Back to Home',
          icon: Iconsax.home_2,
          color: AppPalette.green,
          onPressed: _goHome,
        ),
        AppSpacing.vGapMd,
        AppSecondaryButton(
          label: 'View All Trips',
          icon: Iconsax.truck,
          color: AppPalette.green,
          onPressed: _goHome,
        ),
      ]),
    );
  }

  void _goHome() {
    // Refresh assigned trips so the list reflects the new completed state.
    if (Get.isRegistered<AssignedTripController>()) {
      Get.find<AssignedTripController>().fetchAssignedTrips();
    }
    // Pop back to the root professional shell.
    Get.until((route) => route.isFirst);
  }
}
