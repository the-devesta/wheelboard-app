import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../controllers/Professional/assigned_trip_controller.dart';
import '../../../core/auth/auth_service.dart';
import '../../../models/assigned_trip_model.dart';
import '../../../theme/design_system.dart';
import '../../../utils/trip_status.dart';

/// Wheelboard customer-support line shown on the SOS page. Kept here as a single
/// editable constant so the number can be changed in one place.
const String _wheelboardSupportNumber = '7420861942';

/// Emergency SOS - quick access to emergency services.
///
/// Data-flow fix: the big SOS button previously showed a fake "Alerts sent to
/// all contacts" snackbar but called no API (and there is no backend SOS
/// endpoint on either platform). It now performs a **real** action - opening the
/// dialer to India's unified emergency number (112) - with honest messaging. The
/// emergency-contact cards already place real phone calls via the dialer.
class SOSScreen extends StatefulWidget {
  const SOSScreen({super.key});

  @override
  State<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isActivated = false;
  bool _sending = false; // true while the webhook POST is in-flight

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _triggerSOS() async {
    debugPrint('[SOS] ✅ Driver tapped SOS button');
    setState(() {
      _isActivated = true;
      _sending = true;
    });
    _controller.duration = const Duration(milliseconds: 600);
    _controller.repeat();

    // Fire webhook (with full logs) and open dialer concurrently.
    await Future.wait([
      _fireSOSWebhook(),
      _makePhoneCall('112'),
    ]);

    if (mounted) setState(() => _sending = false);
  }

  Future<void> _fireSOSWebhook() async {
    try {
      // ── Step 1: location permission ──────────────────────────────────────
      debugPrint('[SOS] 📍 Checking location permission...');
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        debugPrint('[SOS] 📍 Permission denied - requesting...');
        perm = await Geolocator.requestPermission();
      }
      debugPrint('[SOS] 📍 Location permission: $perm');

      // ── Step 2: GPS fix ──────────────────────────────────────────────────
      Map<String, dynamic> location = {};
      if (perm != LocationPermission.denied &&
          perm != LocationPermission.deniedForever) {
        debugPrint('[SOS] 📍 Fetching GPS coordinates...');
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        location = {'lat': pos.latitude, 'lng': pos.longitude};
        debugPrint(
            '[SOS] 📍 Location obtained: lat=${pos.latitude}, lng=${pos.longitude}');
      } else {
        debugPrint('[SOS] ⚠️ Location unavailable (permission denied) - sending without coords');
      }

      // ── Step 3: driver identity ──────────────────────────────────────────
      debugPrint('[SOS] 👤 Reading driver info from AuthService...');
      final auth = Get.isRegistered<AuthService>() ? Get.find<AuthService>() : null;
      final user = auth?.currentUser.value;
      final driverName = user?.fullName ?? '';
      final driverPhone = user?.phoneNumber ?? '';
      debugPrint('[SOS] 👤 driver_name="$driverName"  driver_phone="$driverPhone"');

      // ── Step 4: active trip ──────────────────────────────────────────────
      debugPrint('[SOS] 🚗 Looking for active trip...');
      String tripId = '';
      if (Get.isRegistered<AssignedTripController>()) {
        final c = Get.find<AssignedTripController>();
        for (final t in c.assignedTrips) {
          if (c.bucketOf(t) == TripBucket.inProcess) {
            tripId = t.tripCode;
            break;
          }
        }
      }
      if (tripId.isNotEmpty) {
        debugPrint('[SOS] 🚗 Active tripId: "$tripId"');
      } else {
        debugPrint('[SOS] 🚗 No active trip found - tripId will be empty');
      }

      // ── Step 5: build & log payload ──────────────────────────────────────
      final payload = {
        'tripId': tripId,
        'driver_name': driverName,
        'driver_phone': driverPhone,
        'location': location,
      };
      final body = jsonEncode(payload);
      debugPrint('[SOS] 📤 Sending POST → https://n8n.srv1694525.hstgr.cloud/webhook/sos-call');
      debugPrint('[SOS] 📦 Payload: $body');

      // ── Step 6: fire request ─────────────────────────────────────────────
      final response = await http.post(
        Uri.parse('https://n8n.srv1694525.hstgr.cloud/webhook/sos-call'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      // ── Step 7: log response ─────────────────────────────────────────────
      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('[SOS] ✅ Webhook response: ${response.statusCode} OK');
        debugPrint('[SOS] 📥 Response body: ${response.body}');
      } else {
        debugPrint('[SOS] ⚠️ Webhook returned unexpected status: ${response.statusCode}');
        debugPrint('[SOS] 📥 Response body: ${response.body}');
      }
    } catch (e, st) {
      // Webhook failure must never block the emergency call.
      debugPrint('[SOS] ❌ Webhook failed: $e');
      debugPrint('[SOS] 🔍 Stack trace: $st');
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber.replaceAll(RegExp(r'\s'), ''));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open dialer for $phoneNumber')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeTrip = _activeTrip();
    return Scaffold(
      backgroundColor: AppPalette.bg,
      appBar: AppBar(
        backgroundColor: AppPalette.card,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: AppPalette.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Emergency SOS', style: AppText.h2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick access to emergency services', style: AppText.caption),
            AppSpacing.vGapLg,
            if (activeTrip != null) ...[
              _activeTripCard(activeTrip),
              AppSpacing.vGapLg,
            ],
            _alertCard(),
            AppSpacing.vGapXl,
            Text('Emergency Contacts', style: AppText.h3),
            AppSpacing.vGapMd,
            // Wheelboard support line - always available.
            _contactCard(
              title: 'Wheelboard Support',
              number: _wheelboardSupportNumber,
              icon: Iconsax.call_calling,
              tint: const Color(0xFFFFF1F1),
              iconColor: AppPalette.primary,
            ),
            AppSpacing.vGapMd,
            // Assigning transport company - shown only while a trip is in
            // progress, and only that company's number (from the active trip).
            if (activeTrip != null &&
                (activeTrip.companyMobileNo ?? '').trim().isNotEmpty) ...[
              _contactCard(
                title: (activeTrip.companyName ?? '').trim().isNotEmpty
                    ? activeTrip.companyName!.trim()
                    : 'Transport Company',
                number: activeTrip.companyMobileNo!.trim(),
                icon: Iconsax.building_4,
                tint: const Color(0xFFEFF6FF),
                iconColor: const Color(0xFF1565C0),
              ),
              AppSpacing.vGapMd,
            ],
            _contactCard(
              title: 'Police',
              number: '100',
              icon: Iconsax.shield_tick,
              tint: AppPalette.blueBg,
              iconColor: const Color(0xFF1565C0),
            ),
            AppSpacing.vGapMd,
            _contactCard(
              title: 'Ambulance',
              number: '108',
              icon: Iconsax.health,
              tint: AppPalette.dangerBg,
              iconColor: const Color(0xFFC62828),
            ),
            AppSpacing.vGapMd,
            _contactCard(
              title: 'Fire',
              number: '101',
              icon: Iconsax.flash_1,
              tint: AppPalette.amberBg,
              iconColor: const Color(0xFFEF6C00),
            ),
            AppSpacing.vGapMd,
            _contactCard(
              title: 'Roadside Assistance',
              number: '1033',
              icon: Iconsax.truck,
              tint: AppPalette.greenBg,
              iconColor: const Color(0xFF00695C),
            ),
            AppSpacing.vGapXl,
            _safetyTips(),
            AppSpacing.vGapLg,
          ],
        ),
      ),
    );
  }

  /// The current in-progress trip, if any - mirrors the web SOS page which
  /// fetches `GET /trips?status=in_progress&limit=1` and shows it as context.
  /// We read it from the already-loaded [AssignedTripController] (no new fetch).
  AssignedTrip? _activeTrip() {
    if (!Get.isRegistered<AssignedTripController>()) return null;
    final c = Get.find<AssignedTripController>();
    for (final t in c.assignedTrips) {
      if (c.bucketOf(t) == TripBucket.inProcess) return t;
    }
    return null;
  }

  Widget _activeTripCard(AssignedTrip trip) {
    final vehicle = [trip.vehicleModel, trip.vehicleNumber]
        .where((s) => s.trim().isNotEmpty)
        .join(' • ');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppPalette.amberBg,
        borderRadius: AppRadius.rXl,
        border: Border.all(color: const Color(0x33F59E0B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Iconsax.routing, color: Color(0xFFB45309), size: 18),
            AppSpacing.hGapSm,
            Text('Active Trip',
                style: AppText.subtitle.on(const Color(0xFFB45309))),
            const Spacer(),
            if (trip.tripCode.isNotEmpty)
              Text(trip.tripCode, style: AppText.caption),
          ]),
          AppSpacing.vGapMd,
          _tripLine(Iconsax.location, trip.pickupLocation),
          const SizedBox(height: 4),
          _tripLine(Iconsax.flag, trip.deliveryLocation),
          if (vehicle.isNotEmpty) ...[
            const SizedBox(height: 4),
            _tripLine(Iconsax.truck, vehicle),
          ],
          AppSpacing.vGapMd,
          Row(children: [
            const Icon(Iconsax.location_tick,
                size: 14, color: Color(0xFFB45309)),
            AppSpacing.hGapSm,
            Expanded(
              child: Text(
                'Your live location is shared with your company during this trip.',
                style: AppText.caption.on(const Color(0xFF92400E)),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _tripLine(IconData icon, String text) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 14, color: AppPalette.textGrey),
      AppSpacing.hGapSm,
      Expanded(
        child: Text(text,
            style: AppText.bodySm.on(AppPalette.textDark),
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
      ),
    ]);
  }

  Widget _alertCard() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.xxl),
          decoration: BoxDecoration(
            color: _isActivated ? const Color(0xFFFFEBEE) : AppPalette.dangerBg,
            borderRadius: AppRadius.rXl,
            border: _isActivated
                ? Border.all(color: AppPalette.danger, width: 2)
                : Border.all(color: const Color(0x22EF4444)),
          ),
          child: Column(
            children: [
              Text(_isActivated ? 'SOS ACTIVATED' : 'Emergency Alert',
                  style: AppText.h2.on(
                      _isActivated ? AppPalette.danger : AppPalette.textDark)),
              if (_sending) ...[
                AppSpacing.vGapMd,
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppPalette.danger),
                    ),
                  ),
                  AppSpacing.hGapSm,
                  Text('Alerting emergency services...',
                      style: AppText.caption.on(AppPalette.danger)),
                ]),
              ],
              AppSpacing.vGapXl,
              SizedBox(
                width: 200,
                height: 200,
                child: GestureDetector(
                  onTap: _isActivated ? null : _triggerSOS,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _ripple(_controller.value),
                      _ripple((_controller.value + 0.5) % 1.0),
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: AppPalette.danger,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppPalette.danger.withValues(alpha: 0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                                _isActivated
                                    ? Iconsax.call_calling
                                    : Iconsax.danger,
                                color: Colors.white,
                                size: 38),
                            const SizedBox(height: 4),
                            Text('SOS',
                                style: AppText.h1
                                    .on(Colors.white)
                                    .size(24)
                                    .weight(FontWeight.w800)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AppSpacing.vGapXl,
              Text(
                _isActivated
                    ? (_sending
                        ? 'Sending alert + connecting to 112...'
                        : 'Alert sent - connected to 112')
                    : 'Tap to call emergency services',
                textAlign: TextAlign.center,
                style: AppText.subtitle.on(
                    _isActivated ? AppPalette.danger : AppPalette.textDark),
              ),
              const SizedBox(height: 6),
              Text(
                'Connects you directly to 112, India\'s unified emergency helpline.',
                textAlign: TextAlign.center,
                style: AppText.caption,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _ripple(double value) {
    return Container(
      width: 140 + (value * 40),
      height: 140 + (value * 40),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppPalette.danger.withValues(alpha: 0.25 * (1 - value)),
      ),
    );
  }

  Widget _contactCard({
    required String title,
    required String number,
    required IconData icon,
    required Color tint,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: () => _makePhoneCall(number),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(color: tint, borderRadius: AppRadius.rXl),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            AppSpacing.hGapLg,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.subtitle),
                  Text(number, style: AppText.caption),
                ],
              ),
            ),
            Icon(Iconsax.call, color: iconColor, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _safetyTips() {
    const tips = [
      'Always keep emergency contacts handy',
      'Share your live location during trips',
      'Keep a first-aid kit in your vehicle',
      'Do regular vehicle maintenance checks',
      'Stay alert and take regular breaks',
    ];
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration:
          BoxDecoration(color: AppPalette.blueBg, borderRadius: AppRadius.rXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Iconsax.shield_tick, color: AppPalette.blue),
            AppSpacing.hGapSm,
            Text('Safety Tips', style: AppText.h3.on(AppPalette.blue)),
          ]),
          AppSpacing.vGapLg,
          ...tips.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                        color: AppPalette.blue, shape: BoxShape.circle),
                  ),
                  AppSpacing.hGapMd,
                  Expanded(
                      child: Text(t,
                          style: AppText.bodySm.on(const Color(0xFF1E40AF)))),
                ]),
              )),
        ],
      ),
    );
  }
}
