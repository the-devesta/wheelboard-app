import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/Transport/fleet_controller.dart';
import '../../models/get_vehicle_model.dart';
import '../../widgets/custom_loader.dart';
import 'Lease/create_lease_wizard.dart';

const _primary = Color(0xFFF36969);
const _primaryLight = Color(0xFFFFF1F1);
const _bg = Color(0xFFF9FAFB);
const _card = Colors.white;
const _textDark = Color(0xFF111827);
const _textGrey = Color(0xFF6B7280);
const _border = Color(0xFFE5E7EB);

class VehicleDetailScreen extends StatefulWidget {
  final Vehicle vehicle;
  const VehicleDetailScreen({super.key, required this.vehicle});

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  final DriverController _ctrl = Get.find<DriverController>();

  Map<String, dynamic>? _detail;
  bool _loading = true;
  int _imageIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await _ctrl.fetchVehicleDetails(widget.vehicle.vehicleId);
    setState(() {
      _detail = result;
      _loading = false;
    });
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Remove ${widget.vehicle.vehicleModel}?',
            style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
        content: const Text('This will permanently remove the vehicle from your fleet.',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel', style: TextStyle(color: _textGrey, fontFamily: 'Poppins')),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Remove', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final ok = await _ctrl.deleteVehicle(widget.vehicle.vehicleId);
      if (ok) Get.back();
    }
  }

  Future<void> _callDriver(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }

  // ── Data helpers ──────────────────────────────────────────────────────────
  Map<String, dynamic>? get _driver => _detail?['driverInfo'] as Map<String, dynamic>?;
  Map<String, dynamic>? get _metrics => _detail?['metrics'] as Map<String, dynamic>?;
  List get _recentTrips => (_detail?['recentTrips'] as List?) ?? [];
  int get _totalTrips => (_detail?['totalTrips'] as num?)?.toInt() ?? 0;

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'available': return const Color(0xFF22C55E);
      case 'in-transit': case 'in transit': return const Color(0xFF3B82F6);
      case 'assigned': return const Color(0xFFF59E0B);
      case 'maintenance': return const Color(0xFFEF4444);
      default: return _textGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.vehicle;

    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        slivers: [
          _buildSliverHeader(v),
          SliverToBoxAdapter(
            child: _loading
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CustomLoader()),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatusRow(v),
                        const SizedBox(height: 16),
                        _buildQuickStats(v),
                        const SizedBox(height: 16),
                        _buildInfoCard(v),
                        const SizedBox(height: 16),
                        if (_driver != null && (_driver!['driverName']?.toString().isNotEmpty == true)) ...[
                          _buildDriverCard(),
                          const SizedBox(height: 16),
                        ],
                        _buildMetricsCard(),
                        const SizedBox(height: 16),
                        if (_recentTrips.isNotEmpty) ...[
                          _buildRecentTrips(),
                          const SizedBox(height: 16),
                        ],
                        _buildActionsCard(v),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverHeader(Vehicle v) {
    final images = v.imageUrls;

    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: _card,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Get.back(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6)],
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _textDark),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6)],
          ),
          child: IconButton(
            icon: const Icon(Iconsax.refresh, size: 18, color: _textDark),
            onPressed: _load,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Image or placeholder
            if (images.isNotEmpty)
              Image.network(
                images[_imageIndex],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _imgPlaceholder(),
              )
            else
              _imgPlaceholder(),

            // Gradient overlay at bottom
            const Positioned(
              bottom: 0, left: 0, right: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0x99000000)],
                  ),
                ),
                child: SizedBox(height: 80),
              ),
            ),

            // Image dots
            if (images.length > 1)
              Positioned(
                bottom: 12,
                left: 0, right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(images.length, (i) => GestureDetector(
                    onTap: () => setState(() => _imageIndex = i),
                    child: Container(
                      width: i == _imageIndex ? 18 : 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: i == _imageIndex ? Colors.white : Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  )),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(Vehicle v) {
    final sc = _statusColor(v.status);
    return Row(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: sc.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: sc.withValues(alpha: 0.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 7, height: 7, decoration: BoxDecoration(color: sc, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(v.status.isEmpty ? 'Unknown' : v.status,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: sc, fontFamily: 'Poppins')),
        ]),
      ),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(v.ownershipType.isEmpty ? 'Owned' : v.ownershipType,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF3B82F6), fontFamily: 'Poppins')),
      ),
      if (v.vehicleType.isNotEmpty) ...[
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(v.vehicleType,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF8B5CF6), fontFamily: 'Poppins')),
        ),
      ],
    ]);
  }

  Widget _buildQuickStats(Vehicle v) {
    return Row(children: [
      _statCard('$_totalTrips', 'Total Trips', Iconsax.routing, _primary),
      const SizedBox(width: 10),
      _statCard(v.manufacturingYear > 0 ? '${v.manufacturingYear}' : '—', 'Year', Iconsax.calendar, const Color(0xFF3B82F6)),
      const SizedBox(width: 10),
      _statCard(v.vehicleType.isNotEmpty ? v.vehicleType : '—', 'Category', Iconsax.truck, const Color(0xFF8B5CF6)),
    ]);
  }

  Widget _statCard(String val, String label, IconData icon, Color color) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 5),
            Text(val,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color, fontFamily: 'Poppins'),
                maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
            Text(label, style: const TextStyle(fontSize: 10, color: _textGrey, fontFamily: 'Poppins'), textAlign: TextAlign.center),
          ]),
        ),
      );

  Widget _buildInfoCard(Vehicle v) {
    return _sectionCard('Vehicle Information', [
      _infoRow(Iconsax.truck, 'Model', v.vehicleModel),
      _infoRow(Iconsax.receipt_text, 'Registration', v.vehicleNumber),
      if (v.manufacturingYear > 0)
        _infoRow(Iconsax.calendar, 'Year', '${v.manufacturingYear}'),
      if (v.ownershipType.isNotEmpty)
        _infoRow(Iconsax.building, 'Ownership', v.ownershipType),
      if (v.vehicleType.isNotEmpty)
        _infoRow(Iconsax.category, 'Category', v.vehicleType),
      if (v.description.isNotEmpty)
        _infoRow(Iconsax.note_text, 'Description', v.description, multiline: true),
    ]);
  }

  Widget _buildDriverCard() {
    final d = _driver!;
    final name = d['driverName']?.toString() ?? '';
    final phone = d['driverMobile']?.toString() ?? '';
    final img = d['driverImage']?.toString();

    return _sectionCard('Assigned Driver', [
      Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(
            width: 54, height: 54,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _primaryLight, width: 2)),
            child: ClipOval(
              child: img != null && img.isNotEmpty
                  ? Image.network(img, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _driverInitials(name))
                  : _driverInitials(name),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textDark, fontFamily: 'Poppins')),
              if (phone.isNotEmpty)
                Text(phone, style: const TextStyle(fontSize: 12, color: _textGrey, fontFamily: 'Poppins')),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('On Duty', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF22C55E), fontFamily: 'Poppins')),
              ),
            ]),
          ),
          if (phone.isNotEmpty)
            GestureDetector(
              onTap: () => _callDriver(phone),
              child: Container(
                width: 42, height: 42,
                decoration: BoxDecoration(color: const Color(0xFF22C55E).withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Iconsax.call, size: 18, color: Color(0xFF22C55E)),
              ),
            ),
        ]),
      ),
    ]);
  }

  Widget _driverInitials(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'D';
    return Container(
      color: _primaryLight,
      alignment: Alignment.center,
      child: Text(initial, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _primary, fontFamily: 'Poppins')),
    );
  }

  Widget _buildMetricsCard() {
    final m = _metrics ?? const <String, dynamic>{};
    final tripEff = (m['tripEfficiency'] as num?)?.toDouble() ?? 0;
    final monthlyUsage = (m['monthlyUsage'] as num?)?.toDouble() ?? 0;

    // Odometer reading mirrors how wheelboard-fe shows it for the company user
    // (the "Mileage" field on the vehicle info card). Numeric values get a "km"
    // suffix; free-form strings are shown as-is; empty falls back to "N/A".
    final odoStr = _detail?['mileage']?.toString().trim() ?? '';
    final isNumericOdo = RegExp(r'^[0-9]+(\.[0-9]+)?$').hasMatch(odoStr);
    final odometerText = odoStr.isEmpty
        ? 'N/A'
        : (isNumericOdo ? '$odoStr km' : odoStr);

    return _sectionCard('Vehicle Metrics', [
      _metricRow('Odometer', odometerText, Iconsax.speedometer, const Color(0xFF22C55E)),
      // Trip Efficiency is a cost-per-distance figure (Rs/km), same as web fe —
      // it was previously mislabelled as a percentage.
      _metricRow('Trip Efficiency', tripEff > 0 ? '₹${tripEff.toStringAsFixed(1)}/km' : 'N/A', Iconsax.trend_up, _primary),
      _metricRow('Monthly Usage', '${monthlyUsage.toStringAsFixed(1)} km', Iconsax.chart_square, const Color(0xFF3B82F6)),
    ]);
  }

  Widget _metricRow(String label, String value, IconData icon, Color color) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: _textGrey, fontFamily: 'Poppins'))),
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color, fontFamily: 'Poppins')),
        ]),
      );

  Widget _buildRecentTrips() {
    return _sectionCard('Recent Trips', [
      ..._recentTrips.take(3).map((t) {
        final trip = t as Map<String, dynamic>;
        final code = trip['tripCode']?.toString() ?? trip['_id']?.toString() ?? '—';
        final from = trip['pickupCity']?.toString() ?? trip['from']?.toString() ?? '';
        final to = trip['dropCity']?.toString() ?? trip['to']?.toString() ?? '';
        final status = trip['status']?.toString() ?? '';
        final sc = _tripStatusColor(status);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: sc.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(Iconsax.routing, size: 18, color: sc),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(code,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _textDark, fontFamily: 'Poppins')),
                if (from.isNotEmpty || to.isNotEmpty)
                  Text('$from → $to',
                      style: const TextStyle(fontSize: 11, color: _textGrey, fontFamily: 'Poppins'),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
            if (status.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: sc.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(status,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: sc, fontFamily: 'Poppins')),
              ),
          ]),
        );
      }),
    ]);
  }

  Color _tripStatusColor(String s) {
    switch (s.toLowerCase()) {
      case 'completed': return const Color(0xFF22C55E);
      case 'in-transit': case 'in transit': return const Color(0xFF3B82F6);
      case 'assigned': return const Color(0xFFF59E0B);
      case 'cancelled': return const Color(0xFFEF4444);
      default: return _textGrey;
    }
  }

  Widget _buildActionsCard(Vehicle v) {
    return Column(children: [
      // List for lease
      if (v.status.toLowerCase() == 'available')
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Get.to(() => const CreateLeaseWizard()),
              icon: const Icon(Iconsax.receipt_text, size: 16),
              label: const Text('List for Lease', style: TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
            ),
          ),
        ),

      // Delete
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _confirmDelete,
          icon: const Icon(Iconsax.trash, size: 16, color: Color(0xFFEF4444)),
          label: const Text('Remove Vehicle', style: TextStyle(color: Color(0xFFEF4444), fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFEF4444)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    ]);
  }

  Widget _infoRow(IconData icon, String label, String value, {bool multiline = false}) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: _textGrey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label, style: const TextStyle(fontSize: 11, color: _textGrey, fontFamily: 'Poppins')),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textDark, fontFamily: 'Poppins'),
                    maxLines: multiline ? null : 1,
                    overflow: multiline ? null : TextOverflow.ellipsis),
              ]),
            ),
          ],
        ),
      );

  Widget _sectionCard(String title, List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Text(title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textDark, fontFamily: 'Poppins')),
            ),
            const Divider(color: _border, height: 1),
            ...children.expand((w) => [w, const Divider(color: _border, height: 1)]).toList()..removeLast(),
            const SizedBox(height: 4),
          ],
        ),
      );

  Widget _imgPlaceholder() => Container(
        color: const Color(0xFFF3F4F6),
        child: const Center(child: Icon(Iconsax.truck, size: 64, color: _textGrey)),
      );
}
