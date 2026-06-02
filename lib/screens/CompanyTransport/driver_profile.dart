import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/Transport/fleet_controller.dart';
import '../../widgets/custom_loader.dart';

const _primary = Color(0xFFF36969);
const _primaryLight = Color(0xFFFFF1F1);
const _bg = Color(0xFFF9FAFB);
const _card = Colors.white;
const _textDark = Color(0xFF111827);
const _textGrey = Color(0xFF6B7280);
const _border = Color(0xFFE5E7EB);

class DriverProfileScreen extends StatefulWidget {
  final String driverId;
  const DriverProfileScreen({super.key, required this.driverId});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  final DriverController _ctrl = Get.find<DriverController>();

  Map<String, dynamic>? _data;
  bool _loading = true;
  bool _editingPerf = false;

  // Editable performance sliders
  int _timelyDelivery = 0;
  int _tripEfficiency = 0;
  int _safety = 0;
  bool _savingPerf = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await _ctrl.fetchDriverDetail(widget.driverId);
    if (result != null) {
      final perf = result['performance'] as Map<String, dynamic>?;
      setState(() {
        _data = result;
        _timelyDelivery = (perf?['timelyDelivery'] as num?)?.toInt() ?? 0;
        _tripEfficiency = (perf?['tripEfficiency'] as num?)?.toInt() ?? 0;
        _safety = (perf?['safety'] as num?)?.toInt() ?? 0;
      });
    }
    setState(() => _loading = false);
  }

  Future<void> _savePerformance() async {
    setState(() => _savingPerf = true);
    final ok = await _ctrl.updateDriverPerformance(widget.driverId, {
      'performance': {
        'timelyDelivery': _timelyDelivery,
        'tripEfficiency': _tripEfficiency,
        'safety': _safety,
      },
    });
    setState(() { _savingPerf = false; _editingPerf = false; });
    if (ok) await _load();
  }

  Future<void> _call(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Remove $_name?',
            style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
        content: const Text('This will permanently remove the driver from your fleet.',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Get.back(result: false),
              child: const Text('Cancel', style: TextStyle(color: _textGrey, fontFamily: 'Poppins'))),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Remove', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final ok = await _ctrl.deleteDriver(widget.driverId);
      if (ok) Get.back();
    }
  }

  String get _name => (_data?['fullName'] ?? _data?['name'] ?? '').toString();
  String get _phone => (_data?['contactNumber'] ?? _data?['phoneNumber'] ?? '').toString();
  String get _license => (_data?['dlNo'] ?? _data?['licenseNumber'] ?? _data?['dlNumber'] ?? '').toString();
  String get _vehicleType => (_data?['vehicleType'] ?? _data?['vehicleCategoryExpertise'] ?? '').toString();
  String get _experience => (_data?['experience'] ?? '').toString();
  String get _description => (_data?['description'] ?? '').toString();
  String? get _imageUrl => (_data?['driverImagePath'] ?? _data?['image'])?.toString();
  double get _rating => (_data?['rating'] as num?)?.toDouble() ?? 0.0;
  int get _totalTrips => (_data?['totalTrips'] as num?)?.toInt() ?? 0;
  String get _status => (_data?['status'] ?? 'Available').toString();
  bool get _isVerified => _data?['isVerified'] == true || _data?['isKYCCompleted'] == true;
  Map<String, dynamic>? get _performance => _data?['performance'] as Map<String, dynamic>?;
  List get _reviews => (_data?['reviews'] as List?) ?? [];

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(child: CustomLoader()),
      );
    }

    if (_data == null) {
      return Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _card, elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: _textDark), onPressed: () => Get.back()),
        ),
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Iconsax.people, size: 48, color: _textGrey),
            const SizedBox(height: 12),
            const Text('Driver not found', style: TextStyle(fontSize: 16, color: _textDark, fontFamily: 'Poppins')),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _load,
                style: ElevatedButton.styleFrom(backgroundColor: _primary),
                child: const Text('Retry', style: TextStyle(color: Colors.white))),
          ]),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        slivers: [
          _buildSliverHeader(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuickStats(),
                  const SizedBox(height: 16),
                  _buildInfoCard(),
                  const SizedBox(height: 16),
                  _buildPerformanceCard(),
                  const SizedBox(height: 16),
                  if (_reviews.isNotEmpty) ...[
                    _buildReviewsCard(),
                    const SizedBox(height: 16),
                  ],
                  _buildActionsCard(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverHeader() {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: _card,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Get.back(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6)]),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _textDark),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6)]),
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
            // Gradient background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF36969), Color(0xFFf59e60)],
                ),
              ),
            ),
            // Avatar
            Positioned(
              bottom: 20,
              left: 0, right: 0,
              child: Column(
                children: [
                  Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 12)],
                    ),
                    child: ClipOval(
                      child: _imageUrl != null
                          ? Image.network(_imageUrl!, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _initials())
                          : _initials(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(_name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, fontFamily: 'Poppins')),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _statusPill(_status),
                      if (_isVerified) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Iconsax.verify, size: 12, color: Colors.white),
                            SizedBox(width: 4),
                            Text('Verified', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                          ]),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _initials() {
    final initials = _name.isNotEmpty ? _name[0].toUpperCase() : 'D';
    return Container(
      color: _primaryLight,
      alignment: Alignment.center,
      child: Text(initials, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: _primary, fontFamily: 'Poppins')),
    );
  }

  Widget _statusPill(String status) {
    Color bg;
    switch (status.toLowerCase()) {
      case 'available': bg = const Color(0xFF22C55E); break;
      case 'on trip': case 'hired': bg = const Color(0xFF3B82F6); break;
      default: bg = _textGrey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.4))),
      child: Text(status, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
    );
  }

  Widget _buildQuickStats() {
    return Row(children: [
      _statCard('${_totalTrips == 0 ? '—' : _totalTrips}', 'Total Trips', Iconsax.routing, _primary),
      const SizedBox(width: 10),
      _statCard(_rating > 0 ? _rating.toStringAsFixed(1) : '—', 'Rating', Iconsax.star1, const Color(0xFFF59E0B)),
      const SizedBox(width: 10),
      _statCard(_experience.isNotEmpty ? '${_experience}y' : '—', 'Experience', Iconsax.clock, const Color(0xFF3B82F6)),
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
            Text(val, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color, fontFamily: 'Poppins')),
            Text(label, style: const TextStyle(fontSize: 10, color: _textGrey, fontFamily: 'Poppins'), textAlign: TextAlign.center),
          ]),
        ),
      );

  Widget _buildInfoCard() {
    return _sectionCard('Driver Information', [
      if (_phone.isNotEmpty) _infoRow(Iconsax.call, 'Phone', _phone,
          trailing: GestureDetector(
            onTap: () => _call(_phone),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: const Color(0xFF22C55E).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: const Text('Call', style: TextStyle(fontSize: 11, color: Color(0xFF22C55E), fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
            ),
          )),
      if (_license.isNotEmpty) _infoRow(Iconsax.card, 'License No.', _license),
      if (_vehicleType.isNotEmpty) _infoRow(Iconsax.truck, 'Vehicle Type', _vehicleType),
      if (_description.isNotEmpty) _infoRow(Iconsax.note_text, 'Description', _description, multiline: true),
    ]);
  }

  Widget _buildPerformanceCard() {
    if (_editingPerf) return _buildPerformanceEditor();

    final td = _performance?['timelyDelivery'] as num?;
    final te = _performance?['tripEfficiency'] as num?;
    final sf = _performance?['safety'] as num?;

    return _sectionCard(
      'Performance',
      [
        _perfRow('Timely Delivery', td?.toInt() ?? 0, const Color(0xFF22C55E)),
        _perfRow('Trip Efficiency', te?.toInt() ?? 0, _primary),
        _perfRow('Safety Score', sf?.toInt() ?? 0, const Color(0xFF3B82F6)),
      ],
      action: TextButton.icon(
        onPressed: () => setState(() => _editingPerf = true),
        icon: const Icon(Iconsax.edit, size: 14, color: _primary),
        label: const Text('Edit', style: TextStyle(fontSize: 12, color: _primary, fontFamily: 'Poppins')),
        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
      ),
    );
  }

  Widget _buildPerformanceEditor() {
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
            child: Row(children: [
              const Text('Edit Performance',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textDark, fontFamily: 'Poppins')),
              const Spacer(),
              TextButton(
                onPressed: () => setState(() => _editingPerf = false),
                child: const Text('Cancel', style: TextStyle(color: _textGrey, fontFamily: 'Poppins')),
              ),
            ]),
          ),
          const Divider(color: _border, height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              _sliderRow('Timely Delivery', _timelyDelivery, const Color(0xFF22C55E),
                  (v) => setState(() => _timelyDelivery = v.toInt())),
              const SizedBox(height: 16),
              _sliderRow('Trip Efficiency', _tripEfficiency, _primary,
                  (v) => setState(() => _tripEfficiency = v.toInt())),
              const SizedBox(height: 16),
              _sliderRow('Safety Score', _safety, const Color(0xFF3B82F6),
                  (v) => setState(() => _safety = v.toInt())),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _savingPerf ? null : _savePerformance,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    disabledBackgroundColor: _primary.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _savingPerf
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Save Performance', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Poppins')),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _sliderRow(String label, int value, Color color, ValueChanged<double> onChanged) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textDark, fontFamily: 'Poppins')),
            const Spacer(),
            Text('$value%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color, fontFamily: 'Poppins')),
          ]),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              inactiveTrackColor: color.withValues(alpha: 0.15),
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.12),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(value: value.toDouble(), min: 0, max: 100, divisions: 100, onChanged: onChanged),
          ),
        ],
      );

  Widget _buildReviewsCard() {
    return _sectionCard('Recent Reviews', [
      ..._reviews.take(3).map((r) {
        final map = r as Map<String, dynamic>;
        final rating = (map['rating'] as num?)?.toDouble() ?? 0;
        final comment = map['comment']?.toString() ?? '';
        final reviewer = map['reviewerName']?.toString() ?? 'Anonymous';
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 32, height: 32,
                  decoration: const BoxDecoration(color: _primaryLight, shape: BoxShape.circle),
                  child: Center(child: Text(reviewer.isNotEmpty ? reviewer[0].toUpperCase() : 'A',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _primary, fontFamily: 'Poppins'))),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(reviewer,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textDark, fontFamily: 'Poppins'))),
                Row(children: [
                  const Icon(Iconsax.star1, size: 12, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 3),
                  Text(rating.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _textDark, fontFamily: 'Poppins')),
                ]),
              ]),
              if (comment.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(comment,
                    style: const TextStyle(fontSize: 12, color: _textGrey, fontFamily: 'Poppins', height: 1.4)),
              ],
            ],
          ),
        );
      }),
    ]);
  }

  Widget _buildActionsCard() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _confirmDelete,
            icon: const Icon(Iconsax.trash, size: 16, color: Color(0xFFEF4444)),
            label: const Text('Remove Driver', style: TextStyle(color: Color(0xFFEF4444), fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFEF4444)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _perfRow(String label, int value, Color color) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: const TextStyle(fontSize: 12, color: _textGrey, fontFamily: 'Poppins')),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: value / 100,
                  minHeight: 6,
                  backgroundColor: color.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ]),
          ),
          const SizedBox(width: 12),
          Text('$value%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color, fontFamily: 'Poppins')),
        ]),
      );

  Widget _infoRow(IconData icon, String label, String value, {Widget? trailing, bool multiline = false}) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: _textGrey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 11, color: _textGrey, fontFamily: 'Poppins')),
                  const SizedBox(height: 2),
                  Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textDark, fontFamily: 'Poppins'),
                      maxLines: multiline ? null : 1, overflow: multiline ? null : TextOverflow.ellipsis),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      );

  Widget _sectionCard(String title, List<Widget> children, {Widget? action}) => Container(
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
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              child: Row(children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textDark, fontFamily: 'Poppins')),
                if (action != null) ...[const Spacer(), action],
              ]),
            ),
            const Divider(color: _border, height: 1),
            ...children.expand((w) => [w, const Divider(color: _border, height: 1)]).toList()..removeLast(),
            const SizedBox(height: 4),
          ],
        ),
      );
}
