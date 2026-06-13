import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' as geo;

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../services/route_service.dart';
import '../../../utils/call_utils.dart';
import '../../../utils/map_navigation_utils.dart';
import '../../../widgets/custom_snackbar.dart';

class CompanyTrackTripScreen extends StatefulWidget {
  final String tripId;
  const CompanyTrackTripScreen({super.key, required this.tripId});

  @override
  State<CompanyTrackTripScreen> createState() => _CompanyTrackTripScreenState();
}

class _CompanyTrackTripScreenState extends State<CompanyTrackTripScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  // trip data
  Map<String, dynamic>? _trip;
  bool _loading = true;
  String? _error;
  LatLng? _pickup;
  LatLng? _destination;
  LatLng? _driverLocation;
  RouteResult? _currentRoute;
  LatLng? _lastRoutedFrom;
  bool _isFetchingRoute = false;
  String _distanceText = 'Calculating...';
  String _durationText = 'Calculating...';
  double _progress = 0;

  // polling
  Timer? _pollTimer;

  bool get _canUseGoogleMap =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  @override
  void initState() {
    super.initState();
    _loadTrip();
    // Refresh driver position every 15 seconds
    _pollTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _loadTrip(),
    );
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
      _syncRoute();
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
    _pickup = _coordsToLatLng(route['startLocation']?['coordinates'] as List?);
    _destination = _coordsToLatLng(
      route['endLocation']?['coordinates'] as List?,
    );

    final newMarkers = <Marker>{};

    if (_pickup != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: _pickup!,
          infoWindow: const InfoWindow(title: 'Pickup'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      );
    }

    if (_destination != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: _destination!,
          infoWindow: const InfoWindow(title: 'Destination'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
      // Animate to destination if no driver location yet
      if (!newMarkers.any((m) => m.markerId.value == 'driver')) {
        _mapController?.animateCamera(CameraUpdate.newLatLng(_destination!));
      }
    }

    // Live driver location (backend pushes lastLocation or currentLocation)
    final driverLoc =
        _trip!['currentLocation'] as Map<String, dynamic>? ??
        _trip!['lastLocation'] as Map<String, dynamic>?;
    _driverLocation = null;
    if (driverLoc != null) {
      final driverLL = _coordsToLatLng(driverLoc['coordinates'] as List?);
      if (driverLL != null) {
        _driverLocation = driverLL;
        newMarkers.add(
          Marker(
            markerId: const MarkerId('driver'),
            position: driverLL,
            infoWindow: InfoWindow(title: _driverName()),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
          ),
        );
        _mapController?.animateCamera(CameraUpdate.newLatLng(driverLL));
      }
    }

    setState(
      () => _markers
        ..clear()
        ..addAll(newMarkers),
    );
    _rebuildPolyline();
  }

  LatLng? _coordsToLatLng(List? coords) {
    if (coords == null || coords.length < 2) return null;
    final lng = coords[0];
    final lat = coords[1];
    if (lat is! num || lng is! num) return null;
    return LatLng(lat.toDouble(), lng.toDouble());
  }

  LatLng? get _routeOrigin => _driverLocation ?? _pickup;

  Future<void> _syncRoute() async {
    final origin = _routeOrigin;
    final dest = _destination;
    if (origin == null || dest == null) {
      _updateFallbackMetrics();
      return;
    }
    if (_isFetchingRoute) return;

    final last = _lastRoutedFrom;
    if (_currentRoute != null && last != null) {
      final movedKm = _haversineKm(
        origin.latitude,
        origin.longitude,
        last.latitude,
        last.longitude,
      );
      if (movedKm < 0.2) {
        _updateRouteMetrics();
        return;
      }
    }

    _isFetchingRoute = true;
    try {
      final result = await routeService.getRoute(
        origin: origin,
        destination: dest,
      );
      if (!mounted) return;
      setState(() {
        _currentRoute = result;
        _lastRoutedFrom = origin;
        _updateRouteMetrics();
        _rebuildPolyline();
      });
      _fitToRoute();
    } finally {
      _isFetchingRoute = false;
    }
  }

  void _updateRouteMetrics() {
    final route = _currentRoute;
    final origin = _routeOrigin;
    final dest = _destination;
    if (origin == null || dest == null) return;

    double remainingKm;
    int? etaMin;

    if (route != null && route.points.length > 1) {
      final nearIdx = _nearestIndex(route.points, origin);
      remainingKm = 0;
      for (int i = nearIdx; i < route.points.length - 1; i++) {
        remainingKm += _haversineKm(
          route.points[i].latitude,
          route.points[i].longitude,
          route.points[i + 1].latitude,
          route.points[i + 1].longitude,
        );
      }
      etaMin = route.durationMinutes;
    } else {
      remainingKm = _haversineKm(
        origin.latitude,
        origin.longitude,
        dest.latitude,
        dest.longitude,
      );
    }

    _distanceText = remainingKm >= 1
        ? '${remainingKm.toStringAsFixed(1)} km'
        : '${(remainingKm * 1000).toStringAsFixed(0)} m';
    final minutes = etaMin ?? (remainingKm / 40 * 60).round();
    _durationText = minutes > 60
        ? '${minutes ~/ 60}h ${minutes % 60}m'
        : '$minutes min';

    if (_pickup != null && _destination != null) {
      final totalKm = _haversineKm(
        _pickup!.latitude,
        _pickup!.longitude,
        _destination!.latitude,
        _destination!.longitude,
      );
      final toDestKm = _haversineKm(
        origin.latitude,
        origin.longitude,
        _destination!.latitude,
        _destination!.longitude,
      );
      _progress = totalKm > 0
          ? ((totalKm - toDestKm) / totalKm).clamp(0.0, 1.0)
          : 0;
    }
  }

  void _updateFallbackMetrics() {
    final origin = _routeOrigin;
    final dest = _destination;
    if (origin == null || dest == null || !mounted) return;
    setState(() {
      _currentRoute = null;
      _updateRouteMetrics();
      _rebuildPolyline();
    });
  }

  void _rebuildPolyline() {
    _polylines.clear();
    final origin = _routeOrigin;
    final dest = _destination;
    final route = _currentRoute;
    if (origin == null || dest == null) return;

    if (route != null && route.points.length > 1) {
      final splitIdx = _nearestIndex(route.points, origin);
      final completed = route.points.sublist(0, splitIdx + 1);
      final remaining = route.points.sublist(splitIdx);

      if (completed.length > 1) {
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('travelled'),
            points: completed,
            color: const Color(0xFF9CA3AF),
            width: 4,
            patterns: [PatternItem.dot, PatternItem.gap(14)],
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
          ),
        );
      }
      if (remaining.length > 1) {
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('remaining_casing'),
            points: remaining,
            color: const Color(0x33FF5E5E),
            width: 12,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
          ),
        );
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('remaining'),
            points: remaining,
            color: const Color(0xFFFF5E5E),
            width: 6,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
          ),
        );
      }
      return;
    }

    _polylines.add(
      Polyline(
        polylineId: const PolylineId('fallback_route'),
        points: [origin, dest],
        color: const Color(0xFFFF5E5E),
        width: 5,
        patterns: [PatternItem.dash(24), PatternItem.gap(10)],
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ),
    );
  }

  int _nearestIndex(List<LatLng> pts, LatLng pos) {
    int best = 0;
    double bestDist = double.infinity;
    for (int i = 0; i < pts.length; i++) {
      final d = _haversineKm(
        pos.latitude,
        pos.longitude,
        pts[i].latitude,
        pts[i].longitude,
      );
      if (d < bestDist) {
        bestDist = d;
        best = i;
      }
    }
    return best;
  }

  static double _haversineKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const r = 6371.0;
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLon = (lon2 - lon1) * math.pi / 180;
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  Future<void> _recenterMap() async {
    if (_fitToRoute()) {
      return;
    }
    final focus = _driverLocation ?? _destination ?? _pickup;
    if (focus != null) {
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(focus, 14));
    } else {
      await _tryGeocodeAndCenter();
    }
  }

  bool _fitToRoute() {
    if (_mapController == null) return false;
    final points = <LatLng>[
      if (_pickup != null) _pickup!,
      if (_destination != null) _destination!,
      if (_driverLocation != null) _driverLocation!,
      if (_currentRoute != null) ..._currentRoute!.points,
    ];
    if (points.isEmpty) return false;
    Future.delayed(const Duration(milliseconds: 250), () {
      if (!mounted || _mapController == null) return;
      try {
        if (points.length == 1) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(points.first, 14),
          );
        } else {
          _mapController!.animateCamera(
            CameraUpdate.newLatLngBounds(_boundsFromPoints(points), 64),
          );
        }
      } catch (_) {}
    });
    return true;
  }

  LatLngBounds _boundsFromPoints(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;
    for (final p in points) {
      minLat = math.min(minLat, p.latitude);
      maxLat = math.max(maxLat, p.latitude);
      minLng = math.min(minLng, p.longitude);
      maxLng = math.max(maxLng, p.longitude);
    }
    const pad = 0.0025;
    return LatLngBounds(
      southwest: LatLng(minLat - pad, minLng - pad),
      northeast: LatLng(maxLat + pad, maxLng + pad),
    );
  }

  Future<void> _openRouteInMaps() async {
    final dest = _destination;
    if (dest == null) {
      SnackBarHelper.error('Destination is not available for navigation.');
      return;
    }
    final ok = await MapNavigationUtils.openDirections(
      origin: _driverLocation ?? _pickup,
      destination: dest,
      destinationLabel: _to(),
    );
    if (!ok) {
      SnackBarHelper.error('Could not open maps on this device.');
    }
  }

  Future<void> _tryGeocodeAndCenter() async {
    final dest = _to();
    if (dest.isEmpty) return;
    try {
      final locs = await geo.locationFromAddress(dest);
      if (locs.isNotEmpty && mounted) {
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(locs.first.latitude, locs.first.longitude),
          ),
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
      return '${v['name'] ?? v['model'] ?? ''} • ${v['registrationNumber'] ?? ''}'
          .trim();
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
                  child: CircularProgressIndicator(color: Color(0xFFFF5E5E)),
                ),
              )
            else if (_error != null)
              Expanded(child: _buildError())
            else ...[
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.42,
                child: _canUseGoogleMap ? _mapPanel() : _desktopMapFallback(),
              ),
              // details
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: _buildDetails(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _mapPanel() {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(20.5937, 78.9629),
            zoom: 5,
          ),
          onMapCreated: (c) {
            _mapController = c;
            _recenterMap();
          },
          markers: _markers,
          polylines: _polylines,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapType: MapType.normal,
        ),
        Positioned(
          right: 12,
          bottom: 12,
          child: FloatingActionButton.small(
            heroTag: 'recenter',
            backgroundColor: Colors.white,
            onPressed: _recenterMap,
            child: const Icon(Icons.my_location, color: Color(0xFFFF5E5E)),
          ),
        ),
      ],
    );
  }

  Widget _desktopMapFallback() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFFF9FAFB),
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.map_outlined, color: Color(0xFFFF5E5E), size: 42),
          const SizedBox(height: 12),
          Text(
            'Map preview unavailable on macOS',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Run on iPhone, Android, or web to see the live Google Map.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 18),
          _desktopRouteLine('Pickup', _from(), const Color(0xFF27AE60)),
          const SizedBox(height: 10),
          _desktopRouteLine('Destination', _to(), const Color(0xFFFF5E5E)),
        ],
      ),
    );
  }

  Widget _desktopRouteLine(String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(top: 5),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: const Color(0xFF6B7280),
                ),
              ),
              Text(
                value.isNotEmpty ? value : 'Not available',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
        ],
      ),
      child: Row(
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
                  'Track Trip',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                Text(
                  widget.tripId.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() => _loading = true);
              _loadTrip();
            },
            icon: const Icon(Icons.refresh, color: Color(0xFFFF5E5E), size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                setState(() => _loading = true);
                _loadTrip();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5E5E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // status chip
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _statusColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _statusColor().withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                _status(),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _statusColor(),
                ),
              ),
            ),
            if (_driverPhone().isNotEmpty)
              GestureDetector(
                onTap: () => CallUtils.makeCall(_driverPhone()),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.phone,
                        color: Color(0xFF27AE60),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Call Driver',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF27AE60),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            GestureDetector(
              onTap: _openRouteInMaps,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEFEF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.navigation_rounded,
                      color: Color(0xFFFF5E5E),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Open Route',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFF5E5E),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _metricCard(
                Icons.straighten_rounded,
                'Distance',
                _distanceText,
                const Color(0xFFFF5E5E),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _metricCard(
                Icons.schedule_rounded,
                'Est. Duration',
                _durationText,
                const Color(0xFFFF5E5E),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _infoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.route_rounded,
                    size: 16,
                    color: Color(0xFF27AE60),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Live Progress',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${(_progress * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFF111827),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: _progress.clamp(0.0, 1.0),
                  minHeight: 7,
                  backgroundColor: const Color(0xFFE5E7EB),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF27AE60),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // driver + vehicle
        _infoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _rowInfo(Icons.person, 'Driver', _driverName()),
              if (_vehicleName().isNotEmpty) ...[
                const Divider(height: 20),
                _rowInfo(Icons.local_shipping, 'Vehicle', _vehicleName()),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),

        // route
        _infoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _routePoint(
                'Pickup',
                _from(),
                const Color(0xFF27AE60),
                isStart: true,
              ),
              const SizedBox(height: 12),
              _routePoint(
                'Destination',
                _to(),
                const Color(0xFFFF5E5E),
                isStart: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
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

  Widget _metricCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
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

  Widget _rowInfo(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value.isEmpty ? 'N/A' : value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _routePoint(
    String label,
    String addr,
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
                border: Border.all(
                  color: color.withValues(alpha: 0.25),
                  width: 4,
                ),
              ),
            ),
            if (isStart)
              Container(width: 2, height: 28, color: Colors.grey[200]),
          ],
        ),
        const SizedBox(width: 12),
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
                addr.isEmpty ? 'N/A' : addr,
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
}
