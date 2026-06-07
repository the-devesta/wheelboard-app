import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:iconsax/iconsax.dart';

import '../../../controllers/Professional/assigned_trip_controller.dart';
import '../../../controllers/Professional/trip_navigation_controller.dart';
import '../../../models/assigned_trip_model.dart';
import '../../../theme/design_system.dart';
import '../../../utils/call_utils.dart';
import '../Navigation/PodCollectionScreen.dart';
import '../Navigation/TripCompletedScreen.dart';
import '../lr/lr_confirmation_sheet.dart';

/// Live trip navigation for professionals — Uber/Rapido style.
///
/// Full-bleed map up top, floating glass controls, and a rounded action sheet
/// pinned at the bottom that changes its content + CTA per step. The step
/// machine, OTP flow, LR confirm, POD hand-off, GPS + socket pinging all live in
/// [TripNavigationController] / [AssignedTripController] and are untouched — this
/// is a pure presentation refresh that keeps 100% behavioural parity.
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

  // OTP / reason controllers
  final _startOtpController = TextEditingController();
  final _completionReasonController = TextEditingController();

  /// Resilient access: the previous `Get.find<AssignedTripController>()` threw
  /// (→ "Failed to load trip") whenever this screen was opened from a route
  /// that hadn't already registered the controller (e.g. Trip Details). Put it
  /// on demand instead.
  AssignedTripController get _assignedCtrl {
    if (!Get.isRegistered<AssignedTripController>()) {
      return Get.put(AssignedTripController());
    }
    return Get.find<AssignedTripController>();
  }

  @override
  void initState() {
    super.initState();
    _navController = Get.put(TripNavigationController());
    final assignedCtrl = _assignedCtrl;

    _initFromTrip(assignedCtrl);

    // If the assigned-trips list hasn't been loaded yet (e.g. deep link or
    // opened from Trip Details), fetch it then initialise — instead of failing.
    if (assignedCtrl.assignedTrips.isEmpty) {
      assignedCtrl.fetchAssignedTrips().then((_) {
        if (mounted) _initFromTrip(assignedCtrl);
      });
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
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue),
          ));
        });
        _mapController?.animateCamera(CameraUpdate.newLatLng(ll));
      }
    });
  }

  bool _initialised = false;

  /// Locate this trip in the assigned list and initialise the step machine,
  /// destination marker and (for active trips) live GPS. Safe to call again
  /// after the list loads.
  void _initFromTrip(AssignedTripController assignedCtrl) {
    final trip = assignedCtrl.assignedTrips
        .firstWhereOrNull((t) => t.tripId == widget.tripId);
    if (trip == null || _initialised) return;
    _initialised = true;

    _navController.initFromStatus(trip.tripStatus);

    if (trip.latitude != null &&
        trip.latitude != 0 &&
        trip.longitude != null &&
        trip.longitude != 0) {
      _setDestMarker(LatLng(trip.latitude!, trip.longitude!));
    } else {
      _geocodeDestination(trip.deliveryLocation);
    }

    final step = _navController.currentStep.value;
    if (step == TripStep.inTransit ||
        step == TripStep.navigatingToPickup ||
        step == TripStep.atPickup) {
      _navController.startTrackingForTrip(widget.tripId);
    }
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
    _mapController?.animateCamera(CameraUpdate.newLatLng(pos));
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
    _startOtpController.dispose();
    _completionReasonController.dispose();
    super.dispose();
  }

  // ── step → label / headline / colour ──────────────────────────────────────
  String _stepLabel(TripStep step) {
    switch (step) {
      case TripStep.confirmOtp:
        return 'Awaiting Confirmation';
      case TripStep.readyToStart:
        return 'Ready to Start';
      case TripStep.navigatingToPickup:
        return 'En Route to Pickup';
      case TripStep.atPickup:
        return 'At Pickup';
      case TripStep.inTransit:
        return 'In Transit';
      case TripStep.atDestination:
        return 'At Destination';
      case TripStep.podUpload:
        return 'Upload POD';
      case TripStep.completed:
        return 'Completed';
    }
  }

  String _stepHeadline(TripStep step) {
    switch (step) {
      case TripStep.confirmOtp:
        return 'Confirm your Lorry Receipt';
      case TripStep.readyToStart:
        return 'Ready to start';
      case TripStep.navigatingToPickup:
        return 'Heading to pickup';
      case TripStep.atPickup:
        return 'At the pickup point';
      case TripStep.inTransit:
        return 'On the way';
      case TripStep.atDestination:
      case TripStep.podUpload:
        return 'Arrived at destination';
      case TripStep.completed:
        return 'Trip completed';
    }
  }

  Color _stepColor(TripStep step) {
    switch (step) {
      case TripStep.confirmOtp:
        return AppPalette.amber;
      case TripStep.readyToStart:
        return AppPalette.blue;
      case TripStep.navigatingToPickup:
        return AppPalette.purple;
      case TripStep.atPickup:
        return const Color(0xFF06B6D4);
      case TripStep.inTransit:
        return AppPalette.green;
      case TripStep.atDestination:
      case TripStep.podUpload:
        return AppPalette.primary;
      case TripStep.completed:
        return AppPalette.green;
    }
  }

  // ── build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final assignedCtrl = _assignedCtrl;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppPalette.bg,
      body: Obx(() {
        final trip = assignedCtrl.assignedTrips.firstWhereOrNull(
              (t) => t.tripId == widget.tripId,
            ) ??
            AssignedTrip(
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

        return Stack(
          children: [
            // Map — fills the top portion; the sheet overlaps its lower edge.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: size.height * 0.55,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _destination ?? const LatLng(28.5581811, 77.344654),
                  zoom: 13,
                ),
                onMapCreated: (c) {
                  _mapController = c;
                  if (_destination != null) {
                    c.animateCamera(CameraUpdate.newLatLng(_destination!));
                  }
                },
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapType: MapType.normal,
                style: _mapStyle,
                padding: EdgeInsets.only(bottom: size.height * 0.45),
              ),
            ),

            // Floating top controls.
            SafeArea(child: _floatingControls(trip, step)),

            // Bottom action sheet.
            Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: size.height * 0.62),
                child: _bottomSheet(trip, step),
              ),
            ),
          ],
        );
      }),
    );
  }

  // ── floating top controls ──────────────────────────────────────────────────
  Widget _floatingControls(AssignedTrip trip, TripStep step) {
    final color = _stepColor(step);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
      child: Row(
        children: [
          _circleBtn(Iconsax.arrow_left_2, () => Get.back()),
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppPalette.card,
              borderRadius: AppRadius.rPill,
              boxShadow: _softShadow,
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 7),
              Text(_stepLabel(step),
                  style: AppText.label.on(color).weight(FontWeight.w700)),
            ]),
          ),
          const Spacer(),
          _circleBtn(
            Iconsax.refresh,
            () => _navController.startTrackingForTrip(trip.tripId),
          ),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return Material(
      color: AppPalette.card,
      shape: const CircleBorder(),
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(icon, color: AppPalette.textDark, size: 21),
        ),
      ),
    );
  }

  // ── bottom action sheet ─────────────────────────────────────────────────────
  Widget _bottomSheet(AssignedTrip trip, TripStep step) {
    return Container(
      decoration: BoxDecoration(
        color: AppPalette.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                  color: AppPalette.border, borderRadius: AppRadius.rPill),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
                child: _detailsContent(trip, step),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: _stepActions(trip, step),
            ),
          ],
        ),
      ),
    );
  }

  // ── details content ─────────────────────────────────────────────────────────
  Widget _detailsContent(AssignedTrip trip, TripStep step) {
    final showProgress = step != TripStep.confirmOtp &&
        step != TripStep.readyToStart &&
        step != TripStep.completed;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_stepHeadline(step), style: AppText.h2),
                  if (trip.vehicleNumber.isNotEmpty)
                    Text(
                      '${trip.vehicleNumber}'
                      '${trip.vehicleModel.isNotEmpty ? " • ${trip.vehicleModel}" : ""}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.caption
                          .on(AppPalette.primary)
                          .weight(FontWeight.w600),
                    ),
                ],
              ),
            ),
            if (showProgress)
              Obx(() => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: AppPalette.blueBg,
                        borderRadius: AppRadius.rPill),
                    child: Text(
                      '${(_navController.progress.value * 100).toStringAsFixed(0)}% Done',
                      style: AppText.caption
                          .on(AppPalette.blue)
                          .weight(FontWeight.w700),
                    ),
                  )),
          ],
        ),
        if (showProgress) ...[
          AppSpacing.vGapSm,
          Obx(() => ClipRRect(
                borderRadius: AppRadius.rPill,
                child: LinearProgressIndicator(
                  value: _navController.progress.value,
                  backgroundColor: AppPalette.border,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      _stepColor(_navController.currentStep.value)),
                  minHeight: 7,
                ),
              )),
        ],
        AppSpacing.vGapLg,

        // ETA + distance.
        Row(children: [
          Expanded(
              child: Obx(() => _infoCard(
                  'ETA', _navController.eta.value, Iconsax.timer_1))),
          AppSpacing.hGapMd,
          Expanded(
              child: Obx(() => _infoCard('Distance',
                  _navController.distanceRemaining.value, Iconsax.routing))),
        ]),
        AppSpacing.vGapMd,

        _infoCard(
          'Company',
          '${trip.companyName ?? "Transport Co."} • '
              '${trip.companyMobileNo ?? trip.driverContact}',
          Iconsax.building_4,
        ),
        AppSpacing.vGapLg,

        Text('TRIP ROUTE', style: AppText.micro.size(10)),
        AppSpacing.vGapSm,
        _routeItem('Pickup Location', trip.pickupLocation, AppPalette.green,
            isStart: true),
        AppSpacing.vGapMd,
        _routeItem(
            'Delivery Destination', trip.deliveryLocation, AppPalette.danger,
            isStart: false),

        if (trip.specialInstructions.isNotEmpty) ...[
          AppSpacing.vGapLg,
          Text('INSTRUCTIONS', style: AppText.micro.size(10)),
          AppSpacing.vGapSm,
          AppBanner(
            text: trip.specialInstructions,
            icon: Iconsax.info_circle,
            color: AppPalette.amber,
            background: AppPalette.amberBg,
            borderColor: const Color(0x33F59E0B),
          ),
        ],
        const SizedBox(height: 4),
      ],
    );
  }

  // ── step action bar ─────────────────────────────────────────────────────────
  Widget _stepActions(AssignedTrip trip, TripStep step) {
    switch (step) {
      case TripStep.confirmOtp:
        return _primaryButton(
          icon: Iconsax.receipt_text,
          label: 'Review & Confirm LR',
          color: AppPalette.amber,
          onTap: () => _onConfirmLr(trip.tripId),
        );

      case TripStep.readyToStart:
        return _primaryButton(
          icon: Iconsax.play_circle,
          label: 'Start Trip',
          color: AppPalette.green,
          onTap: () => _showStartTripModal(trip),
        );

      case TripStep.navigatingToPickup:
        return Row(children: [
          Expanded(
            flex: 2,
            child: _outlineButton(
              icon: Iconsax.call,
              label: 'Call',
              onTap: () => CallUtils.makeCall(
                  trip.companyMobileNo ?? trip.driverContact),
            ),
          ),
          AppSpacing.hGapMd,
          Expanded(
            flex: 3,
            child: _primaryButton(
              icon: Iconsax.location,
              label: 'Arrived at Pickup',
              color: AppPalette.purple,
              onTap: () => _navController.arriveAtPickup(trip.tripId),
            ),
          ),
        ]);

      case TripStep.atPickup:
        return Row(children: [
          Expanded(
            flex: 2,
            child: _outlineButton(
              icon: Iconsax.call,
              label: 'Call',
              onTap: () => CallUtils.makeCall(
                  trip.companyMobileNo ?? trip.driverContact),
            ),
          ),
          AppSpacing.hGapMd,
          Expanded(
            flex: 3,
            child: _primaryButton(
              icon: Iconsax.truck,
              label: 'Start Trip',
              color: AppPalette.green,
              onTap: () => _showStartTripModal(trip),
            ),
          ),
        ]);

      case TripStep.inTransit:
        return Row(children: [
          Expanded(
            flex: 2,
            child: _outlineButton(
              icon: Iconsax.call,
              label: 'Call',
              onTap: () => CallUtils.makeCall(
                  trip.companyMobileNo ?? trip.driverContact),
            ),
          ),
          AppSpacing.hGapMd,
          Expanded(
            flex: 3,
            child: Obx(() => AppPrimaryButton(
                  label: 'Arrived at Drop-off',
                  icon: Iconsax.flag,
                  loading: _navController.isLoading.value,
                  onPressed: () => _showArrivalConfirmDialog(trip),
                )),
          ),
        ]);

      case TripStep.atDestination:
      case TripStep.podUpload:
        return _primaryButton(
          icon: Iconsax.document_upload,
          label: 'Upload Proof of Delivery',
          color: AppPalette.purple,
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
          icon: Iconsax.tick_circle,
          label: 'View Trip Summary',
          color: AppPalette.green,
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

  // ── modals ──────────────────────────────────────────────────────────────────
  /// Opens the Lorry Receipt review sheet (driver). On confirm the backend
  /// advances the trip to `scheduled`; on reject it moves to `lr-rejected` and
  /// the driver leaves this screen. Refreshes assigned trips either way.
  Future<void> _onConfirmLr(String tripId) async {
    final changed = await LrConfirmationSheet.show(context, tripId: tripId);
    if (changed != true || !mounted) return;
    final assignedCtrl = Get.find<AssignedTripController>();
    await assignedCtrl.fetchAssignedTrips();
    final t = assignedCtrl.assignedTrips
        .firstWhereOrNull((e) => e.tripId == tripId);
    if (t == null) {
      if (mounted) Get.back();
      return;
    }
    if (t.tripStatus.toLowerCase() == 'lr-rejected') {
      if (mounted) Get.back();
    } else {
      _navController.initFromStatus(t.tripStatus);
    }
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
                style: AppText.caption),
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppPalette.border,
                      borderRadius: AppRadius.rPill)),
              AppSpacing.vGapXl,
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                    color: AppPalette.primaryLight,
                    borderRadius: AppRadius.rXl),
                child: const Icon(Iconsax.location_tick,
                    size: 30, color: AppPalette.primary),
              ),
              AppSpacing.vGapMd,
              Text('Arrived at Destination?', style: AppText.h2),
              const SizedBox(height: 6),
              Text(
                'Confirm that you have reached the drop-off location and are ready to collect proof of delivery.',
                textAlign: TextAlign.center,
                style: AppText.bodySm,
              ),
              AppSpacing.vGapLg,
              TextField(
                controller: _completionReasonController,
                maxLines: 2,
                style: AppText.bodySm,
                decoration: InputDecoration(
                  hintText:
                      'e.g. Delivered successfully, customer received goods',
                  hintStyle: AppText.caption,
                  border: OutlineInputBorder(
                      borderRadius: AppRadius.rLg,
                      borderSide:
                          const BorderSide(color: AppPalette.border)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: AppRadius.rLg,
                      borderSide:
                          const BorderSide(color: AppPalette.primary)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                ),
              ),
              AppSpacing.vGapLg,
              Row(children: [
                Expanded(
                    child: AppSecondaryButton(
                  label: 'Cancel',
                  onPressed: () => Navigator.of(ctx).pop(),
                )),
                AppSpacing.hGapMd,
                Expanded(
                  flex: 2,
                  child: Obx(() => AppPrimaryButton(
                        label: "Yes, I've Arrived",
                        loading: _navController.isLoading.value,
                        onPressed: () async {
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
                      )),
                ),
              ]),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  // ── small helpers ─────────────────────────────────────────────────────────
  Widget _primaryButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AppPrimaryButton(
      label: label,
      icon: icon,
      color: color,
      onPressed: onTap,
    );
  }

  Widget _outlineButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return AppSecondaryButton(
      label: label,
      icon: icon,
      color: AppPalette.textMid,
      onPressed: onTap,
    );
  }

  Widget _infoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppPalette.bg,
        borderRadius: AppRadius.rLg,
        border: Border.all(color: AppPalette.border),
      ),
      child: Row(children: [
        Icon(icon, size: 18, color: AppPalette.textGrey),
        AppSpacing.hGapSm,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: AppText.micro.size(10)),
              Text(value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.label
                      .on(AppPalette.textDark)
                      .weight(FontWeight.w700)),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _routeItem(String label, String address, Color color,
      {required bool isStart}) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.2), width: 4)),
        ),
        if (isStart)
          Container(width: 2, height: 30, color: AppPalette.border),
      ]),
      AppSpacing.hGapMd,
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppText.micro.size(10)),
          Text(address.isEmpty ? 'N/A' : address,
              style: AppText.subtitle.size(13)),
        ]),
      ),
    ]);
  }

  static const String _mapStyle = '''[
    {"featureType":"administrative","elementType":"geometry","stylers":[{"visibility":"off"}]},
    {"featureType":"poi","stylers":[{"visibility":"off"}]},
    {"featureType":"road","elementType":"labels.icon","stylers":[{"visibility":"off"}]},
    {"featureType":"transit","stylers":[{"visibility":"off"}]}
  ]''';

  static final _softShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.10),
      blurRadius: 10,
      offset: const Offset(0, 3),
    ),
  ];
}

// ── reusable OTP bottom sheet ───────────────────────────────────────────────
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                  color: AppPalette.border, borderRadius: AppRadius.rPill)),
          AppSpacing.vGapXl,
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
                color: AppPalette.primaryLight, borderRadius: AppRadius.rXl),
            child: const Icon(Iconsax.lock_1, size: 30, color: AppPalette.primary),
          ),
          AppSpacing.vGapMd,
          Text(title, style: AppText.h2),
          const SizedBox(height: 6),
          Text(subtitle, textAlign: TextAlign.center, style: AppText.bodySm),
          AppSpacing.vGapLg,
          TextField(
            controller: controller,
            maxLength: 6,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: AppText.h1.copyWith(
                fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: 12),
            decoration: InputDecoration(
              counterText: '',
              hintText: '------',
              hintStyle: AppText.h1.copyWith(
                  fontSize: 24,
                  color: AppPalette.border,
                  letterSpacing: 12),
              border: OutlineInputBorder(
                  borderRadius: AppRadius.rLg,
                  borderSide: const BorderSide(color: AppPalette.border)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.rLg,
                  borderSide:
                      const BorderSide(color: AppPalette.primary, width: 2)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
          Obx(() => error.value != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(error.value!,
                      style: AppText.caption.on(AppPalette.danger)),
                )
              : const SizedBox.shrink()),
          AppSpacing.vGapLg,
          Row(children: [
            Expanded(
                child: AppSecondaryButton(
              label: 'Cancel',
              color: AppPalette.textMid,
              onPressed: onCancel,
            )),
            AppSpacing.hGapMd,
            Expanded(
              flex: 2,
              child: Obx(() => AppPrimaryButton(
                    label: 'Confirm',
                    loading: isLoading.value,
                    onPressed: onConfirm,
                  )),
            ),
          ]),
          if (extraAction != null) ...[const SizedBox(height: 8), extraAction!],
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
