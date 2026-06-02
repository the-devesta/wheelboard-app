import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' as geo;

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../utils/call_utils.dart';

class CompanyTrackTripScreen extends StatefulWidget {
  final String tripId;
  const CompanyTrackTripScreen({super.key, required this.tripId});

  @override
  State<CompanyTrackTripScreen> createState() => _CompanyTrackTripScreenState();
}

class _CompanyTrackTripScreenState extends State<CompanyTrackTripScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};

  // trip data
  Map<String, dynamic>? _trip;
  bool _loading = true;
  String? _error;

  // polling
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _loadTrip();
    // Refresh driver position every 15 seconds
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) => _loadTrip());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadTrip() async {
    try {
      final res = await ApiClient.instance.get(
        ApiEndpoints.trips.details(widget.tripId),
      );
      final data = res.data;
      if (!mounted) return;
      setState(() {
        _trip = data is Map<String, dynamic> ? data : null;
        _loading = false;
        _error = null;
      });
      _updateMarkers();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Failed to load trip. Tap refresh to retry.';
      });
    }
  }

  void _updateMarkers() {
    if (_trip == null) return;
    final route = _trip!['route'] as Map<String, dynamic>? ?? {};
    final startCoords = (route['startLocation']?['coordinates'] as List?);
    final endCoords = (route['endLocation']?['coordinates'] as List?);

    final newMarkers = <Marker>{};

    if (startCoords != null && startCoords.length >= 2) {
      newMarkers.add(Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(
          (startCoords[1] as num).toDouble(),
          (startCoords[0] as num).toDouble(),
        ),
        infoWindow: const InfoWindow(title: 'Pickup'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));
    }

    if (endCoords != null && endCoords.length >= 2) {
      final dest = LatLng(
        (endCoords[1] as num).toDouble(),
        (endCoords[0] as num).toDouble(),
      );
      newMarkers.add(Marker(
        markerId: const MarkerId('destination'),
        position: dest,
        infoWindow: const InfoWindow(title: 'Destination'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
      // Animate to destination if no driver location yet
      if (!newMarkers.any((m) => m.markerId.value == 'driver')) {
        _mapController?.animateCamera(CameraUpdate.newLatLng(dest));
      }
    }

    // Live driver location (backend pushes lastLocation or currentLocation)
    final driverLoc = _trip!['currentLocation'] as Map<String, dynamic>?
        ?? _trip!['lastLocation'] as Map<String, dynamic>?;
    if (driverLoc != null) {
      final coords = driverLoc['coordinates'] as List?;
      if (coords != null && coords.length >= 2) {
        final driverLL = LatLng(
          (coords[1] as num).toDouble(),
          (coords[0] as num).toDouble(),
        );
        newMarkers.add(Marker(
          markerId: const MarkerId('driver'),
          position: driverLL,
          infoWindow: InfoWindow(title: _driverName()),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ));
        _mapController?.animateCamera(CameraUpdate.newLatLng(driverLL));
      }
    }

    setState(() => _markers
      ..clear()
      ..addAll(newMarkers));
  }

  Future<void> _recenterMap() async {
    final list = _markers.toList();
    final m = list.firstWhereOrNull((m) => m.markerId.value == 'driver')
        ?? list.firstWhereOrNull((m) => m.markerId.value == 'destination');
    if (m != null) {
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: m.position, zoom: 14),
        ),
      );
    } else {
      await _tryGeocodeAndCenter();
    }
  }

  Future<void> _tryGeocodeAndCenter() async {
    final dest = _to();
    if (dest.isEmpty) return;
    try {
      final locs = await geo.locationFromAddress(dest);
      if (locs.isNotEmpty && mounted) {
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(LatLng(locs.first.latitude, locs.first.longitude)),
        );
      }
    } catch (_) {}
  }

  // ── data helpers ──────────────────────────────────────────────────────
  String _driverName() {
    if (_trip == null) return 'Driver';
    final d = _trip!['driverId'];
    if (d is Map) {
      final p = d['profile'] as Map<String, dynamic>?;
      final fn = p?['firstName'] ?? '';
      final ln = p?['lastName'] ?? '';
      return '$fn $ln'.trim().isNotEmpty ? '$fn $ln'.trim() : 'Driver';
    }
    return 'Driver';
  }

  String _driverPhone() {
    if (_trip == null) return '';
    final d = _trip!['driverId'];
    if (d is Map) {
      return (d['profile']?['phoneNumber'] as String?) ?? '';
    }
    return '';
  }

  String _vehicleName() {
    if (_trip == null) return '';
    final v = _trip!['vehicleId'];
    if (v is Map) {
      return '${v['name'] ?? v['model'] ?? ''} • ${v['registrationNumber'] ?? ''}'.trim();
    }
    return '';
  }

  String _from() {
    return (_trip?['route']?['startLocation']?['address'] as String?) ?? '';
  }

  String _to() {
    return (_trip?['route']?['endLocation']?['address'] as String?) ?? '';
  }

  String _status() {
    final raw = (_trip?['status'] as String?) ?? '';
    return raw.replaceAll('-', ' ').toUpperCase();
  }

  Color _statusColor() {
    final s = (_trip?['status'] as String?) ?? '';
    if (s == 'completed') return Colors.green;
    if (s.contains('progress') || s.contains('route') || s.contains('pickup')) {
      return Colors.blue;
    }
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            if (_loading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFFFF5E5E))))
            else if (_error != null)
              Expanded(child: _buildError())
            else ...[
              // map
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.42,
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: const CameraPosition(
                        target: LatLng(20.5937, 78.9629), zoom: 5),
                      onMapCreated: (c) {
                        _mapController = c;
                        _recenterMap();
                      },
                      markers: _markers,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      mapType: MapType.normal,
                    ),
                    // Recenter FAB
                    Positioned(
                      right: 12, bottom: 12,
                      child: FloatingActionButton.small(
                        heroTag: 'recenter',
                        backgroundColor: Colors.white,
                        onPressed: _recenterMap,
                        child: const Icon(Icons.my_location,
                          color: Color(0xFFFF5E5E)),
                      ),
                    ),
                  ],
                ),
              ),
              // details
              Expanded(child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildDetails(),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Row(children: [
        IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new,
            color: Color(0xFFFF5E5E), size: 20),
        ),
        Expanded(child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Track Trip',
              style: GoogleFonts.poppins(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: const Color(0xFF1F2937))),
            Text(widget.tripId.toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: 10, color: Colors.grey[500])),
          ],
        )),
        IconButton(
          onPressed: () { setState(() => _loading = true); _loadTrip(); },
          icon: const Icon(Icons.refresh, color: Color(0xFFFF5E5E), size: 20),
        ),
      ]),
    );
  }

  Widget _buildError() {
    return Center(child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, size: 64, color: Colors.red),
        const SizedBox(height: 16),
        Text(_error!,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () { setState(() => _loading = true); _loadTrip(); },
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5E5E)),
        ),
      ]),
    ));
  }

  Widget _buildDetails() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // status chip
      Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _statusColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _statusColor().withValues(alpha: 0.4)),
          ),
          child: Text(_status(),
            style: GoogleFonts.poppins(
              fontSize: 11, fontWeight: FontWeight.w700, color: _statusColor())),
        ),
        const Spacer(),
        if (_driverPhone().isNotEmpty)
          GestureDetector(
            onTap: () => CallUtils.makeCall(_driverPhone()),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.phone, color: Color(0xFF27AE60), size: 16),
                const SizedBox(width: 6),
                Text('Call Driver',
                  style: GoogleFonts.poppins(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: const Color(0xFF27AE60))),
              ]),
            ),
          ),
      ]),
      const SizedBox(height: 16),

      // driver + vehicle
      _infoCard(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _rowInfo(Icons.person, 'Driver', _driverName()),
          if (_vehicleName().isNotEmpty) ...[
            const Divider(height: 20),
            _rowInfo(Icons.local_shipping, 'Vehicle', _vehicleName()),
          ],
        ],
      )),
      const SizedBox(height: 12),

      // route
      _infoCard(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _routePoint('Pickup', _from(), const Color(0xFF27AE60), isStart: true),
          const SizedBox(height: 12),
          _routePoint('Destination', _to(), const Color(0xFFFF5E5E), isStart: false),
        ],
      )),
      const SizedBox(height: 20),
    ]);
  }

  Widget _infoCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: child,
    );
  }

  Widget _rowInfo(IconData icon, String label, String value) {
    return Row(children: [
      Icon(icon, size: 16, color: const Color(0xFF9CA3AF)),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
          style: GoogleFonts.poppins(
            fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.w500)),
        Text(value.isEmpty ? 'N/A' : value,
          style: GoogleFonts.poppins(
            fontSize: 13, fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937))),
      ]),
    ]);
  }

  Widget _routePoint(String label, String addr, Color color, {required bool isStart}) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(children: [
        Container(
          width: 12, height: 12,
          decoration: BoxDecoration(
            color: color, shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.25), width: 4)),
        ),
        if (isStart) Container(width: 2, height: 28, color: Colors.grey[200]),
      ]),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
          style: GoogleFonts.poppins(
            fontSize: 10, color: Colors.grey[400], fontWeight: FontWeight.w500)),
        Text(addr.isEmpty ? 'N/A' : addr,
          style: GoogleFonts.poppins(
            fontSize: 13, fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937))),
      ])),
    ]);
  }
}
