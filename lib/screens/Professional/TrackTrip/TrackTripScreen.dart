import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../controllers/Professional/assigned_trip_controller.dart';
import '../../../controllers/Professional/track_trip_controller.dart';
import '../../../models/assigned_trip_model.dart';
import '../../../utils/call_utils.dart';
import 'package:geocoding/geocoding.dart' as geo;

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
  Worker? _locationWorker;

  @override
  void initState() {
    super.initState();
    // Initialize controller using Get.put in initState
    final trackController = Get.put(TrackTripController());
    final assignedTripController = Get.find<AssignedTripController>();
    final trip = assignedTripController.assignedTrips.firstWhere(
      (t) => t.tripId == widget.tripId,
    );

    if (trip.latitude != null &&
        trip.longitude != null &&
        trip.latitude != 0 &&
        trip.longitude != 0) {
      _setDestinationMarker(LatLng(trip.latitude!, trip.longitude!));
    } else {
      _geocodeDestination(trip.deliveryLocation);
    }

    trackController.startLocationUpdates(widget.tripId);

    // Listen to location changes to update marker and camera
    _locationWorker = ever(trackController.currentPosition, (Position? pos) {
      if (pos != null && mounted) {
        final currentLatLng = LatLng(pos.latitude, pos.longitude);
        setState(() {
          _markers.removeWhere((m) => m.markerId.value == 'current_pos');
          _markers.add(
            Marker(
              markerId: const MarkerId('current_pos'),
              position: currentLatLng,
              infoWindow: const InfoWindow(title: 'You are here'),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue,
              ),
            ),
          );
        });

        _mapController?.animateCamera(CameraUpdate.newLatLng(currentLatLng));
      }
    });
  }

  void _setDestinationMarker(LatLng position) {
    if (!mounted) return;
    setState(() {
      _destination = position;
      _markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: position,
          infoWindow: const InfoWindow(title: 'Destination'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    });
  }

  Future<void> _geocodeDestination(String address) async {
    if (address.isEmpty) return;
    try {
      List<geo.Location> locations = await geo.locationFromAddress(address);
      if (locations.isNotEmpty) {
        final pos = LatLng(locations.first.latitude, locations.first.longitude);
        _setDestinationMarker(pos);
      }
    } catch (e) {
      debugPrint("❌ Map Geocoding Error: $e");
    }
  }

  @override
  void dispose() {
    _locationWorker?.dispose();
    Get.find<TrackTripController>().stopLocationUpdates();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trackController = Get.find<TrackTripController>();
    final assignedTripController = Get.find<AssignedTripController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          // Find current trip and its status
          final trip = assignedTripController.assignedTrips.firstWhere(
            (t) => t.tripId == widget.tripId,
            orElse: () => AssignedTrip(
              tripId: widget.tripId,
              userId: '',
              vehicleId: '',
              vehicleNumber: '',
              vehicleModel: '',
              vehicleType: '',
              driverId: '',
              driverName: 'Loading...',
              driverContact: '',
              pickupLocation: '',
              deliveryLocation: '',
              pickupDate: DateTime.now(),
              pickupTime: '',
              specialInstructions: '',
              payRange: '',
              tripCode: '',
              tripStatus: 'Active',
              createdDate: DateTime.now(),
              totalBidCount: 0,
            ),
          );

          return Column(
            children: [
              // 1. Top Bar
              // _buildTopBar(context, widget.tripId, trackController),
              _buildTopBar(context, trip, trackController),

              // 2. Map Container with Compact Height (30% of screen)
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.30,
                width: double.infinity,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _destination ?? const LatLng(28.5581811, 77.344654),
                    zoom: 14.0,
                  ),
                  onMapCreated: (controller) => _mapController = controller,
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  mapType: MapType.normal,
                  style: _mapStyle,
                ),
              ),

              // 3. Details Content (Scrollable & Responsive)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: _buildDetailsContent(context, trip, trackController),
                ),
              ),

              // 4. Fixed Action Buttons at the Bottom
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: OutlinedButton(
                        onPressed: () => CallUtils.makeCall(
                          trip.companyMobileNo ?? trip.driverContact,
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.call,
                              color: Color(0xFF1F2937),
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'Call Company',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: Obx(
                        () => ElevatedButton(
                          onPressed: trackController.isLoading.value
                              ? null
                              : () => _confirmEndTrip(
                                  context,
                                  trip.tripId,
                                  trackController,
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF5E5E),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: trackController.isLoading.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Complete Trip',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTopBar(
    BuildContext context,
    // String tripId,
    AssignedTrip trip,
    TrackTripController controller,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFFFF5E5E),
              size: 20,
            ),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'CURRENT TRIP',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[400],
                    letterSpacing: 1.2,
                  ),
                ),
                // Text(
                //   'ID: ${tripId.toUpperCase()}',
                //   textAlign: TextAlign.center,
                //   maxLines: 1,
                //   overflow: TextOverflow.ellipsis,
                //   style: GoogleFonts.poppins(
                //     fontSize: 14,
                //     fontWeight: FontWeight.w700,
                //     color: const Color(0xFF1F2937),
                //   ),
                // ),
                Text(
                  trip.tripCode.isNotEmpty == true
                      ? trip.tripCode
                      : trip.tripId,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                )
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              // onPressed: () => controller.startLocationUpdates(tripId),
               onPressed: () => controller.startLocationUpdates(trip.tripId),
              icon: const Icon(
                Icons.refresh,
                color: Color(0xFFFF5E5E),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsContent(
    BuildContext context,
    AssignedTrip trip,
    TrackTripController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),

        // Progress & Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'On the way',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  Text(
                    'Vehicle: ${trip.vehicleNumber} (${trip.vehicleModel})',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: const Color(0xFFFF5E5E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Obx(
              () => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(controller.progress.value * 100).toStringAsFixed(0)}% Done',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1976D2),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Obx(
            () => LinearProgressIndicator(
              value: controller.progress.value,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF1976D2),
              ),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Quick Info Stats
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            Obx(
              () => _buildInfoCard(
                'ETA',
                controller.eta.value,
                Icons.timer_outlined,
              ),
            ),
            Obx(
              () => _buildInfoCard(
                'Distance',
                controller.distanceRemaining.value,
                Icons.straighten,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildInfoCard(
          'Company',
          '${trip.companyName ?? "Unknown"} • ${trip.companyMobileNo ?? trip.driverContact}',
          Icons.business_outlined,
        ),

        const SizedBox(height: 12),
        // Trip Route Details
        Text(
          'TRIP ROUTE',
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.grey[400],
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        _buildRouteItem(
          'Pickup Location',
          trip.pickupLocation,
          const Color(0xFF2E7D32),
          isStart: true,
        ),
        const SizedBox(height: 12),
        _buildRouteItem(
          'Delivery Destination',
          trip.deliveryLocation,
          const Color(0xFFFF5E5E),
          isStart: false,
        ),

        const SizedBox(height: 24),
        if (trip.specialInstructions.isNotEmpty) ...[
          Text(
            'INSTRUCTIONS',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey[400],
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFEDD5)),
            ),
            child: Text(
              trip.specialInstructions,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF9A3412),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _buildRouteItem(
    String label,
    String address,
    Color color, {
    required bool isStart,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.2), width: 4),
              ),
            ),
            if (isStart)
              Container(width: 2, height: 30, color: Colors.grey[200]),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                address.isEmpty ? "N/A" : address,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmEndTrip(
    BuildContext context,
    String tripId,
    TrackTripController controller,
  ) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Finish Trip?',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Are you sure you want to mark this trip as completed? This action cannot be undone.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      controller.endTrip(tripId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF27AE60),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Yes, Complete',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF9CA3AF)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: const Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static const String _mapStyle = '''
  [
    {
      "featureType": "administrative",
      "elementType": "geometry",
      "stylers": [{"visibility": "off"}]
    },
    {
      "featureType": "poi",
      "stylers": [{"visibility": "off"}]
    },
    {
      "featureType": "road",
      "elementType": "labels.icon",
      "stylers": [{"visibility": "off"}]
    },
    {
      "featureType": "transit",
      "stylers": [{"visibility": "off"}]
    }
  ]
  ''';
}
