import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;

import '../../../controllers/Professional/assigned_trip_controller.dart';
import '../../../controllers/Professional/trip_navigation_controller.dart';
import '../../../models/assigned_trip_model.dart';
import '../../../utils/call_utils.dart';
import '../Navigation/PodCollectionScreen.dart';
import '../Navigation/TripCompletedScreen.dart';

// ── Design tokens (match Home & Fleet) ────────────────────────────────────────
const _primary   = Color(0xFFF36969);
const _primaryLt = Color(0xFFFFF1F1);
const _bg        = Color(0xFFF9FAFB);
const _card      = Colors.white;
const _textDark  = Color(0xFF111827);
const _textGrey  = Color(0xFF6B7280);
const _border    = Color(0xFFE5E7EB);

class TrackTripScreen extends StatefulWidget {
  final String tripId;
  const TrackTripScreen({super.key, required this.tripId});

  @override
  State<TrackTripScreen> createState() => _TrackTripScreenState();
}

class _TrackTripScreenState extends State<TrackTripScreen> {
  final Set<Marker> _markers = {};
  LatLng? _destination;
  GoogleMapController? _mapController;

  late TripNavigationController _navController;

  // OTP controllers
  final _otpController = TextEditingController();
  final _startOtpController = TextEditingController();
  final _completionReasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _navController = Get.put(TripNavigationController());
    final assignedCtrl = Get.find<AssignedTripController>();

    final trips = assignedCtrl.assignedTrips;
    final trip = trips.firstWhereOrNull((t) => t.tripId == widget.tripId);
    if (trip != null) {
      _navController.initFromStatus(trip.tripStatus);

      if (trip.latitude != null && trip.latitude != 0 &&
          trip.longitude != null && trip.longitude != 0) {
        _setDestMarker(LatLng(trip.latitude!, trip.longitude!));
      } else {
        _geocodeDestination(trip.deliveryLocation);
      }

      // Start GPS automatically for active trips
      final step = _navController.currentStep.value;
      if (step == TripStep.inTransit ||
          step == TripStep.navigatingToPickup ||
          step == TripStep.atPickup) {
        _navController.startTrackingForTrip(widget.tripId);
      }
    }

    ever(_navController.currentPosition, (Position? pos) {
      if (pos != null && mounted) {
        final ll = LatLng(pos.latitude, pos.longitude);
        setState(() {
          _markers.removeWhere((m) => m.markerId.value == 'current_pos');
          _markers.add(Marker(
            markerId: const MarkerId('current_pos'),
            position: ll,
            infoWindow: const InfoWindow(title: 'You are here'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ));
        });
        _mapController?.animateCamera(CameraUpdate.newLatLng(ll));
      }
    });
  }

  void _setDestMarker(LatLng pos) {
    if (!mounted) return;
    setState(() {
      _destination = pos;
      _markers.add(Marker(
        markerId: const MarkerId('destination'),
        position: pos,
        infoWindow: const InfoWindow(title: 'Destination'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
    });
  }

  Future<void> _geocodeDestination(String address) async {
    if (address.isEmpty) return;
    try {
      final locs = await geo.locationFromAddress(address);
      if (locs.isNotEmpty) {
        _setDestMarker(LatLng(locs.first.latitude, locs.first.longitude));
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _navController.stopTracking();
    _otpController.dispose();
    _startOtpController.dispose();
    _completionReasonController.dispose();
    super.dispose();
  }

  // ── step label helpers ────────────────────────────────────────────────
  String _stepLabel(TripStep step) {
    switch (step) {
      case TripStep.confirmOtp:       return 'Awaiting Confirmation';
      case TripStep.readyToStart:     return 'Ready to Start';
      case TripStep.navigatingToPickup: return 'En Route to Pickup';
      case TripStep.atPickup:         return 'At Pickup';
      case TripStep.inTransit:        return 'In Transit';
      case TripStep.atDestination:    return 'At Destination';
      case TripStep.podUpload:        return 'Upload POD';
      case TripStep.completed:        return 'Completed';
    }
  }

  Color _stepColor(TripStep step) {
    switch (step) {
      case TripStep.confirmOtp:       return const Color(0xFFF59E0B);
      case TripStep.readyToStart:     return const Color(0xFF3B82F6);
      case TripStep.navigatingToPickup: return const Color(0xFF8B5CF6);
      case TripStep.atPickup:         return const Color(0xFF06B6D4);
      case TripStep.inTransit:        return const Color(0xFF10B981);
      case TripStep.atDestination:    return _primary;
      case TripStep.podUpload:        return _primary;
      case TripStep.completed:        return const Color(0xFF27AE60);
    }
  }

  @override
  Widget build(BuildContext context) {
    final assignedCtrl = Get.find<AssignedTripController>();

    return Scaffold(
      backgroundColor: _card,
      body: SafeArea(
        child: Obx(() {
          final trip = assignedCtrl.assignedTrips.firstWhereOrNull(
            (t) => t.tripId == widget.tripId,
          ) ?? AssignedTrip(
            tripId: widget.tripId,
            userId: '', vehicleId: '', vehicleNumber: '',
            vehicleModel: '', vehicleType: '', driverId: '',
            driverName: 'Loading...', driverContact: '',
            pickupLocation: '', deliveryLocation: '',
            pickupDate: DateTime.now(), pickupTime: '',
            specialInstructions: '', payRange: '',
            tripCode: '', tripStatus: 'scheduled',
            createdDate: DateTime.now(), totalBidCount: 0,
          );

          final step = _navController.currentStep.value;

          return Column(
            children: [
              _buildTopBar(trip),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.38,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _destination ?? const LatLng(28.5581811, 77.344654),
                    zoom: 13,
                  ),
                  onMapCreated: (c) => _mapController = c,
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  mapType: MapType.normal,
                  style: _mapStyle,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: _buildDetailsContent(trip, step),
                ),
              ),
              _buildBottomBar(trip, step),
            ],
          );
        }),
      ),
    );
  }

  // ── top bar ───────────────────────────────────────────────────────────
  Widget _buildTopBar(AssignedTrip trip) {
    return Obx(() {
      final step = _navController.currentStep.value;
      final color = _stepColor(step);
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back_ios_new, color: _primary, size: 20),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    trip.tripCode.isNotEmpty ? trip.tripCode : trip.tripId,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 14, fontWeight: FontWeight.w700,
                      color: _textDark,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _stepLabel(step),
                      style: GoogleFonts.poppins(
                        fontSize: 10, fontWeight: FontWeight.w600, color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: _primaryLt,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: () => _navController.startTrackingForTrip(trip.tripId),
                icon: const Icon(Icons.refresh, color: _primary, size: 20),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ── details content ───────────────────────────────────────────────────
  Widget _buildDetailsContent(AssignedTrip trip, TripStep step) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // progress row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('On the way',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937))),
                  Text('${trip.vehicleNumber} (${trip.vehicleModel})',
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 10, color: _primary, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Obx(() => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(20)),
              child: Text('${(_navController.progress.value * 100).toStringAsFixed(0)}% Done',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF1976D2))),
            )),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() => ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: _navController.progress.value,
            backgroundColor: _border,
            valueColor: AlwaysStoppedAnimation<Color>(_stepColor(_navController.currentStep.value)),
            minHeight: 6,
          ),
        )),
        const SizedBox(height: 16),

        // ETA + distance
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            Obx(() => _infoCard('ETA', _navController.eta.value, Icons.timer_outlined)),
            Obx(() => _infoCard('Distance', _navController.distanceRemaining.value, Icons.straighten)),
          ],
        ),
        const SizedBox(height: 10),

        _infoCard('Company',
          '${trip.companyName ?? "Transport Co."} • ${trip.companyMobileNo ?? trip.driverContact}',
          Icons.business_outlined),
        const SizedBox(height: 12),

        // route
        Text('TRIP ROUTE',
          style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600,
            color: Colors.grey[400], letterSpacing: 1.1)),
        const SizedBox(height: 8),
        _routeItem('Pickup Location', trip.pickupLocation, const Color(0xFF2E7D32), isStart: true),
        const SizedBox(height: 12),
        _routeItem('Delivery Destination', trip.deliveryLocation, _primary, isStart: false),

        if (trip.specialInstructions.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('INSTRUCTIONS',
            style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600,
              color: Colors.grey[400], letterSpacing: 1.1)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFEDD5)),
            ),
            child: Text(trip.specialInstructions,
              style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF9A3412))),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  // ── bottom action bar ─────────────────────────────────────────────────
  Widget _buildBottomBar(AssignedTrip trip, TripStep step) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Obx(() {
        final s = _navController.currentStep.value;
        return _stepActions(trip, s);
      }),
    );
  }

  Widget _stepActions(AssignedTrip trip, TripStep step) {
    switch (step) {
      case TripStep.confirmOtp:
        return _primaryButton(
          icon: Icons.lock_open,
          label: 'Confirm Trip with OTP',
          color: const Color(0xFFF59E0B),
          onTap: () => _showOtpModal(trip.tripId, isLrConfirmation: true),
        );

      case TripStep.readyToStart:
        return Column(children: [
          _primaryButton(
            icon: Icons.play_circle_fill,
            label: 'Start Trip',
            color: const Color(0xFF10B981),
            onTap: () => _showStartTripModal(trip),
          ),
        ]);

      case TripStep.navigatingToPickup:
        return Row(children: [
          Expanded(
            flex: 2,
            child: _outlineButton(
              icon: Icons.call,
              label: 'Call Company',
              onTap: () => CallUtils.makeCall(trip.companyMobileNo ?? trip.driverContact),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: _primaryButton(
              icon: Icons.location_on,
              label: 'Arrived at Pickup',
              color: const Color(0xFF8B5CF6),
              onTap: () => _navController.arriveAtPickup(trip.tripId),
            ),
          ),
        ]);

      case TripStep.atPickup:
        return Row(children: [
          Expanded(
            flex: 2,
            child: _outlineButton(
              icon: Icons.call,
              label: 'Call Company',
              onTap: () => CallUtils.makeCall(trip.companyMobileNo ?? trip.driverContact),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: _primaryButton(
              icon: Icons.local_shipping,
              label: 'Start Trip',
              color: const Color(0xFF10B981),
              onTap: () => _showStartTripModal(trip),
            ),
          ),
        ]);

      case TripStep.inTransit:
        return Row(children: [
          Expanded(
            flex: 2,
            child: _outlineButton(
              icon: Icons.call,
              label: 'Call Company',
              onTap: () => CallUtils.makeCall(trip.companyMobileNo ?? trip.driverContact),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Obx(() => ElevatedButton(
              onPressed: _navController.isLoading.value ? null : () => _showArrivalConfirmDialog(trip),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _navController.isLoading.value
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text('Arrived at Drop-off',
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
            )),
          ),
        ]);

      case TripStep.atDestination:
      case TripStep.podUpload:
        return _primaryButton(
          icon: Icons.upload_file,
          label: 'Upload Proof of Delivery',
          color: const Color(0xFF7C3AED),
          onTap: () => Get.to(
            () => PodCollectionScreen(tripId: trip.tripId),
            transition: Transition.rightToLeft,
          )?.then((_) {
            // Refresh status after returning from POD screen
            final step2 = _navController.currentStep.value;
            if (step2 == TripStep.completed) {
              _goToCompletedScreen(trip);
            }
          }),
        );

      case TripStep.completed:
        return _primaryButton(
          icon: Icons.check_circle,
          label: 'View Trip Summary',
          color: const Color(0xFF27AE60),
          onTap: () => _goToCompletedScreen(trip),
        );
    }
  }

  void _goToCompletedScreen(AssignedTrip trip) {
    Get.off(
      () => TripCompletedScreen(tripId: trip.tripId),
      transition: Transition.rightToLeft,
    );
  }

  // ── modals ────────────────────────────────────────────────────────────
  void _showOtpModal(String tripId, {bool isLrConfirmation = false}) {
    _otpController.clear();
    _navController.otpError.value = null;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _OtpSheet(
          title: isLrConfirmation ? 'Confirm Trip Assignment' : 'Confirm OTP',
          subtitle: 'Enter the 6-digit OTP from your notification to confirm this trip.',
          controller: _otpController,
          isLoading: _navController.isConfirmingOtp,
          error: _navController.otpError,
          onConfirm: () async {
            final nav = Navigator.of(ctx);
            final ok = await _navController.confirmOtp(tripId, _otpController.text.trim());
            if (ok) nav.pop();
          },
          onCancel: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
  }

  void _showStartTripModal(AssignedTrip trip) {
    _startOtpController.clear();
    _navController.startTripOtpError.value = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _OtpSheet(
          title: 'Start Trip',
          subtitle: 'Enter the 6-digit OTP to confirm trip start.',
          controller: _startOtpController,
          isLoading: _navController.isStartingTrip,
          error: _navController.startTripOtpError,
          onConfirm: () async {
            final nav = Navigator.of(ctx);
            final pos = _navController.currentPosition.value;
            final ok = await _navController.startTrip(
              trip.tripId,
              _startOtpController.text.trim(),
              lat: pos?.latitude,
              lng: pos?.longitude,
            );
            if (ok) nav.pop();
          },
          onCancel: () => Navigator.of(ctx).pop(),
          // Allow skipping OTP — some backend versions don't require it
          extraAction: TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final pos = _navController.currentPosition.value;
              await _navController.startTripDirect(
                trip.tripId, lat: pos?.latitude, lng: pos?.longitude);
            },
            child: Text('Skip OTP (start without OTP)',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
          ),
        ),
      ),
    );
  }

  void _showArrivalConfirmDialog(AssignedTrip trip) {
    _completionReasonController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              const Icon(Icons.location_on, size: 48, color: _primary),
              const SizedBox(height: 12),
              Text('Arrived at Destination?',
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('Confirm that you have reached the drop-off location and are ready to collect proof of delivery.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600])),
              const SizedBox(height: 20),
              TextField(
                controller: _completionReasonController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'e.g. Delivered successfully, customer received goods',
                  hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[400]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _primary)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text('Cancel', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.grey)),
                )),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: Obx(() => ElevatedButton(
                  onPressed: _navController.isLoading.value ? null : () async {
                    final nav = Navigator.of(ctx);
                    final pos = _navController.currentPosition.value;
                    await _navController.arriveAtDestination(
                      trip.tripId,
                      lat: pos?.latitude,
                      lng: pos?.longitude,
                      reason: _completionReasonController.text.trim(),
                    );
                    nav.pop();
                    Get.to(
                      () => PodCollectionScreen(tripId: trip.tripId),
                      transition: Transition.rightToLeft,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _navController.isLoading.value
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('Yes, I\'ve Arrived',
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                ))),
              ]),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ── small helpers ─────────────────────────────────────────────────────
  Widget _primaryButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _outlineButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: _border),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: _textDark, size: 18),
        const SizedBox(width: 4),
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF1F2937)))),
      ]),
    );
  }

  Widget _infoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Row(children: [
        Icon(icon, size: 18, color: _textGrey),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: GoogleFonts.poppins(fontSize: 10, color: _textGrey, fontWeight: FontWeight.w500)),
            Text(value, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF111827))),
          ],
        )),
      ]),
    );
  }

  Widget _routeItem(String label, String address, Color color, {required bool isStart}) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(children: [
        Container(
          width: 12, height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.2), width: 4)),
        ),
        if (isStart) Container(width: 2, height: 30, color: Colors.grey[200]),
      ]),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[400], fontWeight: FontWeight.w500)),
        Text(address.isEmpty ? 'N/A' : address,
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1F2937))),
      ])),
    ]);
  }

  static const String _mapStyle = '''[
    {"featureType":"administrative","elementType":"geometry","stylers":[{"visibility":"off"}]},
    {"featureType":"poi","stylers":[{"visibility":"off"}]},
    {"featureType":"road","elementType":"labels.icon","stylers":[{"visibility":"off"}]},
    {"featureType":"transit","stylers":[{"visibility":"off"}]}
  ]''';
}

// ── reusable OTP bottom sheet ─────────────────────────────────────────────
class _OtpSheet extends StatelessWidget {
  final String title;
  final String subtitle;
  final TextEditingController controller;
  final RxBool isLoading;
  final RxnString error;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final Widget? extraAction;

  const _OtpSheet({
    required this.title,
    required this.subtitle,
    required this.controller,
    required this.isLoading,
    required this.error,
    required this.onConfirm,
    required this.onCancel,
    this.extraAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 20),
          const Icon(Icons.lock_outline, size: 48, color: _primary),
          const SizedBox(height: 12),
          Text(title, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(subtitle, textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600])),
          const SizedBox(height: 20),
          TextField(
            controller: controller,
            maxLength: 6,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: 12),
            decoration: InputDecoration(
              counterText: '',
              hintText: '------',
              hintStyle: GoogleFonts.poppins(fontSize: 24, color: Colors.grey[300], letterSpacing: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _primary, width: 2)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
          Obx(() => error.value != null
            ? Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(error.value!,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.red[600])),
              )
            : const SizedBox.shrink()),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: BorderSide(color: Colors.grey[300]!),
              ),
              child: Text('Cancel', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.grey[700])),
            )),
            const SizedBox(width: 12),
            Expanded(flex: 2, child: Obx(() => ElevatedButton(
              onPressed: isLoading.value ? null : onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: isLoading.value
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text('Confirm', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
            ))),
          ]),
          if (extraAction != null) ...[const SizedBox(height: 8), extraAction!],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
